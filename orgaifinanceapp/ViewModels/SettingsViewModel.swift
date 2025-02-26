import SwiftUI

final class SettingsViewModel: ObservableObject {
    // MARK: - Properties
    
    @AppStorage("isDarkMode") var isDarkMode: Bool = false {
        willSet {
            objectWillChange.send()
        }
    }
    
    @AppStorage(AppConfig.UserDefaultsKeys.hasCompletedOnboarding) var hasCompletedOnboarding: Bool = false {
        willSet {
            objectWillChange.send()
        }
    }
    
    // MARK: - Actions
    
    func toggleDarkMode() {
        withAnimation {
            isDarkMode.toggle()
        }
    }
    
    func resetOnboarding() {
        hasCompletedOnboarding = false
    }
    
    // MARK: - App Information
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
} 