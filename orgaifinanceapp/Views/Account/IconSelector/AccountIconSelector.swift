import SwiftUI

struct AccountIconSelector: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedIcon: String
    @State private var selectedCategory: AccountIconCategory?
    @State private var searchText = ""
    
    private var filteredCategories: [AccountIconCategory] {
        if searchText.isEmpty {
            return AccountIconCategory.categories
        }
        
        return AccountIconCategory.categories.map { category in
            let filteredIcons = category.icons.filter { icon in
                icon.name.localizedCaseInsensitiveContains(searchText)
            }
            return AccountIconCategory(name: category.name, icons: filteredIcons)
        }.filter { !$0.icons.isEmpty }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: DesignSystem.Spacing.large) {
                    // Selected Icon Preview
                    VStack(spacing: DesignSystem.Spacing.medium) {
                        Circle()
                            .fill(DesignSystem.Colors.primary.opacity(0.1))
                            .frame(width: 80, height: 80)
                            .overlay {
                                Image(systemName: selectedIcon)
                                    .font(.system(size: 32))
                                    .foregroundStyle(DesignSystem.Colors.primary)
                            }
                        
                        Text("Selected Icon")
                            .font(DesignSystem.Typography.bodyFont(size: .caption))
                            .foregroundStyle(DesignSystem.Colors.secondary)
                    }
                    .padding(.top, DesignSystem.Spacing.large)
                    
                    // Category Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DesignSystem.Spacing.small) {
                            ForEach(AccountIconCategory.categories) { category in
                                Button {
                                    withAnimation(DesignSystem.Animation.snappy) {
                                        selectedCategory = selectedCategory == category ? nil : category
                                    }
                                } label: {
                                    Text(category.name)
                                        .font(DesignSystem.Typography.bodyFont(size: .subheadline))
                                        .padding(.horizontal, DesignSystem.Spacing.medium)
                                        .padding(.vertical, DesignSystem.Spacing.small)
                                        .background(selectedCategory == category ?
                                            DesignSystem.Colors.primary.opacity(0.1) :
                                            DesignSystem.Colors.secondaryBackground)
                                        .foregroundStyle(selectedCategory == category ?
                                            DesignSystem.Colors.primary :
                                            DesignSystem.Colors.secondary)
                                        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium))
                                }
                            }
                        }
                        .padding(.horizontal, DesignSystem.Layout.screenEdgePadding)
                    }
                    
                    // Icons Grid
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.large) {
                        ForEach(selectedCategory.map { [$0] } ?? filteredCategories) { category in
                            if !category.icons.isEmpty {
                                VStack(alignment: .leading, spacing: DesignSystem.Spacing.medium) {
                                    Text(category.name)
                                        .font(DesignSystem.Typography.bodyFont(size: .subheadline))
                                        .foregroundStyle(DesignSystem.Colors.secondary)
                                        .padding(.horizontal, DesignSystem.Layout.screenEdgePadding)
                                    
                                    let columns = Array(repeating: GridItem(.flexible(), spacing: DesignSystem.Spacing.medium), count: 4)
                                    
                                    LazyVGrid(columns: columns, spacing: DesignSystem.Spacing.medium) {
                                        ForEach(category.icons) { icon in
                                            Button {
                                                // Add haptic feedback
                                                let generator = UIImpactFeedbackGenerator(style: .light)
                                                generator.prepare()
                                                generator.impactOccurred()
                                                
                                                withAnimation(DesignSystem.Animation.snappy) {
                                                    selectedIcon = icon.systemName
                                                }
                                            } label: {
                                                VStack(spacing: DesignSystem.Spacing.small) {
                                                    Circle()
                                                        .fill(selectedIcon == icon.systemName ?
                                                            DesignSystem.Colors.primary.opacity(0.1) :
                                                            DesignSystem.Colors.secondaryBackground)
                                                        .frame(height: 60)
                                                        .overlay {
                                                            Image(systemName: icon.systemName)
                                                                .font(.system(size: 24))
                                                                .foregroundStyle(selectedIcon == icon.systemName ?
                                                                    DesignSystem.Colors.primary :
                                                                    DesignSystem.Colors.secondary)
                                                        }
                                                        .overlay {
                                                            if selectedIcon == icon.systemName {
                                                                Circle()
                                                                    .strokeBorder(DesignSystem.Colors.primary.opacity(0.3), lineWidth: 1)
                                                            }
                                                        }
                                                    
                                                    Text(icon.name)
                                                        .font(DesignSystem.Typography.bodyFont(size: .caption))
                                                        .foregroundStyle(selectedIcon == icon.systemName ?
                                                            DesignSystem.Colors.primary :
                                                            DesignSystem.Colors.secondary)
                                                        .lineLimit(1)
                                                        .minimumScaleFactor(0.8)
                                                }
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(.horizontal, DesignSystem.Layout.screenEdgePadding)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, DesignSystem.Spacing.large)
            }
            .navigationTitle("Choose Icon")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer,
                prompt: "Search icons"
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    AccountIconSelector(selectedIcon: .constant("creditcard"))
} 