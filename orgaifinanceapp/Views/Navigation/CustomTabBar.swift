import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: TabBarItem
    @Namespace private var namespace
    @Environment(\.colorScheme) private var colorScheme
    
    private var backgroundColor: Color {
        colorScheme == .dark ? 
            DesignSystem.Colors.secondaryBackground : 
            DesignSystem.Colors.secondaryBackground
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach([TabBarItem.home, .activity, .account, .settings], id: \.self) { tab in
                TabBarButton(
                    tab: tab,
                    selectedTab: $selectedTab,
                    namespace: namespace
                )
            }
        }
        .padding(.vertical, 8)
        .background {
            Rectangle()
                .fill(backgroundColor)
                .ignoresSafeArea(edges: .bottom)
        }
        .animation(DesignSystem.Animation.snappy, value: selectedTab)
    }
}

struct TabBarButton: View {
    let tab: TabBarItem
    @Binding var selectedTab: TabBarItem
    let namespace: Namespace.ID
    @Environment(\.colorScheme) private var colorScheme
    
    private var unselectedColor: Color {
        colorScheme == .dark ? .gray.opacity(0.7) : .gray.opacity(0.6)
    }
    
    private var selectionBackgroundOpacity: Double {
        colorScheme == .dark ? 0.15 : 0.1
    }
    
    var body: some View {
        Button {
            if selectedTab != tab {
                withAnimation(DesignSystem.Animation.snappy) {
                    selectedTab = tab
                }
                
                // Haptic feedback
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred(intensity: 0.4)
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.iconName)
                    .font(.system(size: 22, weight: .semibold))
                    .symbolEffect(.bounce.up.byLayer, value: selectedTab == tab)
                    .contentTransition(.symbolEffect(.replace.downUp))
                
                if selectedTab == tab {
                    Text(tab.title)
                        .font(DesignSystem.Typography.caption2)
                        .fontWeight(.medium)
                        .transition(.push(from: .bottom).combined(with: .opacity))
                }
            }
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .foregroundStyle(selectedTab == tab ? tab.color : unselectedColor)
            .background {
                if selectedTab == tab {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium, style: .continuous)
                        .fill(tab.color.opacity(selectionBackgroundOpacity))
                        .matchedGeometryEffect(id: "TAB", in: namespace, properties: .frame)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack {
        Spacer()
        CustomTabBar(selectedTab: .constant(.home))
            .padding(.bottom, 34)
            .preferredColorScheme(.light)
        
        CustomTabBar(selectedTab: .constant(.home))
            .padding(.bottom, 34)
            .preferredColorScheme(.dark)
    }
} 