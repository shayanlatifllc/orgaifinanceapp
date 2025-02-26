import SwiftUI

// MARK: - Theme Configuration
enum OFTheme: String, CaseIterable {
    case system, light, dark
}

// MARK: - Typography Scale
enum OFFontSize: Int, CaseIterable {
    case caption2
    case caption
    case footnote
    case subheadline
    case body
    case headline
    case title3
    case title2
    case title
    case largeTitle
    
    var size: CGFloat {
        switch self {
        case .caption2: return 11
        case .caption: return 12
        case .footnote: return 13
        case .subheadline: return 15
        case .body: return 17
        case .headline: return 17
        case .title3: return 20
        case .title2: return 22
        case .title: return 28
        case .largeTitle: return 34
        }
    }
}

// MARK: - Design System
struct DesignSystem {
    // MARK: - Colors
    struct Colors {
        // Base Colors
        static let primary = Color("FinancePrimary")
        static let secondary = Color("FinanceSecondary")
        static let background = Color("AdaptiveBackground")
        static let secondaryBackground = Color("SecondaryBackground")
        
        // Semantic Colors
        static let success = Color.green
        static let error = Color.red
        static let warning = Color.orange
        static let info = Color.blue
        
        // Text Colors
        static let textPrimary = primary
        static let textSecondary = secondary
        static let textTertiary = Color.gray.opacity(0.6)
        
        // Shadow Colors
        static let shadowLight = Color.black.opacity(0.1)
        static let shadowMedium = Color.black.opacity(0.15)
        static let shadowDark = Color.black.opacity(0.2)
    }
    
    // MARK: - Typography
    struct Typography {
        static func headlineFont(size: OFFontSize) -> Font {
            .system(size: size.size, weight: .semibold, design: .rounded)
        }
        
        static func bodyFont(size: OFFontSize) -> Font {
            .system(size: size.size, weight: .regular, design: .rounded)
        }
        
        static let largeTitle = headlineFont(size: .largeTitle)
        static let title = headlineFont(size: .title)
        static let headline = headlineFont(size: .headline)
        static let body = bodyFont(size: .body)
        static let subheadline = bodyFont(size: .subheadline)
        static let footnote = bodyFont(size: .footnote)
        static let caption = bodyFont(size: .caption)
        static let caption2 = bodyFont(size: .caption2)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xxxSmall: CGFloat = 2
        static let xxSmall: CGFloat = 4
        static let xSmall: CGFloat = 6
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let xLarge: CGFloat = 32
        static let xxLarge: CGFloat = 40
        static let xxxLarge: CGFloat = 48
    }
    
    // MARK: - Layout
    struct Layout {
        static let screenEdgePadding: CGFloat = 16
        static let contentSpacing: CGFloat = 16
        static let cardPadding: CGFloat = 16
        static let listItemSpacing: CGFloat = 8
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xLarge: CGFloat = 20
        static let circle: CGFloat = 9999
    }
    
    // MARK: - Shadows
    struct Shadows {
        struct Properties {
            let color: Color
            let radius: CGFloat
            let x: CGFloat
            let y: CGFloat
            
            var asViewModifier: some ViewModifier {
                ShadowModifier(color: color, radius: radius, x: x, y: y)
            }
        }
        
        static let small = Properties(
            color: Colors.shadowLight,
            radius: 4,
            x: 0,
            y: 2
        )
        
        static let medium = Properties(
            color: Colors.shadowMedium,
            radius: 8,
            x: 0,
            y: 4
        )
        
        static let large = Properties(
            color: Colors.shadowDark,
            radius: 16,
            x: 0,
            y: 8
        )
    }
    
    // MARK: - Animation
    struct Animation {
        // Standard animations
        static let `default` = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.1)
        static let quick = SwiftUI.Animation.spring(response: 0.2, dampingFraction: 0.7, blendDuration: 0.1)
        static let snappy = SwiftUI.Animation.snappy(duration: 0.2)
        
        // Specialized animations
        static let slideTransition = SwiftUI.Animation.spring(response: 0.35, dampingFraction: 0.7, blendDuration: 0.1)
        static let bouncy = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.65, blendDuration: 0.1)
        
        // Easing curves
        static let easeOut = SwiftUI.Animation.easeOut(duration: 0.2)
        static let easeIn = SwiftUI.Animation.easeIn(duration: 0.2)
        static let easeInOut = SwiftUI.Animation.easeInOut(duration: 0.25)
    }
    
    // MARK: - Icons
    struct Icons {
        // Navigation
        static let home = "house.fill"
        static let activity = "chart.bar.fill"
        static let settings = "gearshape.fill"
        
        // Actions
        static let add = "plus"
        static let close = "xmark.circle.fill"
        static let back = "chevron.left"
        static let forward = "chevron.right"
        
        // Transaction Types
        static let income = "arrow.down.circle.fill"
        static let expense = "arrow.up.circle.fill"
        static let transfer = "arrow.left.arrow.right.circle.fill"
        
        // Account Types
        static let cash = "banknote.fill"
    }
    
    // MARK: - Cash Styling
    struct Cash {
        static let icon = Icons.cash
        static let backgroundOpacity = 0.1
        static let strokeOpacity = 0.3
        static let color = Colors.success
        
        static var background: Color {
            color.opacity(backgroundOpacity)
        }
        
        static var stroke: Color {
            color.opacity(strokeOpacity)
        }
    }
}

// MARK: - Shadow Modifier
private struct ShadowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    
    func body(content: Content) -> some View {
        content.shadow(
            color: color,
            radius: radius,
            x: x,
            y: y
        )
    }
}

// MARK: - View Extensions
extension View {
    func primaryCard() -> some View {
        self.padding(DesignSystem.Layout.cardPadding)
            .background {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                    .fill(DesignSystem.Colors.secondaryBackground)
            }
    }
    
    func primaryButton() -> some View {
        self.padding(.vertical, DesignSystem.Spacing.medium)
            .padding(.horizontal, DesignSystem.Spacing.large)
            .background {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                    .fill(DesignSystem.Colors.primary)
            }
            .foregroundStyle(.white)
    }
    
    func applyShadow(_ shadow: DesignSystem.Shadows.Properties) -> some View {
        self.modifier(shadow.asViewModifier)
    }
} 