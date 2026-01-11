# План: Уведомления, ML прогнозы, Метрики

## Часть 1: Push-уведомления (OneSignal)

### Обзор

**Триггеры уведомлений:**

| Событие | Получатель | Текст |
|---------|------------|-------|
| Заказ создан | Менеджер | "Новый заказ №{id} от {client}" |
| Заказ принят (in_progress) | Клиент | "Ваш заказ №{id} принят в работу" |
| Заказ готов (completed) | Клиент | "Ваш заказ №{id} готов! Ждём вас" |
| Заказ отменён (cancelled) | Клиент | "Заказ №{id} отменён" |
| Заказ просрочен | Менеджер | "Заказ №{id} просрочен на {days} дн." |

### Ответ на вопрос: уведомление о просрочке без запроса на бекенд

**Да, есть 2 способа:**

1. **Локальные уведомления (flutter_local_notifications)**
   - При загрузке заказов сохраняем `dueDate` локально
   - Планируем локальное уведомление на `dueDate`
   - Работает офлайн, но только для уже загруженных заказов
   - Минус: не сработает если приложение не запускалось

2. **Cron-job на бекенде (рекомендуется)**
   - Ежедневно в 9:00 проверяем просроченные заказы
   - Отправляем push через OneSignal API
   - Работает всегда, даже если приложение не открывали

**Рекомендация:** Использовать оба:
- Cron-job для надёжности
- Локальные уведомления для напоминаний за день до срока

---

### 1.1 Backend

#### Установка OneSignal SDK
```bash
cd server
pnpm add onesignal-node
```

#### Схема Prisma - добавить поля
**Файл:** `server/prisma/schema.prisma`

```prisma
model User {
  // ... existing fields
  oneSignalPlayerId  String?   // OneSignal device ID
  pushEnabled        Boolean   @default(true)
}

model ClientUser {
  // ... existing fields
  oneSignalPlayerId  String?
  pushEnabled        Boolean   @default(true)
}

model NotificationLog {
  // ... existing fields
  pushId             String?   // OneSignal notification ID
  pushStatus         String?   // delivered, clicked, failed
}
```

#### Создать OneSignal Service
**Файл:** `server/src/notifications/onesignal.service.ts`

```typescript
import { Injectable } from '@nestjs/common';
import * as OneSignal from 'onesignal-node';

@Injectable()
export class OneSignalService {
  private client: OneSignal.Client;

  constructor() {
    this.client = new OneSignal.Client(
      process.env.ONESIGNAL_APP_ID,
      process.env.ONESIGNAL_API_KEY,
    );
  }

  // Отправка менеджеру
  async sendToManager(tenantId: string, title: string, message: string, data?: object) {
    // Получить всех менеджеров тенанта с pushEnabled = true
    // Отправить уведомление по playerIds
  }

  // Отправка клиенту
  async sendToClient(clientUserId: string, title: string, message: string, data?: object) {
    // Получить clientUser по ID
    // Отправить уведомление по playerId
  }

  // Отправка по теме (tag)
  async sendByTag(tag: string, value: string, title: string, message: string) {
    // Для массовой рассылки
  }
}
```

#### Интеграция в Orders Service
**Файл:** `server/src/orders/orders.service.ts`

```typescript
// При создании заказа
async createOrder(dto: CreateOrderDto) {
  const order = await this.prisma.order.create({ ... });

  // Уведомить менеджеров
  await this.oneSignalService.sendToManager(
    tenantId,
    'Новый заказ',
    `Заказ №${order.id.slice(-6)} от ${order.client.name}`,
    { orderId: order.id, type: 'new_order' }
  );

  return order;
}

// При смене статуса
async updateStatus(orderId: string, status: string) {
  const order = await this.prisma.order.update({ ... });

  if (order.client?.userId) {
    const messages = {
      'in_progress': { title: 'Заказ принят', body: 'Ваш заказ принят в работу' },
      'completed': { title: 'Заказ готов!', body: 'Ваш заказ готов. Ждём вас!' },
      'cancelled': { title: 'Заказ отменён', body: 'Ваш заказ был отменён' },
    };

    if (messages[status]) {
      await this.oneSignalService.sendToClient(
        order.client.userId,
        messages[status].title,
        messages[status].body,
        { orderId: order.id, type: 'order_status' }
      );
    }
  }

  return order;
}
```

