import SwiftUI

struct MainTabView: View {
    @AppStorage("selectedTab") private var selectedTab: TabBarItem = .home
    @State private var previousTab: TabBarItem = .home
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Content Views
                Group {
                    switch selectedTab {
                    case .home:
                        DashboardView()
                    case .activity:
                        ActivityView()
                    case .account:
                        AccountView()
                    case .settings:
                        SettingsView()
                    }
                }
                .transition(.opacity.animation(DesignSystem.Animation.snappy))
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 74)
                }
                
                // Custom Tab Bar
                VStack(spacing: 0) {
                    Divider()
                    CustomTabBar(selectedTab: $selectedTab)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            previousTab = oldValue
            
            // Add haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .soft)
            generator.impactOccurred(intensity: 0.5)
        }
    }
}

#Preview {
    MainTabView()
        .preferredColorScheme(.dark)
} 