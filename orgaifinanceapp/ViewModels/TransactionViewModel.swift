import SwiftUI
import SwiftData

@MainActor
class TransactionViewModel: ObservableObject {
    // MARK: - Properties
    private let modelContext: ModelContext
    @Published private var transactions: [Transaction] = []
    @Published var currentFilter: String = "All"
    
    var filteredTransactions: [Transaction] {
        switch currentFilter {
        case "All":
            return transactions
        case "Income":
            return transactions.filter { $0.type == .income }
        case "Expense":
            return transactions.filter { $0.type == .expense }
        default:
            return transactions
        }
    }
    
    var portfolioValue: Decimal {
        FinancialCalculations.Portfolio.calculatePortfolioValue(transactions)
    }
    
    var todayChange: Decimal {
        FinancialCalculations.Trends.calculateDailyChange(transactions)
    }
    
    var formattedPortfolioValue: String {
        FinancialCalculations.Formatting.formatCurrency(portfolioValue)
    }
    
    var formattedTodayChange: String {
        FinancialCalculations.Formatting.formatCurrency(todayChange)
    }
    
    var totalAssets: Decimal {
        FinancialCalculations.Portfolio.calculateTransactionAssets(transactions)
    }
    
    var totalLiabilities: Decimal {
        FinancialCalculations.Portfolio.calculateTransactionLiabilities(transactions)
    }
    
    var netWorth: Decimal {
        FinancialCalculations.Portfolio.calculateTransactionNetWorth(transactions)
    }
    
    // MARK: - Initialization
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadTransactions()
    }
    
    // MARK: - Public Methods
    func addTransaction(
        title: String,
        subtitle: String,
        amount: Decimal,
        type: Transaction.TransactionType,
        icon: String
    ) {
        let transaction = Transaction(
            title: title,
            subtitle: subtitle,
            amount: amount,
            type: type,
            icon: icon
        )
        
        modelContext.insert(transaction)
        saveContext()
        loadTransactions()
    }
    
    func deleteTransaction(_ transaction: Transaction) {
        modelContext.delete(transaction)
        saveContext()
        loadTransactions()
    }
    
    func updateFilter(_ filter: String) {
        currentFilter = filter
    }
    
    // MARK: - Private Methods
    private func loadTransactions() {
        let descriptor = FetchDescriptor<Transaction>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        do {
            transactions = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch transactions: \(error)")
            transactions = []
        }
    }
    
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    // MARK: - Quick Actions
    func handleQuickAction(_ action: DashboardView.QuickAction) {
        switch action {
        case .buy:
            addTransaction(
                title: "Purchase",
                subtitle: "Quick Action",
                amount: 0,
                type: .expense,
                icon: DesignSystem.Icons.expense
            )
        case .sell:
            addTransaction(
                title: "Sale",
                subtitle: "Quick Action",
                amount: 0,
                type: .income,
                icon: DesignSystem.Icons.income
            )
        case .transfer:
            addTransaction(
                title: "Transfer",
                subtitle: "Quick Action",
                amount: 0,
                type: .transfer,
                icon: DesignSystem.Icons.transfer
            )
        }
    }
}

// MARK: - Preview Helper
extension TransactionViewModel {
    @MainActor
    static var preview: TransactionViewModel {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Transaction.self, configurations: config)
        let context = container.mainContext
        
        // Add some sample data
        let viewModel = TransactionViewModel(modelContext: context)
        viewModel.addTransaction(
            title: "Salary",
            subtitle: "Monthly Income",
            amount: 5000,
            type: .income,
            icon: "dollarsign.circle.fill"
        )
        viewModel.addTransaction(
            title: "Shopping",
            subtitle: "Grocery Store",
            amount: 150.50,
            type: .expense,
            icon: "cart.fill"
        )
        viewModel.addTransaction(
            title: "Transfer",
            subtitle: "To Savings",
            amount: 1000,
            type: .transfer,
            icon: DesignSystem.Icons.transfer
        )
        
        return viewModel
    }
} 