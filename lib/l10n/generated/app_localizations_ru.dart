// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'АтельеПро';

  @override
  String get loading => 'Загрузка...';

  @override
  String get error => 'Ошибка';

  @override
  String get retry => 'Повторить';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get delete => 'Удалить';

  @override
  String get edit => 'Редактировать';

  @override
  String get close => 'Закрыть';

  @override
  String get search => 'Поиск';

  @override
  String get noResults => 'Ничего не найдено';

  @override
  String get connectionError => 'Ошибка подключения';

  @override
  String get connectionErrorMessage =>
      'Проверьте подключение к интернету и попробуйте снова';

  @override
  String get serverError => 'Ошибка сервера';

  @override
  String get serverErrorMessage =>
      'Произошла ошибка на сервере. Попробуйте позже';

  @override
  String get loginTabManager => 'Менеджер';

  @override
  String get loginTabClient => 'Заказчик';

  @override
  String get loginTabEmployee => 'Сотрудник';

  @override
  String get email => 'Email';

  @override
  String get password => 'Пароль';

  @override
  String get login => 'Войти';

  @override
  String get logout => 'Выйти';

  @override
  String get emailRequired => 'Введите email';

  @override
  String get emailInvalid => 'Некорректный email';

  @override
  String get passwordRequired => 'Введите пароль';

  @override
  String get passwordTooShort => 'Минимум 6 символов';

  @override
  String get home => 'Главная';

  @override
  String get orders => 'Заказы';

  @override
  String get clients => 'Клиенты';

  @override
  String get employees => 'Сотрудники';

  @override
  String get analytics => 'Аналитика';

  @override
  String get finance => 'Финансы';

  @override
  String get profile => 'Профиль';

  @override
  String get settings => 'Настройки';

  @override
  String get statusPending => 'Ожидает';

  @override
  String get statusInProgress => 'В работе';

  @override
  String get statusCompleted => 'Выполнен';

  @override
  String get statusCancelled => 'Отменён';

  @override
  String get activeOrders => 'Активные заказы';

  @override
  String get recentOrders => 'Последние заказы';

  @override
  String get totalOrders => 'Всего заказов';

  @override
  String get totalRevenue => 'Выручка';

  @override
  String get totalClients => 'Клиентов';

  @override
  String get newClients => 'Новых клиентов';

  @override
  String get addOrder => 'Добавить заказ';

  @override
  String get addClient => 'Добавить клиента';

  @override
  String get addEmployee => 'Добавить сотрудника';

  @override
  String get orderDetails => 'Детали заказа';

  @override
  String get clientDetails => 'Данные клиента';

  @override
  String get noOrders => 'Нет заказов';

  @override
  String get noClients => 'Нет клиентов';

  @override
  String get noEmployees => 'Нет сотрудников';

  @override
  String ordersInProgress(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count заказов в работе',
      few: '$count заказа в работе',
      one: '1 заказ в работе',
      zero: 'нет заказов в работе',
    );
    return '$_temp0';
  }

  @override
  String currency(String amount) {
    return '$amount ₽';
  }

  @override
  String daysRemaining(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'осталось $days дней',
      few: 'осталось $days дня',
      one: 'остался 1 день',
      zero: 'сегодня',
    );
    return '$_temp0';
  }

  @override
  String get overdue => 'Просрочен';

  @override
  String get today => 'Сегодня';

  @override
  String get yesterday => 'Вчера';

  @override
  String get quantity => 'Количество';

  @override
  String get price => 'Цена';

  @override
  String get dueDate => 'Срок';

  @override
  String get notes => 'Заметки';

  @override
  String get phone => 'Телефон';

  @override
  String get name => 'Имя';

  @override
  String get role => 'Роль';

  @override
  String get selectClient => 'Выберите клиента';

  @override
  String get selectModel => 'Выберите модель';

  @override
  String get models => 'Модели';

  @override
  String get payroll => 'Расчёт зарплаты';

  @override
  String get workLogs => 'Журнал работ';

  @override
  String get subscription => 'Подписка';

  @override
  String get ml => 'ML Аналитика';

  @override
  String get forecast => 'Прогноз';

  @override
  String get insights => 'Инсайты';

  @override
  String get report => 'Отчёт';

  @override
  String get darkMode => 'Тёмная тема';

  @override
  String get lightMode => 'Светлая тема';

  @override
  String get systemMode => 'Системная тема';

  @override
  String get confirmDelete => 'Подтвердите удаление';

  @override
  String get confirmDeleteMessage =>
      'Вы уверены, что хотите удалить этот элемент?';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get successSaved => 'Успешно сохранено';

  @override
  String get successDeleted => 'Успешно удалено';

  @override
  String get vipClient => 'VIP';

  @override
  String get errorOccurred => 'Произошла ошибка';

  @override
  String get atelierManagement => 'Управление ателье';

  @override
  String get registerAtelier => 'Регистрация ателье';

  @override
  String get loginManager => 'Вход для менеджера';

  @override
  String get fullBusinessControl => 'Полный контроль над бизнесом';

  @override
  String get registration => 'Регистрация';

  @override
  String get loginClient => 'Вход для заказчика';

  @override
  String get trackYourOrders => 'Отслеживание ваших заказов';

  @override
  String get loginEmployee => 'Вход для сотрудника';

  @override
  String get workAndEarningsTracking => 'Учёт работы и заработка';

  @override
  String get atelierName => 'Название ателье';

  @override
  String get myAtelierHint => 'Моё ателье';

  @override
  String get yourName => 'Ваше имя';

  @override
  String get enterName => 'Введите название';

  @override
  String get enterYourName => 'Введите имя';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get alreadyHaveAccount => 'Уже есть аккаунт?';

  @override
  String get noAccount => 'Нет аккаунта?';

  @override
  String get credentialsFromManager => 'Учётные данные выдаёт менеджер ателье';

  @override
  String get exampleEmailHint => 'example@mail.ru';

  @override
  String get exampleNameHint => 'Иван Иванов';

  @override
  String get searchHint => 'Поиск...';

  @override
  String get selectDates => 'Выбрать даты';

  @override
  String get dates => 'Даты';

  @override
  String get tomorrow => 'Завтра';

  @override
  String inDays(int days) {
    return 'Через $days дн.';
  }

  @override
  String orderNumber(String id) {
    return 'Заказ #$id';
  }

  @override
  String get clientPlaceholder => 'Заказчик';

  @override
  String quantityItems(int count) {
    return '$count шт.';
  }

  @override
  String ordersCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count заказов',
      few: '$count заказа',
      one: '1 заказ',
      zero: '0 заказов',
    );
    return '$_temp0';
  }

  @override
  String get dashboard => 'Дашборд';

  @override
  String get customers => 'Заказчики';

  @override
  String get workload => 'Загрузка';

  @override
  String get notFound => 'Не найдено';

  @override
  String get notFoundMessage => 'Запрашиваемые данные не найдены';

  @override
  String get back => 'Назад';

  @override
  String get continue_ => 'Продолжить';

  @override
  String get camera => 'Камера';

  @override
  String get gallery => 'Галерея';

  @override
  String get add => 'Добавить';

  @override
  String get modelPhoto => 'Фото модели';

  @override
  String get confirmation => 'Подтверждение';

  @override
  String get roleTailor => 'Портной';

  @override
  String get roleDesigner => 'Дизайнер';

  @override
  String get roleCutter => 'Раскройщик';

  @override
  String get roleSeamstress => 'Швея';

  @override
  String get roleFinisher => 'Отделочник';

  @override
  String get rolePresser => 'Гладильщик';

  @override
  String get roleQualityControl => 'ОТК';

  @override
  String get executorLabel => 'Исполнитель';

  @override
  String get category => 'Категория';

  @override
  String get selectCategory => 'Выберите категорию';

  @override
  String get goodMorning => 'Доброе утро';

  @override
  String get goodAfternoon => 'Добрый день';

  @override
  String get goodEvening => 'Добрый вечер';

  @override
  String youHaveOrdersInProgress(String orders) {
    return 'У вас $orders в работе';
  }

  @override
  String get indicators => 'Показатели';

  @override
  String get monthlyIncome => 'Доход за месяц';

  @override
  String get monthlyFinance => 'Финансы за месяц';

  @override
  String get income => 'Доходы';

  @override
  String get expenses => 'Расходы';

  @override
  String get profit => 'Прибыль';

  @override
  String get all => 'Все';

  @override
  String get ordersWillAppearHere => 'Здесь появятся ваши последние заказы';

  @override
  String get quickActions => 'Быстрые действия';

  @override
  String get newOrder => 'Новый заказ';

  @override
  String get newCustomer => 'Новый заказчик';

  @override
  String get comingSoon => 'Скоро будет доступно';

  @override
  String get notificationsComingSoon => 'Уведомления скоро будут доступны';

  @override
  String get orderCreationComingSoon => 'Создание заказа скоро будет доступно';

  @override
  String get customerAdditionComingSoon =>
      'Добавление заказчика скоро будет доступно';

  @override
  String get workRecords => 'Записи работы';

  @override
  String get help => 'Помощь';

  @override
  String get filters => 'Фильтры';

  @override
  String get searchOrders => 'Поиск заказов...';

  @override
  String get tabPending => 'Ожидают';

  @override
  String get tabCompleted => 'Готово';

  @override
  String get tabCancelled => 'Отменены';

  @override
  String get noOrdersWithStatus => 'Нет заказов с этим статусом';

  @override
  String get tryDifferentSearch => 'Попробуйте изменить поисковый запрос';

  @override
  String get createFirstOrder => 'Создайте первый заказ';

  @override
  String get createOrder => 'Создать заказ';

  @override
  String get reset => 'Сбросить';

  @override
  String get dueDateLabel => 'Срок сдачи';

  @override
  String get allDates => 'Все даты';

  @override
  String get createdDateLabel => 'Дата создания';

  @override
  String get sortLabel => 'Сортировка';

  @override
  String get sortByCreatedDate => 'По дате создания';

  @override
  String get sortByDueDate => 'По сроку';

  @override
  String get sortByQuantity => 'По кол-ву';

  @override
  String get sortDescending => 'По убыванию';

  @override
  String get sortAscending => 'По возрастанию';

  @override
  String get apply => 'Применить';

  @override
  String get searchCustomers => 'Поиск заказчиков...';

  @override
  String get sortByName => 'По имени';

  @override
  String get sortByOrders => 'По заказам';

  @override
  String get sortByAmount => 'По сумме';

  @override
  String get noCustomers => 'Нет заказчиков';

  @override
  String get addFirstCustomer => 'Добавьте первого заказчика';

  @override
  String get customersNotAdded => 'Заказчики пока не добавлены';

  @override
  String get addCustomer => 'Добавить заказчика';

  @override
  String customerSince(String date) {
    return 'Заказчик с $date';
  }

  @override
  String get ordersCountLabel => 'Заказов';

  @override
  String get spent => 'Потрачено';

  @override
  String get availableModels => 'Доступные модели';

  @override
  String get configure => 'Настроить';

  @override
  String get noModelsAssigned => 'Модели не назначены';

  @override
  String get clientCanOrderAnyModel => 'Заказчик может заказывать любые модели';

  @override
  String get contacts => 'Контакты';

  @override
  String get editAction => 'Изменить';

  @override
  String get selectModelsHint =>
      'Выберите модели, которые заказчик сможет заказать. Если ни одна модель не выбрана - доступны все.';

  @override
  String get couldNotLoadModels => 'Не удалось загрузить модели';

  @override
  String get noAvailableModels => 'Нет доступных моделей';

  @override
  String saveWithCount(int count) {
    return 'Сохранить ($count)';
  }

  @override
  String get telegram => 'Telegram';

  @override
  String get filterByRole => 'Фильтр по роли';

  @override
  String get allRoles => 'Все роли';

  @override
  String get searchEmployees => 'Поиск сотрудников...';

  @override
  String get activeEmployees => 'Активные';

  @override
  String get inactiveEmployees => 'Неактивные';

  @override
  String loadingError(String message) {
    return 'Ошибка загрузки: $message';
  }

  @override
  String get tryDifferentFilters => 'Попробуйте изменить параметры поиска';

  @override
  String get addFirstEmployee => 'Добавьте первого сотрудника';

  @override
  String get deleteEmployeeTitle => 'Удалить сотрудника?';

  @override
  String deleteEmployeeMessage(String name) {
    return 'Вы уверены, что хотите удалить \"$name\"?';
  }

  @override
  String get employeeDeleted => 'Сотрудник удалён';

  @override
  String get workHistory => 'История работы';

  @override
  String get periodWeek => 'Неделя';

  @override
  String get periodMonth => 'Месяц';

  @override
  String get periodQuarter => 'Квартал';

  @override
  String get periodYear => 'Год';

  @override
  String get overview => 'Обзор';

  @override
  String get revenue => 'Выручка';

  @override
  String get averageCheck => 'Средний чек';

  @override
  String get noRevenueData => 'Нет данных о выручке';

  @override
  String get ordersByStatus => 'Заказы по статусу';

  @override
  String get statusInWork => 'В работе';

  @override
  String get statusDone => 'Выполнено';

  @override
  String get statusWaiting => 'Ожидает';

  @override
  String get statusCancelledShort => 'Отменено';

  @override
  String get noOrdersData => 'Нет данных о заказах';

  @override
  String get topCustomers => 'Топ заказчики';

  @override
  String get noCustomersData => 'Нет данных о заказчиках';

  @override
  String ordersCountShort(int count) {
    return '$count заказов';
  }

  @override
  String get avatarUpdated => 'Аватар обновлён';

  @override
  String get avatarDeleted => 'Аватар удалён';

  @override
  String get account => 'Аккаунт';

  @override
  String get personalData => 'Личные данные';

  @override
  String get nameEmailPhone => 'Имя, email, телефон';

  @override
  String get atelierData => 'Данные ателье';

  @override
  String get changePassword => 'Сменить пароль';

  @override
  String get changeCurrentPassword => 'Изменить текущий пароль';

  @override
  String get appearance => 'Внешний вид';

  @override
  String get theme => 'Тема';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get themeAuto => 'Авто';

  @override
  String get subscriptionActive => 'Активна';

  @override
  String get subscriptionTrial => 'Пробный период';

  @override
  String get subscriptionExpired => 'Истекла';

  @override
  String get subscriptionFree => 'Бесплатный план';

  @override
  String get manageSubscription => 'Управление подпиской';

  @override
  String get other => 'Другое';

  @override
  String get notifications => 'Уведомления';

  @override
  String get pushEmailSms => 'Push, email, SMS';

  @override
  String get helpSupport => 'Помощь и поддержка';

  @override
  String get faqContactUs => 'FAQ, связаться с нами';

  @override
  String get aboutApp => 'О приложении';

  @override
  String version(String version) {
    return 'Версия $version';
  }

  @override
  String get aboutAppDescription =>
      'Приложение для управления ателье. Управляйте заказами, заказчиками и аналитикой в одном месте.';

  @override
  String get logoutAccount => 'Выйти из аккаунта';

  @override
  String get logoutTitle => 'Выход';

  @override
  String get logoutConfirmation => 'Вы уверены, что хотите выйти из аккаунта?';

  @override
  String get logoutButton => 'Выйти';

  @override
  String get currentPassword => 'Текущий пароль';

  @override
  String get newPassword => 'Новый пароль';

  @override
  String get confirmPassword => 'Подтвердите пароль';

  @override
  String get enterCurrentPassword => 'Введите текущий пароль';

  @override
  String get enterNewPassword => 'Введите новый пароль';

  @override
  String minCharacters(int count) {
    return 'Минимум $count символов';
  }

  @override
  String get passwordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get passwordChanged => 'Пароль успешно изменён';

  @override
  String expiresOn(String date) {
    return 'до $date';
  }

  @override
  String get transactions => 'Транзакции';

  @override
  String transactionEntriesCount(int count) {
    return '$count записей';
  }

  @override
  String get noTransactions => 'Нет транзакций';

  @override
  String get addFirstTransaction => 'Добавьте первую транзакцию';

  @override
  String get transaction => 'Транзакция';

  @override
  String get incomeLabel => 'Доход';

  @override
  String get expenseLabel => 'Расход';

  @override
  String get allFilter => 'Все';

  @override
  String get incomesFilter => 'Доходы';

  @override
  String get expensesFilter => 'Расходы';

  @override
  String get filterTooltip => 'Фильтр';

  @override
  String get deleteTransactionTitle => 'Удалить транзакцию?';

  @override
  String deleteTransactionMessage(String amount) {
    return 'Вы уверены, что хотите удалить эту транзакцию на сумму $amount?';
  }

  @override
  String get transactionDeleted => 'Транзакция удалена';

  @override
  String get dateLabel => 'Дата';

  @override
  String get description => 'Описание';

  @override
  String get searchModels => 'Поиск моделей...';

  @override
  String get filterByCategory => 'Фильтр по категории';

  @override
  String get allCategories => 'Все категории';

  @override
  String get nothingFound => 'Ничего не найдено';

  @override
  String get tryChangeSearchParams => 'Попробуйте изменить параметры поиска';

  @override
  String get noModels => 'Нет моделей';

  @override
  String get addFirstModel => 'Добавьте первую модель одежды';

  @override
  String get addModel => 'Добавить модель';

  @override
  String get newModel => 'Новая модель';

  @override
  String get deleteModelTitle => 'Удалить модель?';

  @override
  String deleteModelMessage(String name) {
    return 'Вы уверены, что хотите удалить \"$name\"?';
  }

  @override
  String get modelDeleted => 'Модель удалена';

  @override
  String get changeAction => 'Изменить';

  @override
  String get categoryDress => 'Платье';

  @override
  String get categorySuit => 'Костюм';

  @override
  String get categoryPants => 'Брюки';

  @override
  String get categoryShirt => 'Рубашка';

  @override
  String get categorySkirt => 'Юбка';

  @override
  String get categoryCoat => 'Пальто';

  @override
  String get categoryOther => 'Другое';

  @override
  String get calculationPeriod => 'Период расчёта';

  @override
  String get fromLabel => 'С';

  @override
  String get toLabel => 'По';

  @override
  String get calculating => 'Расчёт...';

  @override
  String get calculate => 'Рассчитать';

  @override
  String get salaryCalculated => 'Зарплата рассчитана';

  @override
  String get totalToPay => 'Итого к выплате';

  @override
  String get recordToFinance => 'Записать в финансы';

  @override
  String get employeePayments => 'Начисления по сотрудникам';

  @override
  String get employee => 'Сотрудник';

  @override
  String get unknownRole => 'Неизвестная роль';

  @override
  String get workDone => 'Выполненные работы';

  @override
  String get calculationHistory => 'История расчётов';

  @override
  String get noCalculationHistory => 'Нет истории расчётов';

  @override
  String get recordedToFinance => 'Записано в финансы';

  @override
  String salaryDescriptionFormat(Object period) {
    return 'Зарплата ($period)';
  }

  @override
  String get perHour => 'ч';

  @override
  String get perPiece => 'шт';

  @override
  String hoursShort(String hours) {
    return '$hours ч';
  }

  @override
  String piecesShort(int count) {
    return '$count шт';
  }

  @override
  String get allEmployees => 'Все сотрудники';

  @override
  String get totalPieces => 'Всего шт';

  @override
  String get totalHours => 'Всего часов';

  @override
  String get recordsCount => 'Записей';

  @override
  String get noRecords => 'Нет записей';

  @override
  String get tryChangeFilters => 'Попробуйте изменить фильтры';

  @override
  String get employeesNotRecordedWork => 'Сотрудники ещё не записывали работу';

  @override
  String get unknown => 'Неизвестно';

  @override
  String get currentPlan => 'Текущий план';

  @override
  String get freePlan => 'Бесплатный план';

  @override
  String get somethingWentWrong => 'Что-то пошло не так';

  @override
  String get errorHappened => 'Произошла ошибка';

  @override
  String get resourceUsage => 'Использование ресурсов';

  @override
  String get customersLabel => 'Заказчики';

  @override
  String get employeesLabel => 'Сотрудники';

  @override
  String get unlimited => 'Безлимит';

  @override
  String get availablePlans => 'Доступные планы';

  @override
  String get loadingPlans => 'Загрузка планов...';

  @override
  String get activePlan => 'Активен';

  @override
  String get currentPlanButton => 'Текущий план';

  @override
  String get selectPlan => 'Выбрать план';

  @override
  String get popular => 'Популярный';

  @override
  String get restorePurchases => 'Восстановить покупки';

  @override
  String get ofCustomers => 'заказчиков';

  @override
  String get ofEmployees => 'сотрудников';

  @override
  String get ateliers => 'Ателье';

  @override
  String get myAteliers => 'Мои ателье';

  @override
  String get notLinkedToAtelier => 'Вы ещё не привязаны к ателье';

  @override
  String get linkToAtelierHint =>
      'Привяжитесь к ателье, чтобы создавать заказы';

  @override
  String get featureComingSoon => 'Функция скоро будет доступна';

  @override
  String get linkAtelier => 'Привязать ателье';

  @override
  String get noOrdersLabel => 'Нет заказов';

  @override
  String get oneOrder => '1 заказ';

  @override
  String fewOrders(int count) {
    return '$count заказа';
  }

  @override
  String manyOrders(int count) {
    return '$count заказов';
  }

  @override
  String get tasks => 'Задачи';

  @override
  String get history => 'История';

  @override
  String get myTasks => 'Мои задачи';

  @override
  String get inWork => 'В работе';

  @override
  String get ready => 'Готовые';

  @override
  String get dateFilter => 'Фильтр по дате';

  @override
  String tasksCount(int count) {
    return '$count задач';
  }

  @override
  String get noActiveTasks => 'Нет активных задач';

  @override
  String get tasksWillAppearHere =>
      'Когда менеджер назначит вам заказ, он появится здесь';

  @override
  String get statusReady => 'Готов';

  @override
  String get works => 'Работы';

  @override
  String get salary => 'Зарплата';

  @override
  String get noWorkRecords => 'Нет записей о работе';

  @override
  String get workRecordsHint =>
      'Записи появятся после того, как вы начнёте работать';

  @override
  String get noPayrollRecords => 'Нет расчётов';

  @override
  String get payrollRecordsHint =>
      'Когда менеджер рассчитает зарплату, информация появится здесь';

  @override
  String entriesCount(int count) {
    return '$count записей';
  }

  @override
  String get rub => 'руб';

  @override
  String get details => 'Детализация';

  @override
  String get hoursAbbr => 'ч';

  @override
  String get contactInfo => 'Контактная информация';

  @override
  String get phoneLabel => 'Телефон';

  @override
  String get workplace => 'Место работы';

  @override
  String get atelierLabel => 'Ателье';

  @override
  String get activity => 'Активность';

  @override
  String get lastLogin => 'Последний вход';

  @override
  String get justNow => 'Только что';

  @override
  String minutesAgo(int minutes) {
    return '$minutes мин. назад';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours ч. назад';
  }

  @override
  String daysAgo(int days) {
    return '$days дн. назад';
  }

  @override
  String get logoutQuestion => 'Вы уверены, что хотите выйти?';

  @override
  String get appVersionEmployee => 'AteliePro Employee v1.0.0';
}
