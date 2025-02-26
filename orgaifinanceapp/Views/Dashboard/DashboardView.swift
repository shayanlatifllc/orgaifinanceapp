import SwiftUI

struct DashboardView: View {
    // MARK: - Properties
    @AppStorage("username") private var username: String = "Guest"
    
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
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xLarge) {
                    // Balance Section
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
                        Text("Portfolio Value")
                            .font(DesignSystem.Typography.bodyFont(size: .subheadline))
                            .foregroundStyle(.secondary)
                        Text("$10,234.52")
                            .font(.system(.largeTitle, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundStyle(DesignSystem.Colors.primary)
                        
                        HStack(spacing: DesignSystem.Spacing.medium) {
                            Text("+$234.52")
                                .font(DesignSystem.Typography.bodyFont(size: .subheadline))
                                .foregroundStyle(DesignSystem.Colors.success)
                            Text("Today")
                                .font(DesignSystem.Typography.bodyFont(size: .subheadline))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, DesignSystem.Spacing.medium)
                    .applyShadow(DesignSystem.Shadows.small)
                }
                .contentSpacing(navigationTitleDisplayMode: .inline)
            }
        }
    }
}

#Preview {
    DashboardView()
} 