import SwiftUI
import SwiftData

@MainActor
final class AddAccountViewModel: ObservableObject {
    private let modelContext: ModelContext
    @Published var accountName = ""
    @Published var accountType = Account.AccountType.personal
    @Published var accountCategory = Account.AccountCategory.checking
    @Published var initialBalance = ""
    @Published var error: AppError?
    @Published var showingCashExistsAlert = false
    
    // Store the selected primary use
    @Published var selectedPrimaryUse: String?
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // Validate the account name to prevent any potential NaN issues
    func validateAccountName() {
        // Only trim leading and trailing whitespace, preserve spaces within the name
        accountName = accountName.trimmingCharacters(in: .whitespaces)
        
        // Limit the length to prevent potential overflow issues
        if accountName.count > 50 {
            accountName = String(accountName.prefix(50))
        }
        
        // Remove any characters that might cause layout or rendering issues
        accountName = accountName.replacingOccurrences(of: "\0", with: "")
    }
    
    var canCreateAccount: Bool {
        // If account details should be shown, require name and balance
        if accountRequiresDetails {
            return !accountName.isEmpty && !initialBalance.isEmpty
        }
        
        // Otherwise just need the proper selections
        return selectedPrimaryUse != nil
    }
    
    var accountRequiresDetails: Bool {
        // Banking and asset accounts require details
        let isDetailRequired = accountCategory == .checking || 
                               accountCategory == .savings || 
                               accountCategory == .creditCard ||
                               accountCategory == .cashInHand ||
                               accountCategory == .realEstate ||
                               accountCategory == .vehicle ||
                               accountCategory == .otherAssets
                               
        return isDetailRequired
    }
    
    func createAccount() async throws {
        // Validate input first
        guard validateInput() else {
            throw error ?? AppError.invalidOperation
        }
        
        // Apply the validation to the account name just before creating the account
        validateAccountName()
        
        // Check for existing cash account
        if accountCategory == .cashInHand {
            let descriptor = FetchDescriptor<Account>()
            let existingAccounts = try modelContext.fetch(descriptor)
            
            guard !Account.hasExistingCashAccount(in: existingAccounts) else {
                showingCashExistsAlert = true
                throw AppError.duplicateTransaction
            }
        }
        
        // Set account type based on selected primary use
        let finalAccountType: Account.AccountType
        if selectedPrimaryUse == "Personal" {
            finalAccountType = .personal
        } else if selectedPrimaryUse == "Business" {
            finalAccountType = .business
        } else {
            finalAccountType = accountType
        }
        
        // Convert and validate balance
        var balance: Decimal = 0
        if !initialBalance.isEmpty {
            guard let parsedBalance = Decimal(string: initialBalance.replacingOccurrences(of: "[$,]", with: "", options: .regularExpression)) else {
                throw AppError.invalidAmount
            }
            
            // Validate balance is positive
            guard parsedBalance >= 0 else {
                throw AppError.invalidAmount
            }
            
            balance = parsedBalance
        }
        
        // Create new account
        let account = Account(
            name: accountName.isEmpty ? "\(accountCategory.rawValue) Account" : accountName,
            balance: balance,
            type: finalAccountType,
            category: accountCategory
        )
        
        // Save to SwiftData
        modelContext.insert(account)
        try modelContext.save()
        
        // Simulate network delay
        try await Task.sleep(for: .seconds(1))
    }
    
    func validateInput() -> Bool {
        // For asset categories, we need name and balance
        if accountCategory == .cashInHand || 
           accountCategory == .realEstate || 
           accountCategory == .vehicle || 
           accountCategory == .otherAssets {
            
            guard !accountName.isEmpty else {
                error = AppError.missingRequiredField("Account Name")
                return false
            }
            
            guard !initialBalance.isEmpty else {
                error = AppError.missingRequiredField("Initial Balance")
                return false
            }
            
            guard Decimal(string: initialBalance.replacingOccurrences(of: "[$,]", with: "", options: .regularExpression)) != nil else {
                error = AppError.invalidAmount
                return false
            }
            
            return true
        }
        
        // For banking accounts
        if accountCategory == .checking || 
           accountCategory == .savings || 
           accountCategory == .creditCard {
            
            guard !accountName.isEmpty else {
                error = AppError.missingRequiredField("Account Name")
                return false
            }
            
            guard !initialBalance.isEmpty else {
                error = AppError.missingRequiredField("Initial Balance")
                return false
            }
            
            guard Decimal(string: initialBalance.replacingOccurrences(of: "[$,]", with: "", options: .regularExpression)) != nil else {
                error = AppError.invalidAmount
                return false
            }
            
            return true
        }
        
        // For other categories, we only validate what's provided
        if !initialBalance.isEmpty {
            guard Decimal(string: initialBalance.replacingOccurrences(of: "[$,]", with: "", options: .regularExpression)) != nil else {
                error = AppError.invalidAmount
                return false
            }
        }
        
        return true
    }
    
    func formatBalance(_ input: String) -> String {
        // Remove any existing currency symbols and decimals
        let cleaned = input.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        // Convert to decimal
        guard let number = Double(cleaned) else { return input }
        
        // Format as currency
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        
        return formatter.string(from: NSNumber(value: number / 100)) ?? input
    }
} 