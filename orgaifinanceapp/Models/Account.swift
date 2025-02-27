import SwiftUI
import SwiftData

@Model
final class Account {
    var id: UUID
    var name: String
    var balance: Decimal
    var type: AccountType
    var category: AccountCategory?
    var icon: String
    var createdAt: Date
    var updatedAt: Date
    var creditLimit: Decimal = 0 // Added for credit cards
    
    init(
        id: UUID = UUID(),
        name: String,
        balance: Decimal,
        type: AccountType,
        category: AccountCategory = .checking,
        icon: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        creditLimit: Decimal = 0
    ) {
        self.id = id
        self.name = name
        self.balance = balance
        self.type = type
        self.category = category
        self.icon = icon ?? category.defaultIcon
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.creditLimit = creditLimit
    }
    
    enum AccountType: String, Codable, CaseIterable {
        case personal = "Personal"
        case business = "Business"
        case cash = "Cash"
        
        var color: Color {
            switch self {
            case .personal:
                return DesignSystem.Colors.success
            case .business:
                return DesignSystem.Colors.info
            case .cash:
                return DesignSystem.Colors.primary
            }
        }
        
        var icon: String {
            switch self {
            case .personal:
                return "person.circle.fill"
            case .business:
                return "building.2.fill"
            case .cash:
                return "banknote.fill"
            }
        }
    }
    
    enum AccountCategory: String, Codable, CaseIterable {
        // Banking categories
        case checking = "Checking"
        case savings = "Savings"
        case creditCard = "Credit Card"
        
        // Asset categories
        case cashInHand = "Cash in Hand"
        case realEstate = "Real Estate"
        case vehicle = "Vehicle"
        case otherAssets = "Other Assets"
        
        // Liability categories
        case mortgage = "Mortgage"
        case autoLoan = "Auto Loan"
        case lendingLoan = "Lending Loan"
        case otherLoans = "Other Loans"
        
        var defaultIcon: String {
            switch self {
            // Banking icons
            case .checking:
                return "creditcard"
            case .savings:
                return "building.columns"
            case .creditCard:
                return "creditcard.and.123"
                
            // Asset icons
            case .cashInHand:
                return "banknote"
            case .realEstate:
                return "building.2"
            case .vehicle:
                return "car"
            case .otherAssets:
                return "archivebox"
                
            // Liability icons
            case .mortgage:
                return "house"
            case .autoLoan:
                return "car"
            case .lendingLoan:
                return "hand.wave"
            case .otherLoans:
                return "doc.text"
            }
        }
        
        var displayName: String {
            switch self {
            // Banking display names
            case .checking:
                return "Checking Accounts"
            case .savings:
                return "Savings Accounts"
            case .creditCard:
                return "Credit Cards"
                
            // Asset display names
            case .cashInHand:
                return "Cash Accounts"
            case .realEstate:
                return "Real Estate"
            case .vehicle:
                return "Vehicles"
            case .otherAssets:
                return "Other Assets"
                
            // Liability display names
            case .mortgage:
                return "Mortgages"
            case .autoLoan:
                return "Auto Loans"
            case .lendingLoan:
                return "Lending Loans"
            case .otherLoans:
                return "Other Loans"
            }
        }
        
        var color: Color {
            switch self {
            // Banking colors
            case .checking:
                return DesignSystem.Colors.success
            case .savings:
                return DesignSystem.Colors.info
            case .creditCard:
                return DesignSystem.Colors.error
                
            // Asset colors
            case .cashInHand:
                return DesignSystem.Colors.success
            case .realEstate:
                return DesignSystem.Colors.primary
            case .vehicle:
                return DesignSystem.Colors.info
            case .otherAssets:
                return DesignSystem.Colors.secondary
                
            // Liability colors
            case .mortgage:
                return DesignSystem.Colors.error
            case .autoLoan:
                return DesignSystem.Colors.warning
            case .lendingLoan:
                return DesignSystem.Colors.info
            case .otherLoans:
                return DesignSystem.Colors.secondary
            }
        }
        
        var isLiability: Bool {
            switch self {
            case .creditCard, .mortgage, .autoLoan, .lendingLoan, .otherLoans:
                return true
            case .checking, .savings, .cashInHand, .realEstate, .vehicle, .otherAssets:
                return false
            }
        }
    }
    
    var effectiveCategory: AccountCategory {
        category ?? .checking
    }
    
    var formattedBalance: String {
        let amount = effectiveCategory.isLiability ? -balance : balance
        return FinancialCalculations.Formatting.formatCurrency(amount)
    }
    
    var formattedCreditLimit: String {
        return FinancialCalculations.Formatting.formatCurrency(creditLimit)
    }
    
    var availableCredit: Decimal {
        guard effectiveCategory == .creditCard else { return 0 }
        return creditLimit - abs(balance)
    }
    
    var formattedAvailableCredit: String {
        return FinancialCalculations.Formatting.formatCurrency(availableCredit)
    }
    
    static var preview: Account {
        Account(
            name: "Checking Account",
            balance: 2450.00,
            type: .personal,
            category: .checking
        )
    }
    
    static func isNameUnique(_ name: String, type: AccountType, in accounts: [Account], excluding: Account? = nil) -> Bool {
        accounts
            .filter { $0.type == type && $0.id != excluding?.id }
            .allSatisfy { $0.name.lowercased() != name.lowercased() }
    }
    
    // Add helper method for cash account validation
    static func hasExistingCashAccount(in accounts: [Account]) -> Bool {
        accounts.contains { $0.type == .cash }
    }
} 