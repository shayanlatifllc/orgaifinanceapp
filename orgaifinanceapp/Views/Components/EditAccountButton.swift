import SwiftUI

struct EditAccountButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Edit")
                .font(DesignSystem.Typography.bodyFont(size: .caption))
                .foregroundStyle(DesignSystem.Colors.secondary.opacity(0.5))
                .padding(.leading, DesignSystem.Spacing.small)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    EditAccountButton {
        print("Edit tapped")
    }
    .padding()
    .background(DesignSystem.Colors.background)
} 