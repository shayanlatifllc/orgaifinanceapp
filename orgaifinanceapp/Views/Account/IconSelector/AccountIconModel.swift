import SwiftUI

struct AccountIconCategory: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icons: [AccountIcon]
    
    static let categories: [AccountIconCategory] = [
        AccountIconCategory(name: "Finance", icons: [
            AccountIcon(name: "Money", systemName: "banknote"),
            AccountIcon(name: "Credit Card", systemName: "creditcard"),
            AccountIcon(name: "Wallet", systemName: "wallet.pass"),
            AccountIcon(name: "Bank", systemName: "building.columns"),
            AccountIcon(name: "Safe", systemName: "lock.square"),
            AccountIcon(name: "Chart", systemName: "chart.line.uptrend.xyaxis"),
            AccountIcon(name: "Dollar", systemName: "dollarsign.circle"),
            AccountIcon(name: "Coins", systemName: "centsign.circle"),
        ]),
        AccountIconCategory(name: "Business", icons: [
            AccountIcon(name: "Building", systemName: "building.2"),
            AccountIcon(name: "Briefcase", systemName: "briefcase"),
            AccountIcon(name: "Store", systemName: "storefront"),
            AccountIcon(name: "Cart", systemName: "cart"),
            AccountIcon(name: "Bag", systemName: "bag"),
            AccountIcon(name: "Box", systemName: "shippingbox"),
            AccountIcon(name: "Document", systemName: "doc.text"),
            AccountIcon(name: "Folder", systemName: "folder"),
        ]),
        AccountIconCategory(name: "Personal", icons: [
            AccountIcon(name: "Person", systemName: "person.circle"),
            AccountIcon(name: "House", systemName: "house"),
            AccountIcon(name: "Car", systemName: "car"),
            AccountIcon(name: "Gift", systemName: "gift"),
            AccountIcon(name: "Heart", systemName: "heart"),
            AccountIcon(name: "Star", systemName: "star"),
            AccountIcon(name: "Book", systemName: "book"),
            AccountIcon(name: "Phone", systemName: "iphone"),
        ]),
        AccountIconCategory(name: "Savings", icons: [
            AccountIcon(name: "Piggy Bank", systemName: "leaf"),
            AccountIcon(name: "Target", systemName: "target"),
            AccountIcon(name: "Clock", systemName: "clock"),
            AccountIcon(name: "Calendar", systemName: "calendar"),
            AccountIcon(name: "Lock", systemName: "lock"),
            AccountIcon(name: "Key", systemName: "key"),
            AccountIcon(name: "Shield", systemName: "shield"),
            AccountIcon(name: "Flag", systemName: "flag"),
        ])
    ]
}

struct AccountIcon: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let systemName: String
} 