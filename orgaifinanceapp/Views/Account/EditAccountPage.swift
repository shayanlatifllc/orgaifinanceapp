import SwiftUI
import SwiftData

struct EditAccountPage: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var accountType: Account.AccountType
    @State private var accountCategory: Account.AccountCategory
    @State private var accountName: String
    @State private var initialBalance: String
    @State private var selectedIcon: String
    @State private var showingIconSelector = false
    @State private var showingDeleteConfirmation = false
    @State private var error: AppError?
    
    private let account: Account
    
    init(account: Account) {
        self.account = account
        _accountType = State(initialValue: account.type)
        _accountCategory = State(initialValue: account.effectiveCategory)
        _accountName = State(initialValue: account.name)
        _initialBalance = State(initialValue: FinancialCalculations.Formatting.formatCurrency(account.balance))
        _selectedIcon = State(initialValue: account.icon)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xLarge) {
                // Instructions
                VStack(alignment: .leading, spacing: 0) {
                    Text(AccountInstructions.getCategoryInstruction(accountCategory, type: accountType))
                        .font(DesignSystem.Typography.bodyFont(size: .footnote))
                        .foregroundStyle(DesignSystem.Colors.secondary)
                        .lineSpacing(4)
                        .padding(.horizontal, DesignSystem.Spacing.medium)
                        .padding(.vertical, DesignSystem.Spacing.medium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background {
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                                .fill(DesignSystem.Colors.secondaryBackground)
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                                .strokeBorder(DesignSystem.Colors.secondary.opacity(0.1), lineWidth: 1)
                        }
                }
                .padding(.horizontal, DesignSystem.Layout.screenEdgePadding)
                .transition(.opacity.combined(with: .move(edge: .top)))
                .animation(.easeInOut(duration: 0.2), value: accountType)
                .animation(.easeInOut(duration: 0.2), value: accountCategory)
                
                // Icon Selector
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                    Text("Account Icon")
                        .font(DesignSystem.Typography.bodyFont(size: .subheadline))
                        .foregroundStyle(DesignSystem.Colors.secondary)
                    
                    Button {
                        showingIconSelector = true
                    } label: {
                        HStack {
                            Circle()
                                .fill(DesignSystem.Colors.primary.opacity(0.1))
                                .frame(width: 44, height: 44)
                                .overlay {
                                    Image(systemName: selectedIcon)
                                        .font(.system(size: 20))
                                        .foregroundStyle(DesignSystem.Colors.primary)
                                }
                            
                            Text("Change Icon")
                                .font(DesignSystem.Typography.bodyFont(size: .body))
                                .foregroundStyle(DesignSystem.Colors.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(DesignSystem.Colors.secondary)
                        }
                        .padding(.vertical, DesignSystem.Spacing.medium)
                        .padding(.horizontal, DesignSystem.Spacing.medium)
                        .background(DesignSystem.Colors.secondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, DesignSystem.Layout.screenEdgePadding)
                
                // Account Type and Category
                HStack(alignment: .top, spacing: DesignSystem.Spacing.medium) {
                    // Account Type Column
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                        Text("Account Type")
                            .font(DesignSystem.Typography.bodyFont(size: .subheadline))
                            .foregroundStyle(DesignSystem.Colors.secondary)
                        
                        AccountTypeGrid(selectedType: $accountType)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Account Category Column
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                        Text("Account Category")
                            .font(DesignSystem.Typography.bodyFont(size: .subheadline))
                            .foregroundStyle(DesignSystem.Colors.secondary)
                        
                        AccountCategoryGrid(selectedCategory: $accountCategory, accountType: accountType)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, DesignSystem.Layout.screenEdgePadding)
                
                // Account Details
                VStack(spacing: DesignSystem.Spacing.large) {
                    // Account Name
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                        Text("Account Name")
                            .font(DesignSystem.Typography.bodyFont(size: .subheadline))
                            .foregroundStyle(DesignSystem.Colors.secondary)
                        
                        TextField("Enter account name", text: $accountName)
                            .font(DesignSystem.Typography.bodyFont(size: .body))
                            .padding(.vertical, DesignSystem.Spacing.medium)
                            .padding(.horizontal, DesignSystem.Spacing.medium)
                            .background(DesignSystem.Colors.secondaryBackground)
                            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                                    .strokeBorder(DesignSystem.Colors.secondary.opacity(0.2), lineWidth: 1)
                            }
                    }
                    .padding(.horizontal, DesignSystem.Layout.screenEdgePadding)
                    
                    // Balance
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                        Text("Balance")
                            .font(DesignSystem.Typography.bodyFont(size: .subheadline))
                            .foregroundStyle(DesignSystem.Colors.secondary)
                        
                        TextField("$0.00", text: $initialBalance)
                            .font(DesignSystem.Typography.bodyFont(size: .body))
                            .padding(.vertical, DesignSystem.Spacing.medium)
                            .padding(.horizontal, DesignSystem.Spacing.medium)
                            .background(DesignSystem.Colors.secondaryBackground)
                            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                                    .strokeBorder(DesignSystem.Colors.secondary.opacity(0.2), lineWidth: 1)
                            }
                            .keyboardType(.decimalPad)
                    }
                    .padding(.horizontal, DesignSystem.Layout.screenEdgePadding)
                }
            }
            .padding(.vertical, DesignSystem.Spacing.large)
            
            // Delete Account Section
            VStack(spacing: DesignSystem.Spacing.medium) {
                Divider()
                    .padding(.horizontal, DesignSystem.Layout.screenEdgePadding)
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                    Text("Delete Account")
                        .font(DesignSystem.Typography.headlineFont(size: .body))
                        .foregroundStyle(DesignSystem.Colors.error)
                    
                    Text(AccountDeletionHandler.getDeletionWarning(for: account))
                        .font(DesignSystem.Typography.bodyFont(size: .footnote))
                        .foregroundStyle(DesignSystem.Colors.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                        ForEach(AccountDeletionHandler.getDeletionImpact(for: account), id: \.self) { impact in
                            Text(impact)
                                .font(DesignSystem.Typography.bodyFont(size: .caption))
                                .foregroundStyle(DesignSystem.Colors.secondary)
                        }
                    }
                    .padding(.vertical, DesignSystem.Spacing.small)
                    
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Account")
                        }
                        .font(DesignSystem.Typography.bodyFont(size: .body))
                        .foregroundStyle(DesignSystem.Colors.error)
                        .padding(.vertical, DesignSystem.Spacing.medium)
                        .frame(maxWidth: .infinity)
                        .background(DesignSystem.Colors.error.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, DesignSystem.Layout.screenEdgePadding)
                .padding(.vertical, DesignSystem.Spacing.medium)
            }
        }
        .navigationTitle("Edit Account")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveChanges()
                }
                .fontWeight(.semibold)
            }
        }
        .sheet(isPresented: $showingIconSelector) {
            AccountIconSelector(selectedIcon: $selectedIcon)
        }
        .alert("Delete Account", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text("Are you sure you want to delete this account? This action cannot be undone.")
        }
        .handleError($error)
    }
    
    private func saveChanges() {
        do {
            // Update account properties
            account.type = accountType
            account.category = accountCategory
            account.name = accountName
            account.icon = selectedIcon
            
            // Parse and update balance
            let balanceString = initialBalance.replacingOccurrences(of: "[$,]", with: "", options: .regularExpression)
            if let balance = Decimal(string: balanceString) {
                account.balance = balance
            } else {
                throw AppError.invalidAmount
            }
            
            try modelContext.save()
            dismiss()
        } catch {
            self.error = .invalidOperation
        }
    }
    
    private func deleteAccount() {
        do {
            try AccountDeletionHandler.deleteAccount(account, from: modelContext)
            dismiss()
        } catch {
            self.error = .invalidOperation
        }
    }
}

