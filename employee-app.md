# План: Режим сотрудника в приложении

## Обзор

Добавить возможность для сотрудников входить в приложение и самостоятельно записывать свою работу.

---

## Часть 1: Backend - Аутентификация сотрудников

### 1.1 Обновить модель Employee

**Файл:** `server/prisma/schema.prisma`

Добавить поля для аутентификации:

```prisma
model Employee {
  id          String            @id @default(auto()) @map("_id") @db.ObjectId
  tenantId    String            @db.ObjectId
  tenant      Tenant            @relation(fields: [tenantId], references: [id])
  name        String
  role        String
  phone       String?
  email       String?           @unique  // сделать уникальным для логина
  password    String?           // хэш пароля
  pin         String?           // 4-6 значный PIN для быстрого входа
  isActive    Boolean           @default(true)
  lastLoginAt DateTime?
  createdAt   DateTime          @default(now())
  updatedAt   DateTime          @updatedAt
  workLogs    WorkLog[]
  assignments OrderAssignment[]

  @@index([tenantId])
  @@index([email])
}
```

### 1.2 Создать модуль employee-auth

**Создать:** `server/src/employee-auth/`

Файлы:

- `employee-auth.module.ts`
- `employee-auth.controller.ts`
- `employee-auth.service.ts`
- `dto/employee-login.dto.ts`
- `dto/employee-pin-login.dto.ts`
- `guards/employee-jwt-auth.guard.ts`
- `strategies/employee-jwt.strategy.ts`

API endpoints:

- `POST /employee/auth/login` - вход по email + password
- `POST /employee/auth/pin-login` - вход по PIN (быстрый вход)
- `POST /employee/auth/logout` - выход
- `GET /employee/auth/me` - получить текущего сотрудника

### 1.3 Создать модуль employee-portal

**Создать:** `server/src/employee-portal/`

API endpoints для сотрудника:

- `GET /employee/portal/assignments` - мои назначения (активные заказы)
- `GET /employee/portal/assignments/:id` - детали назначения
- `POST /employee/portal/worklogs` - записать свою работу
- `GET /employee/portal/worklogs` - история моих работ
- `GET /employee/portal/stats` - моя статистика (за день/неделю/месяц)

---

## Часть 2: Flutter - Режим сотрудника

### 2.1 Экран выбора режима

**Файл:** `mobile_flutter/lib/features/auth/mode_selection_screen.dart` (NEW)

При первом запуске показать выбор:

- "Я менеджер/администратор"
- "Я сотрудник"
- "Я клиент"

### 2.2 Экран входа сотрудника

**Файл:** `mobile_flutter/lib/features/employee_mode/auth/employee_login_screen.dart` (NEW)

Два варианта входа:

1. Email + пароль
2. Быстрый вход по PIN (4-6 цифр)

UI:

```
[Логотип AteliePro]
[Вход для сотрудников]

[Email]
[Пароль]
[Войти]

--- или ---

[Введите PIN]
[● ● ● ●]
[Цифровая клавиатура]
```

### 2.3 Главный экран сотрудника (Shell)

**Файл:** `mobile_flutter/lib/features/employee_mode/shell/employee_app_shell.dart` (NEW)

Bottom Navigation:

1. **Мои задачи** - активные назначения
2. **История** - выполненные работы
3. **Профиль** - настройки, выход

### 2.4 Экран "Мои задачи"

**Файл:** `mobile_flutter/lib/features/employee_mode/tasks/my_tasks_screen.dart` (NEW)

Список карточек с назначениями:

```
[Заказ #12345 - Платье вечернее]
[Клиент: Иванова А.П.]
[Этап: Раскрой]
[Срок: 15 января]
[Записать работу →]
```

При нажатии открывается форма записи работы.

### 2.5 Экран записи работы

**Файл:** `mobile_flutter/lib/features/employee_mode/tasks/record_work_screen.dart` (NEW)

```
[Заказ: Платье вечернее #12345]
[Этап: Раскрой]

Количество выполненных единиц:
[___10___] шт.

Затраченное время:
[___2.5___] часов

Комментарий (опционально):
[_____________________]

[Сохранить]
```

### 2.6 Экран истории работ

**Файл:** `mobile_flutter/lib/features/employee_mode/history/work_history_screen.dart` (NEW)

Список выполненных работ с фильтрами:

- За сегодня
- За неделю
- За месяц

