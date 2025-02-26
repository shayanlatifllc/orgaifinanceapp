import XCTest
@testable import orgaifinanceapp

final class OrgaiFinanceUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        // Configure launch arguments to disable animations and launch measurements
        app.launchArguments = [
            "UI-Testing",
            "-UIViewControllerBasedStatusBarAppearance", "NO",
            "-com.apple.CoreData.ConcurrencyDebug", "1",
            "-disableAnimations", "YES"
        ]
        
        // Configure launch environment to disable system logging and caching
        app.launchEnvironment = [
            "UITEST_DISABLE_APP_LAUNCH_MEASUREMENT": "YES",
            "OS_ACTIVITY_MODE": "disable",
            "SQLITE_ENABLE_THREAD_ASSERTIONS": "1",
            "DYLD_PRINT_STATISTICS": "1"
        ]
        
        // Reset app state
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        
        // Clear any existing CoreData stores
        try? FileManager.default.removeItem(at: FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent("orgaifinanceapp"))
        
        app.launch()
    }
    
    override func tearDownWithError() throws {
        // Clean up after each test
        app.terminate()
        
        // Clear launch cache
        try? FileManager.default.removeItem(at: FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent("com.apple.CoreSimulator.CoreSimulatorService"))
    }
    
    // MARK: - Test Configuration
    
    override class func setUp() {
        super.setUp()
        
        // Disable system animations
        let springboardSettings = """
        {
            "AnimationsEnabled": false,
            "UIDisableLocalizedLayoutDirection": true
        }
        """
        UserDefaults.standard.set(springboardSettings, forKey: "UITestingOverrides")
    }
    
    override class func tearDown() {
        super.tearDown()
        UserDefaults.standard.removeObject(forKey: "UITestingOverrides")
    }
    
    // MARK: - Welcome Flow Tests
    
    func testWelcomeScreenFlow() throws {
        // Wait for welcome screen to appear
        let welcomeTitle = app.staticTexts["Orgai Finance"]
        XCTAssertTrue(welcomeTitle.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Simplified Organized Finance"].exists)
        
        // Test sign in buttons
        let appleSignInButton = app.buttons["Sign in with Apple"]
        let googleSignInButton = app.buttons["Sign in with Google"]
        
        XCTAssertTrue(appleSignInButton.exists)
        XCTAssertTrue(googleSignInButton.exists)
        
        // Test dismiss welcome screen
        let dismissButton = app.buttons["xmark"]
        XCTAssertTrue(dismissButton.exists)
        dismissButton.tap()
        
        // Verify main app screen is shown
        XCTAssertTrue(app.navigationBars["Accounts"].waitForExistence(timeout: 2))
    }
    
    // MARK: - Account Management Tests
    
    func testAddPersonalCheckingAccount() throws {
        skipWelcomeScreen()
        
        // Navigate to Accounts tab if not already there
        app.tabBars.buttons["Account"].tap()
        
        // Tap add account button
        let addButton = app.buttons["plus.circle.fill"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 2))
        addButton.tap()
        
        // Verify Add Account sheet is presented
        XCTAssertTrue(app.navigationBars["Add Account"].waitForExistence(timeout: 2))
        
        // Select account type and category
        app.buttons["Personal"].tap()
        app.buttons["Checking"].tap()
        
        // Fill in account details
        let nameField = app.textFields["Enter account name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("Test Checking")
        
        let balanceField = app.textFields["$0.00"]
        XCTAssertTrue(balanceField.waitForExistence(timeout: 2))
        balanceField.tap()
        balanceField.typeText("1000")
        
        // Add account
        app.buttons["Add"].tap()
        
        // Verify account was added
        XCTAssertTrue(app.staticTexts["Test Checking"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["$1,000.00"].exists)
    }
    
    func testAddBusinessCreditCard() throws {
        skipWelcomeScreen()
        
        // Navigate to Accounts
        app.tabBars.buttons["Account"].tap()
        
        // Add new account
        let addButton = app.buttons["plus.circle.fill"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 2))
        addButton.tap()
        
        // Select Business type and Credit Card category
        app.buttons["Business"].tap()
        app.buttons["Credit Card"].tap()
        
        // Fill details
        let nameField = app.textFields["Enter account name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("Business Credit")
        
        let balanceField = app.textFields["$0.00"]
        XCTAssertTrue(balanceField.waitForExistence(timeout: 2))
        balanceField.tap()
        balanceField.typeText("5000")
        
        // Add account
        app.buttons["Add"].tap()
        
        // Verify account was added with negative balance (credit card)
        XCTAssertTrue(app.staticTexts["Business Credit"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["-$5,000.00"].exists)
    }
    
    // MARK: - Navigation Tests
    
    func testTabBarNavigation() throws {
        skipWelcomeScreen()
        
        // Test each tab
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 2))
        
        // Home tab
        tabBar.buttons["Home"].tap()
        XCTAssertTrue(app.staticTexts["Portfolio Value"].waitForExistence(timeout: 2))
        
        // Activity tab
        tabBar.buttons["Activity"].tap()
        XCTAssertTrue(app.buttons["All"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Income"].exists)
        XCTAssertTrue(app.buttons["Expense"].exists)
        
        // Account tab
        tabBar.buttons["Account"].tap()
        XCTAssertTrue(app.staticTexts["Overview"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Assets"].exists)
        
        // Settings tab
        tabBar.buttons["Settings"].tap()
        XCTAssertTrue(app.staticTexts["Display"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["App Settings"].exists)
    }
    
    // MARK: - Account Interaction Tests
    
    func testAccountGroupExpansion() throws {
        skipWelcomeScreen()
        
        // Navigate to Accounts
        app.tabBars.buttons["Account"].tap()
        
        // Add test accounts first
        addTestAccount(name: "Personal Checking", type: "Personal", category: "Checking", balance: "1000")
        addTestAccount(name: "Business Savings", type: "Business", category: "Savings", balance: "5000")
        
        // Test Personal group expansion
        let personalGroup = app.buttons["Personal"]
        XCTAssertTrue(personalGroup.waitForExistence(timeout: 2))
        personalGroup.tap()
        
        // Verify account is visible
        XCTAssertTrue(app.staticTexts["Personal Checking"].waitForExistence(timeout: 2))
        
        // Test Business group expansion
        let businessGroup = app.buttons["Business"]
        XCTAssertTrue(businessGroup.exists)
        businessGroup.tap()
        
        // Verify account is visible
        XCTAssertTrue(app.staticTexts["Business Savings"].waitForExistence(timeout: 2))
    }
    
    // MARK: - Settings Tests
    
    func testThemeToggle() throws {
        skipWelcomeScreen()
        
        // Navigate to Settings
        app.tabBars.buttons["Settings"].tap()
        
        // Test theme switching
        let themeSegment = app.segmentedControls.firstMatch
        XCTAssertTrue(themeSegment.waitForExistence(timeout: 2))
        
        // Switch to Light theme
        themeSegment.buttons["Light"].tap()
        
        // Switch to Dark theme
        themeSegment.buttons["Dark"].tap()
        
        // Switch back to System theme
        themeSegment.buttons["System"].tap()
    }
    
    // MARK: - Account Screen UI Tests
    
    func testAccountScreenInitialState() throws {
        skipWelcomeScreen()
        
        // Navigate to Accounts tab
        app.tabBars.buttons["Account"].tap()
        
        // Verify initial state
        XCTAssertTrue(app.staticTexts["Overview"].exists)
        XCTAssertTrue(app.staticTexts["Assets"].exists)
        XCTAssertTrue(app.staticTexts["Liabilities"].exists)
        XCTAssertTrue(app.staticTexts["Net Worth"].exists)
        
        // Verify Personal and Business sections exist
        XCTAssertTrue(app.buttons["Personal"].exists)
        XCTAssertTrue(app.buttons["Business"].exists)
        
        // Verify Personal section is expanded by default (based on @AppStorage)
        XCTAssertTrue(app.buttons["Personal"].isSelected)
    }
    
    func testAccountCreationWithLargeBalance() throws {
        skipWelcomeScreen()
        app.tabBars.buttons["Account"].tap()
        
        // Add account with large balance
        let addButton = app.buttons["plus.circle.fill"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 2))
        addButton.tap()
        
        // Fill in account details
        app.buttons["Personal"].tap()
        app.buttons["Checking"].tap()
        
        let nameField = app.textFields["Enter account name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("High Balance Account")
        
        let balanceField = app.textFields["$0.00"]
        XCTAssertTrue(balanceField.waitForExistence(timeout: 2))
        balanceField.tap()
        balanceField.typeText("1500000") // $1.5M
        
        // Add account
        app.buttons["Add"].tap()
        
        // Verify account was added with correct formatting
        XCTAssertTrue(app.staticTexts["High Balance Account"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["$1.5M"].exists || app.staticTexts["$1,500,000.00"].exists)
    }
    
    func testAccountSectionExpansionAndCollapse() throws {
        skipWelcomeScreen()
        app.tabBars.buttons["Account"].tap()
        
        // Add test accounts
        addTestAccount(name: "Personal Savings", type: "Personal", category: "Savings", balance: "10000")
        addTestAccount(name: "Business Checking", type: "Business", category: "Checking", balance: "50000")
        
        // Test Personal section
        let personalButton = app.buttons["Personal"]
        XCTAssertTrue(personalButton.waitForExistence(timeout: 2))
        
        // Collapse Personal section
        personalButton.tap()
        XCTAssertFalse(app.staticTexts["Personal Savings"].exists)
        
        // Expand Personal section
        personalButton.tap()
        XCTAssertTrue(app.staticTexts["Personal Savings"].exists)
        
        // Test Business section
        let businessButton = app.buttons["Business"]
        XCTAssertTrue(businessButton.exists)
        
        // Expand Business section
        businessButton.tap()
        XCTAssertTrue(app.staticTexts["Business Checking"].exists)
        
        // Collapse Business section
        businessButton.tap()
        XCTAssertFalse(app.staticTexts["Business Checking"].exists)
    }
    
    func testAccountBalanceCalculations() throws {
        skipWelcomeScreen()
        app.tabBars.buttons["Account"].tap()
        
        // Add test accounts with known balances
        addTestAccount(name: "Checking", type: "Personal", category: "Checking", balance: "1000")
        addTestAccount(name: "Credit Card", type: "Personal", category: "Credit Card", balance: "500")
        
        // Verify total assets (checking: 1000)
        XCTAssertTrue(app.staticTexts["$1,000.00"].exists)
        
        // Verify total liabilities (credit card: 500)
        XCTAssertTrue(app.staticTexts["-$500.00"].exists)
        
        // Verify net worth (1000 - 500 = 500)
        XCTAssertTrue(app.staticTexts["$500.00"].exists)
    }
    
    func testAccountEditFunctionality() throws {
        skipWelcomeScreen()
        app.tabBars.buttons["Account"].tap()
        
        // Add test account
        addTestAccount(name: "Edit Test Account", type: "Personal", category: "Checking", balance: "1000")
        
        // Tap on account to edit
        app.staticTexts["Edit Test Account"].tap()
        
        // Verify edit sheet appears
        XCTAssertTrue(app.navigationBars["Edit Account"].waitForExistence(timeout: 2))
        
        // Edit account details
        let nameField = app.textFields["Account name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.clearText()
        nameField.typeText("Updated Account")
        
        let balanceField = app.textFields["Balance"]
        balanceField.tap()
        balanceField.clearText()
        balanceField.typeText("2000")
        
        // Save changes
        app.buttons["Save"].tap()
        
        // Verify updates
        XCTAssertTrue(app.staticTexts["Updated Account"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["$2,000.00"].exists)
    }
    
    func testScrollPositionRestoration() throws {
        skipWelcomeScreen()
        app.tabBars.buttons["Account"].tap()
        
        // Add multiple accounts to create scrollable content
        for i in 1...10 {
            addTestAccount(name: "Account \(i)", type: "Personal", category: "Checking", balance: "1000")
        }
        
        // Scroll to bottom
        let lastAccount = app.staticTexts["Account 10"]
        XCTAssertTrue(lastAccount.waitForExistence(timeout: 2))
        lastAccount.swipeUp()
        
        // Navigate away and back
        app.tabBars.buttons["Settings"].tap()
        app.tabBars.buttons["Account"].tap()
        
        // Verify scroll position is restored
        XCTAssertTrue(app.staticTexts["Account 10"].waitForExistence(timeout: 2))
    }
    
    func testAccessibilityLabels() throws {
        skipWelcomeScreen()
        app.tabBars.buttons["Account"].tap()
        
        // Add test account
        addTestAccount(name: "Accessibility Test", type: "Personal", category: "Checking", balance: "1000")
        
        // Verify accessibility labels
        XCTAssertTrue(app.buttons["Add account"].exists)
        XCTAssertTrue(app.buttons["Personal accounts section"].exists)
        XCTAssertTrue(app.buttons["Business accounts section"].exists)
        XCTAssertTrue(app.staticTexts["Account balance: $1,000.00"].exists)
        XCTAssertTrue(app.staticTexts["Net Worth: $1,000.00"].exists)
    }
    
    // MARK: - Helper Methods
    
    private func skipWelcomeScreen() {
        let dismissButton = app.buttons["xmark"]
        if dismissButton.waitForExistence(timeout: 5) {
            dismissButton.tap()
        }
    }
    
    private func addTestAccount(name: String, type: String, category: String, balance: String) {
        let addButton = app.buttons["plus.circle.fill"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 2))
        addButton.tap()
        
        app.buttons[type].tap()
        app.buttons[category].tap()
        
        let nameField = app.textFields["Enter account name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText(name)
        
        let balanceField = app.textFields["$0.00"]
        XCTAssertTrue(balanceField.waitForExistence(timeout: 2))
        balanceField.tap()
        balanceField.typeText(balance)
        
        app.buttons["Add"].tap()
    }
    
    private func clearText(in element: XCUIElement) {
        element.tap()
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: 50)
        element.typeText(deleteString)
    }
} 