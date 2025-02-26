import SwiftUI

struct SignInButton: View {
    let brandName: String
    let icon: String
    let action: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var brandColor: Color {
        switch brandName.lowercased() {
        case "apple":
            return colorScheme == .dark ? .white : .black
        case "google":
            return Color(red: 66/255, green: 133/255, blue: 244/255)
        default:
            return DesignSystem.Colors.primary
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.medium) {
                Image(systemName: icon)
                    .imageScale(.medium)
                Text("Sign in with \(brandName)")
                    .font(DesignSystem.Typography.headlineFont(size: .body))
            }
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.medium)
            .background(brandColor.opacity(0.1))
            .foregroundColor(brandColor)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                    .stroke(brandColor.opacity(0.3), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: DesignSystem.Spacing.large) {
        SignInButton(
            brandName: "Apple",
            icon: "apple.logo"
        ) {
            print("Apple sign in tapped")
        }
        
        SignInButton(
            brandName: "Google",
            icon: "g.circle.fill"
        ) {
            print("Google sign in tapped")
        }
    }
    .padding()
    .background(DesignSystem.Colors.background)
} 