```
[5 января 2026]
├── Платье вечернее - Раскрой - 10 шт. - 2.5 ч.
├── Костюм мужской - Раскрой - 5 шт. - 1.5 ч.
└── Итого: 15 шт., 4 ч., 2500 ₽

[4 января 2026]
├── ...
```

### 2.7 Экран профиля сотрудника

**Файл:** `mobile_flutter/lib/features/employee_mode/profile/employee_profile_screen.dart` (NEW)

- Имя, роль
- Статистика за период
- Сменить PIN
- Выход

---

## Часть 3: Экран "Мои задачи" в режиме менеджера

Альтернативный вариант - добавить экран в существующее приложение менеджера.

### 3.1 Добавить вкладку в навигацию

**Файл:** `mobile_flutter/lib/features/shell/app_shell.dart`

Добавить вкладку "Задачи" в bottom navigation (если пользователь также является сотрудником).

### 3.2 Экран "Мои задачи" для менеджера

**Файл:** `mobile_flutter/lib/features/tasks/my_tasks_screen.dart` (NEW)

Показывает назначения текущего пользователя (если он связан с Employee).

---

## Часть 4: Связь User и Employee

### 4.1 Обновить схему

**Файл:** `server/prisma/schema.prisma`

Добавить связь:

```prisma
model User {
  // ... existing fields
  employeeId  String?   @db.ObjectId
  employee    Employee? @relation(fields: [employeeId], references: [id])
}

model Employee {
  // ... existing fields
  userId      String?   @db.ObjectId @unique
  user        User?     @relation(fields: [userId], references: [id])
}
```

Это позволит менеджеру, который также работает как сотрудник, видеть свои задачи.

---

## Порядок реализации

### Этап 1: Backend аутентификации (2-3 дня)

1. Обновить schema.prisma
2. Создать employee-auth module
3. Создать employee-portal module
4. Добавить в app.module.ts

### Этап 2: Flutter - режим сотрудника (3-4 дня)

1. Создать EmployeeProvider
2. Создать экран выбора режима
3. Создать экран входа
4. Создать shell с навигацией
5. Создать экран "Мои задачи"
6. Создать экран записи работы
7. Создать экран истории
8. Создать экран профиля

### Этап 3: Интеграция (1 день)

1. Обновить main.dart для поддержки режима сотрудника
2. Тестирование

---

## Файлы для создания

### Backend

- `server/src/employee-auth/employee-auth.module.ts`
- `server/src/employee-auth/employee-auth.controller.ts`
- `server/src/employee-auth/employee-auth.service.ts`
- `server/src/employee-auth/dto/employee-login.dto.ts`
- `server/src/employee-auth/guards/employee-jwt-auth.guard.ts`
- `server/src/employee-portal/employee-portal.module.ts`
- `server/src/employee-portal/employee-portal.controller.ts`
- `server/src/employee-portal/employee-portal.service.ts`

### Flutter

- `mobile_flutter/lib/core/providers/employee_provider.dart`
- `mobile_flutter/lib/features/auth/mode_selection_screen.dart`
- `mobile_flutter/lib/features/employee_mode/auth/employee_login_screen.dart`
- `mobile_flutter/lib/features/employee_mode/shell/employee_app_shell.dart`
- `mobile_flutter/lib/features/employee_mode/tasks/my_tasks_screen.dart`
- `mobile_flutter/lib/features/employee_mode/tasks/record_work_screen.dart`
- `mobile_flutter/lib/features/employee_mode/history/work_history_screen.dart`
- `mobile_flutter/lib/features/employee_mode/profile/employee_profile_screen.dart`

### Модификация

- `server/prisma/schema.prisma`
- `server/src/app.module.ts`
- `mobile_flutter/lib/main.dart`
- `mobile_flutter/lib/core/services/api_service.dart`

---

## Промпт для реализации

```
Реализуй режим сотрудника в приложении AteliePro согласно плану в employee-app.md:

1. Backend:
   - Добавь поля email (unique), password, pin, isActive в модель Employee
   - Создай модуль employee-auth с JWT аутентификацией для сотрудников
   - Создай модуль employee-portal с API для получения назначений и записи работы

2. Flutter:
   - Создай EmployeeProvider для управления состоянием сотрудника
   - Добавь режим "employee" в выбор режима приложения
   - Создай экраны: вход, мои задачи, запись работы, история, профиль
   - Создай employee_app_shell.dart с bottom navigation

3. Интеграция:
   - Обнови main.dart для поддержки режима сотрудника
   - Обнови api_service.dart с методами для employee API
```
