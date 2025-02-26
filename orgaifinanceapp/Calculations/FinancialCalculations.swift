import Foundation

struct FinancialCalculations {
    // MARK: - Portfolio Calculations
    struct Portfolio {
        static func calculateTotalAssets(_ accounts: [Account]) -> Decimal {
            // Assets are positive balances in non-liability accounts
            accounts
                .filter { 
                    $0.balance > 0 && 
                    !$0.effectiveCategory.isLiability 
                }
                .reduce(Decimal(0)) { $0 + $1.balance }
        }
        
        static func calculateTotalLiabilities(_ accounts: [Account]) -> Decimal {
            // Liabilities calculation has multiple components:
            
            // 1. Negative balances in liability accounts (as positive amounts)
            let negativeLiabilities = accounts.filter { 
                $0.balance < 0 && 
                $0.effectiveCategory.isLiability 
            }.reduce(Decimal(0)) { $0 + abs($1.balance) }
            
            // 2. Positive balances in liability accounts (reducing total liabilities)
            let positiveLiabilities = accounts.filter { 
                $0.balance > 0 && 
                $0.effectiveCategory.isLiability 
            }.reduce(Decimal(0)) { $0 + $1.balance }
            
            // 3. Negative balances in non-liability accounts (as positive amounts)
            let negativeAssets = accounts.filter { 
                $0.balance < 0 && 
                !$0.effectiveCategory.isLiability 
            }.reduce(Decimal(0)) { $0 + abs($1.balance) }
            
            // Total liabilities = negative liabilities + negative assets - positive liabilities
            return negativeLiabilities + negativeAssets - positiveLiabilities
        }
        
        static func calculateNetWorth(_ accounts: [Account]) -> Decimal {
            // New approach: separate all positive and negative balances across all accounts
            
            // 1. Sum all positive balances across all accounts
            let positiveSum = accounts.filter { $0.balance > 0 }
                .reduce(Decimal(0)) { $0 + $1.balance }
            
            // 2. Sum all negative balances (converted to positive) across all accounts
            let negativeSum = accounts.filter { $0.balance < 0 }
                .reduce(Decimal(0)) { $0 + abs($1.balance) }
            
            // 3. Net Worth = (sum of all positive values) - (sum of converted negative values)
            return positiveSum - negativeSum
        }
        
        static func calculatePersonalAccountsTotal(_ accounts: [Account]) -> Decimal {
            let personalAccounts = accounts.filter { $0.type == .personal }
            
            // Banking assets (checking, savings)
            let bankingTotal = personalAccounts
                .filter { $0.effectiveCategory == .checking || $0.effectiveCategory == .savings }
                .reduce(Decimal(0)) { $0 + $1.balance }
            
            // Credit cards - only count positive balances as assets
            let creditCardTotal = personalAccounts
                .filter { $0.effectiveCategory == .creditCard }
                .reduce(Decimal(0)) { $0 + ($1.balance > 0 ? $1.balance : 0) }
                
            return bankingTotal + creditCardTotal
        }
        
        static func calculateBusinessAccountsTotal(_ accounts: [Account]) -> Decimal {
            let businessAccounts = accounts.filter { $0.type == .business }
            
            // Banking assets (checking, savings)
            let bankingTotal = businessAccounts
                .filter { $0.effectiveCategory == .checking || $0.effectiveCategory == .savings }
                .reduce(Decimal(0)) { $0 + $1.balance }
            
            // Credit cards - only count positive balances as assets
            let creditCardTotal = businessAccounts
                .filter { $0.effectiveCategory == .creditCard }
                .reduce(Decimal(0)) { $0 + ($1.balance > 0 ? $1.balance : 0) }
                
            return bankingTotal + creditCardTotal
        }
        
        static func calculateTotalBalance(_ accounts: [Account]) -> Decimal {
            calculateNetWorth(accounts)
        }
        
