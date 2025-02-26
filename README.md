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

## Version Management

### Version Numbering
We follow Semantic Versioning (SemVer):
- Format: `MAJOR.MINOR.PATCH` (e.g., 1.0.0)
- MAJOR: Breaking changes
- MINOR: New features, backward compatible
- PATCH: Bug fixes, backward compatible

### Release Process
1. **Preparation**
   ```bash
   # Create release branch
   git checkout -b release/v1.0.0
   
   # Update version numbers
   # - In Xcode: Update the version and build numbers
   # - Update CHANGELOG.md
   ```

2. **Testing**
   - Run full test suite
   - Perform beta testing through TestFlight
   - Address feedback and bug fixes

3. **App Store Submission**
   - Archive build in Xcode
   - Submit through App Store Connect
   - Monitor review process

4. **Release**
   ```bash
   # Merge release branch
   git checkout main
   git merge release/v1.0.0
   
   # Tag release
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```

### Working on Next Version
1. Create feature branches from main
   ```bash
   git checkout -b feature/new-feature
   ```

2. Develop and test new features

3. Merge feature branches through pull requests

4. Create new release when ready
   ```bash
   git checkout -b release/v1.1.0
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

## Planned Security & Compliance Features

### Infrastructure Security
- AWS-based secure cloud infrastructure with separate environments
- Network segmentation based on asset sensitivity
- TLS 1.2+ encryption for data-in-transit
- Encryption for data-at-rest
- Robust monitoring and alerting system
- Comprehensive audit trails and logging

### Access Control & Authentication
- Role-based access control (RBAC)
- Mandatory 2FA for all critical assets
- Strict access management for production assets
- No BYOD policy for sensitive operations

### Development Security
- Defined CI/CD process for code changes
- Mandatory code review and approval process
- Automated vulnerability scanning
- Pre-deployment testing requirements
- Independent security audits and pen-testing

### Data Protection
- Consumer consent management system
- Data minimization and retention policies
- Compliance with privacy laws
- No selling of consumer data
- Secure API data handling

### Security Operations
- Documented information security policies
- Incident response procedures
- Employee security awareness training
- Vendor management process
- Regular security assessments
- Background checks for employees

### Endpoint Security
- Endpoint protection against malware
- Regular vulnerability scanning
- Asset discovery and management
- Automated patch management

## Contact

Shayan Latif - [@shayanlatifllc](https://github.com/shayanlatifllc)

Project Link: [https://github.com/shayanlatifllc/orgaifinanceapp](https://github.com/shayanlatifllc/orgaifinanceapp)

## Acknowledgments

- SwiftUI for the modern UI framework
- SwiftData for persistence
- Apple's SF Symbols for iconography
- All contributors who help improve this project 