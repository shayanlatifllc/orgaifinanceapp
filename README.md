# OrgAI Finance App

A modern iOS application for managing personal and business finances with real-time tracking, comprehensive reporting, and intuitive interface.

## Features

- **Account Management**
  - Personal and business account tracking
  - Asset and liability management
  - Real-time balance updates
  - Multi-currency support

- **Financial Overview**
  - Net worth calculation
  - Asset allocation visualization
  - Liability tracking
  - Trend analysis

- **User Interface**
  - Modern SwiftUI design
  - Dark mode support
  - Responsive layout
  - Animated transitions

## Technical Stack

- **Framework**: SwiftUI
- **Persistence**: SwiftData
- **Minimum iOS**: iOS 17.0
- **Architecture**: MVVM
- **Design Pattern**: Protocol-oriented programming

## Project Structure

```
orgaifinanceapp/
├── Models/
│   ├── Account.swift
│   ├── Transaction.swift
│   └── AccountInstructions.swift
├── Views/
│   ├── Account/
│   ├── Dashboard/
│   ├── Components/
│   └── Settings/
├── ViewModels/
│   ├── AddAccountViewModel.swift
│   ├── EditAccountViewModel.swift
│   └── SettingsViewModel.swift
├── Calculations/
│   └── FinancialCalculations.swift
└── Documentation/
    ├── Architecture.md
    └── TestPlan.md
```

## Getting Started

1. Clone the repository
```bash
git clone https://github.com/yourusername/orgaifinanceapp.git
```

2. Open the project in Xcode
```bash
cd orgaifinanceapp
open orgaifinanceapp.xcodeproj
```

3. Build and run the project (⌘ + R)

## Development

### Prerequisites
- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

### Building
1. Open `orgaifinanceapp.xcodeproj`
2. Select your target device
3. Build the project (⌘ + B)

### Testing
Run the test suite:
```bash
⌘ + U
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details

## Contact

Your Name - [@yourtwitter](https://twitter.com/yourtwitter)

Project Link: [https://github.com/yourusername/orgaifinanceapp](https://github.com/yourusername/orgaifinanceapp)

## Acknowledgments

- SwiftUI for the modern UI framework
- SwiftData for persistence
- Apple's SF Symbols for iconography 