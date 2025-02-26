//
//  orgaifinanceappApp.swift
//  orgaifinanceapp
//
//  Created by Shayan Latif on 2/23/25.
//

import SwiftUI
import SwiftData

@main
struct orgaifinanceappApp: App {
    @StateObject private var themeManager = ThemeManager()
    @State private var showWelcomeScreen = false
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Transaction.self,
            Account.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    private func shouldShowWelcomeScreen() -> Bool {
        switch AppConfig.welcomeScreenMode {
        case .firstTimeOnly:
            return !UserDefaults.standard.bool(forKey: AppConfig.UserDefaultsKeys.hasCompletedOnboarding)
        case .everyTime:
            return true
        case .never:
            return false
        }
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                MainTabView()
                    .modelContainer(sharedModelContainer)
                    .environmentObject(themeManager)
                    .environmentObject(TransactionViewModel(modelContext: sharedModelContainer.mainContext))
                    .preferredColorScheme(themeManager.currentColorScheme)
                
                if showWelcomeScreen {
                    WelcomeView(
                        isPresented: $showWelcomeScreen
                    )
                    .transition(.move(edge: .bottom))
                    .environmentObject(themeManager)
                }
            }
            .onAppear {
                showWelcomeScreen = shouldShowWelcomeScreen()
            }
        }
    }
}

