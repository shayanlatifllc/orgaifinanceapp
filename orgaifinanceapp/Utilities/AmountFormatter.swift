import SwiftUI

struct AmountFormatter {
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
} 