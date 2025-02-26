# OrgAI Finance App Architecture

## Overview
OrgAI Finance App is a SwiftUI-based iOS application for managing personal and business finances. The app follows MVVM architecture and uses SwiftData for persistence.

## Core Components

### Models
- `Account`: Represents financial accounts with properties for name, balance, type, and category
- `Transaction`: Represents financial transactions (planned for future implementation)

### Views
- `AccountView`: Main view for displaying accounts and financial summary
  - Shows total assets, liabilities, and net worth
  - Organizes accounts by type (Personal, Business) and category
  - Implements custom UI components for consistent financial data display

### Financial Calculations
The app implements several key financial calculations:

#### Net Worth Calculation
```swift
Net Worth = Total Assets - abs(Total Liabilities)
```
- Assets: Sum of all positive balances from non-liability accounts
- Liabilities: Sum of all negative balances (stored as absolute values)

#### Account Categorization
- Personal Accounts: Checking, Savings, Credit Cards
- Business Accounts: Checking, Savings, Credit Cards
- Assets: Real Estate, Vehicles, Investments
- Liabilities: Mortgages, Loans, Credit Card Debt

### UI Components
- `SummaryBox`: Displays financial metrics with color-coded values
- `CustomDisclosureGroup`: Expandable/collapsible account sections
- `AnimatedAmountView`: Animated display of changing financial values

## Data Flow
1. SwiftData manages persistent storage of accounts
2. AccountView observes changes in the account data
3. Financial calculations are performed in real-time
4. UI updates automatically reflect data changes

## Design System
- Consistent color scheme for financial status indication
- Typography system for hierarchical information display
- Spacing and layout guidelines for uniform appearance

## Testing Strategy
- Unit tests for financial calculations
- UI tests for critical user flows
- Test data for consistent testing scenarios

## Future Enhancements
- Transaction tracking and categorization
- Budget planning and monitoring
- Financial goal setting and tracking
- Investment portfolio management
- Reports and analytics

## 1. App Structure

```mermaid
graph TD
    A[App Entry] --> B[MainTabView]
    B --> C[DashboardView]
    B --> D[ActivityView]
    B --> E[SettingsView]
    
    C --> F[Quick Actions]
    D --> G[Transaction List]
    E --> H[User Preferences]
    
    F --> I[Transaction Creation]
    G --> I
    H --> J[Theme Management]
```

## 2. Data Flow

```mermaid
graph LR
    A[User Action] --> B[ViewModel]
    B --> C[SwiftData]
    C --> D[Model]
    D --> B
    B --> E[View Update]
```

## 3. MVVM Architecture

```mermaid
graph TD
    subgraph View Layer
        A[Views] --> B[User Interface]
        B --> C[User Input]
    end
    
    subgraph ViewModel Layer
        D[Business Logic]
        E[State Management]
        F[Data Transformation]
    end
    
    subgraph Model Layer
        G[Data Models]
        H[Persistence]
        I[Business Rules]
    end
    
    C --> D
    D --> E
    E --> F
    F --> G
    G --> H
    H --> I
    I --> D
```

## 4. Authentication Flow

```mermaid
sequenceDiagram
    participant U as User
    participant V as View
    participant VM as ViewModel
    participant A as Auth Service
    
    U->>V: Tap Sign In
    V->>VM: Request Auth
    VM->>A: Authenticate
    A-->>VM: Token
    VM-->>V: Update State
    V-->>U: Show Dashboard
```

## 5. Transaction Flow

```mermaid
sequenceDiagram
    participant U as User
    participant V as View
    participant VM as ViewModel
    participant DB as SwiftData
    
    U->>V: Create Transaction
    V->>VM: Add Transaction
    VM->>DB: Save
    DB-->>VM: Confirm
    VM-->>V: Update UI
    V-->>U: Show Confirmation
```

## 6. Component Structure

```mermaid
classDiagram
    class Transaction {
        +UUID id
        +String title
        +String subtitle
        +Decimal amount
        +TransactionType type
        +String icon
        +Date date
    }
    
    class TransactionViewModel {
        -ModelContext context
        -[Transaction] transactions
        +addTransaction()
        +deleteTransaction()
        +updateFilter()
    }
    
    class ThemeManager {
        +OFTheme selectedTheme
        +OFFontSize customFontSize
        +Bool isDarkMode
    }
    
    Transaction --> TransactionViewModel
    TransactionViewModel --> ThemeManager
```

## 7. Error Handling

```mermaid
graph TD
    A[User Action] --> B{Validation}
    B -->|Valid| C[Process]
    B -->|Invalid| D[Error]
    C --> E{Success}
    E -->|Yes| F[Update UI]
    E -->|No| D
    D --> G[Show Error]
    G --> H[Recovery Action]
```

## 8. State Management

```mermaid
stateDiagram-v2
    [*] --> Loading
    Loading --> Ready
    Ready --> Processing
    Processing --> Ready
    Processing --> Error
    Error --> Ready
    Ready --> [*]
```

## 9. Design System

```mermaid
graph TD
    A[Design System] --> B[Colors]
    A --> C[Typography]
    A --> D[Spacing]
    A --> E[Components]
    
    B --> F[Primary]
    B --> G[Secondary]
    B --> H[Semantic]
    
    C --> I[Headlines]
    C --> J[Body]
    C --> K[Caption]
    
    D --> L[Layout]
    D --> M[Content]
    D --> N[Components]
    
    E --> O[Buttons]
    E --> P[Cards]
    E --> Q[Lists]
```

## 10. Testing Strategy

```mermaid
graph TD
    A[Testing] --> B[Unit Tests]
    A --> C[Integration Tests]
    A --> D[UI Tests]
    A --> E[Performance Tests]
    
    B --> F[Models]
    B --> G[ViewModels]
    B --> H[Business Logic]
    
    C --> I[Data Flow]
    C --> J[Navigation]
    
    D --> K[User Flows]
    D --> L[Accessibility]
    
    E --> M[Data Loading]
    E --> N[UI Response]
```

## 11. Deployment Flow

```mermaid
graph LR
    A[Development] --> B[Testing]
    B --> C[Staging]
    C --> D[Production]
    
    B -.-> A
    C -.-> B
    D -.-> C
```

## 12. Security Model

```mermaid
graph TD
    A[Security] --> B[Authentication]
    A --> C[Data Protection]
    A --> D[Network Security]
    
    B --> E[OAuth]
    B --> F[Biometrics]
    
    C --> G[Encryption]
    C --> H[Secure Storage]
    
    D --> I[SSL/TLS]
    D --> J[Certificate Pinning]
``` 