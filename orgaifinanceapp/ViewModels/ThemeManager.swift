import SwiftUI

class ThemeManager: ObservableObject {
    @AppStorage("selectedTheme") var selectedTheme: OFTheme = .system
    @AppStorage("customFontSize") var customFontSize: OFFontSize = .body
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    
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
} 