import SwiftUI

struct AppIcon: View {
    var size: CGFloat = 80
    var showBackground: Bool = true
    
    var body: some View {
        Image(systemName: "dollarsign.circle.fill")
            .font(.system(size: size))
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(DesignSystem.Colors.primary)
            .background {
                if showBackground {
                    Circle()
                        .fill(DesignSystem.Colors.primary.opacity(0.1))
                        .frame(width: size * 1.2, height: size * 1.2)
                }
            }
            .symbolEffect(.bounce, options: .repeating, value: showBackground)
    }
}

#Preview {
    VStack(spacing: 40) {
        AppIcon(size: 100)
        AppIcon(size: 60, showBackground: false)
    }
    .padding()
    .background(DesignSystem.Colors.background)
} 