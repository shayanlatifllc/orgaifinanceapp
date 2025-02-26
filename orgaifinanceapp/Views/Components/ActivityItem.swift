import SwiftUI

struct ActivityItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let amount: String
    let isExpense: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: DesignSystem.Spacing.large) {
                Circle()
                    .fill(DesignSystem.Colors.secondary.opacity(0.1))
                    .frame(width: 44, height: 44)
                    .overlay {
                        Image(systemName: icon)
                            .font(.system(size: 16))
                            .foregroundStyle(DesignSystem.Colors.secondary)
                    }
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xSmall) {
                    Text(title)
                        .font(DesignSystem.Typography.body)
                        .fontWeight(.medium)
                    Text(subtitle)
                        .font(DesignSystem.Typography.caption2)
                        .foregroundStyle(DesignSystem.Colors.textTertiary)
                }
                
                Spacer()
                
                Text(amount)
                    .font(DesignSystem.Typography.body)
                    .fontWeight(.medium)
                    .foregroundStyle(isExpense ? DesignSystem.Colors.error : DesignSystem.Colors.success)
            }
            .padding(.vertical, DesignSystem.Spacing.medium)
            .padding(.horizontal, DesignSystem.Spacing.large)
            .background {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                    .fill(DesignSystem.Colors.secondaryBackground)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 16) {
        ActivityItem(
            icon: "cart.fill",
            title: "Shopping",
            subtitle: "Grocery Store",
            amount: "-$24.99",
            isExpense: true
        ) {
            print("Tapped")
        }
        
        ActivityItem(
            icon: "arrow.down.circle.fill",
            title: "Salary",
            subtitle: "Monthly Income",
            amount: "+$5,000.00",
            isExpense: false
        ) {
            print("Tapped")
        }
    }
    .padding()
    .background(Color("AdaptiveBackground"))
} 