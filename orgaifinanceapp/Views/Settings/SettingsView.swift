import SwiftUI
import SwiftData

// MARK: - Profile Section
private struct ProfileSection: View {
    @Binding var username: String
    @Binding var editingUsername: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.small) {
            HStack(spacing: DesignSystem.Spacing.medium) {
                Circle()
                    .fill(DesignSystem.Colors.primary.opacity(0.1))
                    .frame(width: 60, height: 60)
                    .overlay {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(DesignSystem.Colors.primary)
                    }
                
                VStack(alignment: .leading, spacing: 4) {
                    if editingUsername {
                        TextField("Username", text: $username)
                            .textFieldStyle(.plain)
                            .font(DesignSystem.Typography.headlineFont(size: .title3))
                    } else {
                        Text(username)
                            .font(DesignSystem.Typography.headlineFont(size: .title3))
                    }
                    Text("Personal Account")
                        .font(DesignSystem.Typography.bodyFont(size: .footnote))
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Button {
                    withAnimation {
                        editingUsername.toggle()
                    }
                } label: {
                    Image(systemName: editingUsername ? "checkmark.circle.fill" : "pencil")
                        .font(.system(size: 20))
                        .foregroundStyle(editingUsername ? .green : DesignSystem.Colors.primary)
                }
            }
            .padding(DesignSystem.Spacing.medium)
            .background(Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                    .stroke(DesignSystem.Colors.primary.opacity(0.1), lineWidth: 1)
            )
        }
        .padding(.horizontal, DesignSystem.Spacing.medium)
    }
}

// MARK: - Collapsible Section
private struct CollapsibleSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    @State private var isExpanded: Bool = true
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(DesignSystem.Animation.default) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: icon)
                        .foregroundStyle(DesignSystem.Colors.primary)
                        .frame(width: 24)
                    
                    Text(title)
                        .font(DesignSystem.Typography.bodyFont(size: .subheadline))
                        .foregroundStyle(DesignSystem.Colors.primary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(DesignSystem.Colors.primary)
                }
                .padding(.vertical, DesignSystem.Spacing.medium)
                .padding(.horizontal, DesignSystem.Spacing.medium)
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                content
                    .padding(.leading, DesignSystem.Spacing.medium)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            Divider()
                .padding(.horizontal, DesignSystem.Spacing.medium)
        }
    }
}

// MARK: - Settings Row
private struct SettingsRow<Content: View>: View {
    let icon: String
    let title: String
    let content: Content
    let showDivider: Bool
    
    init(icon: String, title: String, showDivider: Bool = true, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.title = title
        self.showDivider = showDivider
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Label {
                    Text(title)
                        .font(DesignSystem.Typography.bodyFont(size: .body))
                } icon: {
                    Image(systemName: icon)
                        .foregroundStyle(DesignSystem.Colors.primary)
                        .frame(width: 24)
                }
                
                Spacer()
                
                content
            }
            .padding(.vertical, DesignSystem.Spacing.medium)
            .padding(.horizontal, DesignSystem.Spacing.medium)
            
            if showDivider {
                Divider()
                    .padding(.leading, 64)
                    .padding(.trailing, DesignSystem.Spacing.medium)
            }
        }
    }
}

// MARK: - Main Settings View
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var theme: ThemeManager
    @AppStorage("username") private var username: String = "Guest"
    @State private var showingResetConfirmation = false
    @State private var editingUsername = false
    @State private var error: AppError?
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: DesignSystem.Spacing.medium) {
                    ProfileSection(username: $username, editingUsername: $editingUsername)
                        .padding(.top, DesignSystem.Spacing.medium)
                    
                    // Display Section
                    CollapsibleSection(title: "Display", icon: "paintbrush") {
                        SettingsRow(icon: "circle.lefthalf.filled", title: "Appearance", showDivider: false) {
                            Picker("", selection: $theme.selectedTheme) {
                                ForEach(OFTheme.allCases, id: \.self) { theme in
                                    Text(theme.rawValue.capitalized)
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 180)
                        }
                    }
                    
                    // App Settings Section
                    CollapsibleSection(title: "App Settings", icon: "gearshape") {
                        SettingsRow(icon: "arrow.clockwise", title: "Reset Onboarding", showDivider: false) {
                            Button {
                                showingResetConfirmation = true
                            } label: {
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    // Security Section
                    CollapsibleSection(title: "Security", icon: "lock.shield") {
                        VStack(spacing: 0) {
                            SettingsRow(icon: "lock", title: "App Lock") {
                                Toggle("", isOn: .constant(false))
                                    .tint(DesignSystem.Colors.primary)
                            }
                            
                            SettingsRow(icon: "faceid", title: "Face ID", showDivider: false) {
                                Toggle("", isOn: .constant(false))
                                    .tint(DesignSystem.Colors.primary)
                            }
                        }
                    }
                    
                    // About Section
                    CollapsibleSection(title: "About", icon: "info.circle") {
                        VStack(spacing: 0) {
                            SettingsRow(icon: "number", title: "Version") {
                                Text("1.0.0")
                                    .font(DesignSystem.Typography.bodyFont(size: .body))
                                    .foregroundStyle(.secondary)
                            }
                            
                            SettingsRow(icon: "hammer", title: "Build", showDivider: false) {
                                Text("1")
                                    .font(DesignSystem.Typography.bodyFont(size: .body))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    // Support Section
                    CollapsibleSection(title: "Support", icon: "questionmark.circle") {
                        VStack(spacing: 0) {
                            SettingsRow(icon: "book", title: "Help Center") {
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }
                            
                            SettingsRow(icon: "envelope", title: "Contact Us", showDivider: false) {
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding(.vertical, DesignSystem.Spacing.medium)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Reset Onboarding", isPresented: $showingResetConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetOnboarding()
                }
            } message: {
                Text("This will delete all accounts and reset the app to its initial state. This action cannot be undone.")
            }
            .handleError($error)
        }
    }
    
    private func resetOnboarding() {
        do {
            // Reset onboarding state
            UserDefaults.standard.set(false, forKey: AppConfig.UserDefaultsKeys.hasCompletedOnboarding)
            
            // Delete all accounts
            try deleteAllAccounts(from: modelContext)
        } catch {
            self.error = .invalidOperation
        }
    }
    
    private func deleteAllAccounts(from context: ModelContext) throws {
        // Fetch all accounts
        let descriptor = FetchDescriptor<Account>()
        let accounts = try context.fetch(descriptor)
        
        // Delete each account
        for account in accounts {
            context.delete(account)
        }
        
        // Save changes
        try context.save()
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(ThemeManager())
    }
} 