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
git clone https://github.com/shayanlatifllc/orgaifinanceapp.git
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
- macOS Sonoma 14.0+

### Building
1. Open `orgaifinanceapp.xcodeproj`
2. Select your target device (iOS 17.0 or later)
3. Build the project (⌘ + B)

### Testing
Run the test suite:
```bash
⌘ + U
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/YourFeature`)
3. Commit your changes (`git commit -m 'feat: add some feature'`)
4. Push to the branch (`git push origin feature/YourFeature`)
5. Open a Pull Request

## Commit Convention

We follow the conventional commits specification:

- `feat:` New features
- `fix:` Bug fixes
- `docs:` Documentation changes
- `style:` Code style changes (formatting, etc)
- `refactor:` Code refactoring
- `test:` Test updates
- `chore:` Routine tasks, maintenance

## License and Copyright

Copyright © 2024 Shayan Latif. All rights reserved.

This software is proprietary and confidential. Unauthorized copying, modification, distribution, or use of this software, via any medium, is strictly prohibited.

### Usage Restrictions:
- Viewing the public repository is permitted
- Forking, copying, or reusing any part of the codebase is not permitted
- Commercial use is strictly prohibited
- Modification and redistribution are not allowed

### Exceptions:
- Screenshots and descriptions may be used for educational or portfolio purposes
- Public documentation may be referenced with proper attribution

## Contact

Shayan Latif - [@shayanlatifllc](https://github.com/shayanlatifllc)

Project Link: [https://github.com/shayanlatifllc/orgaifinanceapp](https://github.com/shayanlatifllc/orgaifinanceapp)

## Acknowledgments

- SwiftUI for the modern UI framework
- SwiftData for persistence
- Apple's SF Symbols for iconography
- All contributors who help improve this project 