// MARK: - Supporting Views
struct AccountTypeGrid: View {
    @Binding var selectedType: Account.AccountType
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            ForEach(Account.AccountType.allCases, id: \.self) { type in
                Button {
                    // Add haptic feedback
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.prepare()
                    generator.impactOccurred()
                    
                    withAnimation(DesignSystem.Animation.snappy) {
                        selectedType = type
                    }
                } label: {
                    Text(type.rawValue)
                        .font(DesignSystem.Typography.bodyFont(size: .body))
                        .padding(.horizontal, DesignSystem.Spacing.medium)
                        .padding(.vertical, DesignSystem.Spacing.small)
                        .frame(maxWidth: .infinity)
                        .background(selectedType == type ? 
                            DesignSystem.Colors.primary.opacity(0.1) : 
                            DesignSystem.Colors.secondaryBackground)
                        .foregroundStyle(selectedType == type ?
                            DesignSystem.Colors.primary :
                            DesignSystem.Colors.secondary)
                        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous))
                        .overlay {
                            if selectedType == type {
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                                    .strokeBorder(DesignSystem.Colors.primary.opacity(0.3), lineWidth: 1)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct AccountCategoryGrid: View {
    @Binding var selectedCategory: Account.AccountCategory
    let accountType: Account.AccountType
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.small) {
            ForEach(Account.AccountCategory.allCases.filter {
                if accountType == .cash {
                    return $0 == .cashInHand
                } else {
                    return $0 != .cashInHand
                }
            }, id: \.self) { category in
                Button {
                    // Add haptic feedback
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.prepare()
                    generator.impactOccurred()
                    
                    withAnimation(DesignSystem.Animation.snappy) {
                        selectedCategory = category
                    }
                } label: {
                    Text(category.rawValue)
                        .font(DesignSystem.Typography.bodyFont(size: .body))
                        .padding(.horizontal, DesignSystem.Spacing.medium)
                        .padding(.vertical, DesignSystem.Spacing.small)
                        .frame(maxWidth: .infinity)
                        .background(selectedCategory == category ? 
                            DesignSystem.Colors.primary.opacity(0.1) : 
                            DesignSystem.Colors.secondaryBackground)
                        .foregroundStyle(selectedCategory == category ?
                            DesignSystem.Colors.primary :
                            DesignSystem.Colors.secondary)
                        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous))
                        .overlay {
                            if selectedCategory == category {
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                                    .strokeBorder(DesignSystem.Colors.primary.opacity(0.3), lineWidth: 1)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    EditAccountPage(account: Account(name: "Test Account", balance: 1000, type: .personal, category: .checking))
} 