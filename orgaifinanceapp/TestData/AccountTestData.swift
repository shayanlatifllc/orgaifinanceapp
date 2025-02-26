import Foundation

struct AccountTestData {
    static let sampleAccounts = [
        // Personal Assets
        Account(name: "Bank of America", balance: 1500.00, type: .personal, category: .checking),
        Account(name: "BOFA Savings", balance: 3200.00, type: .personal, category: .savings),
        
        // Personal Liabilities
        Account(name: "CapitalOne Savor", balance: -3258.74, type: .personal, category: .creditCard),
        
        // Business Assets
        Account(name: "Business Checking", balance: 5000.00, type: .business, category: .checking),
        Account(name: "Business Savings", balance: 10000.00, type: .business, category: .savings),
        
        // Business Liabilities
        Account(name: "Business Credit Card", balance: -2500.00, type: .business, category: .creditCard),
        
        // Other Assets
        Account(name: "Investment Property", balance: 250000.00, type: .personal, category: .realEstate),
        Account(name: "Vehicle", balance: 35000.00, type: .personal, category: .vehicle),
        
        // Other Liabilities
        Account(name: "Mortgage", balance: -200000.00, type: .personal, category: .mortgage),
        Account(name: "Car Loan", balance: -25000.00, type: .personal, category: .autoLoan)
    ]
    
    static let expectedTotals = AccountTotals(
        totalAssets: 304700.00,  // Sum of all positive balances
        totalLiabilities: 230758.74,  // Sum of absolute values of negative balances
        netWorth: 73941.26,  // Assets - Liabilities
        personalTotal: 11441.26,  // Personal accounts net
        businessTotal: 12500.00   // Business accounts net
    )
}

struct AccountTotals {
    let totalAssets: Decimal
    let totalLiabilities: Decimal
    let netWorth: Decimal
    let personalTotal: Decimal
    let businessTotal: Decimal
} 