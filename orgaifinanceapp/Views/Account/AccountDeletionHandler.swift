import SwiftUI
import SwiftData

struct AccountDeletionHandler {
    static func deleteAccount(_ account: Account, from modelContext: ModelContext) throws {
        // Delete associated transactions
        // Note: In a real app, you might want to archive or mark as deleted instead of permanent deletion
        let descriptor = FetchDescriptor<Transaction>()
        if let transactions = try? modelContext.fetch(descriptor) {
            // TODO: Add proper transaction-account relationship and filtering
            // For now, we'll just delete the account since transactions aren't linked yet
            // let accountTransactions = transactions.filter { $0.accountId == account.id }
            // accountTransactions.forEach { modelContext.delete($0) }
        }
        
        // Delete the account
        modelContext.delete(account)
        
        // Save changes
        try modelContext.save()
    }
    
    static func deleteAllAccounts(from modelContext: ModelContext) throws {
        // Fetch all accounts
        let descriptor = FetchDescriptor<Account>()
        let accounts = try modelContext.fetch(descriptor)
        
        // Delete each account
        for account in accounts {
            modelContext.delete(account)
        }
        
        // Save changes
        try modelContext.save()
    }
    
    static func getDeletionWarning(for account: Account) -> String {
        switch account.type {
        case .personal:
            return "Deleting this personal account will permanently remove all associated transactions and financial data. This action cannot be undone."
        case .business:
            return "Deleting this business account will permanently remove all associated transactions, financial records, and business data. This action cannot be undone."
        case .cash:
            return "Deleting this cash account will permanently remove all cash transactions and related financial records. This action cannot be undone."
        }
    }
    
    static func getDeletionImpact(for account: Account) -> [String] {
        var impacts = [String]()
        
        // Add general impacts
        impacts.append("• All transaction history will be permanently deleted")
        impacts.append("• Account balance and statistics will be removed")
        
        // Add type-specific impacts
        switch account.type {
        case .personal:
            impacts.append("• Personal financial tracking data will be lost")
            impacts.append("• Net worth calculations will be affected")
        case .business:
            impacts.append("• Business financial records will be removed")
            impacts.append("• Business analytics and reports will be affected")
        case .cash:
            impacts.append("• Cash flow tracking will be affected")
            impacts.append("• Physical cash records will be removed")
        }
        
        return impacts
    }
} 