#### Cron Job для просроченных заказов
**Файл:** `server/src/notifications/overdue-orders.cron.ts`

```typescript
import { Injectable } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';

@Injectable()
export class OverdueOrdersCron {
  constructor(
    private prisma: PrismaService,
    private oneSignal: OneSignalService,
  ) {}

  @Cron('0 9 * * *') // Каждый день в 9:00
  async checkOverdueOrders() {
    const overdueOrders = await this.prisma.order.findMany({
      where: {
        status: 'in_progress',
        dueDate: { lt: new Date() },
      },
      include: { client: true, tenant: true },
    });

    // Группируем по тенанту
    const byTenant = groupBy(overdueOrders, 'tenantId');

    for (const [tenantId, orders] of Object.entries(byTenant)) {
      await this.oneSignal.sendToManager(
        tenantId,
        `${orders.length} просроченных заказов`,
        `Заказы: ${orders.map(o => o.id.slice(-6)).join(', ')}`,
        { type: 'overdue_orders', orderIds: orders.map(o => o.id) }
      );
    }
  }
}
```

---

### 1.2 Flutter

#### Установка зависимостей
**Файл:** `mobile_flutter/pubspec.yaml`

```yaml
dependencies:
  onesignal_flutter: ^5.1.0
  flutter_local_notifications: ^16.0.0
```

#### Инициализация OneSignal
**Файл:** `mobile_flutter/lib/core/services/notification_service.dart`

```dart
import 'package:onesignal_flutter/onesignal_flutter.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  Future<void> init() async {
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize("YOUR_ONESIGNAL_APP_ID");

    // Запрос разрешения
    await OneSignal.Notifications.requestPermission(true);

    // Обработка нажатия на уведомление
    OneSignal.Notifications.addClickListener((event) {
      final data = event.notification.additionalData;
      _handleNotificationClick(data);
    });
  }

  // Получить playerId для отправки на сервер
  Future<String?> getPlayerId() async {
    return await OneSignal.User.getOnesignalId();
  }

  // Установить тег (для фильтрации)
  Future<void> setTenantTag(String tenantId) async {
    OneSignal.User.addTagWithKey("tenantId", tenantId);
  }

  // Установить тег роли
  Future<void> setRoleTag(String role) async {
    OneSignal.User.addTagWithKey("role", role); // manager, client, employee
  }

  void _handleNotificationClick(Map<String, dynamic>? data) {
    if (data == null) return;

    final type = data['type'];
    final orderId = data['orderId'];

    switch (type) {
      case 'new_order':
      case 'order_status':
        // Navigate to order detail
        NavigationService.navigateTo('/orders/$orderId');
        break;
      case 'overdue_orders':
        // Navigate to orders list with overdue filter
        NavigationService.navigateTo('/orders?filter=overdue');
        break;
    }
  }
}
```

