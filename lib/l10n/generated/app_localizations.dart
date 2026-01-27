import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// The application title
  ///
  /// In ru, this message translates to:
  /// **'АтельеПро'**
  String get appTitle;

  /// Loading indicator text
  ///
  /// In ru, this message translates to:
  /// **'Загрузка...'**
  String get loading;

  /// Generic error title
  ///
  /// In ru, this message translates to:
  /// **'Ошибка'**
  String get error;

  /// Retry button text
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get retry;

  /// Cancel button text
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel;

  /// Save button text
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get save;

  /// Delete button text
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get delete;

  /// Edit button text
  ///
  /// In ru, this message translates to:
  /// **'Редактировать'**
  String get edit;

  /// Close button text
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get close;

  /// Search placeholder text
  ///
  /// In ru, this message translates to:
  /// **'Поиск'**
  String get search;

  /// Empty search results message
  ///
  /// In ru, this message translates to:
  /// **'Ничего не найдено'**
  String get noResults;

  /// Network connection error title
  ///
  /// In ru, this message translates to:
  /// **'Ошибка подключения'**
  String get connectionError;

  /// Network connection error message
  ///
  /// In ru, this message translates to:
  /// **'Проверьте подключение к интернету и попробуйте снова'**
  String get connectionErrorMessage;

  /// Server error title
  ///
  /// In ru, this message translates to:
  /// **'Ошибка сервера'**
  String get serverError;

  /// Server error message
  ///
  /// In ru, this message translates to:
  /// **'Произошла ошибка на сервере. Попробуйте позже'**
  String get serverErrorMessage;

  /// Manager login tab title
  ///
  /// In ru, this message translates to:
  /// **'Менеджер'**
  String get loginTabManager;

  /// Client login tab title
  ///
  /// In ru, this message translates to:
  /// **'Заказчик'**
  String get loginTabClient;

  /// Employee login tab title
  ///
  /// In ru, this message translates to:
  /// **'Сотрудник'**
  String get loginTabEmployee;

  /// Email field label
  ///
  /// In ru, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get password;

  /// Login button text
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get login;

  /// Logout button text
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get logout;

  /// Email validation error
  ///
  /// In ru, this message translates to:
  /// **'Введите email'**
  String get emailRequired;

  /// Invalid email validation error
  ///
  /// In ru, this message translates to:
  /// **'Некорректный email'**
  String get emailInvalid;

  /// Password validation error
  ///
  /// In ru, this message translates to:
  /// **'Введите пароль'**
  String get passwordRequired;

  /// Password too short validation error
  ///
  /// In ru, this message translates to:
  /// **'Минимум 6 символов'**
  String get passwordTooShort;

  /// Home screen title
  ///
  /// In ru, this message translates to:
  /// **'Главная'**
  String get home;

  /// Orders screen title
  ///
  /// In ru, this message translates to:
  /// **'Заказы'**
  String get orders;

  /// Clients screen title
  ///
  /// In ru, this message translates to:
  /// **'Клиенты'**
  String get clients;

  /// Employees screen title
  ///
  /// In ru, this message translates to:
  /// **'Сотрудники'**
  String get employees;

  /// Analytics screen title
  ///
  /// In ru, this message translates to:
  /// **'Аналитика'**
  String get analytics;

  /// Finance screen title
  ///
  /// In ru, this message translates to:
  /// **'Финансы'**
  String get finance;

  /// Profile screen title
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get profile;

  /// Settings screen title
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settings;

  /// Order status: pending
  ///
  /// In ru, this message translates to:
  /// **'Ожидает'**
  String get statusPending;

  /// Order status: in progress
  ///
  /// In ru, this message translates to:
  /// **'В работе'**
  String get statusInProgress;

  /// Order status: completed
  ///
  /// In ru, this message translates to:
  /// **'Выполнен'**
  String get statusCompleted;

  /// Order status: cancelled
  ///
  /// In ru, this message translates to:
  /// **'Отменён'**
  String get statusCancelled;

  /// Active orders section title
  ///
  /// In ru, this message translates to:
  /// **'Активные заказы'**
  String get activeOrders;

  /// Recent orders section title
  ///
  /// In ru, this message translates to:
  /// **'Последние заказы'**
  String get recentOrders;

  /// Total orders stat label
  ///
  /// In ru, this message translates to:
  /// **'Всего заказов'**
  String get totalOrders;

  /// Total revenue stat label
  ///
  /// In ru, this message translates to:
  /// **'Выручка'**
  String get totalRevenue;

  /// Total clients stat label
  ///
  /// In ru, this message translates to:
  /// **'Клиентов'**
  String get totalClients;

  /// New clients stat label
  ///
  /// In ru, this message translates to:
  /// **'Новых клиентов'**
  String get newClients;

  /// Add order button text
  ///
  /// In ru, this message translates to:
  /// **'Добавить заказ'**
  String get addOrder;

  /// Add client button text
  ///
  /// In ru, this message translates to:
  /// **'Добавить клиента'**
  String get addClient;

  /// Add employee button text
  ///
  /// In ru, this message translates to:
  /// **'Добавить сотрудника'**
  String get addEmployee;

  /// Order details screen title
  ///
  /// In ru, this message translates to:
  /// **'Детали заказа'**
  String get orderDetails;

  /// Client details screen title
  ///
  /// In ru, this message translates to:
  /// **'Данные клиента'**
  String get clientDetails;

  /// No orders message
  ///
  /// In ru, this message translates to:
  /// **'Нет заказов'**
  String get noOrders;

  /// No clients message
  ///
  /// In ru, this message translates to:
  /// **'Нет клиентов'**
  String get noClients;

  /// No employees message
  ///
  /// In ru, this message translates to:
  /// **'Нет сотрудников'**
  String get noEmployees;

  /// Orders in progress count with pluralization
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, =0{нет заказов в работе} =1{1 заказ в работе} few{{count} заказа в работе} other{{count} заказов в работе}}'**
  String ordersInProgress(int count);

  /// Currency format
  ///
  /// In ru, this message translates to:
  /// **'{amount} сом'**
  String currency(String amount);

  /// Days remaining with pluralization
  ///
  /// In ru, this message translates to:
  /// **'{days, plural, =0{сегодня} =1{остался 1 день} few{осталось {days} дня} other{осталось {days} дней}}'**
  String daysRemaining(int days);

  /// Overdue order label
  ///
  /// In ru, this message translates to:
  /// **'Просрочен'**
  String get overdue;

  /// Today label
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get today;

  /// Yesterday label
  ///
  /// In ru, this message translates to:
  /// **'Вчера'**
  String get yesterday;

  /// Quantity field label
  ///
  /// In ru, this message translates to:
  /// **'Количество'**
  String get quantity;

  /// Price field label
  ///
  /// In ru, this message translates to:
  /// **'Цена'**
  String get price;

  /// Due date field label
  ///
  /// In ru, this message translates to:
  /// **'Срок'**
  String get dueDate;

  /// Notes field label
  ///
  /// In ru, this message translates to:
  /// **'Заметки'**
  String get notes;

  /// Phone field label
  ///
  /// In ru, this message translates to:
  /// **'Телефон'**
  String get phone;

  /// Name field label
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get name;

  /// Role field label
  ///
  /// In ru, this message translates to:
  /// **'Роль'**
  String get role;

  /// Select client placeholder
  ///
  /// In ru, this message translates to:
  /// **'Выберите клиента'**
  String get selectClient;

  /// Select model placeholder
  ///
  /// In ru, this message translates to:
  /// **'Выберите модель'**
  String get selectModel;

  /// Models screen title
  ///
  /// In ru, this message translates to:
  /// **'Модели'**
  String get models;

  /// Payroll screen title
  ///
  /// In ru, this message translates to:
  /// **'Расчёт зарплаты'**
  String get payroll;

  /// Work logs screen title
  ///
  /// In ru, this message translates to:
  /// **'Журнал работ'**
  String get workLogs;

  /// Subscription screen title
  ///
  /// In ru, this message translates to:
  /// **'Подписка'**
  String get subscription;

  /// ML analytics screen title
  ///
  /// In ru, this message translates to:
  /// **'ML Аналитика'**
  String get ml;

  /// Forecast screen title
  ///
  /// In ru, this message translates to:
  /// **'Прогноз'**
  String get forecast;

  /// Business insights section
  ///
  /// In ru, this message translates to:
  /// **'Инсайты'**
  String get insights;

  /// Report section
  ///
  /// In ru, this message translates to:
  /// **'Отчёт'**
  String get report;

  /// Dark mode setting
  ///
  /// In ru, this message translates to:
  /// **'Тёмная тема'**
  String get darkMode;

  /// Light mode setting
  ///
  /// In ru, this message translates to:
  /// **'Светлая тема'**
  String get lightMode;

  /// System theme mode setting
  ///
  /// In ru, this message translates to:
  /// **'Системная тема'**
  String get systemMode;

  /// Delete confirmation dialog title
  ///
  /// In ru, this message translates to:
  /// **'Подтвердите удаление'**
  String get confirmDelete;

  /// Delete confirmation dialog message
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите удалить этот элемент?'**
  String get confirmDeleteMessage;

  /// Yes button text
  ///
  /// In ru, this message translates to:
  /// **'Да'**
  String get yes;

  /// No button text
  ///
  /// In ru, this message translates to:
  /// **'Нет'**
  String get no;

  /// Success save message
  ///
  /// In ru, this message translates to:
  /// **'Успешно сохранено'**
  String get successSaved;

  /// Success delete message
  ///
  /// In ru, this message translates to:
  /// **'Успешно удалено'**
  String get successDeleted;

  /// VIP client badge
  ///
  /// In ru, this message translates to:
  /// **'VIP'**
  String get vipClient;

  /// Generic error message
  ///
  /// In ru, this message translates to:
  /// **'Произошла ошибка'**
  String get errorOccurred;

  /// App subtitle on login
  ///
  /// In ru, this message translates to:
  /// **'Управление ателье'**
  String get atelierManagement;

  /// Atelier registration title
  ///
  /// In ru, this message translates to:
  /// **'Регистрация ателье'**
  String get registerAtelier;

  /// Manager login title
  ///
  /// In ru, this message translates to:
  /// **'Вход для менеджера'**
  String get loginManager;

  /// Manager login subtitle
  ///
  /// In ru, this message translates to:
  /// **'Полный контроль над бизнесом'**
  String get fullBusinessControl;

  /// Registration button/title
  ///
  /// In ru, this message translates to:
  /// **'Регистрация'**
  String get registration;

  /// Client login title
  ///
  /// In ru, this message translates to:
  /// **'Вход для заказчика'**
  String get loginClient;

  /// Client login subtitle
  ///
  /// In ru, this message translates to:
  /// **'Отслеживание ваших заказов'**
  String get trackYourOrders;

  /// Employee login title
  ///
  /// In ru, this message translates to:
  /// **'Вход для сотрудника'**
  String get loginEmployee;

  /// Employee login subtitle
  ///
  /// In ru, this message translates to:
  /// **'Учёт работы и заработка'**
  String get workAndEarningsTracking;

  /// Atelier name field label
  ///
  /// In ru, this message translates to:
  /// **'Название ателье'**
  String get atelierName;

  /// Atelier name hint
  ///
  /// In ru, this message translates to:
  /// **'Моё ателье'**
  String get myAtelierHint;

  /// Your name field label
  ///
  /// In ru, this message translates to:
  /// **'Ваше имя'**
  String get yourName;

  /// Enter name validation
  ///
  /// In ru, this message translates to:
  /// **'Введите название'**
  String get enterName;

  /// Enter your name validation
  ///
  /// In ru, this message translates to:
  /// **'Введите имя'**
  String get enterYourName;

  /// Create account button
  ///
  /// In ru, this message translates to:
  /// **'Создать аккаунт'**
  String get createAccount;

  /// Already have account text
  ///
  /// In ru, this message translates to:
  /// **'Уже есть аккаунт?'**
  String get alreadyHaveAccount;

  /// No account text
  ///
  /// In ru, this message translates to:
  /// **'Нет аккаунта?'**
  String get noAccount;

  /// Info about employee credentials
  ///
  /// In ru, this message translates to:
  /// **'Учётные данные выдаёт менеджер ателье'**
  String get credentialsFromManager;

  /// Example email hint
  ///
  /// In ru, this message translates to:
  /// **'example@mail.ru'**
  String get exampleEmailHint;

  /// Example name hint
  ///
  /// In ru, this message translates to:
  /// **'Иван Иванов'**
  String get exampleNameHint;

  /// Search field hint
  ///
  /// In ru, this message translates to:
  /// **'Поиск...'**
  String get searchHint;

  /// Date picker placeholder
  ///
  /// In ru, this message translates to:
  /// **'Выбрать даты'**
  String get selectDates;

  /// Dates chip label
  ///
  /// In ru, this message translates to:
  /// **'Даты'**
  String get dates;

  /// Tomorrow label
  ///
  /// In ru, this message translates to:
  /// **'Завтра'**
  String get tomorrow;

  /// In X days label
  ///
  /// In ru, this message translates to:
  /// **'Через {days} дн.'**
  String inDays(int days);

  /// Order number with ID
  ///
  /// In ru, this message translates to:
  /// **'Заказ #{id}'**
  String orderNumber(String id);

  /// Client placeholder
  ///
  /// In ru, this message translates to:
  /// **'Заказчик'**
  String get clientPlaceholder;

  /// Quantity with unit
  ///
  /// In ru, this message translates to:
  /// **'{count} шт.'**
  String quantityItems(int count);

  /// Orders count with pluralization
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, =0{0 заказов} =1{1 заказ} few{{count} заказа} other{{count} заказов}}'**
  String ordersCountPlural(int count);

  /// Dashboard menu item
  ///
  /// In ru, this message translates to:
  /// **'Дашборд'**
  String get dashboard;

  /// Customers menu item
  ///
  /// In ru, this message translates to:
  /// **'Заказчики'**
  String get customers;

  /// Workload menu item
  ///
  /// In ru, this message translates to:
  /// **'Загрузка'**
  String get workload;

  /// Not found title
  ///
  /// In ru, this message translates to:
  /// **'Не найдено'**
  String get notFound;

  /// Not found message
  ///
  /// In ru, this message translates to:
  /// **'Запрашиваемые данные не найдены'**
  String get notFoundMessage;

  /// Back button
  ///
  /// In ru, this message translates to:
  /// **'Назад'**
  String get back;

  /// Continue button
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get continue_;

  /// Camera option
  ///
  /// In ru, this message translates to:
  /// **'Камера'**
  String get camera;

  /// Gallery option
  ///
  /// In ru, this message translates to:
  /// **'Галерея'**
  String get gallery;

  /// Add button
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get add;

  /// Model photo label
  ///
  /// In ru, this message translates to:
  /// **'Фото модели'**
  String get modelPhoto;

  /// Confirmation dialog title
  ///
  /// In ru, this message translates to:
  /// **'Подтверждение'**
  String get confirmation;

  /// Tailor role
  ///
  /// In ru, this message translates to:
  /// **'Портной'**
  String get roleTailor;

  /// Designer role
  ///
  /// In ru, this message translates to:
  /// **'Дизайнер'**
  String get roleDesigner;

  /// Cutter role
  ///
  /// In ru, this message translates to:
  /// **'Раскройщик'**
  String get roleCutter;

  /// Seamstress role
  ///
  /// In ru, this message translates to:
  /// **'Швея'**
  String get roleSeamstress;

  /// Finisher role
  ///
  /// In ru, this message translates to:
  /// **'Отделочник'**
  String get roleFinisher;

  /// Presser role
  ///
  /// In ru, this message translates to:
  /// **'Гладильщик'**
  String get rolePresser;

  /// Quality control role
  ///
  /// In ru, this message translates to:
  /// **'ОТК'**
  String get roleQualityControl;

  /// Executor field label
  ///
  /// In ru, this message translates to:
  /// **'Исполнитель'**
  String get executorLabel;

  /// Category field label
  ///
  /// In ru, this message translates to:
  /// **'Категория'**
  String get category;

  /// Select category hint
  ///
  /// In ru, this message translates to:
  /// **'Выберите категорию'**
  String get selectCategory;

  /// Morning greeting
  ///
  /// In ru, this message translates to:
  /// **'Доброе утро'**
  String get goodMorning;

  /// Afternoon greeting
  ///
  /// In ru, this message translates to:
  /// **'Добрый день'**
  String get goodAfternoon;

  /// Evening greeting
  ///
  /// In ru, this message translates to:
  /// **'Добрый вечер'**
  String get goodEvening;

  /// Orders in progress message
  ///
  /// In ru, this message translates to:
  /// **'У вас {orders}'**
  String youHaveOrdersInProgress(String orders);

  /// Dashboard indicators section
  ///
  /// In ru, this message translates to:
  /// **'Показатели'**
  String get indicators;

  /// Monthly income stat
  ///
  /// In ru, this message translates to:
  /// **'Доход за месяц'**
  String get monthlyIncome;

  /// Monthly finance section
  ///
  /// In ru, this message translates to:
  /// **'Финансы за месяц'**
  String get monthlyFinance;

  /// Income label
  ///
  /// In ru, this message translates to:
  /// **'Доходы'**
  String get income;

  /// Expenses label
  ///
  /// In ru, this message translates to:
  /// **'Расходы'**
  String get expenses;

  /// Profit label
  ///
  /// In ru, this message translates to:
  /// **'Прибыль'**
  String get profit;

  /// All button
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get all;

  /// Empty orders subtitle
  ///
  /// In ru, this message translates to:
  /// **'Здесь появятся ваши последние заказы'**
  String get ordersWillAppearHere;

  /// Quick actions section
  ///
  /// In ru, this message translates to:
  /// **'Быстрые действия'**
  String get quickActions;

  /// New order button
  ///
  /// In ru, this message translates to:
  /// **'Новый заказ'**
  String get newOrder;

  /// New customer button
  ///
  /// In ru, this message translates to:
  /// **'Новый заказчик'**
  String get newCustomer;

  /// Coming soon message
  ///
  /// In ru, this message translates to:
  /// **'Скоро будет доступно'**
  String get comingSoon;

  /// Notifications coming soon
  ///
  /// In ru, this message translates to:
  /// **'Уведомления скоро будут доступны'**
  String get notificationsComingSoon;

  /// Order creation coming soon
  ///
  /// In ru, this message translates to:
  /// **'Создание заказа скоро будет доступно'**
  String get orderCreationComingSoon;

  /// Customer addition coming soon
  ///
  /// In ru, this message translates to:
  /// **'Добавление заказчика скоро будет доступно'**
  String get customerAdditionComingSoon;

  /// Work records menu item
  ///
  /// In ru, this message translates to:
  /// **'Записи работы'**
  String get workRecords;

  /// Help menu item
  ///
  /// In ru, this message translates to:
  /// **'Помощь'**
  String get help;

  /// Filters button/title
  ///
  /// In ru, this message translates to:
  /// **'Фильтры'**
  String get filters;

  /// Orders search hint
  ///
  /// In ru, this message translates to:
  /// **'Поиск заказов...'**
  String get searchOrders;

  /// Pending tab label
  ///
  /// In ru, this message translates to:
  /// **'Ожидают'**
  String get tabPending;

  /// Completed tab label
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get tabCompleted;

  /// Cancelled tab label
  ///
  /// In ru, this message translates to:
  /// **'Отменены'**
  String get tabCancelled;

  /// No orders with status message
  ///
  /// In ru, this message translates to:
  /// **'Нет заказов с этим статусом'**
  String get noOrdersWithStatus;

  /// Try different search suggestion
  ///
  /// In ru, this message translates to:
  /// **'Попробуйте изменить поисковый запрос'**
  String get tryDifferentSearch;

  /// Create first order suggestion
  ///
  /// In ru, this message translates to:
  /// **'Создайте первый заказ'**
  String get createFirstOrder;

  /// Create order button
  ///
  /// In ru, this message translates to:
  /// **'Создать заказ'**
  String get createOrder;

  /// Reset button
  ///
  /// In ru, this message translates to:
  /// **'Сбросить'**
  String get reset;

  /// Due date filter label
  ///
  /// In ru, this message translates to:
  /// **'Срок сдачи'**
  String get dueDateLabel;

  /// All dates placeholder
  ///
  /// In ru, this message translates to:
  /// **'Все даты'**
  String get allDates;

  /// Created date filter label
  ///
  /// In ru, this message translates to:
  /// **'Дата создания'**
  String get createdDateLabel;

  /// Sort section label
  ///
  /// In ru, this message translates to:
  /// **'Сортировка'**
  String get sortLabel;

  /// Sort by created date option
  ///
  /// In ru, this message translates to:
  /// **'По дате создания'**
  String get sortByCreatedDate;

  /// Sort by due date option
  ///
  /// In ru, this message translates to:
  /// **'По сроку'**
  String get sortByDueDate;

  /// Sort by quantity option
  ///
  /// In ru, this message translates to:
  /// **'По кол-ву'**
  String get sortByQuantity;

  /// Sort descending option
  ///
  /// In ru, this message translates to:
  /// **'По убыванию'**
  String get sortDescending;

  /// Sort ascending option
  ///
  /// In ru, this message translates to:
  /// **'По возрастанию'**
  String get sortAscending;

  /// Apply button
  ///
  /// In ru, this message translates to:
  /// **'Применить'**
  String get apply;

  /// Customers search hint
  ///
  /// In ru, this message translates to:
  /// **'Поиск заказчиков...'**
  String get searchCustomers;

  /// Sort by name option
  ///
  /// In ru, this message translates to:
  /// **'По имени'**
  String get sortByName;

  /// Sort by orders option
  ///
  /// In ru, this message translates to:
  /// **'По заказам'**
  String get sortByOrders;

  /// Sort by amount option
  ///
  /// In ru, this message translates to:
  /// **'По сумме'**
  String get sortByAmount;

  /// No customers message
  ///
  /// In ru, this message translates to:
  /// **'Нет заказчиков'**
  String get noCustomers;

  /// Add first customer suggestion
  ///
  /// In ru, this message translates to:
  /// **'Добавьте первого заказчика'**
  String get addFirstCustomer;

  /// Customers not added message
  ///
  /// In ru, this message translates to:
  /// **'Заказчики пока не добавлены'**
  String get customersNotAdded;

  /// Add customer button
  ///
  /// In ru, this message translates to:
  /// **'Добавить заказчика'**
  String get addCustomer;

  /// Customer since date
  ///
  /// In ru, this message translates to:
  /// **'Заказчик с {date}'**
  String customerSince(String date);

  /// Orders count label
  ///
  /// In ru, this message translates to:
  /// **'Заказов'**
  String get ordersCountLabel;

  /// Spent amount label
  ///
  /// In ru, this message translates to:
  /// **'Потрачено'**
  String get spent;

  /// Available models section
  ///
  /// In ru, this message translates to:
  /// **'Доступные модели'**
  String get availableModels;

  /// Configure button
  ///
  /// In ru, this message translates to:
  /// **'Настроить'**
  String get configure;

  /// No models assigned message
  ///
  /// In ru, this message translates to:
  /// **'Модели не назначены'**
  String get noModelsAssigned;

  /// Client can order any model hint
  ///
  /// In ru, this message translates to:
  /// **'Заказчик может заказывать любые модели'**
  String get clientCanOrderAnyModel;

  /// Contacts section
  ///
  /// In ru, this message translates to:
  /// **'Контакты'**
  String get contacts;

  /// Edit action button
  ///
  /// In ru, this message translates to:
  /// **'Изменить'**
  String get editAction;

  /// Select models dialog hint
  ///
  /// In ru, this message translates to:
  /// **'Выберите модели, которые заказчик сможет заказать. Если ни одна модель не выбрана - доступны все.'**
  String get selectModelsHint;

  /// Could not load models error
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить модели'**
  String get couldNotLoadModels;

  /// No available models message
  ///
  /// In ru, this message translates to:
  /// **'Нет доступных моделей'**
  String get noAvailableModels;

  /// Save button with count
  ///
  /// In ru, this message translates to:
  /// **'Сохранить ({count})'**
  String saveWithCount(int count);

  /// Telegram contact label
  ///
  /// In ru, this message translates to:
  /// **'Telegram'**
  String get telegram;

  /// Filter by role tooltip
  ///
  /// In ru, this message translates to:
  /// **'Фильтр по роли'**
  String get filterByRole;

  /// All roles filter option
  ///
  /// In ru, this message translates to:
  /// **'Все роли'**
  String get allRoles;

  /// Employees search hint
  ///
  /// In ru, this message translates to:
  /// **'Поиск сотрудников...'**
  String get searchEmployees;

  /// Active employees filter
  ///
  /// In ru, this message translates to:
  /// **'Активные'**
  String get activeEmployees;

  /// Inactive employees filter
  ///
  /// In ru, this message translates to:
  /// **'Неактивные'**
  String get inactiveEmployees;

  /// Loading error message
  ///
  /// In ru, this message translates to:
  /// **'Ошибка загрузки: {message}'**
  String loadingError(String message);

  /// Try different filters suggestion
  ///
  /// In ru, this message translates to:
  /// **'Попробуйте изменить параметры поиска'**
  String get tryDifferentFilters;

  /// Add first employee suggestion
  ///
  /// In ru, this message translates to:
  /// **'Добавьте первого сотрудника'**
  String get addFirstEmployee;

  /// Delete employee dialog title
  ///
  /// In ru, this message translates to:
  /// **'Удалить сотрудника?'**
  String get deleteEmployeeTitle;

  /// Delete employee confirmation
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите удалить \"{name}\"?'**
  String deleteEmployeeMessage(String name);

  /// Employee deleted message
  ///
  /// In ru, this message translates to:
  /// **'Сотрудник удалён'**
  String get employeeDeleted;

  /// Work history button
  ///
  /// In ru, this message translates to:
  /// **'История работы'**
  String get workHistory;

  /// Week period option
  ///
  /// In ru, this message translates to:
  /// **'Неделя'**
  String get periodWeek;

  /// Month period option
  ///
  /// In ru, this message translates to:
  /// **'Месяц'**
  String get periodMonth;

  /// Quarter period option
  ///
  /// In ru, this message translates to:
  /// **'Квартал'**
  String get periodQuarter;

  /// Year period option
  ///
  /// In ru, this message translates to:
  /// **'Год'**
  String get periodYear;

  /// Overview section title
  ///
  /// In ru, this message translates to:
  /// **'Обзор'**
  String get overview;

  /// Revenue label
  ///
  /// In ru, this message translates to:
  /// **'Выручка'**
  String get revenue;

  /// Average check label
  ///
  /// In ru, this message translates to:
  /// **'Средний чек'**
  String get averageCheck;

  /// No revenue data message
  ///
  /// In ru, this message translates to:
  /// **'Нет данных о выручке'**
  String get noRevenueData;

  /// Orders by status section
  ///
  /// In ru, this message translates to:
  /// **'Заказы по статусу'**
  String get ordersByStatus;

  /// In work status label
  ///
  /// In ru, this message translates to:
  /// **'В работе'**
  String get statusInWork;

  /// Done status label
  ///
  /// In ru, this message translates to:
  /// **'Выполнено'**
  String get statusDone;

  /// Waiting status label
  ///
  /// In ru, this message translates to:
  /// **'Ожидает'**
  String get statusWaiting;

  /// Cancelled status short label
  ///
  /// In ru, this message translates to:
  /// **'Отменено'**
  String get statusCancelledShort;

  /// No orders data message
  ///
  /// In ru, this message translates to:
  /// **'Нет данных о заказах'**
  String get noOrdersData;

  /// Top customers section
  ///
  /// In ru, this message translates to:
  /// **'Топ заказчики'**
  String get topCustomers;

  /// No customers data message
  ///
  /// In ru, this message translates to:
  /// **'Нет данных о заказчиках'**
  String get noCustomersData;

  /// Orders count short format
  ///
  /// In ru, this message translates to:
  /// **'{count} заказов'**
  String ordersCountShort(int count);

  /// No description provided for @avatarUpdated.
  ///
  /// In ru, this message translates to:
  /// **'Аватар обновлён'**
  String get avatarUpdated;

  /// No description provided for @avatarDeleted.
  ///
  /// In ru, this message translates to:
  /// **'Аватар удалён'**
  String get avatarDeleted;

  /// No description provided for @account.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт'**
  String get account;

  /// No description provided for @personalData.
  ///
  /// In ru, this message translates to:
  /// **'Личные данные'**
  String get personalData;

  /// No description provided for @nameEmailPhone.
  ///
  /// In ru, this message translates to:
  /// **'Имя, email, телефон'**
  String get nameEmailPhone;

  /// No description provided for @atelierData.
  ///
  /// In ru, this message translates to:
  /// **'Данные ателье'**
  String get atelierData;

  /// No description provided for @changePassword.
  ///
  /// In ru, this message translates to:
  /// **'Сменить пароль'**
  String get changePassword;

  /// No description provided for @changeCurrentPassword.
  ///
  /// In ru, this message translates to:
  /// **'Изменить текущий пароль'**
  String get changeCurrentPassword;

  /// No description provided for @appearance.
  ///
  /// In ru, this message translates to:
  /// **'Внешний вид'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In ru, this message translates to:
  /// **'Тема'**
  String get theme;

  /// No description provided for @themeLight.
  ///
  /// In ru, this message translates to:
  /// **'Светлая'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ru, this message translates to:
  /// **'Тёмная'**
  String get themeDark;

  /// No description provided for @themeAuto.
  ///
  /// In ru, this message translates to:
  /// **'Авто'**
  String get themeAuto;

  /// No description provided for @subscriptionActive.
  ///
  /// In ru, this message translates to:
  /// **'Активна'**
  String get subscriptionActive;

  /// No description provided for @subscriptionTrial.
  ///
  /// In ru, this message translates to:
  /// **'Пробный период'**
  String get subscriptionTrial;

  /// No description provided for @subscriptionExpired.
  ///
  /// In ru, this message translates to:
  /// **'Истекла'**
  String get subscriptionExpired;

  /// No description provided for @subscriptionFree.
  ///
  /// In ru, this message translates to:
  /// **'Бесплатный план'**
  String get subscriptionFree;

  /// No description provided for @manageSubscription.
  ///
  /// In ru, this message translates to:
  /// **'Управление подпиской'**
  String get manageSubscription;

  /// No description provided for @other.
  ///
  /// In ru, this message translates to:
  /// **'Другое'**
  String get other;

  /// No description provided for @notifications.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get notifications;

  /// No description provided for @pushEmailSms.
  ///
  /// In ru, this message translates to:
  /// **'Push, email, SMS'**
  String get pushEmailSms;

  /// No description provided for @helpSupport.
  ///
  /// In ru, this message translates to:
  /// **'Помощь и поддержка'**
  String get helpSupport;

  /// No description provided for @faqContactUs.
  ///
  /// In ru, this message translates to:
  /// **'FAQ, связаться с нами'**
  String get faqContactUs;

  /// No description provided for @aboutApp.
  ///
  /// In ru, this message translates to:
  /// **'О приложении'**
  String get aboutApp;

  /// No description provided for @version.
  ///
  /// In ru, this message translates to:
  /// **'Версия {version}'**
  String version(String version);

  /// No description provided for @aboutAppDescription.
  ///
  /// In ru, this message translates to:
  /// **'Приложение для управления ателье. Управляйте заказами, заказчиками и аналитикой в одном месте.'**
  String get aboutAppDescription;

  /// No description provided for @logoutAccount.
  ///
  /// In ru, this message translates to:
  /// **'Выйти из аккаунта'**
  String get logoutAccount;

  /// No description provided for @logoutTitle.
  ///
  /// In ru, this message translates to:
  /// **'Выход'**
  String get logoutTitle;

  /// No description provided for @logoutConfirmation.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите выйти из аккаунта?'**
  String get logoutConfirmation;

  /// No description provided for @logoutButton.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get logoutButton;

  /// No description provided for @currentPassword.
  ///
  /// In ru, this message translates to:
  /// **'Текущий пароль'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In ru, this message translates to:
  /// **'Новый пароль'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердите пароль'**
  String get confirmPassword;

  /// No description provided for @enterCurrentPassword.
  ///
  /// In ru, this message translates to:
  /// **'Введите текущий пароль'**
  String get enterCurrentPassword;

  /// No description provided for @enterNewPassword.
  ///
  /// In ru, this message translates to:
  /// **'Введите новый пароль'**
  String get enterNewPassword;

  /// No description provided for @minCharacters.
  ///
  /// In ru, this message translates to:
  /// **'Минимум {count} символов'**
  String minCharacters(int count);

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In ru, this message translates to:
  /// **'Пароли не совпадают'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordChanged.
  ///
  /// In ru, this message translates to:
  /// **'Пароль успешно изменён'**
  String get passwordChanged;

  /// No description provided for @expiresOn.
  ///
  /// In ru, this message translates to:
  /// **'до {date}'**
  String expiresOn(String date);

  /// No description provided for @transactions.
  ///
  /// In ru, this message translates to:
  /// **'Транзакции'**
  String get transactions;

  /// No description provided for @transactionEntriesCount.
  ///
  /// In ru, this message translates to:
  /// **'{count} записей'**
  String transactionEntriesCount(int count);

  /// No description provided for @noTransactions.
  ///
  /// In ru, this message translates to:
  /// **'Нет транзакций'**
  String get noTransactions;

  /// No description provided for @addFirstTransaction.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте первую транзакцию'**
  String get addFirstTransaction;

  /// No description provided for @transaction.
  ///
  /// In ru, this message translates to:
  /// **'Транзакция'**
  String get transaction;

  /// No description provided for @incomeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Доход'**
  String get incomeLabel;

  /// No description provided for @expenseLabel.
  ///
  /// In ru, this message translates to:
  /// **'Расход'**
  String get expenseLabel;

  /// No description provided for @allFilter.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get allFilter;

  /// No description provided for @incomesFilter.
  ///
  /// In ru, this message translates to:
  /// **'Доходы'**
  String get incomesFilter;

  /// No description provided for @expensesFilter.
  ///
  /// In ru, this message translates to:
  /// **'Расходы'**
  String get expensesFilter;

  /// No description provided for @filterTooltip.
  ///
  /// In ru, this message translates to:
  /// **'Фильтр'**
  String get filterTooltip;

  /// No description provided for @deleteTransactionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить транзакцию?'**
  String get deleteTransactionTitle;

  /// No description provided for @deleteTransactionMessage.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите удалить эту транзакцию на сумму {amount}?'**
  String deleteTransactionMessage(String amount);

  /// No description provided for @transactionDeleted.
  ///
  /// In ru, this message translates to:
  /// **'Транзакция удалена'**
  String get transactionDeleted;

  /// No description provided for @dateLabel.
  ///
  /// In ru, this message translates to:
  /// **'Дата'**
  String get dateLabel;

  /// No description provided for @description.
  ///
  /// In ru, this message translates to:
  /// **'Описание'**
  String get description;

  /// No description provided for @searchModels.
  ///
  /// In ru, this message translates to:
  /// **'Поиск моделей...'**
  String get searchModels;

  /// No description provided for @filterByCategory.
  ///
  /// In ru, this message translates to:
  /// **'Фильтр по категории'**
  String get filterByCategory;

  /// No description provided for @allCategories.
  ///
  /// In ru, this message translates to:
  /// **'Все категории'**
  String get allCategories;

  /// No description provided for @nothingFound.
  ///
  /// In ru, this message translates to:
  /// **'Ничего не найдено'**
  String get nothingFound;

  /// No description provided for @tryChangeSearchParams.
  ///
  /// In ru, this message translates to:
  /// **'Попробуйте изменить параметры поиска'**
  String get tryChangeSearchParams;

  /// No description provided for @noModels.
  ///
  /// In ru, this message translates to:
  /// **'Нет моделей'**
  String get noModels;

  /// No description provided for @addFirstModel.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте первую модель одежды'**
  String get addFirstModel;

  /// No description provided for @addModel.
  ///
  /// In ru, this message translates to:
  /// **'Добавить модель'**
  String get addModel;

  /// No description provided for @newModel.
  ///
  /// In ru, this message translates to:
  /// **'Новая модель'**
  String get newModel;

  /// No description provided for @deleteModelTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить модель?'**
  String get deleteModelTitle;

  /// No description provided for @deleteModelMessage.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите удалить \"{name}\"?'**
  String deleteModelMessage(String name);

  /// No description provided for @modelDeleted.
  ///
  /// In ru, this message translates to:
  /// **'Модель удалена'**
  String get modelDeleted;

  /// No description provided for @changeAction.
  ///
  /// In ru, this message translates to:
  /// **'Изменить'**
  String get changeAction;

  /// No description provided for @categoryDress.
  ///
  /// In ru, this message translates to:
  /// **'Платье'**
  String get categoryDress;

  /// No description provided for @categorySuit.
  ///
  /// In ru, this message translates to:
  /// **'Костюм'**
  String get categorySuit;

  /// No description provided for @categoryPants.
  ///
  /// In ru, this message translates to:
  /// **'Брюки'**
  String get categoryPants;

  /// No description provided for @categoryShirt.
  ///
  /// In ru, this message translates to:
  /// **'Рубашка'**
  String get categoryShirt;

  /// No description provided for @categorySkirt.
  ///
  /// In ru, this message translates to:
  /// **'Юбка'**
  String get categorySkirt;

  /// No description provided for @categoryCoat.
  ///
  /// In ru, this message translates to:
  /// **'Пальто'**
  String get categoryCoat;

  /// No description provided for @categoryOther.
  ///
  /// In ru, this message translates to:
  /// **'Другое'**
  String get categoryOther;

  /// No description provided for @calculationPeriod.
  ///
  /// In ru, this message translates to:
  /// **'Период расчёта'**
  String get calculationPeriod;

  /// No description provided for @fromLabel.
  ///
  /// In ru, this message translates to:
  /// **'С'**
  String get fromLabel;

  /// No description provided for @toLabel.
  ///
  /// In ru, this message translates to:
  /// **'По'**
  String get toLabel;

  /// No description provided for @calculating.
  ///
  /// In ru, this message translates to:
  /// **'Расчёт...'**
  String get calculating;

  /// No description provided for @calculate.
  ///
  /// In ru, this message translates to:
  /// **'Рассчитать'**
  String get calculate;

  /// No description provided for @salaryCalculated.
  ///
  /// In ru, this message translates to:
  /// **'Зарплата рассчитана'**
  String get salaryCalculated;

  /// No description provided for @totalToPay.
  ///
  /// In ru, this message translates to:
  /// **'Итого к выплате'**
  String get totalToPay;

  /// No description provided for @recordToFinance.
  ///
  /// In ru, this message translates to:
  /// **'Записать в финансы'**
  String get recordToFinance;

  /// No description provided for @employeePayments.
  ///
  /// In ru, this message translates to:
  /// **'Начисления по сотрудникам'**
  String get employeePayments;

  /// No description provided for @employee.
  ///
  /// In ru, this message translates to:
  /// **'Сотрудник'**
  String get employee;

  /// No description provided for @unknownRole.
  ///
  /// In ru, this message translates to:
  /// **'Неизвестная роль'**
  String get unknownRole;

  /// No description provided for @workDone.
  ///
  /// In ru, this message translates to:
  /// **'Выполненные работы'**
  String get workDone;

  /// No description provided for @calculationHistory.
  ///
  /// In ru, this message translates to:
  /// **'История расчётов'**
  String get calculationHistory;

  /// No description provided for @noCalculationHistory.
  ///
  /// In ru, this message translates to:
  /// **'Нет истории расчётов'**
  String get noCalculationHistory;

  /// No description provided for @recordedToFinance.
  ///
  /// In ru, this message translates to:
  /// **'Записано в финансы'**
  String get recordedToFinance;

  /// No description provided for @salaryDescriptionFormat.
  ///
  /// In ru, this message translates to:
  /// **'Зарплата ({period})'**
  String salaryDescriptionFormat(Object period);

  /// No description provided for @perHour.
  ///
  /// In ru, this message translates to:
  /// **'ч'**
  String get perHour;

  /// No description provided for @perPiece.
  ///
  /// In ru, this message translates to:
  /// **'шт'**
  String get perPiece;

  /// No description provided for @hoursShort.
  ///
  /// In ru, this message translates to:
  /// **'{hours} ч'**
  String hoursShort(String hours);

  /// No description provided for @piecesShort.
  ///
  /// In ru, this message translates to:
  /// **'{count} шт'**
  String piecesShort(int count);

  /// No description provided for @allEmployees.
  ///
  /// In ru, this message translates to:
  /// **'Все сотрудники'**
  String get allEmployees;

  /// No description provided for @totalPieces.
  ///
  /// In ru, this message translates to:
  /// **'Всего шт'**
  String get totalPieces;

  /// No description provided for @totalHours.
  ///
  /// In ru, this message translates to:
  /// **'Всего часов'**
  String get totalHours;

  /// No description provided for @recordsCount.
  ///
  /// In ru, this message translates to:
  /// **'Записей'**
  String get recordsCount;

  /// No description provided for @noRecords.
  ///
  /// In ru, this message translates to:
  /// **'Нет записей'**
  String get noRecords;

  /// No description provided for @tryChangeFilters.
  ///
  /// In ru, this message translates to:
  /// **'Попробуйте изменить фильтры'**
  String get tryChangeFilters;

  /// No description provided for @employeesNotRecordedWork.
  ///
  /// In ru, this message translates to:
  /// **'Сотрудники ещё не записывали работу'**
  String get employeesNotRecordedWork;

  /// No description provided for @unknown.
  ///
  /// In ru, this message translates to:
  /// **'Неизвестно'**
  String get unknown;

  /// No description provided for @currentPlan.
  ///
  /// In ru, this message translates to:
  /// **'Текущий план'**
  String get currentPlan;

  /// No description provided for @freePlan.
  ///
  /// In ru, this message translates to:
  /// **'Бесплатный план'**
  String get freePlan;

  /// No description provided for @somethingWentWrong.
  ///
  /// In ru, this message translates to:
  /// **'Что-то пошло не так'**
  String get somethingWentWrong;

  /// No description provided for @errorHappened.
  ///
  /// In ru, this message translates to:
  /// **'Произошла ошибка'**
  String get errorHappened;

  /// No description provided for @resourceUsage.
  ///
  /// In ru, this message translates to:
  /// **'Использование ресурсов'**
  String get resourceUsage;

  /// No description provided for @customersLabel.
  ///
  /// In ru, this message translates to:
  /// **'Заказчики'**
  String get customersLabel;

  /// No description provided for @employeesLabel.
  ///
  /// In ru, this message translates to:
  /// **'Сотрудники'**
  String get employeesLabel;

  /// No description provided for @unlimited.
  ///
  /// In ru, this message translates to:
  /// **'Безлимит'**
  String get unlimited;

  /// No description provided for @availablePlans.
  ///
  /// In ru, this message translates to:
  /// **'Доступные планы'**
  String get availablePlans;

  /// No description provided for @loadingPlans.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка планов...'**
  String get loadingPlans;

  /// No description provided for @activePlan.
  ///
  /// In ru, this message translates to:
  /// **'Активен'**
  String get activePlan;

  /// No description provided for @currentPlanButton.
  ///
  /// In ru, this message translates to:
  /// **'Текущий план'**
  String get currentPlanButton;

  /// No description provided for @selectPlan.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать план'**
  String get selectPlan;

  /// No description provided for @popular.
  ///
  /// In ru, this message translates to:
  /// **'Популярный'**
  String get popular;

  /// No description provided for @restorePurchases.
  ///
  /// In ru, this message translates to:
  /// **'Восстановить покупки'**
  String get restorePurchases;

  /// No description provided for @ofCustomers.
  ///
  /// In ru, this message translates to:
  /// **'заказчиков'**
  String get ofCustomers;

  /// No description provided for @ofEmployees.
  ///
  /// In ru, this message translates to:
  /// **'сотрудников'**
  String get ofEmployees;

  /// No description provided for @ateliers.
  ///
  /// In ru, this message translates to:
  /// **'Ателье'**
  String get ateliers;

  /// No description provided for @myAteliers.
  ///
  /// In ru, this message translates to:
  /// **'Мои ателье'**
  String get myAteliers;

  /// No description provided for @notLinkedToAtelier.
  ///
  /// In ru, this message translates to:
  /// **'Вы ещё не привязаны к ателье'**
  String get notLinkedToAtelier;

  /// No description provided for @linkToAtelierHint.
  ///
  /// In ru, this message translates to:
  /// **'Привяжитесь к ателье, чтобы создавать заказы'**
  String get linkToAtelierHint;

  /// No description provided for @featureComingSoon.
  ///
  /// In ru, this message translates to:
  /// **'Функция скоро будет доступна'**
  String get featureComingSoon;

  /// No description provided for @linkAtelier.
  ///
  /// In ru, this message translates to:
  /// **'Привязать ателье'**
  String get linkAtelier;

  /// No description provided for @noOrdersLabel.
  ///
  /// In ru, this message translates to:
  /// **'Нет заказов'**
  String get noOrdersLabel;

  /// No description provided for @oneOrder.
  ///
  /// In ru, this message translates to:
  /// **'1 заказ'**
  String get oneOrder;

  /// No description provided for @fewOrders.
  ///
  /// In ru, this message translates to:
  /// **'{count} заказа'**
  String fewOrders(int count);

  /// No description provided for @manyOrders.
  ///
  /// In ru, this message translates to:
  /// **'{count} заказов'**
  String manyOrders(int count);

  /// No description provided for @tasks.
  ///
  /// In ru, this message translates to:
  /// **'Задачи'**
  String get tasks;

  /// No description provided for @history.
  ///
  /// In ru, this message translates to:
  /// **'История'**
  String get history;

  /// No description provided for @myTasks.
  ///
  /// In ru, this message translates to:
  /// **'Мои задачи'**
  String get myTasks;

  /// No description provided for @inWork.
  ///
  /// In ru, this message translates to:
  /// **'В работе'**
  String get inWork;

  /// No description provided for @ready.
  ///
  /// In ru, this message translates to:
  /// **'Готовые'**
  String get ready;

  /// No description provided for @dateFilter.
  ///
  /// In ru, this message translates to:
  /// **'Фильтр по дате'**
  String get dateFilter;

  /// No description provided for @tasksCount.
  ///
  /// In ru, this message translates to:
  /// **'{count} задач'**
  String tasksCount(int count);

  /// No description provided for @noActiveTasks.
  ///
  /// In ru, this message translates to:
  /// **'Нет активных задач'**
  String get noActiveTasks;

  /// No description provided for @tasksWillAppearHere.
  ///
  /// In ru, this message translates to:
  /// **'Когда менеджер назначит вам заказ, он появится здесь'**
  String get tasksWillAppearHere;

  /// No description provided for @statusReady.
  ///
  /// In ru, this message translates to:
  /// **'Готов'**
  String get statusReady;

  /// No description provided for @works.
  ///
  /// In ru, this message translates to:
  /// **'Работы'**
  String get works;

  /// No description provided for @salary.
  ///
  /// In ru, this message translates to:
  /// **'Зарплата'**
  String get salary;

  /// No description provided for @noWorkRecords.
  ///
  /// In ru, this message translates to:
  /// **'Нет записей о работе'**
  String get noWorkRecords;

  /// No description provided for @workRecordsHint.
  ///
  /// In ru, this message translates to:
  /// **'Записи появятся после того, как вы начнёте работать'**
  String get workRecordsHint;

  /// No description provided for @noPayrollRecords.
  ///
  /// In ru, this message translates to:
  /// **'Нет расчётов'**
  String get noPayrollRecords;

  /// No description provided for @payrollRecordsHint.
  ///
  /// In ru, this message translates to:
  /// **'Когда менеджер рассчитает зарплату, информация появится здесь'**
  String get payrollRecordsHint;

  /// No description provided for @entriesCount.
  ///
  /// In ru, this message translates to:
  /// **'{count} записей'**
  String entriesCount(int count);

  /// No description provided for @rub.
  ///
  /// In ru, this message translates to:
  /// **'сом'**
  String get rub;

  /// No description provided for @details.
  ///
  /// In ru, this message translates to:
  /// **'Детализация'**
  String get details;

  /// No description provided for @hoursAbbr.
  ///
  /// In ru, this message translates to:
  /// **'ч'**
  String get hoursAbbr;

  /// No description provided for @contactInfo.
  ///
  /// In ru, this message translates to:
  /// **'Контактная информация'**
  String get contactInfo;

  /// No description provided for @phoneLabel.
  ///
  /// In ru, this message translates to:
  /// **'Телефон'**
  String get phoneLabel;

  /// No description provided for @workplace.
  ///
  /// In ru, this message translates to:
  /// **'Место работы'**
  String get workplace;

  /// No description provided for @atelierLabel.
  ///
  /// In ru, this message translates to:
  /// **'Ателье'**
  String get atelierLabel;

  /// No description provided for @activity.
  ///
  /// In ru, this message translates to:
  /// **'Активность'**
  String get activity;

  /// No description provided for @lastLogin.
  ///
  /// In ru, this message translates to:
  /// **'Последний вход'**
  String get lastLogin;

  /// No description provided for @justNow.
  ///
  /// In ru, this message translates to:
  /// **'Только что'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In ru, this message translates to:
  /// **'{minutes} мин. назад'**
  String minutesAgo(int minutes);

  /// No description provided for @hoursAgo.
  ///
  /// In ru, this message translates to:
  /// **'{hours} ч. назад'**
  String hoursAgo(int hours);

  /// No description provided for @daysAgo.
  ///
  /// In ru, this message translates to:
  /// **'{days} дн. назад'**
  String daysAgo(int days);

  /// No description provided for @logoutQuestion.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите выйти?'**
  String get logoutQuestion;

  /// No description provided for @appVersionEmployee.
  ///
  /// In ru, this message translates to:
  /// **'AteliePro Employee v1.0.0'**
  String get appVersionEmployee;

  /// FAQ section title
  ///
  /// In ru, this message translates to:
  /// **'Часто задаваемые вопросы'**
  String get faqTitle;

  /// Contact support section title
  ///
  /// In ru, this message translates to:
  /// **'Связаться с поддержкой'**
  String get contactSupport;

  /// App version label
  ///
  /// In ru, this message translates to:
  /// **'Версия приложения'**
  String get appVersion;

  /// Support email label
  ///
  /// In ru, this message translates to:
  /// **'Email поддержки'**
  String get supportEmail;

  /// Telegram channel label
  ///
  /// In ru, this message translates to:
  /// **'Telegram'**
  String get telegramChannel;

  /// FAQ question: how to create order
  ///
  /// In ru, this message translates to:
  /// **'Как создать заказ?'**
  String get faqCreateOrder;

  /// FAQ answer: how to create order
  ///
  /// In ru, this message translates to:
  /// **'Перейдите в раздел «Заказы» и нажмите кнопку «+» в правом нижнем углу. Выберите клиента, модель, укажите количество и срок выполнения.'**
  String get faqCreateOrderAnswer;

  /// FAQ question: how to add client
  ///
  /// In ru, this message translates to:
  /// **'Как добавить клиента?'**
  String get faqAddClient;

  /// FAQ answer: how to add client
  ///
  /// In ru, this message translates to:
  /// **'Перейдите в раздел «Заказчики» и нажмите кнопку «+». Заполните имя, телефон и email клиента.'**
  String get faqAddClientAnswer;

  /// FAQ question: how to manage employees
  ///
  /// In ru, this message translates to:
  /// **'Как управлять сотрудниками?'**
  String get faqManageEmployees;

  /// FAQ answer: how to manage employees
  ///
  /// In ru, this message translates to:
  /// **'В боковом меню выберите «Сотрудники». Здесь можно добавлять новых сотрудников, назначать роли и просматривать историю работы.'**
  String get faqManageEmployeesAnswer;

  /// FAQ question: how payroll works
  ///
  /// In ru, this message translates to:
  /// **'Как работает расчёт зарплаты?'**
  String get faqPayroll;

  /// FAQ answer: how payroll works
  ///
  /// In ru, this message translates to:
  /// **'Перейдите в раздел «Расчёт зарплаты», выберите период и нажмите «Рассчитать». Система автоматически рассчитает оплату на основе записей работы сотрудников.'**
  String get faqPayrollAnswer;

  /// FAQ question: how production works
  ///
  /// In ru, this message translates to:
  /// **'Как работает производство?'**
  String get faqProduction;

  /// FAQ answer: how production works
  ///
  /// In ru, this message translates to:
  /// **'Раздел «Производство» показывает текущие заказы в работе, их этапы и исполнителей. Сотрудники отмечают выполнение этапов в своём приложении.'**
  String get faqProductionAnswer;

  /// FAQ question: how to configure notifications
  ///
  /// In ru, this message translates to:
  /// **'Как настроить уведомления?'**
  String get faqNotifications;

  /// FAQ answer: how to configure notifications
  ///
  /// In ru, this message translates to:
  /// **'Перейдите в «Настройки» → «Уведомления». Вы можете включить или отключить push-уведомления о новых заказах, изменениях статуса и других событиях.'**
  String get faqNotificationsAnswer;

  /// FAQ question: how to manage subscription
  ///
  /// In ru, this message translates to:
  /// **'Как управлять подпиской?'**
  String get faqSubscription;

  /// FAQ answer: how to manage subscription
  ///
  /// In ru, this message translates to:
  /// **'В боковом меню выберите «Подписка». Здесь отображается текущий план, использование ресурсов и доступные тарифы для расширения возможностей.'**
  String get faqSubscriptionAnswer;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
