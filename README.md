# My Money - Personal Finance Tracker

A beautiful and scalable Flutter app for tracking personal finances with income management, expense tracking, financial reports, and AI-powered advice.

## Features

### 🏠 Dashboard
- **Total Balance Overview** - See your current financial status at a glance
- **Income vs Expenses** - Visual comparison with color-coded cards
- **Recent Transactions** - Quick view of your latest financial activities
- **Beautiful Animations** - Smooth transitions and engaging UI

### 💰 Transaction Management
- **Add Income/Expenses** - Easy-to-use form with category selection
- **Transaction History** - Complete list of all your financial activities
- **Transaction Details** - Detailed view with edit and delete options
- **Smart Categories** - Pre-defined categories for better organization

### 📊 Financial Reports
- **Monthly Overview** - Income, expenses, and balance statistics
- **Category Analysis** - Pie chart showing expense distribution
- **Visual Charts** - Beautiful charts powered by FL Chart
- **Transaction Summary** - Comprehensive financial insights

### 💡 Financial Advice
- **Health Score** - AI-powered financial health assessment (0-100)
- **Smart Recommendations** - Personalized advice based on spending patterns
- **Financial Tips** - Expert tips for better money management
- **Spending Alerts** - Warnings for high spending ratios

## Technical Architecture

### 🏗️ Clean Architecture
- **Feature-based Structure** - Modular organization for scalability
- **Separation of Concerns** - Clear boundaries between layers
- **SOLID Principles** - Maintainable and extensible codebase

### 🔧 Technology Stack
- **Flutter 3.10+** - Cross-platform mobile development
- **Riverpod** - State management solution
- **Hive** - Local database for offline-first approach
- **Material 3** - Modern design system
- **FL Chart** - Beautiful charts and graphs
- **Google Fonts** - Typography with Inter font family

### 📱 UI/UX Features
- **Material 3 Design** - Modern and consistent UI
- **Dark/Light Theme** - Automatic theme switching
- **Smooth Animations** - Flutter Animate for engaging interactions
- **Responsive Design** - Works on all screen sizes
- **Accessibility** - Screen reader and keyboard navigation support

## Project Structure

```
lib/
├── core/
│   ├── database/          # Hive database service
│   ├── models/           # Data models (Transaction, etc.)
│   ├── providers/        # Riverpod state management
│   └── theme/           # App theming
├── features/
│   ├── dashboard/       # Home screen with overview
│   ├── expenses/        # Transaction management
│   ├── reports/         # Financial reports and charts
│   └── advice/          # AI-powered financial advice
└── shared/
    ├── widgets/         # Reusable UI components
    └── utils/           # Utility functions
```

## Getting Started

### Prerequisites
- Flutter SDK 3.10 or higher
- Dart SDK 3.0 or higher
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd mymoney
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## Usage Guide

### Adding Transactions
1. Tap the **"Add Transaction"** floating action button
2. Choose between **Income** or **Expense**
3. Fill in the transaction details:
   - Title (required)
   - Amount (required)
   - Category (required)
   - Description (optional)
4. Tap **"Add Income/Expense"** to save

### Viewing Reports
1. Navigate to the **Reports** tab
2. View your monthly financial overview
3. Analyze spending by category with the pie chart
4. Check transaction summary statistics

### Getting Financial Advice
1. Go to the **Advice** tab
2. Check your **Financial Health Score**
3. Read personalized **Recommendations**
4. Browse **Financial Tips** for better money management

## Customization

### Adding New Categories
Edit the categories in `lib/shared/utils/app_utils.dart`:

```dart
static List<String> get expenseCategories => [
  'Food & Dining',
  'Transportation',
  'Your New Category', // Add here
  // ...
];
```

### Changing Theme Colors
Modify colors in `lib/core/theme/app_theme.dart`:

```dart
static const Color primaryColor = Color(0xFF6366F1); // Change this
```

### Adding New Features
1. Create a new folder in `lib/features/`
2. Add your screens and logic
3. Update navigation in `lib/main.dart`

## Database Schema

### Transaction Model
```dart
class Transaction {
  String id;           // Unique identifier
  String title;        // Transaction title
  double amount;       // Transaction amount
  String category;     // Category name
  DateTime date;       // Transaction date
  TransactionType type; // Income or Expense
  String? description; // Optional description
}
```

## Performance Optimizations

- **Offline-first** - All data stored locally with Hive
- **Lazy loading** - Efficient list rendering
- **State management** - Optimized with Riverpod
- **Memory efficient** - Proper disposal of resources

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Future Enhancements

- [ ] **Cloud Sync** - Firebase integration for data backup
- [ ] **Budget Planning** - Set and track monthly budgets
- [ ] **Recurring Transactions** - Automatic transaction scheduling
- [ ] **Export Data** - CSV/PDF export functionality
- [ ] **Multi-currency** - Support for different currencies
- [ ] **Bank Integration** - Connect with bank accounts
- [ ] **Investment Tracking** - Portfolio management
- [ ] **Bill Reminders** - Payment notifications

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support, email your-email@example.com or create an issue in the repository.

---

**Built with ❤️ using Flutter**