import SwiftUI
import SwiftData

struct AddAccountView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: [SortDescriptor(\Account.name)]) private var accounts: [Account]
    
    @State private var accountName = ""
    @State private var initialBalance = ""
    @State private var accountType: Account.AccountType = .personal
    @State private var accountCategory: Account.AccountCategory = .checking
    @State private var showingDuplicateAlert = false
    @State private var isLoading = false
    @FocusState private var focusedField: Field?
    
    private enum Field {
        case accountName
        case initialBalance
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: Date())
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Instructions
                Section {
                    Text(AccountInstructions.getCategoryInstruction(accountCategory, type: accountType))
                        .font(DesignSystem.Typography.bodyFont(size: .footnote))
                        .foregroundStyle(DesignSystem.Colors.secondary)
                        .listRowBackground(Color.clear)
                        .lineSpacing(4)
                }
                
                // Account Type
                Section {
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
                                    .foregroundStyle(accountType == type ?
                                        DesignSystem.Colors.primary :
                                        DesignSystem.Colors.secondary)
                                    .fontWeight(accountType == type ? .semibold : .regular)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .listRowBackground(Color.clear)
                } header: {
                    Text("Account Type")
                        .font(DesignSystem.Typography.bodyFont(size: .subheadline))
                        .foregroundStyle(DesignSystem.Colors.secondary)
                }
                
                // Account Category
                Section {
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
                                        .foregroundStyle(accountCategory == category ?
                                            DesignSystem.Colors.primary :
                                            DesignSystem.Colors.secondary)
                                        .fontWeight(accountCategory == category ? .semibold : .regular)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .listRowBackground(Color.clear)
                } header: {
                    Text("Account Category")
                        .font(DesignSystem.Typography.bodyFont(size: .subheadline))
                        .foregroundStyle(DesignSystem.Colors.secondary)
                }
                
                // Account Details
                Section {
                    HStack {
                        Text("Account Name")
                            .font(DesignSystem.Typography.bodyFont(size: .body))
                            .foregroundStyle(DesignSystem.Colors.secondary)
                        
                        Spacer()
                        
                        TextField("Enter account name", text: $accountName)
                            .font(DesignSystem.Typography.bodyFont(size: .body))
                            .multilineTextAlignment(.trailing)
                            .focused($focusedField, equals: .accountName)
                            .submitLabel(.next)
                    }
                    .listRowBackground(Color.clear)
                    
                    HStack {
                        Text("Balance")
                            .font(DesignSystem.Typography.bodyFont(size: .body))
                            .foregroundStyle(DesignSystem.Colors.secondary)
                        
                        Spacer()
                        
                        TextField("$0.00", text: $initialBalance)
                            .font(DesignSystem.Typography.bodyFont(size: .body))
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .initialBalance)
                            .submitLabel(.done)
                            .onChange(of: initialBalance) { _, newValue in
                                initialBalance = formatBalance(newValue)
                            }
                    }
                    .listRowBackground(Color.clear)
                } header: {
                    Text("Account Details")
                        .font(DesignSystem.Typography.bodyFont(size: .subheadline))
                        .foregroundStyle(DesignSystem.Colors.secondary)
                } footer: {
                    Text("Balance as of \(formattedDate)")
                        .font(DesignSystem.Typography.bodyFont(size: .footnote))
                        .foregroundStyle(DesignSystem.Colors.secondary)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(DesignSystem.Colors.background)
            .navigationTitle("Add Account")
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
                        addAccount()
                    } label: {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Add")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(!canAddAccount || isLoading)
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
    
    private var canAddAccount: Bool {
        !accountName.isEmpty && !initialBalance.isEmpty
    }
    
    private func addAccount() {
        guard Account.isNameUnique(accountName, type: accountType, in: accounts) else {
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
                // Convert balance string to Decimal
                let balanceString = initialBalance.replacingOccurrences(of: "[$,]", with: "", options: .regularExpression)
                guard let balance = Decimal(string: balanceString) else {
                    throw AppError.invalidAmount
                }
                
                let account = Account(
                    name: accountName,
                    balance: balance,
                    type: accountType,
                    category: accountCategory
                )
                
                modelContext.insert(account)
                try modelContext.save()
                
                // Simulate network delay
                try await Task.sleep(for: .seconds(1))
                
                dismiss()
            } catch {
                print("Failed to add account: \(error)")
                isLoading = false
            }
        }
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
        
        return formatter.string(from: NSNumber(value: number / 100)) ?? input
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Account.self, configurations: config)
    
    return AddAccountView()
        .modelContainer(container)
} 