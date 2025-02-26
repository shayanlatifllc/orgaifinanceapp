import Foundation
import SwiftUI

enum AppError: LocalizedError {
    // MARK: - Data Errors
    case failedToLoadTransactions
    case failedToSaveTransaction
    case failedToDeleteTransaction
    case invalidTransactionData
    case databaseError(String)
    
    // MARK: - Authentication Errors
    case authenticationFailed
    case userNotFound
    case invalidCredentials
    case sessionExpired
    
    // MARK: - Network Errors
    case networkError
    case serverError
    case timeoutError
    case noInternetConnection
    
    // MARK: - Validation Errors
    case invalidAmount
    case invalidDate
    case invalidCategory
    case missingRequiredField(String)
    
    // MARK: - Business Logic Errors
    case insufficientFunds
    case invalidTransactionType
    case duplicateTransaction
    case invalidOperation
    
    var errorDescription: String? {
        switch self {
        // Data Errors
        case .failedToLoadTransactions:
            return "Failed to load transactions"
        case .failedToSaveTransaction:
            return "Failed to save transaction"
        case .failedToDeleteTransaction:
            return "Failed to delete transaction"
        case .invalidTransactionData:
            return "Invalid transaction data"
        case .databaseError(let message):
            return "Database error: \(message)"
            
        // Authentication Errors
        case .authenticationFailed:
            return "Authentication failed"
        case .userNotFound:
            return "User not found"
        case .invalidCredentials:
            return "Invalid credentials"
        case .sessionExpired:
            return "Session expired"
            
        // Network Errors
        case .networkError:
            return "Network error occurred"
        case .serverError:
            return "Server error occurred"
        case .timeoutError:
            return "Request timed out"
        case .noInternetConnection:
            return "No internet connection"
            
        // Validation Errors
        case .invalidAmount:
            return "Invalid amount"
        case .invalidDate:
            return "Invalid date"
        case .invalidCategory:
            return "Invalid category"
        case .missingRequiredField(let field):
            return "Missing required field: \(field)"
            
        // Business Logic Errors
        case .insufficientFunds:
            return "Insufficient funds"
        case .invalidTransactionType:
            return "Invalid transaction type"
        case .duplicateTransaction:
            return "Duplicate transaction"
        case .invalidOperation:
            return "Invalid operation"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        // Data Errors
        case .failedToLoadTransactions:
            return "Please try restarting the app"
        case .failedToSaveTransaction:
            return "Please try again"
        case .failedToDeleteTransaction:
            return "Please try again"
        case .invalidTransactionData:
            return "Please check the transaction details"
        case .databaseError:
            return "Please try restarting the app"
            
        // Authentication Errors
        case .authenticationFailed:
            return "Please try signing in again"
        case .userNotFound:
            return "Please check your credentials"
        case .invalidCredentials:
            return "Please check your username and password"
        case .sessionExpired:
            return "Please sign in again"
            
        // Network Errors
        case .networkError:
            return "Please check your internet connection"
        case .serverError:
            return "Please try again later"
        case .timeoutError:
            return "Please try again"
        case .noInternetConnection:
            return "Please check your internet connection"
            
        // Validation Errors
        case .invalidAmount:
            return "Please enter a valid amount"
        case .invalidDate:
            return "Please enter a valid date"
        case .invalidCategory:
            return "Please select a valid category"
        case .missingRequiredField:
            return "Please fill in all required fields"
            
        // Business Logic Errors
        case .insufficientFunds:
            return "Please check your balance"
        case .invalidTransactionType:
            return "Please select a valid transaction type"
        case .duplicateTransaction:
            return "This transaction already exists"
        case .invalidOperation:
            return "This operation is not allowed"
        }
    }
}

// MARK: - Error Handling Extensions
extension Result {
    func handle(
        onSuccess: (Success) -> Void,
        onFailure: (Error) -> Void
    ) {
        switch self {
        case .success(let value):
            onSuccess(value)
        case .failure(let error):
            onFailure(error)
        }
    }
}

// MARK: - View Extension for Error Presentation
extension View {
    func handleError(_ error: Binding<AppError?>) -> some View {
        alert(
            "Error",
            isPresented: .constant(error.wrappedValue != nil),
            presenting: error.wrappedValue
        ) { _ in
            Button("OK") {
                error.wrappedValue = nil
            }
        } message: { error in
            if let recoverySuggestion = error.recoverySuggestion {
                Text(error.errorDescription ?? "")
                    .font(DesignSystem.Typography.bodyFont(size: .body))
                Text(recoverySuggestion)
                    .font(DesignSystem.Typography.bodyFont(size: .footnote))
                    .foregroundColor(.secondary)
            } else {
                Text(error.errorDescription ?? "")
                    .font(DesignSystem.Typography.bodyFont(size: .body))
            }
        }
    }
} 