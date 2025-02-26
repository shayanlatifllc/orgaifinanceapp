import SwiftUI

struct ContentSpacingModifier: ViewModifier {
    let navigationTitleDisplayMode: NavigationBarItem.TitleDisplayMode
    
    // Standard iOS spacing metrics
    private enum Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32
    }
    
    private var topPadding: CGFloat {
        switch navigationTitleDisplayMode {
        case .large:
            return Spacing.extraLarge + Spacing.medium // 48pt for large titles
        case .inline:
            return Spacing.extraLarge // 32pt for inline titles
        default:
            return Spacing.large // 24pt for other cases
        }
    }
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, Spacing.medium)
            .padding(.top, topPadding)
            .padding(.bottom, Spacing.large)
    }
}

extension View {
    func contentSpacing(navigationTitleDisplayMode: NavigationBarItem.TitleDisplayMode = .large) -> some View {
        modifier(ContentSpacingModifier(navigationTitleDisplayMode: navigationTitleDisplayMode))
    }
} 