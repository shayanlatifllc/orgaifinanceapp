import SwiftUI

struct FilterBar<T: Hashable>: View {
    let items: [T]
    @Binding var selectedItem: T
    let itemTitle: (T) -> String
    
    @Namespace private var namespace
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(items, id: \.self) { item in
                Button {
                    withAnimation(DesignSystem.Animation.quick) {
                        selectedItem = item
                    }
                } label: {
                    Text(itemTitle(item))
                        .font(DesignSystem.Typography.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background {
                            if selectedItem == item {
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                                    .fill(DesignSystem.Colors.primary)
                                    .matchedGeometryEffect(id: "FILTER", in: namespace)
                            }
                        }
                        .foregroundStyle(selectedItem == item ? .white : DesignSystem.Colors.primary)
                }
            }
        }
        .padding(4)
        .background {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                .fill(DesignSystem.Colors.secondaryBackground)
        }
    }
}

#Preview {
    VStack {
        FilterBar(
            items: ["All", "Income", "Expense"],
            selectedItem: .constant("All")
        ) { $0 }
        .padding()
        
        FilterBar(
            items: ["Daily", "Weekly", "Monthly", "Yearly"],
            selectedItem: .constant("Monthly")
        ) { $0 }
        .padding()
    }
    .background(DesignSystem.Colors.background)
} 