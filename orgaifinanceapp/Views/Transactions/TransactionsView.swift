import SwiftUI

struct ActivityView: View {
    // MARK: - Properties
    @State private var selectedFilter: String = "All"
    @State private var showingQuickActions = false
    @State private var selectedAction: QuickAction?
    
    private let filters = ["All", "Income", "Expense"]
    
    // MARK: - Quick Action Types
    enum QuickAction: String, CaseIterable, Identifiable {
        case buy = "Buy"
        case sell = "Sell"
        case transfer = "Transfer"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .buy: return DesignSystem.Icons.income
            case .sell: return DesignSystem.Icons.expense
            case .transfer: return DesignSystem.Icons.transfer
            }
        }
        
        var title: String { rawValue }
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.large) {
                    // Filter Section
                    FilterBar(
                        items: filters,
                        selectedItem: $selectedFilter
                    ) { $0 }
                    .padding(.horizontal, DesignSystem.Layout.screenEdgePadding)
                    .padding(.top, DesignSystem.Spacing.medium)
                    
                    // Transactions List
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.large) {
                        Text("Today")
                            .font(DesignSystem.Typography.headline)
                            .foregroundStyle(DesignSystem.Colors.primary)
                            .padding(.horizontal, DesignSystem.Layout.screenEdgePadding)
                        
                        ForEach(0..<5) { _ in
                            ActivityItem(
                                icon: "cart.fill",
                                title: "Shopping",
                                subtitle: "Grocery Store",
                                amount: "-$24.99",
                                isExpense: true
                            ) {
                                // Handle tap
                            }
                            .padding(.horizontal, DesignSystem.Layout.screenEdgePadding)
                        }
                    }
                    .padding(.top, DesignSystem.Spacing.medium)
                }
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 100)
            }
            
            // Quick Add Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        // Add haptic feedback
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.prepare()
                        generator.impactOccurred()
                        
                        withAnimation(DesignSystem.Animation.quick) {
                            showingQuickActions.toggle()
                        }
                    } label: {
                        Image(systemName: DesignSystem.Icons.add)
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background {
                                Circle()
                                    .fill(DesignSystem.Colors.primary)
                            }
                            .applyShadow(DesignSystem.Shadows.medium)
                    }
                    .offset(x: -24, y: -124)
                }
            }
        }
        .sheet(isPresented: $showingQuickActions) {
            NavigationStack {
                VStack(spacing: DesignSystem.Spacing.medium) {
                    ForEach(QuickAction.allCases) { action in
                        Button {
                            // Add haptic feedback
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.prepare()
                            generator.impactOccurred()
                            
                            selectedAction = action
                            showingQuickActions = false
                            handleQuickAction(action)
                        } label: {
                            HStack {
                                Image(systemName: action.icon)
                                    .font(.title2)
                                    .foregroundStyle(DesignSystem.Colors.primary)
                                Text(action.title)
                                    .font(DesignSystem.Typography.headlineFont(size: .body))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, DesignSystem.Spacing.medium)
                            .padding(.horizontal, DesignSystem.Spacing.large)
                            .background {
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                                    .fill(DesignSystem.Colors.secondaryBackground)
                            }
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(DesignSystem.Colors.primary)
                    }
                }
                .padding()
                .navigationTitle("Quick Actions")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingQuickActions = false
                        } label: {
                            Image(systemName: DesignSystem.Icons.close)
                                .foregroundStyle(.secondary)
                                .imageScale(.large)
                        }
                    }
                }
                .presentationDetents([.height(340)])
                .presentationDragIndicator(.visible)
            }
            .presentationBackground(DesignSystem.Colors.background)
        }
    }
    
    // MARK: - Action Handlers
    private func handleQuickAction(_ action: QuickAction) {
        switch action {
        case .buy:
            // TODO: Implement buy flow
            print("Starting buy flow")
        case .sell:
            // TODO: Implement sell flow
            print("Starting sell flow")
        case .transfer:
            // TODO: Implement transfer flow
            print("Starting transfer flow")
        }
    }
}

#Preview {
    ActivityView()
} 