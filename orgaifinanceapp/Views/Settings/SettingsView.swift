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
    @EnvironmentObject private var theme: ThemeManager
    let title: String
    let icon: String
    let content: Content
    let isEditing: Bool
    let onMove: (() -> Void)?
    let tab: SettingsTab
    
    init(title: String, icon: String, tab: SettingsTab, isEditing: Bool = false, onMove: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
        self.isEditing = isEditing
        self.onMove = onMove
        self.tab = tab
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                if !isEditing {
                    withAnimation(DesignSystem.Animation.default) {
                        theme.toggleTabExpansion(tab)
                    }
                }
            } label: {
                HStack {
                    if isEditing {
                        Image(systemName: "line.3.horizontal")
                            .foregroundStyle(.secondary)
                            .frame(width: 24)
                    }
                    
                    Image(systemName: icon)
                        .foregroundStyle(DesignSystem.Colors.primary)
                        .frame(width: 24)
                    
                    Text(title)
                        .font(DesignSystem.Typography.bodyFont(size: .subheadline))
                        .foregroundStyle(DesignSystem.Colors.primary)
                    
                    Spacer()
                    
                    if !isEditing {
                        Image(systemName: theme.isTabExpanded(tab) ? "chevron.up" : "chevron.down")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(DesignSystem.Colors.primary)
                    }
                }
                .padding(.vertical, DesignSystem.Spacing.medium)
                .padding(.horizontal, DesignSystem.Spacing.medium)
                .background(isEditing ? DesignSystem.Colors.secondaryBackground.opacity(0.3) : Color.clear)
            }
            .buttonStyle(.plain)
            
            if theme.isTabExpanded(tab) && !isEditing {
                content
                    .padding(.leading, DesignSystem.Spacing.medium)
                    .transition(.opacity)
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

// MARK: - Edit Mode Button
private struct EditModeButton: View {
    @EnvironmentObject private var theme: ThemeManager
    
    var body: some View {
        Button {
            theme.toggleEditMode()
        } label: {
            HStack {
                Spacer()
                
                Text(theme.isEditingTabs ? "Done" : "Edit")
                    .font(DesignSystem.Typography.bodyFont(size: .body))
                    .foregroundStyle(DesignSystem.Colors.primary)
                
                Spacer()
            }
            .padding(.vertical, DesignSystem.Spacing.medium)
            .background(Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                    .stroke(DesignSystem.Colors.primary.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, DesignSystem.Spacing.medium)
        .padding(.vertical, DesignSystem.Spacing.small)
    }
}

// MARK: - Reset Order Button
private struct ResetOrderButton: View {
    @EnvironmentObject private var theme: ThemeManager
    
    var body: some View {
        Button {
            theme.resetTabOrder()
        } label: {
            HStack {
                Spacer()
                
                Text("Reset Order")
                    .font(DesignSystem.Typography.bodyFont(size: .body))
                    .foregroundStyle(DesignSystem.Colors.primary)
                
                Spacer()
            }
            .padding(.vertical, DesignSystem.Spacing.medium)
            .background(Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.large, style: .continuous)
                    .stroke(DesignSystem.Colors.primary.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, DesignSystem.Spacing.medium)
        .padding(.vertical, DesignSystem.Spacing.small)
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
    @State private var draggedItem: SettingsTab?
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: DesignSystem.Spacing.medium) {
                    ProfileSection(username: $username, editingUsername: $editingUsername)
                        .padding(.top, DesignSystem.Spacing.medium)
                    
                    // Tabs
                    ForEach(theme.tabOrder) { tab in
                        tabView(for: tab)
                            .opacity(draggedItem == tab ? 0.5 : 1)
                            .onDrag {
                                if theme.isEditingTabs {
                                    self.draggedItem = tab
                                    return NSItemProvider(object: tab.id as NSString)
                                } else {
                                    return NSItemProvider()
                                }
                            }
                            .onDrop(of: [.text], delegate: DropViewDelegate(
                                item: tab,
                                items: $theme.tabOrder,
                                draggedItem: $draggedItem,
                                onDropEnded: {
                                    theme.saveTabOrder()
                                }
                            ))
                    }
                    
                    if theme.isEditingTabs {
                        ResetOrderButton()
                            .padding(.top, DesignSystem.Spacing.small)
                    }
                    
                    Spacer(minLength: DesignSystem.Spacing.large)
                    
                    // Edit Mode Button
                    EditModeButton()
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
    
    @ViewBuilder
    private func tabView(for tab: SettingsTab) -> some View {
        switch tab {
        case .display:
            CollapsibleSection(title: tab.rawValue, icon: tab.icon, tab: tab, isEditing: theme.isEditingTabs) {
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
            
        case .appSettings:
            CollapsibleSection(title: tab.rawValue, icon: tab.icon, tab: tab, isEditing: theme.isEditingTabs) {
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
            
        case .security:
            CollapsibleSection(title: tab.rawValue, icon: tab.icon, tab: tab, isEditing: theme.isEditingTabs) {
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
            
        case .about:
            CollapsibleSection(title: tab.rawValue, icon: tab.icon, tab: tab, isEditing: theme.isEditingTabs) {
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
            
        case .support:
            CollapsibleSection(title: tab.rawValue, icon: tab.icon, tab: tab, isEditing: theme.isEditingTabs) {
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

// MARK: - Drop Delegate
struct DropViewDelegate: DropDelegate {
    let item: SettingsTab
    @Binding var items: [SettingsTab]
    @Binding var draggedItem: SettingsTab?
    let onDropEnded: () -> Void
    
    func performDrop(info: DropInfo) -> Bool {
        onDropEnded()
        draggedItem = nil
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedItem = self.draggedItem else { return }
        
        if draggedItem != item {
            let from = items.firstIndex(of: draggedItem)!
            let to = items.firstIndex(of: item)!
            
            withAnimation {
                items.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
            }
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(ThemeManager())
    }
} 