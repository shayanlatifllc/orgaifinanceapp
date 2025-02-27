import SwiftUI
import SwiftData

struct AccountView: View {
    // MARK: - Properties
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Account.createdAt, order: .reverse)], animation: .snappy) private var accounts: [Account]
    @AppStorage("isPersonalAccountsExpanded") private var isPersonalExpanded = true
    @AppStorage("isBusinessAccountsExpanded") private var isBusinessExpanded = false
    @AppStorage("isAssetsAccountsExpanded") private var isAssetsExpanded = false
    @AppStorage("isLiabilitiesAccountsExpanded") private var isLiabilitiesExpanded = false
    @AppStorage("lastScrollPosition") private var lastScrollPosition: Double = 0
    @State private var showingAddAccount = false
    @State private var showingEditAccount = false
    @State private var selectedAccount: Account?
    @State private var scrollProxy: ScrollViewProxy?
    @State private var refreshTrigger = UUID()
    
    // MARK: - Computed Properties
    private var totalAssets: Decimal {
        // Sum of all positive amounts EXCLUDING credit cards and liability accounts
        return accounts.filter { 
            $0.balance > 0 && 
            !$0.effectiveCategory.isLiability // Exclude all liabilities
        }.reduce(Decimal(0)) { $0 + $1.balance }
    }
    
    private var totalLiabilities: Decimal {
        // Sum of all credit cards and liability accounts regardless of sign
        // Also include any negative balances from non-liability accounts
        
        // 1. All negative balances from liability accounts (as positive numbers)
        let negativeLiabilities = accounts.filter { 
            $0.balance < 0 && 
            $0.effectiveCategory.isLiability 
        }.reduce(Decimal(0)) { $0 + abs($1.balance) }
        
        // 2. All positive balances from liability accounts (as negative contribution)
        let positiveLiabilities = accounts.filter { 
            $0.balance > 0 && 
            $0.effectiveCategory.isLiability 
        }.reduce(Decimal(0)) { $0 + $1.balance }
        
        // 3. All negative balances from non-liability accounts (as positive numbers)
        let negativeAssets = accounts.filter { 
            $0.balance < 0 && 
            !$0.effectiveCategory.isLiability 
        }.reduce(Decimal(0)) { $0 + abs($1.balance) }
        
        // Combine all liabilities - positive balance liabilities reduce the total
        return negativeLiabilities + negativeAssets - positiveLiabilities
    }
    
    private var netWorth: Decimal {
        // Net Worth = Total Assets - Total Liabilities
        return totalAssets - abs(totalLiabilities)
    }
    
    private var personalTotal: Decimal {
        // Checking + Savings
        let checkingSavingsTotal = accounts.filter { 
            $0.type == .personal && 
            ($0.effectiveCategory == .checking || $0.effectiveCategory == .savings) 
        }.reduce(Decimal(0)) { $0 + $1.balance }
        
        // Credit cards (should be subtracted regardless of balance sign)
        let creditCardsTotal = accounts.filter { 
            $0.type == .personal && 
            $0.effectiveCategory == .creditCard
        }.reduce(Decimal(0)) { $0 + $1.balance }
        
        return checkingSavingsTotal - abs(creditCardsTotal)
    }
    
    private var businessTotal: Decimal {
        // Checking + Savings
        let checkingSavingsTotal = accounts.filter { 
            $0.type == .business && 
            ($0.effectiveCategory == .checking || $0.effectiveCategory == .savings) 
        }.reduce(Decimal(0)) { $0 + $1.balance }
        
        // Credit cards (should be subtracted regardless of balance sign)
        let creditCardsTotal = accounts.filter { 
            $0.type == .business && 
            $0.effectiveCategory == .creditCard
        }.reduce(Decimal(0)) { $0 + $1.balance }
        
        return checkingSavingsTotal - abs(creditCardsTotal)
    }
    
    private var personalAccounts: [Account.AccountCategory: [Account]] {
        let personalAccountsList = accounts.filter { 
            $0.type == .personal && 
            ($0.effectiveCategory == .checking || 
             $0.effectiveCategory == .savings || 
             $0.effectiveCategory == .creditCard)
        }
        let groupedAccounts = Dictionary(grouping: personalAccountsList) { $0.effectiveCategory }
        return groupedAccounts
    }
    
    private var businessAccounts: [Account.AccountCategory: [Account]] {
        let businessAccountsList = accounts.filter { 
            $0.type == .business && 
            ($0.effectiveCategory == .checking || 
             $0.effectiveCategory == .savings || 
             $0.effectiveCategory == .creditCard)
        }
        let groupedAccounts = Dictionary(grouping: businessAccountsList) { $0.effectiveCategory }
        return groupedAccounts
    }
    
    private func accountsForCategory(_ category: Account.AccountCategory, type: Account.AccountType) -> [Account] {
        let typeMatches = accounts.filter { $0.type == type }
        let categoryMatches = typeMatches.filter { $0.effectiveCategory == category }
        
        // If dealing with a liability category, only return accounts with negative balances
        if category.isLiability {
            return categoryMatches.filter { $0.balance < 0 }
        }
        // If it's an asset category that could have positive balances (like loans with positive balances)
        else if category == .mortgage || category == .autoLoan || 
                category == .lendingLoan || category == .otherLoans {
            return categoryMatches.filter { $0.balance > 0 }
        }
        // For credit cards, split based on balance
        else if category == .creditCard {
            // In the Personal/Business tabs, show all credit cards
            // In the Assets tab, show positive balances
            // In the Liabilities tab, show negative balances
            return categoryMatches
        }
        // Otherwise, regular asset categories
        else {
            return categoryMatches
        }
    }
    
    private func totalForCategory(_ category: Account.AccountCategory, type: Account.AccountType) -> Decimal {
        // Get accounts that match the category and type
        let categoryAccounts = accountsForCategory(category, type: type)
        
        // Calculate total based on business logic:
        // 1. For Assets tab: Only include positive balances
        // 2. For Liabilities tab: Only include negative balances (as absolute values)
        if category.isLiability {
            // Only sum negative balances and return as positive amount
            return categoryAccounts
                .filter { $0.balance < 0 }
                .reduce(Decimal(0)) { $0 + abs($1.balance) }
        } else if category == .creditCard {
            // For credit cards:
            // - In Assets tab: Include only positive balances
            // - In Liabilities tab: Include only negative balances (as absolute values)
            // - In Banking tabs (Personal/Business): Show all credit cards
            let positiveBalances = categoryAccounts
                .filter { $0.balance > 0 }
                .reduce(Decimal(0)) { $0 + $1.balance }
            
            let negativeBalances = categoryAccounts
                .filter { $0.balance < 0 }
                .reduce(Decimal(0)) { $0 + abs($1.balance) }
            
            // In Banking tabs, show the net balance
            return positiveBalances - negativeBalances
        } else {
            // For regular assets, include all positive balances
            return categoryAccounts
                .filter { $0.balance > 0 }
                .reduce(Decimal(0)) { $0 + $1.balance }
        }
    }
    
    private var cashAccounts: [Account] {
        accounts.filter { $0.type == .cash }
    }
    
    private var cashTotal: Decimal {
        cashAccounts.reduce(Decimal(0)) { $0 + $1.balance }
    }
    
    private var cashTrend: (amount: Decimal, percentage: String, isPositive: Bool) {
        FinancialCalculations.Portfolio.calculateAccountTrend(cashAccounts)
    }
    
    // Personal Assets accounts - now based on positive balances
    private var personalAssetsAccounts: [Account] {
        accounts.filter {
            $0.type == .personal && 
            $0.balance > 0 &&
            ($0.effectiveCategory == .cashInHand || 
             $0.effectiveCategory == .realEstate || 
             $0.effectiveCategory == .vehicle || 
             $0.effectiveCategory == .otherAssets ||
             $0.effectiveCategory == .mortgage || 
             $0.effectiveCategory == .autoLoan || 
             $0.effectiveCategory == .lendingLoan || 
             $0.effectiveCategory == .otherLoans)
        }
    }
    
    // Business Assets accounts - now based on positive balances
    private var businessAssetsAccounts: [Account] {
        accounts.filter {
            $0.type == .business && 
            $0.balance > 0 &&
            ($0.effectiveCategory == .cashInHand || 
             $0.effectiveCategory == .realEstate || 
             $0.effectiveCategory == .vehicle || 
             $0.effectiveCategory == .otherAssets ||
             $0.effectiveCategory == .mortgage || 
             $0.effectiveCategory == .autoLoan || 
             $0.effectiveCategory == .lendingLoan || 
             $0.effectiveCategory == .otherLoans)
        }
    }
    
    // Personal Assets total
    private var personalAssetsTotal: Decimal {
        let positiveTotal = personalAssetsAccounts.filter { $0.balance > 0 }
            .reduce(Decimal(0)) { $0 + $1.balance }
        
        let negativeTotal = personalAssetsAccounts.filter { $0.balance < 0 }
            .reduce(Decimal(0)) { $0 + abs($1.balance) }
        
        return positiveTotal - negativeTotal
    }
    
    // Business Assets total
    private var businessAssetsTotal: Decimal {
        let positiveTotal = businessAssetsAccounts.filter { $0.balance > 0 }
            .reduce(Decimal(0)) { $0 + $1.balance }
        
        let negativeTotal = businessAssetsAccounts.filter { $0.balance < 0 }
            .reduce(Decimal(0)) { $0 + abs($1.balance) }
        
        return positiveTotal - negativeTotal
    }
    
    // Combined Assets total
    private var assetsTotal: Decimal {
        personalAssetsTotal + businessAssetsTotal
    }
    
    // Personal Liabilities accounts - now based on negative balances
    private var personalLiabilitiesAccounts: [Account] {
        accounts.filter {
            $0.type == .personal && 
            $0.balance < 0 &&
            ($0.effectiveCategory == .mortgage || 
             $0.effectiveCategory == .autoLoan || 
             $0.effectiveCategory == .lendingLoan || 
             $0.effectiveCategory == .otherLoans ||
             $0.effectiveCategory == .cashInHand || 
             $0.effectiveCategory == .realEstate || 
             $0.effectiveCategory == .vehicle || 
             $0.effectiveCategory == .otherAssets)
        }
    }
    
    // Business Liabilities accounts - now based on negative balances
    private var businessLiabilitiesAccounts: [Account] {
        accounts.filter {
            $0.type == .business && 
            $0.balance < 0 &&
            ($0.effectiveCategory == .mortgage || 
             $0.effectiveCategory == .autoLoan || 
             $0.effectiveCategory == .lendingLoan || 
             $0.effectiveCategory == .otherLoans ||
             $0.effectiveCategory == .cashInHand || 
             $0.effectiveCategory == .realEstate || 
             $0.effectiveCategory == .vehicle || 
             $0.effectiveCategory == .otherAssets)
        }
    }
    
    // Personal Liabilities total
    private var personalLiabilitiesTotal: Decimal {
        let positiveTotal = personalLiabilitiesAccounts.filter { $0.balance > 0 }
            .reduce(Decimal(0)) { $0 + $1.balance }
        
        let negativeTotal = personalLiabilitiesAccounts.filter { $0.balance < 0 }
            .reduce(Decimal(0)) { $0 + abs($1.balance) }
        
        return positiveTotal - negativeTotal
    }
    
    // Business Liabilities total
    private var businessLiabilitiesTotal: Decimal {
        let positiveTotal = businessLiabilitiesAccounts.filter { $0.balance > 0 }
            .reduce(Decimal(0)) { $0 + $1.balance }
        
        let negativeTotal = businessLiabilitiesAccounts.filter { $0.balance < 0 }
            .reduce(Decimal(0)) { $0 + abs($1.balance) }
        
        return positiveTotal - negativeTotal
    }
    
    // Combined Liabilities total
    private var liabilitiesTotal: Decimal {
        personalLiabilitiesTotal + businessLiabilitiesTotal
    }
    
    @ViewBuilder
    private func accountCategorySection(
        category: Account.AccountCategory,
        accounts: [Account],
        isExpanded: Bool
    ) -> some View {
        if accounts.isEmpty {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: 0) {
                // Category Header
                let headerText = Text(category.displayName)
                    .font(DesignSystem.Typography.bodyFont(size: .caption))
                    .foregroundStyle(DesignSystem.Colors.secondary)
                    .padding(.horizontal, DesignSystem.Spacing.medium)
                    .padding(.vertical, DesignSystem.Spacing.small)
                
                headerText
                
                if isExpanded {
                    VStack(spacing: 0) {
                        ForEach(Array(accounts.enumerated()), id: \.element.id) { index, account in
                            // Determine if account should display as negative based on category
                            let isLiability = account.effectiveCategory.isLiability
                            let isNegativeBalance = account.balance < 0
                            
                            // For liabilities, display the amount with a negative sign
                            // For assets, use the actual balance
                            let displayAmount = isLiability ? -abs(account.balance) : account.balance
                            let amountColor = isLiability || isNegativeBalance
                                ? DesignSystem.Colors.error 
                                : DesignSystem.Colors.success
                            
                            HStack {
                                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
                                    HStack(spacing: DesignSystem.Spacing.small) {
                                        Image(systemName: account.icon)
                                            .font(.system(size: 12))
                                            .foregroundStyle(DesignSystem.Colors.secondary)
                                        Text(account.name)
                                            .font(DesignSystem.Typography.bodyFont(size: .subheadline))
                                            .foregroundStyle(DesignSystem.Colors.primary)
                                    }
                                    
                                    // Display remaining credit for credit card accounts
                                    if account.effectiveCategory == .creditCard {
                                        Text("Remaining Credit: \(account.formattedAvailableCredit)")
                                            .font(DesignSystem.Typography.bodyFont(size: .caption))
                                            .foregroundStyle(DesignSystem.Colors.secondary)
                                            .padding(.leading, 24) // Align with the account name
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                HStack(spacing: DesignSystem.Spacing.small) {
                                    AnimatedAmountView(
                                        amount: displayAmount,
                                        font: DesignSystem.Typography.bodyFont(size: .subheadline),
                                        color: amountColor
                                    )
                                    
                                    Button {
                                        selectedAccount = account
                                    } label: {
                                        Text("Edit")
                                            .font(DesignSystem.Typography.caption2)
                                            .foregroundStyle(DesignSystem.Colors.secondary)
                                    }
                                }
                            }
                            .padding(.vertical, DesignSystem.Spacing.medium)
                            .padding(.horizontal, DesignSystem.Spacing.large)
                            .contentShape(Rectangle())
                            
                            if index != accounts.count - 1 {
                                Divider()
                                    .padding(.horizontal, DesignSystem.Spacing.medium)
                            }
                        }
                    }
                    .background(DesignSystem.Colors.background)
                }
            }
        }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: DesignSystem.Spacing.xLarge) {
                        // Overview Section
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xLarge) {
                            // Header
                            HStack(alignment: .center, spacing: DesignSystem.Spacing.small) {
                                HStack(spacing: DesignSystem.Spacing.small) {
                                    Image(systemName: "chart.pie.fill")
                                        .font(.title2)
                                        .foregroundStyle(DesignSystem.Colors.primary)
                                    Text("Overview")
                                        .font(DesignSystem.Typography.headlineFont(size: .title3))
                                        .foregroundStyle(DesignSystem.Colors.primary)
                                }
                                
                                Spacer()
                                
                                Button {
                                    // Add haptic feedback
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.prepare()
                                    generator.impactOccurred()
                                    
                                    showingAddAccount = true
                                } label: {
                                    HStack(spacing: DesignSystem.Spacing.small) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.headline)
                                        Text("Add New")
                                            .font(DesignSystem.Typography.bodyFont(size: .subheadline))
                                            .fontWeight(.medium)
                                    }
                                    .foregroundStyle(DesignSystem.Colors.primary)
                                }
                            }
                            .padding(.horizontal, DesignSystem.Layout.screenEdgePadding)
                            
                            // Financial Summary Grid
                            let columns = [
                                GridItem(.flexible(), spacing: DesignSystem.Spacing.medium),
                                GridItem(.flexible(), spacing: DesignSystem.Spacing.medium),
                                GridItem(.flexible(), spacing: DesignSystem.Spacing.medium)
                            ]
                            
                            LazyVGrid(columns: columns, spacing: DesignSystem.Spacing.medium) {
                                // Assets
                                SummaryBox(
                                    title: "Assets",
                                    amount: totalAssets,
                                    trend: "+2.5%",  // TODO: Calculate actual trend
                                    trendIsPositive: true,
                                    color: DesignSystem.Colors.success,
                                    isCompact: true
                                )
                                .id("assetsSummaryBox-\(refreshTrigger)")
                                
                                // Liabilities
                                SummaryBox(
                                    title: "Liabilities",
                                    amount: -totalLiabilities,
                                    trend: "-1.2%",  // TODO: Calculate actual trend
                                    trendIsPositive: false,
                                    color: DesignSystem.Colors.error,
                                    isCompact: true,
                                    useNegativeDisplay: true
                                )
                                .id("liabilitiesSummaryBox-\(refreshTrigger)")
                                
                                // Net Worth
                                SummaryBox(
                                    title: "Net Worth",
                                    amount: netWorth,
                                    trend: "+5.8%",  // TODO: Calculate actual trend
                                    trendIsPositive: netWorth >= 0,
                                    color: netWorth >= 0 ? DesignSystem.Colors.success : DesignSystem.Colors.error,
                                    isCompact: true,
                                    useNegativeDisplay: true  // Always show negative sign when negative
                                )
                                .id("netWorthSummaryBox-\(refreshTrigger)")
                            }
                            .onChange(of: accounts) { _, _ in
                                // Force refresh when accounts change
                                refreshTrigger = UUID()
                                print("Accounts changed - refresh triggered")
                            }
                            .padding(.horizontal, DesignSystem.Layout.screenEdgePadding)
                        }
                        
                        // Cash Accounts Section
                        if !cashAccounts.isEmpty {
                            CustomDisclosureGroup(
                                isExpanded: .constant(true),
                                title: "Cash",
                                amount: cashTotal
                            ) {
                                VStack(spacing: DesignSystem.Spacing.medium) {
                                    ForEach(cashAccounts) { account in
                                        accountCategorySection(
                                            category: account.effectiveCategory,
                                            accounts: [account],
                                            isExpanded: true
                                        )
                                    }
                                }
                                .padding(.top, DesignSystem.Spacing.small)
                            }
                            .padding(.horizontal, DesignSystem.Layout.screenEdgePadding)
                        }
                        
                        // Account Sections
                        LazyVStack(spacing: DesignSystem.Spacing.medium) {
                            // Personal Accounts Section
                            if personalAccounts.isEmpty {
                                emptyAccountsView(type: "Personal", icon: "person.circle")
                                    .padding(.horizontal, DesignSystem.Layout.screenEdgePadding)
                            } else {
                                CustomDisclosureGroup(
                                    isExpanded: $isPersonalExpanded,
                                    title: "Personal",
                                    amount: personalTotal
                                ) {
                                    VStack(spacing: DesignSystem.Spacing.medium) {
                                        ForEach(Account.AccountCategory.allCases, id: \.self) { category in
                                            if let accounts = personalAccounts[category] {
                                                accountCategorySection(
                                                    category: category,
                                                    accounts: accounts,
                                                    isExpanded: isPersonalExpanded
                                                )
                                            }
                                        }
                                    }
                                    .padding(.top, DesignSystem.Spacing.small)
                                }
                                .padding(.horizontal, DesignSystem.Layout.screenEdgePadding)
                            }
                            
                            // Business Accounts Section
                            if businessAccounts.isEmpty {
                                emptyAccountsView(type: "Business", icon: "building.2")
                                    .padding(.horizontal, DesignSystem.Layout.screenEdgePadding)
                            } else {
                                CustomDisclosureGroup(
                                    isExpanded: $isBusinessExpanded,
                                    title: "Business",
                                    amount: businessTotal
                                ) {
                                    VStack(spacing: DesignSystem.Spacing.medium) {
                                        ForEach(Account.AccountCategory.allCases, id: \.self) { category in
                                            if let accounts = businessAccounts[category] {
                                                accountCategorySection(
                                                    category: category,
                                                    accounts: accounts,
                                                    isExpanded: isBusinessExpanded
                                                )
                                            }
                                        }
                                    }
                                    .padding(.top, DesignSystem.Spacing.small)
                                }
                                .padding(.horizontal, DesignSystem.Layout.screenEdgePadding)
                            }
                            
                            // Assets Accounts Section
                            if personalAssetsAccounts.isEmpty && businessAssetsAccounts.isEmpty {
                                emptyAccountsView(type: "Assets", icon: "house")
                                    .padding(.horizontal, DesignSystem.Layout.screenEdgePadding)
                            } else {
                                CustomDisclosureGroup(
                                    isExpanded: $isAssetsExpanded,
                                    title: "Assets",
                                    amount: assetsTotal
                                ) {
                                    VStack(spacing: DesignSystem.Spacing.medium) {
                                        // Personal Assets
                                        if !personalAssetsAccounts.isEmpty {
                                            VStack(alignment: .leading, spacing: 0) {
                                                Text("Personal Assets")
                                                    .font(DesignSystem.Typography.bodyFont(size: .caption))
                                                    .foregroundStyle(DesignSystem.Colors.secondary)
                                                    .padding(.horizontal, DesignSystem.Spacing.medium)
                                                    .padding(.vertical, DesignSystem.Spacing.small)
                                                
                                                if isAssetsExpanded {
                                                    let groupedPersonalAssets = Dictionary(grouping: personalAssetsAccounts) { $0.effectiveCategory }
                                                    ForEach(Array(groupedPersonalAssets.keys).sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { category in
                                                        if let accounts = groupedPersonalAssets[category] {
                                                            accountCategorySection(
                                                                category: category,
                                                                accounts: accounts,
                                                                isExpanded: isAssetsExpanded
                                                            )
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        
                                        // Business Assets
                                        if !businessAssetsAccounts.isEmpty {
                                            VStack(alignment: .leading, spacing: 0) {
                                                Text("Business Assets")
                                                    .font(DesignSystem.Typography.bodyFont(size: .caption))
                                                    .foregroundStyle(DesignSystem.Colors.secondary)
                                                    .padding(.horizontal, DesignSystem.Spacing.medium)
                                                    .padding(.vertical, DesignSystem.Spacing.small)
                                                
                                                if isAssetsExpanded {
                                                    let groupedBusinessAssets = Dictionary(grouping: businessAssetsAccounts) { $0.effectiveCategory }
                                                    ForEach(Array(groupedBusinessAssets.keys).sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { category in
                                                        if let accounts = groupedBusinessAssets[category] {
                                                            accountCategorySection(
                                                                category: category,
                                                                accounts: accounts,
                                                                isExpanded: isAssetsExpanded
                                                            )
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .padding(.top, DesignSystem.Spacing.small)
                                }
                                .padding(.horizontal, DesignSystem.Layout.screenEdgePadding)
                            }
                            
                            // Liabilities Accounts Section
                            if personalLiabilitiesAccounts.isEmpty && businessLiabilitiesAccounts.isEmpty {
                                emptyAccountsView(type: "Liabilities", icon: "creditcard")
                                    .padding(.horizontal, DesignSystem.Layout.screenEdgePadding)
                            } else {
                                CustomDisclosureGroup(
                                    isExpanded: $isLiabilitiesExpanded,
                                    title: "Liabilities",
                                    amount: -totalLiabilities,
                                    isNegativeAmount: false
                                ) {
                                    VStack(spacing: DesignSystem.Spacing.medium) {
                                        // Personal Liabilities
                                        if !personalLiabilitiesAccounts.isEmpty {
                                            VStack(alignment: .leading, spacing: 0) {
                                                Text("Personal Liabilities")
                                                    .font(DesignSystem.Typography.bodyFont(size: .caption))
                                                    .foregroundStyle(DesignSystem.Colors.secondary)
                                                    .padding(.horizontal, DesignSystem.Spacing.medium)
                                                    .padding(.vertical, DesignSystem.Spacing.small)
                                                
                                                if isLiabilitiesExpanded {
                                                    let groupedPersonalLiabilities = Dictionary(grouping: personalLiabilitiesAccounts) { $0.effectiveCategory }
                                                    ForEach(Array(groupedPersonalLiabilities.keys).sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { category in
                                                        if let accounts = groupedPersonalLiabilities[category] {
                                                            accountCategorySection(
                                                                category: category,
                                                                accounts: accounts,
                                                                isExpanded: isLiabilitiesExpanded
                                                            )
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        
                                        // Business Liabilities
                                        if !businessLiabilitiesAccounts.isEmpty {
                                            VStack(alignment: .leading, spacing: 0) {
                                                Text("Business Liabilities")
                                                    .font(DesignSystem.Typography.bodyFont(size: .caption))
                                                    .foregroundStyle(DesignSystem.Colors.secondary)
                                                    .padding(.horizontal, DesignSystem.Spacing.medium)
                                                    .padding(.vertical, DesignSystem.Spacing.small)
                                                
                                                if isLiabilitiesExpanded {
                                                    let groupedBusinessLiabilities = Dictionary(grouping: businessLiabilitiesAccounts) { $0.effectiveCategory }
                                                    ForEach(Array(groupedBusinessLiabilities.keys).sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { category in
                                                        if let accounts = groupedBusinessLiabilities[category] {
                                                            accountCategorySection(
                                                                category: category,
                                                                accounts: accounts,
                                                                isExpanded: isLiabilitiesExpanded
                                                            )
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .padding(.top, DesignSystem.Spacing.small)
                                }
                                .padding(.horizontal, DesignSystem.Layout.screenEdgePadding)
                            }
                        }
                    }
                    .padding(.vertical, DesignSystem.Spacing.large)
                    .background(GeometryReader { geometry in
                        Color.clear.preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: geometry.frame(in: .named("scroll")).minY
                        )
                    })
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    lastScrollPosition = value
                }
                .onAppear {
                    scrollProxy = proxy
                    // Force recalculation of net worth by accessing the property
                    let _ = self.netWorth
                    print("View appeared - Net Worth: \(netWorth), Accounts count: \(accounts.count)")
                    
                    // Regenerate refresh trigger to ensure views update
                    refreshTrigger = UUID()
                    
                    // Restore scroll position after a short delay to ensure content is loaded
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            proxy.scrollTo("scrollAnchor", anchor: .top)
                        }
                    }
                }
            }
            .scrollDisabled(false)
            .navigationTitle("Accounts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Accounts")
                        .font(DesignSystem.Typography.headlineFont(size: .body))
                        .foregroundStyle(DesignSystem.Colors.primary)
                }
            }
            .navigationDestination(isPresented: $showingAddAccount) {
                AddAccountPage(modelContext: modelContext)
            }
            .navigationDestination(item: $selectedAccount) { account in
                EditAccountPage(account: account)
                    .navigationBarBackButtonHidden()
            }
        }
    }
}

// MARK: - Custom Disclosure Group
private struct CustomDisclosureGroup<Content: View>: View {
    @Binding var isExpanded: Bool
    let title: String
    let amount: Decimal
    var isNegativeAmount: Bool = false
    let content: () -> Content
    @State private var isAmountExpanded = false
    
    private var displayAmount: Decimal {
        isNegativeAmount ? abs(amount) : amount
    }
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            // Header
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: DesignSystem.Spacing.medium) {
                    HStack(alignment: .center) {
                        Text(title)
                            .font(DesignSystem.Typography.headlineFont(size: .body))
                            .foregroundStyle(DesignSystem.Colors.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Amount with dynamic sizing
                        Text(isAmountExpanded ? 
                            AmountFormatter.formatCurrency(displayAmount) :
                            AmountFormatter.formatCompactCurrency(displayAmount))
                            .font(DesignSystem.Typography.headlineFont(size: .body))
                            .foregroundStyle(DesignSystem.Colors.primary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                            .frame(alignment: .trailing)
                            .contentTransition(.numericText(value: Double(truncating: displayAmount as NSNumber)))
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    isAmountExpanded.toggle()
                                }
                            }
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.body.weight(.medium))
                        .foregroundStyle(DesignSystem.Colors.secondary.opacity(0.5))
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isExpanded)
                        .frame(width: 20)
                }
                .padding(.vertical, DesignSystem.Spacing.medium)
                .padding(.horizontal, DesignSystem.Spacing.medium)
                .background(DesignSystem.Colors.background)
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                VStack(alignment: .trailing, spacing: DesignSystem.Spacing.medium) {
                    content()
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .transition(.opacity.combined(with: .scale(scale: 0.98, anchor: .top)))
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isExpanded)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large)
                .stroke(DesignSystem.Colors.secondary.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Supporting Views
@ViewBuilder
private func emptyAccountsView(type: String, icon: String) -> some View {
    VStack(spacing: DesignSystem.Spacing.medium) {
        Image(systemName: icon)
            .font(.system(size: 24))
            .foregroundStyle(DesignSystem.Colors.secondary)
        
        Text("No \(type) Accounts")
            .font(DesignSystem.Typography.headlineFont(size: .subheadline))
            .foregroundStyle(DesignSystem.Colors.primary)
        
        Text("Use the \"Add New\" button to create your first \(type.lowercased()) account.")
            .font(DesignSystem.Typography.bodyFont(size: .subheadline))
            .foregroundStyle(DesignSystem.Colors.secondary)
            .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity)
    .padding(DesignSystem.Spacing.large)
    .background {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
            .fill(DesignSystem.Colors.secondaryBackground)
    }
    .overlay {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
            .strokeBorder(DesignSystem.Colors.secondary.opacity(0.1), lineWidth: 1)
    }
}

private struct SummaryBox: View {
    let title: String
    let amount: Decimal
    let trend: String
    let trendIsPositive: Bool
    let color: Color
    var isCompact: Bool = false
    var useNegativeDisplay: Bool = true
    @State private var isExpanded = false
    
    private var titleFont: Font {
        isCompact ? DesignSystem.Typography.bodyFont(size: .caption) : DesignSystem.Typography.bodyFont(size: .subheadline)
    }
    
    private var amountFont: Font {
        if isCompact {
            return .system(size: 20, weight: .medium, design: .rounded)
        } else {
            return .system(size: 28, weight: .medium, design: .rounded)
        }
    }
    
    private var boxHeight: CGFloat {
        isCompact ? 90 : 120
    }
    
    // Determines how to display the amount - liabilities can show as positive in summary
    private var displayAmount: Decimal {
        // If useNegativeDisplay is true, show the amount as provided (which could be negative)
        // If useNegativeDisplay is false, show the absolute value (force positive display)
        useNegativeDisplay ? amount : abs(amount)
    }
    
    // Determine the color based on the amount and context
    private var amountColor: Color {
        // Override with provided color if specified
        if color != DesignSystem.Colors.primary {
            return color
        }
        
        // Default coloring based on value
        if displayAmount < 0 {
            return DesignSystem.Colors.error
        } else {
            return DesignSystem.Colors.success
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: isCompact ? DesignSystem.Spacing.xxSmall : DesignSystem.Spacing.small) {
            // Title
            Text(title)
                .font(titleFont)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Amount Container
            let formattedAmount = isExpanded ? AmountFormatter.formatCurrency(displayAmount) : AmountFormatter.formatCompactCurrency(displayAmount)
            
            Text(formattedAmount)
                .font(amountFont)
                .foregroundStyle(amountColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .contentTransition(.numericText(value: Double(truncating: displayAmount as NSNumber)))
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                    }
                }
            
            // Trend
            HStack(spacing: DesignSystem.Spacing.xxSmall) {
                Image(systemName: trendIsPositive ? "arrow.up.right" : "arrow.down.right")
                Text(trend)
            }
            .font(DesignSystem.Typography.caption2)
            .foregroundStyle(trendIsPositive ? DesignSystem.Colors.success : DesignSystem.Colors.error)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(DesignSystem.Spacing.medium)
        .frame(maxWidth: .infinity, minHeight: boxHeight, maxHeight: boxHeight, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                .fill(DesignSystem.Colors.secondaryBackground)
        }
    }
}

private struct AccountActionButton: View {
    let title: String
    let amount: Decimal
    let icon: String
    let account: Account
    @Binding var showingEditAccount: Bool
    @Binding var selectedAccount: Account?
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.medium) {
            // Icon with background
            Circle()
                .fill(DesignSystem.Colors.primary.opacity(0.1))
                .frame(width: 36, height: 36)
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundStyle(DesignSystem.Colors.primary)
                }
            
            // Account details
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(DesignSystem.Typography.bodyFont(size: .subheadline))
                    .foregroundStyle(DesignSystem.Colors.primary)
                
                Text(account.type.rawValue)
                    .font(DesignSystem.Typography.bodyFont(size: .caption))
                    .foregroundStyle(DesignSystem.Colors.secondary)
            }
            
            Spacer()
            
            // Amount
            AnimatedAmountView(
                amount: amount,
                font: DesignSystem.Typography.bodyFont(size: .subheadline),
                color: amount < 0 ? DesignSystem.Colors.error : DesignSystem.Colors.success
            )
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Scroll Position Preference Key
private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: Double = 0
    static func reduce(value: inout Double, nextValue: () -> Double) {
        value = nextValue()
    }
}

struct AccountPreviewContainer: View {
    @StateObject private var themeManager = ThemeManager()
    
    var body: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Account.self, configurations: config)
        let context = container.mainContext
        
        // Add preview data
        let previewAccounts = [
            Account(name: "Checking", balance: 2450.00, type: .personal, category: .checking),
            Account(name: "Savings", balance: 12380.00, type: .personal, category: .savings),
            Account(name: "Business Checking", balance: 8750.00, type: .business, category: .checking)
        ]
        
        previewAccounts.forEach { context.insert($0) }
        
        return NavigationStack {
            AccountView()
        }
        .modelContainer(container)
        .environmentObject(themeManager)
    }
}

#Preview {
    AccountPreviewContainer()
} 