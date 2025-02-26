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

## License

This project is licensed under the MIT License:

```
MIT License

Copyright (c) 2024 Shayan Latif

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## Contact

Shayan Latif - [@shayanlatifllc](https://github.com/shayanlatifllc)

Project Link: [https://github.com/shayanlatifllc/orgaifinanceapp](https://github.com/shayanlatifllc/orgaifinanceapp)

## Acknowledgments

- SwiftUI for the modern UI framework
- SwiftData for persistence
- Apple's SF Symbols for iconography
- All contributors who help improve this project 