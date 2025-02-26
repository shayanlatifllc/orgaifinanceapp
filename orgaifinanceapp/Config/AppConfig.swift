import Foundation

/// Configuration settings for the Orgai Finance app
enum AppConfig {
    /// Welcome Screen Display Mode
    enum WelcomeScreenMode {
        /// Shows welcome screen only on first launch
        case firstTimeOnly
        /// Shows welcome screen on every app launch
        case everyTime
        /// Never shows welcome screen
        case never
    }
    
    // MARK: - Welcome Screen Configuration
    
    /// Controls when the welcome screen is displayed
    ///
    /// Options:
    /// - `.firstTimeOnly`: Shows only on first app launch (production default)
    /// - `.everyTime`: Shows every time the app launches (development/testing)
    /// - `.never`: Never shows the welcome screen
    ///
    /// Usage:
    /// ```swift
    /// // For production (first-time only):
    /// static let welcomeScreenMode: WelcomeScreenMode = .firstTimeOnly
    ///
    /// // For development/testing (every time):
    /// static let welcomeScreenMode: WelcomeScreenMode = .everyTime
    /// ```
    static let welcomeScreenMode: WelcomeScreenMode = .everyTime
    
    // MARK: - UserDefaults Keys
    
    /// UserDefaults keys used throughout the app
    struct UserDefaultsKeys {
        /// Key for tracking if user has completed onboarding
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
    }
} 