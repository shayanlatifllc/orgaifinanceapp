import SwiftUI

// MARK: - Settings Tab Identifier
enum SettingsTab: String, CaseIterable, Identifiable, Codable {
    case display = "Display"
    case appSettings = "App Settings"
    case security = "Security"
    case about = "About"
    case support = "Support"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .display: return "paintbrush"
        case .appSettings: return "gearshape"
        case .security: return "lock.shield"
        case .about: return "info.circle"
        case .support: return "questionmark.circle"
        }
    }
}

class ThemeManager: ObservableObject {
    @AppStorage("selectedTheme") var selectedTheme: OFTheme = .system
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    @Published var tabOrder: [SettingsTab] = SettingsTab.allCases
    @AppStorage("isEditingTabs") var isEditingTabs: Bool = false
    @Published var expandedTabs: Set<SettingsTab> = Set(SettingsTab.allCases)
    
    init() {
        // Load tab order
        if let savedOrder = UserDefaults.standard.data(forKey: "settingsTabOrder") {
            if let decodedOrder = try? JSONDecoder().decode([SettingsTab].self, from: savedOrder) {
                self.tabOrder = decodedOrder
            }
        }
        
        // Load expanded tabs state
        if let savedExpandedState = UserDefaults.standard.data(forKey: "expandedTabsState") {
            if let decodedState = try? JSONDecoder().decode([SettingsTab].self, from: savedExpandedState) {
                self.expandedTabs = Set(decodedState)
            }
        }
    }
    
    func saveTabOrder() {
        if let encoded = try? JSONEncoder().encode(tabOrder) {
            UserDefaults.standard.set(encoded, forKey: "settingsTabOrder")
        }
    }
    
    func resetTabOrder() {
        tabOrder = SettingsTab.allCases
        saveTabOrder()
    }
    
    func toggleTabExpansion(_ tab: SettingsTab) {
        if expandedTabs.contains(tab) {
            expandedTabs.remove(tab)
        } else {
            expandedTabs.insert(tab)
        }
        saveExpandedState()
    }
    
    func saveExpandedState() {
        if let encoded = try? JSONEncoder().encode(Array(expandedTabs)) {
            UserDefaults.standard.set(encoded, forKey: "expandedTabsState")
        }
    }
    
    func isTabExpanded(_ tab: SettingsTab) -> Bool {
        return expandedTabs.contains(tab)
    }
    
    var currentColorScheme: ColorScheme? {
        switch selectedTheme {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }
    
    func toggleDarkMode() {
        withAnimation {
            isDarkMode.toggle()
        }
    }
    
    func toggleEditMode() {
        withAnimation {
            isEditingTabs.toggle()
            
            // Save tab order when exiting edit mode
            if !isEditingTabs {
                saveTabOrder()
            }
        }
    }
} 