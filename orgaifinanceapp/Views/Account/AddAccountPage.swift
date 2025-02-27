import SwiftUI
import SwiftData

struct AddAccountPage: View {
    @Environment(\.dismiss) private var dismiss
    private let modelContext: ModelContext
    @StateObject private var viewModel: AddAccountViewModel
    @State private var selectedType: AccountType?
    @State private var selectedSubtype: AccountSubtype?
    @State private var selectedPrimaryUse: PrimaryUse?
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self._viewModel = StateObject(wrappedValue: AddAccountViewModel(modelContext: modelContext))
    }
    
    private enum AccountType: String, CaseIterable {
        case banking = "Banking"
        case investmentsRetirement = "Investments & Retirement"
        case liabilities = "Liabilities"
        case assets = "Assets"
        
        var icon: String {
            switch self {
            case .banking:
                return "building.columns.fill"
            case .investmentsRetirement:
                return "chart.line.uptrend.xyaxis"
            case .liabilities:
                return "creditcard.fill"
            case .assets:
                return "house.fill"
            }
        }
        
        var subtypes: [AccountSubtype] {
            switch self {
            case .banking:
                return [.checking, .savings, .creditCards]
            case .investmentsRetirement:
                return []
            case .liabilities:
                return [.mortgage, .autoLoan, .lendingLoan, .otherLoans]
            case .assets:
                return [.cash, .realEstate, .vehicle, .otherAssets]
            }
        }
    }
    
    private enum AccountSubtype: String {
        // Banking
        case checking = "Checking"
        case savings = "Savings"
        case creditCards = "Credit Cards"
        
        // Liabilities
        case mortgage = "Mortgage"
        case autoLoan = "Auto Loan"
        case lendingLoan = "Lending Loan"
        case otherLoans = "Other Loans"
        
        // Assets
        case cash = "Cash"
        case realEstate = "Real Estate"
        case vehicle = "Vehicle"
        case otherAssets = "Other Assets"
        
        var icon: String {
            switch self {
            case .checking: return "dollarsign.circle.fill"
            case .savings: return "banknote.fill"
            case .creditCards: return "creditcard.fill"
            case .mortgage: return "house.fill"
            case .autoLoan: return "car.fill"
            case .lendingLoan: return "hand.wave.fill"
            case .otherLoans: return "doc.text.fill"
            case .cash: return "banknote.fill"
            case .realEstate: return "building.2.fill"
            case .vehicle: return "car.fill"
            case .otherAssets: return "archivebox.fill"
            }
        }
    }
    
    private enum PrimaryUse: String, CaseIterable {
        case personal = "Personal"
        case business = "Business"
        
        var icon: String {
            switch self {
            case .personal:
                return "person.fill"
            case .business:
                return "building.2.fill"
            }
        }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xLarge) {
                offlineAccountsNoticeView
                
                accountTypeSelectionView
                
                // Account Subtype Selection (if available)
                if let type = selectedType, !type.subtypes.isEmpty {
                    accountSubtypeSelectionView
                }
                
                // Primary Use Selection
                if selectedSubtype != nil {
                    primaryUseSelectionView
                }
                
                // Account Details Fields
                if let type = selectedType, 
                   let subtype = selectedSubtype, 
                   let primaryUse = selectedPrimaryUse, 
                   shouldShowAccountDetails(type: type, subtype: subtype, primaryUse: primaryUse) {
                    accountDetailsFieldsView
                }
            }
            .padding(.vertical, DesignSystem.Spacing.large)
            .animation(.easeInOut(duration: 0.3), value: selectedType)
            .animation(.easeInOut(duration: 0.3), value: selectedSubtype)
            .animation(.easeInOut(duration: 0.3), value: selectedPrimaryUse)
            .animation(.easeInOut(duration: 0.3), value: shouldShowAccountDetails(type: selectedType, subtype: selectedSubtype, primaryUse: selectedPrimaryUse))
        }
        .navigationTitle("Add Account")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // Add haptic feedback
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.prepare()
                    generator.impactOccurred()
                    
                    Task {
                        do {
                            try await viewModel.createAccount()
                            dismiss()
                        } catch let error as AppError {
                            viewModel.error = error
                        } catch {
                            viewModel.error = .invalidOperation
                        }
                    }
                } label: {
                    Text("Add")
                        .fontWeight(.semibold)
                }
                .disabled(!viewModel.canCreateAccount)
            }
        }
        .handleError($viewModel.error)
    }
    
    // MARK: - Extracted Views
    
    private var offlineAccountsNoticeView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            HStack(spacing: DesignSystem.Spacing.small) {
                Text("Offline Accounts")
                    .font(DesignSystem.Typography.headlineFont(size: .title3))
                    .foregroundStyle(DesignSystem.Colors.primary)
                
                Button {
                    // TODO: Show help info
                } label: {
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundStyle(DesignSystem.Colors.secondary.opacity(0.5))
                        .imageScale(.small)
                }
            }
            
            Text("Enter transactions manually. Track your net worth with assets, liabilities, etc.")
                .font(DesignSystem.Typography.bodyFont(size: .subheadline))
                .foregroundStyle(DesignSystem.Colors.secondary)
                .lineSpacing(4)
        }
        .padding(DesignSystem.Spacing.large)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                .fill(DesignSystem.Colors.secondaryBackground)
        }
        .overlay {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                .strokeBorder(DesignSystem.Colors.secondary.opacity(0.1), lineWidth: 1)
        }
        .padding(.horizontal, DesignSystem.Layout.screenEdgePadding)
    }
    
    private var accountTypeSelectionView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            Text("Account Type")
                .font(DesignSystem.Typography.bodyFont(size: .subheadline))
                .foregroundStyle(DesignSystem.Colors.secondary)
            
            FlowLayout(spacing: DesignSystem.Spacing.small) {
                ForEach(AccountType.allCases, id: \.self) { type in
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedType = type
                            selectedSubtype = nil // Reset subtype when type changes
                            selectedPrimaryUse = nil // Reset primary use when type changes
                        }
                    } label: {
                        HStack(spacing: DesignSystem.Spacing.small) {
                            Image(systemName: type.icon)
                                .imageScale(.small)
                                .foregroundStyle(selectedType == type ? 
                                    DesignSystem.Colors.primary : DesignSystem.Colors.secondary)
                            
                            Text(type.rawValue)
                                .font(DesignSystem.Typography.bodyFont(size: .subheadline))
                                .foregroundStyle(selectedType == type ? 
                                    DesignSystem.Colors.primary : DesignSystem.Colors.secondary)
                        }
                        .frame(height: 36)
                        .padding(.horizontal, DesignSystem.Spacing.medium)
                        .background(selectedType == type ? 
                            DesignSystem.Colors.secondaryBackground : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                                .stroke(DesignSystem.Colors.primary.opacity(0.1), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, DesignSystem.Layout.screenEdgePadding)
    }
    
    private var accountSubtypeSelectionView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            Text("Account Details")
                .font(DesignSystem.Typography.bodyFont(size: .subheadline))
                .foregroundStyle(DesignSystem.Colors.secondary)
            
            if let type = selectedType {
                if type == .investmentsRetirement {
                    // Special handling for Investments & Retirement
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                        Text("Coming Soon")
                            .font(DesignSystem.Typography.headlineFont(size: .title3))
                            .foregroundStyle(DesignSystem.Colors.primary)
                        Text("These features are coming in next updates. Stay tuned for enhanced investment tracking capabilities!")
                            .font(DesignSystem.Typography.bodyFont(size: .subheadline))
                            .foregroundStyle(DesignSystem.Colors.secondary)
                            .lineSpacing(4)
                    }
                    .padding(DesignSystem.Spacing.large)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                            .fill(DesignSystem.Colors.secondaryBackground)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                            .strokeBorder(DesignSystem.Colors.secondary.opacity(0.1), lineWidth: 1)
                    }
                } else if !type.subtypes.isEmpty {
                    FlowLayout(spacing: DesignSystem.Spacing.small) {
                        ForEach(type.subtypes, id: \.rawValue) { subtype in
                            Button {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    selectedSubtype = subtype
                                    selectedPrimaryUse = nil // Reset primary use when subtype changes
                                    updateViewModel()
                                }
                            } label: {
                                HStack(spacing: DesignSystem.Spacing.small) {
                                    Image(systemName: subtype.icon)
                                        .imageScale(.small)
                                        .foregroundStyle(selectedSubtype == subtype ? 
                                            DesignSystem.Colors.primary : DesignSystem.Colors.secondary)
                                    
                                    Text(subtype.rawValue)
                                        .font(DesignSystem.Typography.bodyFont(size: .subheadline))
                                        .foregroundStyle(selectedSubtype == subtype ? 
                                            DesignSystem.Colors.primary : DesignSystem.Colors.secondary)
                                }
                                .frame(height: 36)
                                .padding(.horizontal, DesignSystem.Spacing.medium)
                                .background(selectedSubtype == subtype ? 
                                    DesignSystem.Colors.secondaryBackground : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                                        .stroke(DesignSystem.Colors.primary.opacity(0.1), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } else {
                    Text("No subtypes available")
                        .font(DesignSystem.Typography.bodyFont(size: .subheadline))
                        .foregroundStyle(DesignSystem.Colors.secondary)
                        .padding(.vertical, DesignSystem.Spacing.medium)
                }
            }
        }
        .padding(.horizontal, DesignSystem.Layout.screenEdgePadding)
        .transition(.opacity)
    }
    
    private var primaryUseSelectionView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            Text("Primary Use")
                .font(DesignSystem.Typography.bodyFont(size: .subheadline))
                .foregroundStyle(DesignSystem.Colors.secondary)
            
            HStack(spacing: DesignSystem.Spacing.medium) {
                ForEach(PrimaryUse.allCases, id: \.self) { primaryUse in
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedPrimaryUse = primaryUse
                            updateViewModel()
                        }
                    } label: {
                        HStack(spacing: DesignSystem.Spacing.small) {
                            Image(systemName: primaryUse.icon)
                                .imageScale(.small)
                                .foregroundStyle(selectedPrimaryUse == primaryUse ? 
                                    DesignSystem.Colors.primary : DesignSystem.Colors.secondary)
                            
                            Text(primaryUse.rawValue)
                                .font(DesignSystem.Typography.bodyFont(size: .subheadline))
                                .foregroundStyle(selectedPrimaryUse == primaryUse ? 
                                    DesignSystem.Colors.primary : DesignSystem.Colors.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(selectedPrimaryUse == primaryUse ? 
                            DesignSystem.Colors.secondaryBackground : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                                .stroke(DesignSystem.Colors.primary.opacity(0.1), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, DesignSystem.Layout.screenEdgePadding)
        .transition(.opacity)
    }
    
    private var accountDetailsFieldsView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.large) {
            // Dynamic account description
            if let type = selectedType, let subtype = selectedSubtype, let primaryUse = selectedPrimaryUse {
                let accountCategory = mapSubtypeToCategory(subtype)
                let accountType = mapPrimaryUseToAccountType(primaryUse)
                
                Text(AccountInstructions.getCategoryInstruction(accountCategory, type: accountType))
                    .font(DesignSystem.Typography.bodyFont(size: .subheadline))
                    .foregroundStyle(DesignSystem.Colors.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Account Name Field
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                Text("Account Name")
                    .font(DesignSystem.Typography.bodyFont(size: .subheadline))
                    .foregroundStyle(DesignSystem.Colors.secondary)
                
                TextField("Enter account name", text: $viewModel.accountName)
                    .font(DesignSystem.Typography.bodyFont(size: .body))
                    .foregroundStyle(DesignSystem.Colors.primary)
                    .padding(.vertical, DesignSystem.Spacing.medium)
                    .padding(.horizontal, DesignSystem.Spacing.medium)
                    .background(Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                            .stroke(DesignSystem.Colors.primary.opacity(0.1), lineWidth: 1)
                    )
            }
            
            // Amount Field
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                // Format the current date
                let formattedDate = formatCurrentDate()
                
                Text("Amount (as of \(formattedDate))")
                    .font(DesignSystem.Typography.bodyFont(size: .subheadline))
                    .foregroundStyle(DesignSystem.Colors.secondary)
                
                TextField("$0.00", text: $viewModel.initialBalance)
                    .font(DesignSystem.Typography.bodyFont(size: .body))
                    .foregroundStyle(DesignSystem.Colors.primary)
                    .keyboardType(.decimalPad)
                    .padding(.vertical, DesignSystem.Spacing.medium)
                    .padding(.horizontal, DesignSystem.Spacing.medium)
                    .background(Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                            .stroke(DesignSystem.Colors.primary.opacity(0.1), lineWidth: 1)
                    )
                    .onChange(of: viewModel.initialBalance) { oldValue, newValue in
                        viewModel.initialBalance = viewModel.formatBalance(newValue)
                    }
            }
        }
        .padding(.horizontal, DesignSystem.Layout.screenEdgePadding)
        .transition(.opacity) // Use a simpler transition to avoid potential NaN issues
    }
    
    // MARK: - Helper Methods
    
    // Helper method to format the current date
    private func formatCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: Date())
    }
    
    private func shouldShowAccountDetails(type: AccountType?, subtype: AccountSubtype?, primaryUse: PrimaryUse?) -> Bool {
        guard let type = type, let subtype = subtype, let primaryUse = primaryUse else { return false }
        
        // Show details for specific banking account types
        if type == .banking && (subtype == .checking || subtype == .savings || subtype == .creditCards) {
            // Only show for personal and business primary use
            return primaryUse == .personal || primaryUse == .business
        }
        
        // Show details for asset account types
        if type == .assets && (subtype == .cash || subtype == .realEstate || subtype == .vehicle || subtype == .otherAssets) {
            // Show for personal and business primary use
            return primaryUse == .personal || primaryUse == .business
        }
        
        return false
    }
    
    // Update the ViewModel with the selected values
    private func updateViewModel() {
        if let primaryUse = selectedPrimaryUse {
            viewModel.selectedPrimaryUse = primaryUse.rawValue
        } else {
            viewModel.selectedPrimaryUse = nil
        }
        
        // Map selected subtype to account category
        if let subtype = selectedSubtype {
            switch subtype {
            // Banking categories
            case .checking:
                viewModel.accountCategory = .checking
            case .savings:
                viewModel.accountCategory = .savings
            case .creditCards:
                viewModel.accountCategory = .creditCard
                
            // Asset categories
            case .cash:
                viewModel.accountCategory = .cashInHand
            case .realEstate:
                viewModel.accountCategory = .realEstate
            case .vehicle:
                viewModel.accountCategory = .vehicle
            case .otherAssets:
                viewModel.accountCategory = .otherAssets
                
            // Liability categories
            case .mortgage:
                viewModel.accountCategory = .mortgage
            case .autoLoan:
                viewModel.accountCategory = .autoLoan
            case .lendingLoan:
                viewModel.accountCategory = .lendingLoan
            case .otherLoans:
                viewModel.accountCategory = .otherLoans
            }
        }
    }
    
    // Map the selected subtype to the actual account category
    private func mapSubtypeToCategory(_ subtype: AccountSubtype) -> Account.AccountCategory {
        switch subtype {
        case .checking:
            return .checking
        case .savings:
            return .savings
        case .creditCards:
            return .creditCard
        case .mortgage:
            return .mortgage
        case .autoLoan:
            return .autoLoan
        case .lendingLoan:
            return .lendingLoan
        case .otherLoans:
            return .otherLoans
        case .cash:
            return .cashInHand
        case .realEstate:
            return .realEstate
        case .vehicle:
            return .vehicle
        case .otherAssets:
            return .otherAssets
        }
    }
    
    // Map the selected primary use to the account type
    private func mapPrimaryUseToAccountType(_ primaryUse: PrimaryUse) -> Account.AccountType {
        switch primaryUse {
        case .personal:
            return .personal
        case .business:
            return .business
        }
    }
}

#Preview {
    NavigationStack {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Account.self, configurations: config)
        
        AddAccountPage(modelContext: container.mainContext)
    }
}

// MARK: - FlowLayout
struct FlowLayout: Layout {
    var spacing: CGFloat
    
    init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var height: CGFloat = 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeight: CGFloat = 0
        
        for view in subviews {
            let viewSize = view.sizeThatFits(.unspecified)
            
            if x + viewSize.width > width {
                // Move to next row
                y += maxHeight + spacing
                x = 0
                maxHeight = 0
            }
            
            maxHeight = max(maxHeight, viewSize.height)
            x += viewSize.width + spacing
        }
        
        height = y + maxHeight
        
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var maxHeight: CGFloat = 0
        
        for view in subviews {
            let viewSize = view.sizeThatFits(.unspecified)
            
            if x + viewSize.width > bounds.maxX {
                // Move to next row
                y += maxHeight + spacing
                x = bounds.minX
                maxHeight = 0
            }
            
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(width: viewSize.width, height: viewSize.height))
            
            maxHeight = max(maxHeight, viewSize.height)
            x += viewSize.width + spacing
        }
    }
} 