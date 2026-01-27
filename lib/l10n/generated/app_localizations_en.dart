// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AteliePro';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get close => 'Close';

  @override
  String get search => 'Search';

  @override
  String get noResults => 'No results found';

  @override
  String get connectionError => 'Connection Error';

  @override
  String get connectionErrorMessage =>
      'Check your internet connection and try again';

  @override
  String get serverError => 'Server Error';

  @override
  String get serverErrorMessage =>
      'A server error occurred. Please try again later';

  @override
  String get loginTabManager => 'Manager';

  @override
  String get loginTabClient => 'Client';

  @override
  String get loginTabEmployee => 'Employee';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get login => 'Log In';

  @override
  String get logout => 'Log Out';

  @override
  String get emailRequired => 'Enter email';

  @override
  String get emailInvalid => 'Invalid email';

  @override
  String get passwordRequired => 'Enter password';

  @override
  String get passwordTooShort => 'Minimum 6 characters';

  @override
  String get home => 'Home';

  @override
  String get orders => 'Orders';

  @override
  String get clients => 'Clients';

  @override
  String get employees => 'Employees';

  @override
  String get analytics => 'Analytics';

  @override
  String get finance => 'Finance';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get activeOrders => 'Active Orders';

  @override
  String get recentOrders => 'Recent Orders';

  @override
  String get totalOrders => 'Total Orders';

  @override
  String get totalRevenue => 'Revenue';

  @override
  String get totalClients => 'Clients';

  @override
  String get newClients => 'New Clients';

  @override
  String get addOrder => 'Add Order';

  @override
  String get addClient => 'Add Client';

  @override
  String get addEmployee => 'Add Employee';

  @override
  String get orderDetails => 'Order Details';

  @override
  String get clientDetails => 'Client Details';

  @override
  String get noOrders => 'No orders';

  @override
  String get noClients => 'No clients';

  @override
  String get noEmployees => 'No employees';

  @override
  String ordersInProgress(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orders in progress',
      one: '1 order in progress',
      zero: 'no orders in progress',
    );
    return '$_temp0';
  }

  @override
  String currency(String amount) {
    return '$amount сом';
  }

  @override
  String daysRemaining(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days left',
      one: '1 day left',
      zero: 'today',
    );
    return '$_temp0';
  }

  @override
  String get overdue => 'Overdue';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get quantity => 'Quantity';

  @override
  String get price => 'Price';

  @override
  String get dueDate => 'Due Date';

  @override
  String get notes => 'Notes';

  @override
  String get phone => 'Phone';

  @override
  String get name => 'Name';

  @override
  String get role => 'Role';

  @override
  String get selectClient => 'Select client';

  @override
  String get selectModel => 'Select model';

  @override
  String get models => 'Models';

  @override
  String get payroll => 'Payroll';

  @override
  String get workLogs => 'Work Logs';

  @override
  String get subscription => 'Subscription';

  @override
  String get ml => 'ML Analytics';

  @override
  String get forecast => 'Forecast';

  @override
  String get insights => 'Insights';

  @override
  String get report => 'Report';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get systemMode => 'System Theme';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get confirmDeleteMessage =>
      'Are you sure you want to delete this item?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get successSaved => 'Successfully saved';

  @override
  String get successDeleted => 'Successfully deleted';

  @override
  String get vipClient => 'VIP';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get atelierManagement => 'Atelier management';

  @override
  String get registerAtelier => 'Register atelier';

  @override
  String get loginManager => 'Manager login';

  @override
  String get fullBusinessControl => 'Full business control';

  @override
  String get registration => 'Sign up';

  @override
  String get loginClient => 'Client login';

  @override
  String get trackYourOrders => 'Track your orders';

  @override
  String get loginEmployee => 'Employee login';

  @override
  String get workAndEarningsTracking => 'Work and earnings tracking';

  @override
  String get atelierName => 'Atelier name';

  @override
  String get myAtelierHint => 'My atelier';

  @override
  String get yourName => 'Your name';

  @override
  String get enterName => 'Enter name';

  @override
  String get enterYourName => 'Enter your name';

  @override
  String get createAccount => 'Create account';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get noAccount => 'No account?';

  @override
  String get credentialsFromManager =>
      'Credentials are provided by the atelier manager';

  @override
  String get exampleEmailHint => 'example@mail.com';

  @override
  String get exampleNameHint => 'John Doe';

  @override
  String get searchHint => 'Search...';

  @override
  String get selectDates => 'Select dates';

  @override
  String get dates => 'Dates';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String inDays(int days) {
    return 'In $days days';
  }

  @override
  String orderNumber(String id) {
    return 'Order #$id';
  }

  @override
  String get clientPlaceholder => 'Client';

  @override
  String quantityItems(int count) {
    return '$count pcs';
  }

  @override
  String ordersCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orders',
      one: '1 order',
      zero: '0 orders',
    );
    return '$_temp0';
  }

  @override
  String get dashboard => 'Dashboard';

  @override
  String get customers => 'Customers';

  @override
  String get workload => 'Workload';

  @override
  String get notFound => 'Not found';

  @override
  String get notFoundMessage => 'The requested data was not found';

  @override
  String get back => 'Back';

  @override
  String get continue_ => 'Continue';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get add => 'Add';

  @override
  String get modelPhoto => 'Model photo';

  @override
  String get confirmation => 'Confirmation';

  @override
  String get roleTailor => 'Tailor';

  @override
  String get roleDesigner => 'Designer';

  @override
  String get roleCutter => 'Cutter';

  @override
  String get roleSeamstress => 'Seamstress';

  @override
  String get roleFinisher => 'Finisher';

  @override
  String get rolePresser => 'Presser';

  @override
  String get roleQualityControl => 'QC';

  @override
  String get executorLabel => 'Executor';

  @override
  String get category => 'Category';

  @override
  String get selectCategory => 'Select category';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String youHaveOrdersInProgress(String orders) {
    return 'You have $orders';
  }

  @override
  String get indicators => 'Indicators';

  @override
  String get monthlyIncome => 'Monthly income';

  @override
  String get monthlyFinance => 'Monthly finance';

  @override
  String get income => 'Income';

  @override
  String get expenses => 'Expenses';

  @override
  String get profit => 'Profit';

  @override
  String get all => 'All';

  @override
  String get ordersWillAppearHere => 'Your recent orders will appear here';

  @override
  String get quickActions => 'Quick actions';

  @override
  String get newOrder => 'New order';

  @override
  String get newCustomer => 'New customer';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get notificationsComingSoon => 'Notifications coming soon';

  @override
  String get orderCreationComingSoon => 'Order creation coming soon';

  @override
  String get customerAdditionComingSoon => 'Customer addition coming soon';

  @override
  String get workRecords => 'Work records';

  @override
  String get help => 'Help';

  @override
  String get filters => 'Filters';

  @override
  String get searchOrders => 'Search orders...';

  @override
  String get tabPending => 'Pending';

  @override
  String get tabCompleted => 'Done';

  @override
  String get tabCancelled => 'Cancelled';

  @override
  String get noOrdersWithStatus => 'No orders with this status';

  @override
  String get tryDifferentSearch => 'Try a different search query';

  @override
  String get createFirstOrder => 'Create your first order';

  @override
  String get createOrder => 'Create order';

  @override
  String get reset => 'Reset';

  @override
  String get dueDateLabel => 'Due date';

  @override
  String get allDates => 'All dates';

  @override
  String get createdDateLabel => 'Created date';

  @override
  String get sortLabel => 'Sort by';

  @override
  String get sortByCreatedDate => 'By created date';

  @override
  String get sortByDueDate => 'By due date';

  @override
  String get sortByQuantity => 'By quantity';

  @override
  String get sortDescending => 'Descending';

  @override
  String get sortAscending => 'Ascending';

  @override
  String get apply => 'Apply';

  @override
  String get searchCustomers => 'Search customers...';

  @override
  String get sortByName => 'By name';

  @override
  String get sortByOrders => 'By orders';

  @override
  String get sortByAmount => 'By amount';

  @override
  String get noCustomers => 'No customers';

  @override
  String get addFirstCustomer => 'Add your first customer';

  @override
  String get customersNotAdded => 'No customers added yet';

  @override
  String get addCustomer => 'Add customer';

  @override
  String customerSince(String date) {
    return 'Customer since $date';
  }

  @override
  String get ordersCountLabel => 'Orders';

  @override
  String get spent => 'Spent';

  @override
  String get availableModels => 'Available models';

  @override
  String get configure => 'Configure';

  @override
  String get noModelsAssigned => 'No models assigned';

  @override
  String get clientCanOrderAnyModel => 'Customer can order any model';

  @override
  String get contacts => 'Contacts';

  @override
  String get editAction => 'Edit';

  @override
  String get selectModelsHint =>
      'Select models that the customer can order. If none selected - all models are available.';

  @override
  String get couldNotLoadModels => 'Could not load models';

  @override
  String get noAvailableModels => 'No available models';

  @override
  String saveWithCount(int count) {
    return 'Save ($count)';
  }

  @override
  String get telegram => 'Telegram';

  @override
  String get filterByRole => 'Filter by role';

  @override
  String get allRoles => 'All roles';

  @override
  String get searchEmployees => 'Search employees...';

  @override
  String get activeEmployees => 'Active';

  @override
  String get inactiveEmployees => 'Inactive';

  @override
  String loadingError(String message) {
    return 'Loading error: $message';
  }

  @override
  String get tryDifferentFilters => 'Try different search parameters';

  @override
  String get addFirstEmployee => 'Add your first employee';

  @override
  String get deleteEmployeeTitle => 'Delete employee?';

  @override
  String deleteEmployeeMessage(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get employeeDeleted => 'Employee deleted';

  @override
  String get workHistory => 'Work history';

  @override
  String get periodWeek => 'Week';

  @override
  String get periodMonth => 'Month';

  @override
  String get periodQuarter => 'Quarter';

  @override
  String get periodYear => 'Year';

  @override
  String get overview => 'Overview';

  @override
  String get revenue => 'Revenue';

  @override
  String get averageCheck => 'Average order';

  @override
  String get noRevenueData => 'No revenue data';

  @override
  String get ordersByStatus => 'Orders by status';

  @override
  String get statusInWork => 'In progress';

  @override
  String get statusDone => 'Completed';

  @override
  String get statusWaiting => 'Pending';

  @override
  String get statusCancelledShort => 'Cancelled';

  @override
  String get noOrdersData => 'No orders data';

  @override
  String get topCustomers => 'Top customers';

  @override
  String get noCustomersData => 'No customers data';

  @override
  String ordersCountShort(int count) {
    return '$count orders';
  }

  @override
  String get avatarUpdated => 'Avatar updated';

  @override
  String get avatarDeleted => 'Avatar deleted';

  @override
  String get account => 'Account';

  @override
  String get personalData => 'Personal data';

  @override
  String get nameEmailPhone => 'Name, email, phone';

  @override
  String get atelierData => 'Atelier data';

  @override
  String get changePassword => 'Change password';

  @override
  String get changeCurrentPassword => 'Change current password';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeAuto => 'Auto';

  @override
  String get subscriptionActive => 'Active';

  @override
  String get subscriptionTrial => 'Trial period';

  @override
  String get subscriptionExpired => 'Expired';

  @override
  String get subscriptionFree => 'Free plan';

  @override
  String get manageSubscription => 'Manage subscription';

  @override
  String get other => 'Other';

  @override
  String get notifications => 'Notifications';

  @override
  String get pushEmailSms => 'Push, email, SMS';

  @override
  String get helpSupport => 'Help and support';

  @override
  String get faqContactUs => 'FAQ, contact us';

  @override
  String get aboutApp => 'About app';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get aboutAppDescription =>
      'App for atelier management. Manage orders, customers and analytics in one place.';

  @override
  String get logoutAccount => 'Log out';

  @override
  String get logoutTitle => 'Log out';

  @override
  String get logoutConfirmation => 'Are you sure you want to log out?';

  @override
  String get logoutButton => 'Log out';

  @override
  String get currentPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get enterCurrentPassword => 'Enter current password';

  @override
  String get enterNewPassword => 'Enter new password';

  @override
  String minCharacters(int count) {
    return 'Minimum $count characters';
  }

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordChanged => 'Password changed successfully';

  @override
  String expiresOn(String date) {
    return 'until $date';
  }

  @override
  String get transactions => 'Transactions';

  @override
  String transactionEntriesCount(int count) {
    return '$count entries';
  }

  @override
  String get noTransactions => 'No transactions';

  @override
  String get addFirstTransaction => 'Add first transaction';

  @override
  String get transaction => 'Transaction';

  @override
  String get incomeLabel => 'Income';

  @override
  String get expenseLabel => 'Expense';

  @override
  String get allFilter => 'All';

  @override
  String get incomesFilter => 'Income';

  @override
  String get expensesFilter => 'Expenses';

  @override
  String get filterTooltip => 'Filter';

  @override
  String get deleteTransactionTitle => 'Delete transaction?';

  @override
  String deleteTransactionMessage(String amount) {
    return 'Are you sure you want to delete this transaction for $amount?';
  }

  @override
  String get transactionDeleted => 'Transaction deleted';

  @override
  String get dateLabel => 'Date';

  @override
  String get description => 'Description';

  @override
  String get searchModels => 'Search models...';

  @override
  String get filterByCategory => 'Filter by category';

  @override
  String get allCategories => 'All categories';

  @override
  String get nothingFound => 'Nothing found';

  @override
  String get tryChangeSearchParams => 'Try changing search parameters';

  @override
  String get noModels => 'No models';

  @override
  String get addFirstModel => 'Add your first clothing model';

  @override
  String get addModel => 'Add model';

  @override
  String get newModel => 'New model';

  @override
  String get deleteModelTitle => 'Delete model?';

  @override
  String deleteModelMessage(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get modelDeleted => 'Model deleted';

  @override
  String get changeAction => 'Edit';

  @override
  String get categoryDress => 'Dress';

  @override
  String get categorySuit => 'Suit';

  @override
  String get categoryPants => 'Pants';

  @override
  String get categoryShirt => 'Shirt';

  @override
  String get categorySkirt => 'Skirt';

  @override
  String get categoryCoat => 'Coat';

  @override
  String get categoryOther => 'Other';

  @override
  String get calculationPeriod => 'Calculation period';

  @override
  String get fromLabel => 'From';

  @override
  String get toLabel => 'To';

  @override
  String get calculating => 'Calculating...';

  @override
  String get calculate => 'Calculate';

  @override
  String get salaryCalculated => 'Salary calculated';

  @override
  String get totalToPay => 'Total to pay';

  @override
  String get recordToFinance => 'Record to finance';

  @override
  String get employeePayments => 'Payments by employee';

  @override
  String get employee => 'Employee';

  @override
  String get unknownRole => 'Unknown role';

  @override
  String get workDone => 'Work done';

  @override
  String get calculationHistory => 'Calculation history';

  @override
  String get noCalculationHistory => 'No calculation history';

  @override
  String get recordedToFinance => 'Recorded to finance';

  @override
  String salaryDescriptionFormat(Object period) {
    return 'Salary ($period)';
  }

  @override
  String get perHour => 'h';

  @override
  String get perPiece => 'pcs';

  @override
  String hoursShort(String hours) {
    return '$hours h';
  }

  @override
  String piecesShort(int count) {
    return '$count pcs';
  }

  @override
  String get allEmployees => 'All employees';

  @override
  String get totalPieces => 'Total pieces';

  @override
  String get totalHours => 'Total hours';

  @override
  String get recordsCount => 'Records';

  @override
  String get noRecords => 'No records';

  @override
  String get tryChangeFilters => 'Try changing filters';

  @override
  String get employeesNotRecordedWork => 'Employees haven\'t recorded work yet';

  @override
  String get unknown => 'Unknown';

  @override
  String get currentPlan => 'Current plan';

  @override
  String get freePlan => 'Free plan';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get errorHappened => 'An error occurred';

  @override
  String get resourceUsage => 'Resource usage';

  @override
  String get customersLabel => 'Customers';

  @override
  String get employeesLabel => 'Employees';

  @override
  String get unlimited => 'Unlimited';

  @override
  String get availablePlans => 'Available plans';

  @override
  String get loadingPlans => 'Loading plans...';

  @override
  String get activePlan => 'Active';

  @override
  String get currentPlanButton => 'Current plan';

  @override
  String get selectPlan => 'Select plan';

  @override
  String get popular => 'Popular';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get ofCustomers => 'customers';

  @override
  String get ofEmployees => 'employees';

  @override
  String get ateliers => 'Ateliers';

  @override
  String get myAteliers => 'My Ateliers';

  @override
  String get notLinkedToAtelier => 'You are not linked to any atelier yet';

  @override
  String get linkToAtelierHint => 'Link to an atelier to create orders';

  @override
  String get featureComingSoon => 'Feature coming soon';

  @override
  String get linkAtelier => 'Link Atelier';

  @override
  String get noOrdersLabel => 'No orders';

  @override
  String get oneOrder => '1 order';

  @override
  String fewOrders(int count) {
    return '$count orders';
  }

  @override
  String manyOrders(int count) {
    return '$count orders';
  }

  @override
  String get tasks => 'Tasks';

  @override
  String get history => 'History';

  @override
  String get myTasks => 'My Tasks';

  @override
  String get inWork => 'In Progress';

  @override
  String get ready => 'Completed';

  @override
  String get dateFilter => 'Filter by date';

  @override
  String tasksCount(int count) {
    return '$count tasks';
  }

  @override
  String get noActiveTasks => 'No active tasks';

  @override
  String get tasksWillAppearHere =>
      'When the manager assigns an order to you, it will appear here';

  @override
  String get statusReady => 'Ready';

  @override
  String get works => 'Works';

  @override
  String get salary => 'Salary';

  @override
  String get noWorkRecords => 'No work records';

  @override
  String get workRecordsHint => 'Records will appear after you start working';

  @override
  String get noPayrollRecords => 'No payroll records';

  @override
  String get payrollRecordsHint =>
      'When the manager calculates salary, information will appear here';

  @override
  String entriesCount(int count) {
    return '$count entries';
  }

  @override
  String get rub => 'KGS';

  @override
  String get details => 'Details';

  @override
  String get hoursAbbr => 'h';

  @override
  String get contactInfo => 'Contact Information';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get workplace => 'Workplace';

  @override
  String get atelierLabel => 'Atelier';

  @override
  String get activity => 'Activity';

  @override
  String get lastLogin => 'Last login';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int minutes) {
    return '$minutes min. ago';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours h. ago';
  }

  @override
  String daysAgo(int days) {
    return '$days d. ago';
  }

  @override
  String get logoutQuestion => 'Are you sure you want to log out?';

  @override
  String get appVersionEmployee => 'AteliePro Employee v1.0.0';

  @override
  String get faqTitle => 'Frequently Asked Questions';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get appVersion => 'App Version';

  @override
  String get supportEmail => 'Support Email';

  @override
  String get telegramChannel => 'Telegram';

  @override
  String get faqCreateOrder => 'How to create an order?';

  @override
  String get faqCreateOrderAnswer =>
      'Go to the \"Orders\" section and tap the \"+\" button in the bottom right corner. Select a client, model, specify the quantity and due date.';

  @override
  String get faqAddClient => 'How to add a client?';

  @override
  String get faqAddClientAnswer =>
      'Go to the \"Customers\" section and tap the \"+\" button. Fill in the client\'s name, phone and email.';

  @override
  String get faqManageEmployees => 'How to manage employees?';

  @override
  String get faqManageEmployeesAnswer =>
      'In the side menu, select \"Employees\". Here you can add new employees, assign roles, and view work history.';

  @override
  String get faqPayroll => 'How does payroll work?';

  @override
  String get faqPayrollAnswer =>
      'Go to the \"Payroll\" section, select a period and tap \"Calculate\". The system will automatically calculate payment based on employee work records.';

  @override
  String get faqProduction => 'How does production work?';

  @override
  String get faqProductionAnswer =>
      'The \"Production\" section shows current orders in progress, their stages, and assigned workers. Employees mark stages as complete in their app.';

  @override
  String get faqNotifications => 'How to configure notifications?';

  @override
  String get faqNotificationsAnswer =>
      'Go to \"Settings\" → \"Notifications\". You can enable or disable push notifications about new orders, status changes, and other events.';

  @override
  String get faqSubscription => 'How to manage subscription?';

  @override
  String get faqSubscriptionAnswer =>
      'In the side menu, select \"Subscription\". Here you can see your current plan, resource usage, and available plans to expand capabilities.';
}