#### Локальные уведомления (напоминания)
**Файл:** `mobile_flutter/lib/core/services/local_notification_service.dart`

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);
    await _plugin.initialize(settings);
  }

  // Запланировать напоминание за день до срока
  Future<void> scheduleOrderReminder(Order order) async {
    if (order.dueDate == null) return;

    final reminderDate = order.dueDate!.subtract(const Duration(days: 1));
    if (reminderDate.isBefore(DateTime.now())) return;

    await _plugin.zonedSchedule(
      order.id.hashCode,
      'Напоминание о заказе',
      'Заказ №${order.id.substring(order.id.length - 6)} - срок завтра!',
      tz.TZDateTime.from(reminderDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'order_reminders',
          'Напоминания о заказах',
          importance: Importance.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Отменить напоминание (если заказ выполнен)
  Future<void> cancelOrderReminder(String orderId) async {
    await _plugin.cancel(orderId.hashCode);
  }
}
```

#### Регистрация playerId на сервере
**Файл:** `mobile_flutter/lib/core/services/api_service.dart`

```dart
// Добавить метод
Future<void> registerPushToken(String playerId) async {
  await _request('POST', '/auth/push-token', body: {'playerId': playerId});
}
```

#### Интеграция в main.dart
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService().init();
  await LocalNotificationService().init();

  runApp(const AtelieProApp());
}
```

---

## Часть 2: ML Прогнозы

### Обзор функций

| Функция | Описание | Использование |
|---------|----------|---------------|
| Прогноз спроса | Предсказание заказов на следующий месяц | Планирование загрузки |
| Прогноз выручки | Предсказание дохода | Финансовое планирование |
| Рекомендации цен | Оптимальные цены на услуги | Ценообразование |
| Анализ клиентов | Сегментация, LTV | Маркетинг |

### 2.1 Backend

#### Улучшить ML Service
**Файл:** `server/src/ml/ml.service.ts`

```typescript
@Injectable()
export class MlService {
  // Прогноз спроса на основе исторических данных
  async forecastDemand(months: number = 3) {
    const tenantId = this.cls.get('tenantId');

    // Получить заказы за последний год
    const historicalOrders = await this.prisma.order.findMany({
      where: {
        tenantId,
        createdAt: { gte: subMonths(new Date(), 12) },
      },
    });

    // Группировка по месяцам
    const ordersByMonth = groupByMonth(historicalOrders);

    // Простая линейная регрессия
    const forecast = linearRegression(ordersByMonth, months);

    return {
      historical: ordersByMonth,
      forecast: forecast,
      confidence: 0.85,
    };
  }

  // Прогноз выручки
  async forecastRevenue(months: number = 3) {
    const tenantId = this.cls.get('tenantId');

    const transactions = await this.prisma.transaction.findMany({
      where: {
        tenantId,
        type: 'income',
        date: { gte: subMonths(new Date(), 12) },
      },
    });

    const revenueByMonth = groupByMonth(transactions, 'amount');
    const forecast = linearRegression(revenueByMonth, months);

    return {
      historical: revenueByMonth,
      forecast: forecast,
      confidence: 0.80,
    };
  }

  // Анализ клиентов (RFM)
  async analyzeClients() {
    const tenantId = this.cls.get('tenantId');

    const clients = await this.prisma.client.findMany({
      where: { tenantId },
      include: {
        orders: {
          where: { status: 'completed' },
        },
      },
    });

    return clients.map(client => {
      const orders = client.orders;
      const totalSpent = orders.reduce((sum, o) => sum + o.totalPrice, 0);
      const lastOrder = orders.sort((a, b) =>
        b.createdAt.getTime() - a.createdAt.getTime()
      )[0];

      const recency = lastOrder
        ? differenceInDays(new Date(), lastOrder.createdAt)
        : 999;
      const frequency = orders.length;
      const monetary = totalSpent;

      // RFM Score (1-5)
      const rScore = recency < 30 ? 5 : recency < 90 ? 4 : recency < 180 ? 3 : recency < 365 ? 2 : 1;
      const fScore = frequency > 10 ? 5 : frequency > 5 ? 4 : frequency > 3 ? 3 : frequency > 1 ? 2 : 1;
      const mScore = monetary > 100000 ? 5 : monetary > 50000 ? 4 : monetary > 20000 ? 3 : monetary > 5000 ? 2 : 1;

      const segment = getSegment(rScore, fScore, mScore);

      return {
        clientId: client.id,
        name: client.name,
        recency, frequency, monetary,
        rfmScore: `${rScore}${fScore}${mScore}`,
        segment, // "VIP", "Loyal", "At Risk", "Lost", etc.
        predictedLTV: monetary * (frequency / recency) * 365,
      };
    });
  }
}
```

#### API Endpoints
**Файл:** `server/src/ml/ml.controller.ts`

```typescript
@Controller('ml')
export class MlController {
  @Get('forecast/demand')
  forecastDemand(@Query('months') months: number) {
    return this.mlService.forecastDemand(months);
  }

  @Get('forecast/revenue')
  forecastRevenue(@Query('months') months: number) {
    return this.mlService.forecastRevenue(months);
  }

  @Get('clients/analysis')
  analyzeClients() {
    return this.mlService.analyzeClients();
  }
}
```

---

### 2.2 Flutter

#### Модели
**Файл:** `mobile_flutter/lib/core/models/ml_models.dart`

```dart
class DemandForecast {
  final List<MonthlyData> historical;
  final List<MonthlyData> forecast;
  final double confidence;
}

class MonthlyData {
  final DateTime month;
  final int count;
  final double amount;
}

class ClientAnalysis {
  final String clientId;
  final String name;
  final int recency;
  final int frequency;
  final double monetary;
  final String rfmScore;
  final String segment;
  final double predictedLTV;
}
```

#### API Methods
**Файл:** `mobile_flutter/lib/core/services/api_service.dart`

```dart
Future<DemandForecast> getForecastDemand({int months = 3}) async {
  final data = await _request('GET', '/ml/forecast/demand?months=$months');
  return DemandForecast.fromJson(data);
}

Future<DemandForecast> getForecastRevenue({int months = 3}) async {
  final data = await _request('GET', '/ml/forecast/revenue?months=$months');
  return DemandForecast.fromJson(data);
}

Future<List<ClientAnalysis>> getClientAnalysis() async {
  final data = await _request('GET', '/ml/clients/analysis');
  return (data as List).map((e) => ClientAnalysis.fromJson(e)).toList();
}
```

#### Экран прогнозов
**Файл:** `mobile_flutter/lib/features/ml/forecast_screen.dart`

```dart
class ForecastScreen extends StatefulWidget {
  // Показывает:
  // 1. График прогноза спроса (LineChart)
  // 2. График прогноза выручки (LineChart)
  // 3. Карточки с ключевыми прогнозами
}
```

#### Экран анализа клиентов
**Файл:** `mobile_flutter/lib/features/ml/client_analysis_screen.dart`

```dart
class ClientAnalysisScreen extends StatefulWidget {
  // Показывает:
  // 1. Сегменты клиентов (PieChart)
  // 2. Список клиентов с RFM скором
  // 3. Фильтр по сегментам
}
```

---

## Часть 3: Расширенные метрики

### Обзор метрик

| Метрика | Описание | Формула |
|---------|----------|---------|
| Конверсия | % заказов от обращений | completed / total |
| Средний чек | Средняя сумма заказа | revenue / orders |
| LTV | Пожизненная ценность клиента | avg_order * frequency |
| Retention | Удержание клиентов | returning / total |
| Загрузка | % занятости сотрудников | work_hours / available_hours |

### 3.1 Backend

#### Расширить Metrics Service
**Файл:** `server/src/metrics/metrics.service.ts`

```typescript
@Injectable()
export class MetricsService {
  // Бизнес-метрики ателье
  async getBusinessMetrics(period: 'week' | 'month' | 'year') {
    const tenantId = this.cls.get('tenantId');
    const startDate = getStartDate(period);

    // Заказы
    const orders = await this.prisma.order.findMany({
      where: { tenantId, createdAt: { gte: startDate } },
    });

    const completedOrders = orders.filter(o => o.status === 'completed');
    const cancelledOrders = orders.filter(o => o.status === 'cancelled');

    // Клиенты
    const clients = await this.prisma.client.findMany({
      where: { tenantId },
      include: { orders: true },
    });

    const newClients = clients.filter(c => c.createdAt >= startDate);
    const returningClients = clients.filter(c =>
      c.orders.filter(o => o.createdAt >= startDate).length > 1
    );

    // Сотрудники
    const workLogs = await this.prisma.workLog.findMany({
      where: { date: { gte: startDate }, order: { tenantId } },
    });
    const totalWorkHours = workLogs.reduce((sum, w) => sum + w.hours, 0);

    // Финансы
    const revenue = completedOrders.reduce((sum, o) => sum + o.totalPrice, 0);

    return {
      period,
      orders: {
        total: orders.length,
        completed: completedOrders.length,
        cancelled: cancelledOrders.length,
        conversionRate: orders.length > 0
          ? completedOrders.length / orders.length
          : 0,
      },
      revenue: {
        total: revenue,
        averageOrder: completedOrders.length > 0
          ? revenue / completedOrders.length
          : 0,
      },
      clients: {
        total: clients.length,
        new: newClients.length,
        returning: returningClients.length,
        retentionRate: clients.length > 0
          ? returningClients.length / clients.length
          : 0,
      },
      employees: {
        totalWorkHours,
        ordersPerHour: totalWorkHours > 0
          ? completedOrders.length / totalWorkHours
          : 0,
      },
    };
  }

  // Метрики по сотрудникам
  async getEmployeeMetrics(period: 'week' | 'month') {
    const tenantId = this.cls.get('tenantId');
    const startDate = getStartDate(period);

    const employees = await this.prisma.employee.findMany({
      where: { tenantId },
      include: {
        workLogs: {
          where: { date: { gte: startDate } },
          include: { order: true },
        },
      },
    });

    return employees.map(emp => {
      const logs = emp.workLogs;
      const totalHours = logs.reduce((sum, l) => sum + l.hours, 0);
      const totalUnits = logs.reduce((sum, l) => sum + l.quantity, 0);
      const uniqueOrders = new Set(logs.map(l => l.orderId)).size;

      return {
        employeeId: emp.id,
        name: emp.name,
        role: emp.role,
        metrics: {
          totalHours,
          totalUnits,
          ordersWorked: uniqueOrders,
          avgUnitsPerHour: totalHours > 0 ? totalUnits / totalHours : 0,
          efficiency: calculateEfficiency(logs),
        },
      };
    });
  }
}
```

---

### 3.2 Flutter

#### Модели метрик
**Файл:** `mobile_flutter/lib/core/models/metrics.dart`

```dart
class BusinessMetrics {
  final String period;
  final OrderMetrics orders;
  final RevenueMetrics revenue;
  final ClientMetrics clients;
  final EmployeeMetrics employees;
}

class OrderMetrics {
  final int total;
  final int completed;
  final int cancelled;
  final double conversionRate;
}

class EmployeePerformance {
  final String employeeId;
  final String name;
  final String role;
  final double totalHours;
  final int totalUnits;
  final int ordersWorked;
  final double avgUnitsPerHour;
  final double efficiency;
}
```

#### Экран метрик
**Файл:** `mobile_flutter/lib/features/metrics/metrics_screen.dart`

UI включает:
1. **Сводка KPI** - карточки с основными метриками
2. **Графики трендов** - сравнение периодов
3. **Таблица сотрудников** - производительность
4. **Переключатель периода** - неделя/месяц/год

---

## Файлы для создания

### Backend:
- `server/src/notifications/onesignal.service.ts`
- `server/src/notifications/overdue-orders.cron.ts`
- `server/src/ml/ml.service.ts` (обновить)
- `server/src/metrics/metrics.service.ts` (обновить)

### Flutter:
- `mobile_flutter/lib/core/services/notification_service.dart`
- `mobile_flutter/lib/core/services/local_notification_service.dart`
- `mobile_flutter/lib/core/models/ml_models.dart`
- `mobile_flutter/lib/core/models/metrics.dart`
- `mobile_flutter/lib/features/ml/forecast_screen.dart`
- `mobile_flutter/lib/features/ml/client_analysis_screen.dart`
- `mobile_flutter/lib/features/metrics/metrics_screen.dart`

---

## Порядок реализации

### Этап 1: Уведомления (2-3 дня)
1. Настроить OneSignal аккаунт
2. Backend: OneSignal service + интеграция в orders
3. Flutter: onesignal_flutter + регистрация токена
4. Тестирование push-уведомлений

### Этап 2: Cron для просроченных (1 день)
1. Backend: @nestjs/schedule + cron job
2. Тестирование ежедневной проверки

### Этап 3: Локальные уведомления (1 день)
1. Flutter: flutter_local_notifications
2. Планирование напоминаний при загрузке заказов

### Этап 4: ML прогнозы (2-3 дня)
1. Backend: алгоритмы прогнозирования
2. Flutter: экраны с графиками

### Этап 5: Метрики (2 дня)
1. Backend: расширенные метрики
2. Flutter: экран метрик с графиками

---

## Переменные окружения

```env
# OneSignal
ONESIGNAL_APP_ID=your-app-id
ONESIGNAL_API_KEY=your-rest-api-key
```
