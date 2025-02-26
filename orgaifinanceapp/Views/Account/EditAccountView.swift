import SwiftUI
import SwiftData

struct EditAccountView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: [SortDescriptor(\Account.name)]) private var accounts: [Account]
    
    let account: Account
    @State private var accountName: String
    @State private var initialBalance: String
    @State private var accountType: Account.AccountType
    @State private var accountCategory: Account.AccountCategory
    @State private var showingDuplicateAlert = false
    @State private var isLoading = false
    @FocusState private var focusedField: Field?
    
    private enum Field {
        case accountName
        case initialBalance
    }
    
    init(account: Account) {
        self.account = account
        _accountName = State(initialValue: account.name)
        _accountType = State(initialValue: account.type)
        _accountCategory = State(initialValue: account.effectiveCategory)
        _initialBalance = State(initialValue: FinancialCalculations.Formatting.formatCurrency(account.balance)
            .replacingOccurrences(of: "$", with: ""))
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: Date())
    }
    
    private var canSaveChanges: Bool {
        !accountName.isEmpty && !initialBalance.isEmpty && hasChanges
    }
    
    private var hasChanges: Bool {
        accountName != account.name ||
        accountType != account.type ||
        accountCategory != account.effectiveCategory ||
        getBalanceDecimal() != account.balance
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.large) {
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
                    .padding(.bottom, DesignSystem.Spacing.small)
                    
                    // Account Type and Category
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                        // Account Type
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                            Text("Account Type")
                                .font(DesignSystem.Typography.bodyFont(size: .subheadline))
                                .foregroundStyle(DesignSystem.Colors.secondary)
                            
                            HStack(spacing: DesignSystem.Spacing.medium) {
                                ForEach(Account.AccountType.allCases, id: \.self) { type in
                                    Button {
                                        // Add haptic feedback
                                        let generator = UIImpactFeedbackGenerator(style: .light)
                                        generator.prepare()
                                        generator.impactOccurred()
                                        
                                        withAnimation(DesignSystem.Animation.snappy) {
                                            accountType = type
                                        }
                                    } label: {
                                        Text(type.rawValue)
                                            .font(DesignSystem.Typography.bodyFont(size: .body))
                                            .padding(.horizontal, DesignSystem.Spacing.medium)
                                            .padding(.vertical, DesignSystem.Spacing.small)
                                            .background(accountType == type ? 
                                                DesignSystem.Colors.primary.opacity(0.1) : 
                                                DesignSystem.Colors.secondaryBackground)
                                            .foregroundStyle(accountType == type ?
                                                DesignSystem.Colors.primary :
                                                DesignSystem.Colors.secondary)
                                            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous))
                                            .overlay {
                                                if accountType == type {
                                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                                                        .strokeBorder(DesignSystem.Colors.primary.opacity(0.3), lineWidth: 1)
                                                }
                                            }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        
                        // Account Category
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                            Text("Account Category")
                                .font(DesignSystem.Typography.bodyFont(size: .subheadline))
                                .foregroundStyle(DesignSystem.Colors.secondary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: DesignSystem.Spacing.small) {
                                    ForEach(Account.AccountCategory.allCases, id: \.self) { category in
                                        Button {
                                            // Add haptic feedback
                                            let generator = UIImpactFeedbackGenerator(style: .light)
                                            generator.prepare()
                                            generator.impactOccurred()
                                            
                                            withAnimation(DesignSystem.Animation.snappy) {
                                                accountCategory = category
                                            }
                                        } label: {
                                            Text(category.rawValue)
                                                .font(DesignSystem.Typography.bodyFont(size: .body))
                                                .padding(.horizontal, DesignSystem.Spacing.medium)
                                                .padding(.vertical, DesignSystem.Spacing.small)
                                                .background(accountCategory == category ? 
                                                    DesignSystem.Colors.primary.opacity(0.1) : 
                                                    DesignSystem.Colors.secondaryBackground)
                                                .foregroundStyle(accountCategory == category ?
                                                    DesignSystem.Colors.primary :
                                                    DesignSystem.Colors.secondary)
                                                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous))
                                                .overlay {
                                                    if accountCategory == category {
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
                                .focused($focusedField, equals: .accountName)
                                .submitLabel(.next)
                        }
                        .padding(.horizontal, DesignSystem.Layout.screenEdgePadding)
                        
                        // Balance as of today
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                            Text("Balance as of \(formattedDate)")
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
                                .focused($focusedField, equals: .initialBalance)
                                .submitLabel(.done)
                                .onChange(of: initialBalance) { _, newValue in
                                    initialBalance = formatBalance(newValue)
                                }
                        }
                        .padding(.horizontal, DesignSystem.Layout.screenEdgePadding)
                    }
                    .padding(.top, DesignSystem.Spacing.large)
                }
                .padding(.vertical, DesignSystem.Spacing.large)
            }
            .navigationTitle("Edit Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        // Add haptic feedback
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.prepare()
                        generator.impactOccurred()
                        
                        focusedField = nil
                        dismiss()
                    }
                    .foregroundStyle(DesignSystem.Colors.secondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        saveChanges()
                    } label: {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Save")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(!canSaveChanges || isLoading)
                }
                
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") {
                            focusedField = nil
                        }
                    }
                }
            }
            .alert("Duplicate Account Name", isPresented: $showingDuplicateAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("An account with this name already exists in your \(accountType == .personal ? "Personal" : "Business") accounts. Please choose a different name.")
            }
        }
        .presentationDetents([.height(520)])
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled(isLoading)
    }
    
    private func saveChanges() {
        guard Account.isNameUnique(accountName, type: accountType, in: accounts, excluding: account) else {
            showingDuplicateAlert = true
            return
        }
        
        // Add haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        
        focusedField = nil
        isLoading = true
        
        Task {
            do {
                // Update account properties
                account.name = accountName
                account.type = accountType
                account.category = accountCategory
                account.balance = getBalanceDecimal()
                account.updatedAt = Date()
                
                try modelContext.save()
                
                // Simulate network delay
                try await Task.sleep(for: .seconds(1))
                
                dismiss()
            } catch {
                print("Failed to save account changes: \(error)")
                isLoading = false
            }
        }
    }
    
    private func getBalanceDecimal() -> Decimal {
        let balanceString = initialBalance.replacingOccurrences(of: "[$,]", with: "", options: .regularExpression)
        return Decimal(string: balanceString) ?? 0
    }
    
    private func formatBalance(_ input: String) -> String {
        // Remove any existing currency symbols and decimals
        let cleaned = input.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        // Convert to decimal
        guard let number = Double(cleaned) else { return input }
        
        // Format as currency
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        
        return formatter.string(from: NSNumber(value: number / 100))?.replacingOccurrences(of: "$", with: "") ?? input
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Account.self, configurations: config)
    let context = container.mainContext
    
    let previewAccount = Account(
        name: "Test Account",
        balance: 1000,
        type: .personal,
        category: .checking
    )
    context.insert(previewAccount)
    
    return EditAccountView(account: previewAccount)
        .modelContainer(container)
} 