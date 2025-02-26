import SwiftUI
import SwiftData

// MARK: - Profile Section
private struct ProfileSection: View {
    @Binding var username: String
    @Binding var editingUsername: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
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
            .background {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                    .fill(DesignSystem.Colors.secondaryBackground)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.medium)
    }
}

// MARK: - Display Section
private struct DisplaySection: View {
    @EnvironmentObject private var theme: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            Text("Display")
                .font(DesignSystem.Typography.headlineFont(size: .title3))
                .foregroundStyle(DesignSystem.Colors.primary)
                .padding(.horizontal, DesignSystem.Spacing.medium)
            
            VStack(spacing: 1) {
                // Theme Picker
                HStack {
                    Label("Appearance", systemImage: "paintbrush.fill")
                        .font(DesignSystem.Typography.bodyFont(size: .body))
                    
                    Spacer()
                    
                    Picker("", selection: $theme.selectedTheme) {
                        ForEach(OFTheme.allCases, id: \.self) { theme in
                            Text(theme.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }
                .padding(DesignSystem.Spacing.medium)
                .background(DesignSystem.Colors.secondaryBackground)
                
                // Font Size Control
                HStack {
                    Label("Text Size", systemImage: "textformat.size")
                        .font(DesignSystem.Typography.bodyFont(size: .body))
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        ForEach([OFFontSize.caption, .body, .title3, .title], id: \.self) { size in
                            Button {
                                theme.customFontSize = size
                            } label: {
                                Text("Aa")
                                    .font(.system(size: size.size))
                                    .foregroundColor(theme.customFontSize == size ?
                                        DesignSystem.Colors.primary : .primary)
                            }
                        }
                    }
                }
                .padding(DesignSystem.Spacing.medium)
                .background(DesignSystem.Colors.secondaryBackground)
            }
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous))
        }
        .padding(.horizontal, DesignSystem.Spacing.medium)
    }
}

// MARK: - App Settings Section
private struct AppSettingsSection: View {
    @Binding var showingResetConfirmation: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            Text("App Settings")
                .font(DesignSystem.Typography.headlineFont(size: .title3))
                .foregroundStyle(DesignSystem.Colors.primary)
                .padding(.horizontal, DesignSystem.Spacing.medium)
            
            VStack(spacing: 1) {
                // Reset Onboarding Button
                Button {
                    showingResetConfirmation = true
                } label: {
                    HStack {
                        Label("Reset Onboarding", systemImage: "arrow.clockwise")
                            .font(DesignSystem.Typography.bodyFont(size: .body))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    .padding(DesignSystem.Spacing.medium)
                }
                .buttonStyle(.plain)
            }
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous))
        }
        .padding(.horizontal, DesignSystem.Spacing.medium)
    }
}

// MARK: - About Section
private struct AboutSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
            Text("About")
                .font(DesignSystem.Typography.headlineFont(size: .title3))
                .foregroundStyle(DesignSystem.Colors.primary)
                .padding(.horizontal, DesignSystem.Spacing.medium)
            
            VStack(spacing: 1) {
                InfoRow(title: "Version", value: "1.0.0")
                InfoRow(title: "Build", value: "1")
            }
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous))
        }
        .padding(.horizontal, DesignSystem.Spacing.medium)
    }
}

private struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(DesignSystem.Typography.bodyFont(size: .body))
            Spacer()
            Text(value)
                .font(DesignSystem.Typography.bodyFont(size: .body))
                .foregroundStyle(.secondary)
        }
        .padding(DesignSystem.Spacing.medium)
        .background(DesignSystem.Colors.secondaryBackground)
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
                VStack(spacing: DesignSystem.Spacing.xLarge) {
                    ProfileSection(username: $username, editingUsername: $editingUsername)
                    DisplaySection()
                    AppSettingsSection(showingResetConfirmation: $showingResetConfirmation)
                    AboutSection()
                }
                .padding(.vertical, DesignSystem.Spacing.large)
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