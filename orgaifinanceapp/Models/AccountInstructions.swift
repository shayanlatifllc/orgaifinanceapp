import SwiftUI

struct AccountInstructions {
    static func getCategoryInstruction(_ category: Account.AccountCategory, type: Account.AccountType) -> String {
        switch category {
        case .checking:
            switch type {
            case .personal:
                return "Track your daily expenses and income with a personal checking account."
            case .business:
                return "Manage your business's day-to-day transactions and cash flow."
            case .cash:
                return "Track your physical cash transactions and daily spending."
            }
        case .savings:
            switch type {
            case .personal:
                return "Set aside money for future goals and earn interest on your savings."
            case .business:
                return "Build your business's emergency fund or save for future investments."
            case .cash:
                return "Set aside physical cash for specific purposes or emergency funds."
            }
        case .creditCard:
            switch type {
            case .personal:
                return "Monitor your credit card spending and track your monthly payments."
            case .business:
                return "Keep track of business expenses and manage company credit cards."
            case .cash:
                return "Track cash advances and ATM withdrawals from credit cards."
            }
        case .cashInHand:
            switch type {
            case .personal:
                return "Keep track of your personal physical cash and daily cash transactions."
            case .business:
                return "Manage your business's physical cash and petty cash transactions."
            case .cash:
                return "Track all your physical cash in one dedicated cash account."
            }
        // Asset categories
        case .realEstate:
            switch type {
            case .personal:
                return "Track the value of your personal real estate properties and related expenses."
            case .business:
                return "Manage your business's real estate assets and property investments."
            case .cash:
                return "Monitor cash investments in real estate properties."
            }
        case .vehicle:
            switch type {
            case .personal:
                return "Keep track of your vehicles' value, loans, and maintenance expenses."
            case .business:
                return "Manage your company vehicles, fleet costs, and depreciation."
            case .cash:
                return "Track cash spent on vehicle purchases and maintenance."
            }
        case .otherAssets:
            switch type {
            case .personal:
                return "Track other valuable personal assets like collectibles, jewelry, or equipment."
            case .business:
                return "Manage miscellaneous business assets, equipment, and inventory."
            case .cash:
                return "Monitor cash investments in various assets."
            }
        // Liability categories
        case .mortgage:
            switch type {
            case .personal:
                return "Track your mortgage payments, balance, and interest for personal properties."
            case .business:
                return "Manage your business property mortgages and related expenses."
            case .cash:
                return "Monitor cash payments toward mortgage balances."
            }
        case .autoLoan:
            switch type {
            case .personal:
                return "Keep track of your auto loan payments, interest, and remaining balance."
            case .business:
                return "Manage business vehicle loans and payment schedules."
            case .cash:
                return "Track cash payments toward auto loan balances."
            }
        case .lendingLoan:
            switch type {
            case .personal:
                return "Track loans you've given to others and manage repayment schedules."
            case .business:
                return "Manage business loans extended to clients, partners, or employees."
            case .cash:
                return "Monitor cash lent to others and incoming repayments."
            }
        case .otherLoans:
            switch type {
            case .personal:
                return "Keep track of other personal loans, credit lines, or financing agreements."
            case .business:
                return "Manage miscellaneous business loans, lines of credit, or financing."
            case .cash:
                return "Track cash payments toward miscellaneous loan balances."
            }
        }
    }
    
    static func getTypeInstruction(_ type: Account.AccountType) -> String {
        switch type {
        case .personal:
            return "Personal accounts help you track your individual finances and daily transactions."
        case .business:
            return "Business accounts keep your company's finances organized and separate from personal accounts."
        case .cash:
            return "Cash accounts help you track physical money and cash transactions separately."
        }
    }
    
    static var defaultInstruction: String {
        "Select an account type and category to get started with your new account."
    }
} 