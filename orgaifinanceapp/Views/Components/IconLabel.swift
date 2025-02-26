import SwiftUI

struct IconLabel: View {
    let icon: String
    let text: String
    var fontSize: OFFontSize
    var foregroundColor: Color = .primary
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.medium) {
            Image(systemName: icon)
                .symbolRenderingMode(.multicolor)
                .font(.system(size: fontSize.size * 1.2))
            
            Text(text)
                .font(DesignSystem.Typography.bodyFont(size: fontSize))
        }
        .foregroundColor(foregroundColor)
    }
}

#Preview {
    VStack(spacing: 20) {
        IconLabel(
            icon: "house.fill",
            text: "Home",
            fontSize: .body
        )
        
        IconLabel(
            icon: "chart.bar.fill",
            text: "Portfolio",
            fontSize: .title3,
            foregroundColor: DesignSystem.Colors.primary
        )
    }
    .padding()
} 