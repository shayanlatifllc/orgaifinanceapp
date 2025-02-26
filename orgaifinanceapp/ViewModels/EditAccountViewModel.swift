import SwiftUI
import SwiftData

@MainActor
final class EditAccountViewModel: ObservableObject {
    private let modelContext: ModelContext
    private let account: Account
    
    @Published var accountName: String
    @Published var accountType: Account.AccountType
    @Published var accountCategory: Account.AccountCategory
    @Published var balance: String
    @Published var error: AppError?
    
    init(modelContext: ModelContext, account: Account) {
        self.modelContext = modelContext
        self.account = account
        self.accountName = account.name
        self.accountType = account.type
        self.accountCategory = account.effectiveCategory
        self.balance = FinancialCalculations.Formatting.formatCurrency(account.balance)
            .replacingOccurrences(of: "$", with: "")
    }
    
    var canSaveChanges: Bool {
        !accountName.isEmpty && !balance.isEmpty && hasChanges
    }
    
    private var hasChanges: Bool {
        accountName != account.name ||
        accountType != account.type ||
        accountCategory != account.effectiveCategory ||
        Decimal(string: balance.replacingOccurrences(of: "[$,]", with: "", options: .regularExpression)) != account.balance
    }
    
    func saveChanges() async throws {
        // Validate input first
        guard validateInput() else {
            throw error ?? AppError.invalidOperation
        }
        
        // Convert and validate balance
        guard let newBalance = Decimal(string: balance.replacingOccurrences(of: "[$,]", with: "", options: .regularExpression)) else {
            throw AppError.invalidAmount
        }
        
        // Validate balance is positive
        guard newBalance >= 0 else {
            throw AppError.invalidAmount
        }
        
        // Update account properties
        account.name = accountName
        account.type = accountType
        account.category = accountCategory
        account.balance = newBalance
        account.updatedAt = Date()
        
        // Save to SwiftData
        try modelContext.save()
        
        // Simulate network delay
        try await Task.sleep(for: .seconds(1))
    }
    
    func validateInput() -> Bool {
        guard !accountName.isEmpty else {
            error = AppError.missingRequiredField("Account Name")
            return false
        }
        
        guard !balance.isEmpty else {
            error = AppError.missingRequiredField("Balance")
            return false
        }
        
        guard Decimal(string: balance.replacingOccurrences(of: "[$,]", with: "", options: .regularExpression)) != nil else {
            error = AppError.invalidAmount
            return false
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
        
        return formatter.string(from: NSNumber(value: number / 100))?.replacingOccurrences(of: "$", with: "") ?? input
    }
} 