        static func calculateAccountTrend(_ accounts: [Account], timeframe: TimeFrame = .daily) -> (amount: Decimal, percentage: String, isPositive: Bool) {
            // TODO: Implement actual trend calculation based on transaction history
            let total = calculateTotalBalance(accounts)
            let previousTotal = total * Decimal(0.95) // Simulate 5% change
            let trend = Trends.calculateTrend(total, previousTotal)
            return (total - previousTotal, trend.percentage, trend.isPositive)
        }
        
        static func calculatePortfolioValue(_ transactions: [Transaction]) -> Decimal {
            transactions.reduce(Decimal(0)) { total, transaction in
                switch transaction.type {
                case .income:
                    return total + transaction.amount
                case .expense:
                    return total - transaction.amount
                case .transfer:
                    return total
                }
            }
        }
        
        static func calculateTransactionAssets(_ transactions: [Transaction]) -> Decimal {
            transactions
                .filter { $0.type == .income }
                .reduce(Decimal(0)) { $0 + $1.amount }
        }
        
        static func calculateTransactionLiabilities(_ transactions: [Transaction]) -> Decimal {
            transactions
                .filter { $0.type == .expense }
                .reduce(Decimal(0)) { $0 + $1.amount }
        }
        
        static func calculateTransactionNetWorth(_ transactions: [Transaction]) -> Decimal {
            calculateTransactionAssets(transactions) - calculateTransactionLiabilities(transactions)
        }
    }
    
    // MARK: - Time Frame
    enum TimeFrame {
        case daily
        case weekly
        case monthly
        case yearly
    }
    
    // MARK: - Trend Calculations
    struct Trends {
        static func calculateDailyChange(_ transactions: [Transaction]) -> Decimal {
            let today = Calendar.current.startOfDay(for: Date())
            return transactions
                .filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
                .reduce(Decimal(0)) { total, transaction in
                    switch transaction.type {
                    case .income:
                        return total + transaction.amount
                    case .expense:
                        return total - transaction.amount
                    case .transfer:
                        return total
                    }
                }
        }
        
        static func calculateTrend(_ current: Decimal, _ previous: Decimal) -> (percentage: String, isPositive: Bool) {
            guard previous != 0 else { return ("+0.0%", true) }
            let change = ((current - previous) / previous) * 100
            let isPositive = change >= 0
            return (String(format: "%+.1f%%", Double(truncating: change as NSNumber)), isPositive)
        }
    }
    
    // MARK: - Formatting
    struct Formatting {
        static func formatCurrency(_ amount: Decimal) -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencySymbol = "$"
            
            let number = NSDecimalNumber(decimal: amount)
            return formatter.string(from: number) ?? "$0.00"
        }
        
        static func formatCompactCurrency(_ amount: Decimal) -> String {
            let absAmount = abs(amount)
            let sign = amount < 0 ? "-" : ""
            
            switch absAmount {
            case 0..<1000:
                return formatCurrency(amount)
            case 1000..<1_000_000:
                let value = absAmount / 1000
                return "\(sign)$\(formatDecimal(value))k"
            case 1_000_000..<1_000_000_000:
                let value = absAmount / 1_000_000
                return "\(sign)$\(formatDecimal(value))M"
            default:
                let value = absAmount / 1_000_000_000
                return "\(sign)$\(formatDecimal(value))B"
            }
        }
        
        private static func formatDecimal(_ value: Decimal) -> String {
            if value < 10 {
                // For values less than 10, show one decimal place
                return String(format: "%.1f", NSDecimalNumber(decimal: value).doubleValue)
            } else {
                // For values 10 or greater, show no decimal places
                return String(format: "%.0f", NSDecimalNumber(decimal: value).doubleValue)
            }
        }
        
        static func formatCompactTrend(_ value: Decimal) -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 1
            formatter.minimumFractionDigits = 1
            
            let number = NSDecimalNumber(decimal: value)
            let formatted = formatter.string(from: number) ?? "0.0"
            return value >= 0 ? "+\(formatted)%" : "\(formatted)%"
        }
    }
} 