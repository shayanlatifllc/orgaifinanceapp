import SwiftUI

struct WelcomeView: View {
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage(AppConfig.UserDefaultsKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = false
    @EnvironmentObject private var theme: ThemeManager
    @Binding var isPresented: Bool
    
    private func handleSignIn(with provider: String) {
        // TODO: Implement actual authentication
        print("\(provider) sign in tapped")
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            // Only set hasCompletedOnboarding in firstTimeOnly mode
            if case .firstTimeOnly = AppConfig.welcomeScreenMode {
                hasCompletedOnboarding = true
            }
            isPresented = false
        }
    }
    
    private func dismissWelcome() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            if case .firstTimeOnly = AppConfig.welcomeScreenMode {
                hasCompletedOnboarding = true
            }
            isPresented = false
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.background
                    .ignoresSafeArea()
                
                VStack(spacing: DesignSystem.Spacing.xLarge) {
                    Spacer()
                    
                    // Logo and App Name
                    VStack(spacing: DesignSystem.Spacing.large) {
                        AppIcon(size: 80)
                            .symbolEffect(.bounce, value: theme.isDarkMode)
                        
                        VStack(spacing: DesignSystem.Spacing.small) {
                            Text("Orgai Finance")
                                .font(DesignSystem.Typography.title)
                                .foregroundColor(DesignSystem.Colors.primary)
                            
                            Text("Simplified Organized Finance")
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(DesignSystem.Colors.secondary)
                        }
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    
                    Spacer()
                    
                    // Sign in buttons
                    VStack(spacing: DesignSystem.Spacing.medium) {
                        SignInButton(
                            brandName: "Apple",
                            icon: "apple.logo"
                        ) {
                            handleSignIn(with: "Apple")
                        }
                        
                        SignInButton(
                            brandName: "Google",
                            icon: "g.circle.fill"
                        ) {
                            handleSignIn(with: "Google")
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.medium)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    
                    Spacer()
                }
                .padding(DesignSystem.Spacing.medium)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismissWelcome()
                    } label: {
                        Image(systemName: "xmark")
                            .imageScale(.large)
                            .foregroundColor(DesignSystem.Colors.primary)
                    }
                }
            }
        }
        .preferredColorScheme(theme.currentColorScheme)
    }
}

#Preview {
    WelcomeView(
        isPresented: .constant(true)
    )
    .environmentObject(ThemeManager())
} 