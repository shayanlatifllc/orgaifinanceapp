import SwiftUI
import SwiftData

@Model
final class Transaction {
    var id: UUID
    var title: String
    var subtitle: String
    var amount: Decimal
    var type: TransactionType
    var icon: String
    var date: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        amount: Decimal,
        type: TransactionType,
        icon: String,
        date: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.amount = amount
        self.type = type
        self.icon = icon
        self.date = date
    }
}

extension Transaction {
    enum TransactionType: String, Codable {
        case income
        case expense
        case transfer
        
        var color: Color {
            switch self {
            case .income:
                return DesignSystem.Colors.success
            case .expense:
                return DesignSystem.Colors.error
            case .transfer:
                return DesignSystem.Colors.info
            }
        }
        
        var icon: String {
            switch self {
            case .income:
                return DesignSystem.Icons.income
            case .expense:
                return DesignSystem.Icons.expense
            case .transfer:
                return DesignSystem.Icons.transfer
            }
        }
    }
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        
        let number = NSDecimalNumber(decimal: amount)
        return formatter.string(from: number) ?? "$0.00"
    }
    
    var isExpense: Bool {
        type == .expense
    }
    
    static var preview: Transaction {
        Transaction(
            title: "Shopping",
            subtitle: "Grocery Store",
            amount: 24.99,
            type: .expense,
            icon: "cart.fill"
        )
    }
} 