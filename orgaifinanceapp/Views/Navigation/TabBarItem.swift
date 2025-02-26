import SwiftUI

enum TabBarItem: String, Hashable, RawRepresentable {
    case home = "home"
    case activity = "activity"
    case account = "account"
    case settings = "settings"
    
    var iconName: String {
        switch self {
        case .home:
            return "house.fill"
        case .activity:
            return "chart.bar.fill"
        case .account:
            return "person.circle.fill"
        case .settings:
            return "gearshape.fill"
        }
    }
    
    var title: String {
        switch self {
        case .home:
            return "Home"
        case .activity:
            return "Activity"
        case .account:
            return "Account"
        case .settings:
            return "Settings"
        }
    }
    
    var color: Color {
        return Color("FinancePrimary")
    }
} 