import 'package:flutter_test/flutter_test.dart';
import 'package:clothing_dashboard/core/models/client.dart';

void main() {
  group('ClientContact', () {
    test('fromJson parses all contact fields', () {
      final json = {
        'email': 'test@example.com',
        'phone': '+79001234567',
        'telegram': '@testuser',
        'whatsapp': '+79001234567',
      };

      final contact = ClientContact.fromJson(json);

      expect(contact.email, equals('test@example.com'));
      expect(contact.phone, equals('+79001234567'));
      expect(contact.telegram, equals('@testuser'));
      expect(contact.whatsapp, equals('+79001234567'));
    });

    test('fromJson handles null fields', () {
      final json = <String, dynamic>{};

      final contact = ClientContact.fromJson(json);

      expect(contact.email, isNull);
      expect(contact.phone, isNull);
      expect(contact.telegram, isNull);
      expect(contact.whatsapp, isNull);
    });

    test('toJson serializes all fields', () {
      final contact = ClientContact(
        email: 'test@example.com',
        phone: '+79001234567',
        telegram: '@testuser',
        whatsapp: '+79001234567',
      );

      final json = contact.toJson();

      expect(json['email'], equals('test@example.com'));
      expect(json['phone'], equals('+79001234567'));
      expect(json['telegram'], equals('@testuser'));
      expect(json['whatsapp'], equals('+79001234567'));
    });
  });

  group('ClientAssignedModel', () {
    test('fromJson parses correctly', () {
      final json = {
        'id': 'model-1',
        'name': 'Платье',
        'category': 'Женская одежда',
        'basePrice': 5000,
      };

      final model = ClientAssignedModel.fromJson(json);

      expect(model.id, equals('model-1'));
      expect(model.name, equals('Платье'));
      expect(model.category, equals('Женская одежда'));
      expect(model.basePrice, equals(5000.0));
    });

    test('fromJson handles int basePrice', () {
      final json = {
        'id': 'model-1',
        'name': 'Платье',
        'basePrice': 5000,
      };

      final model = ClientAssignedModel.fromJson(json);

      expect(model.basePrice, equals(5000.0));
    });

    test('fromJson handles null category', () {
      final json = {
        'id': 'model-1',
        'name': 'Платье',
        'basePrice': 5000,
      };

      final model = ClientAssignedModel.fromJson(json);

      expect(model.category, isNull);
    });
  });

  group('Client', () {
    final baseClientJson = {
      'id': 'client-1',
      'name': 'Анна Иванова',
      'contacts': {
        'email': 'anna@example.com',
        'phone': '+79001234567',
      },
      'createdAt': '2024-01-01T00:00:00Z',
      'updatedAt': '2024-01-02T00:00:00Z',
    };

    test('fromJson parses complete JSON correctly', () {
      final json = {
        ...baseClientJson,
        'notes': 'VIP клиент',
        'preferences': {'color': 'red', 'size': 'M'},
        'ordersCount': 15,
        'totalSpent': 75000.0,
        'assignedModelIds': ['model-1', 'model-2'],
        'assignedModels': [
          {
            'id': 'model-1',
            'name': 'Платье',
            'basePrice': 5000,
          },
        ],
      };

      final client = Client.fromJson(json);

      expect(client.id, equals('client-1'));
      expect(client.name, equals('Анна Иванова'));
      expect(client.contacts.email, equals('anna@example.com'));
      expect(client.contacts.phone, equals('+79001234567'));
      expect(client.notes, equals('VIP клиент'));
      expect(client.preferences, isNotNull);
      expect(client.preferences!['color'], equals('red'));
      expect(client.ordersCount, equals(15));
      expect(client.totalSpent, equals(75000.0));
      expect(client.assignedModelIds, equals(['model-1', 'model-2']));
      expect(client.assignedModels, hasLength(1));
      expect(client.assignedModels.first.name, equals('Платье'));
    });

    test('fromJson handles null optional fields', () {
      final client = Client.fromJson(baseClientJson);

      expect(client.notes, isNull);
      expect(client.preferences, isNull);
      expect(client.ordersCount, isNull);
      expect(client.totalSpent, isNull);
      expect(client.assignedModelIds, isEmpty);
      expect(client.assignedModels, isEmpty);
    });

    group('toJson', () {
      test('serializes required fields', () {
        final client = Client(
          id: 'client-1',
          name: 'Анна Иванова',
          contacts: ClientContact(email: 'anna@example.com'),
          createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
          updatedAt: DateTime.parse('2024-01-02T00:00:00Z'),
        );

        final json = client.toJson();

        expect(json['id'], equals('client-1'));
        expect(json['name'], equals('Анна Иванова'));
        expect(json['contacts'], isA<Map<String, dynamic>>());
        expect(json['contacts']['email'], equals('anna@example.com'));
      });

      test('includes preferences when present', () {
        final client = Client(
          id: 'client-1',
          name: 'Анна Иванова',
          contacts: ClientContact(),
          preferences: {'color': 'blue'},
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final json = client.toJson();

        expect(json['preferences'], equals({'color': 'blue'}));
      });
    });

    group('initials', () {
      test('returns first letters of two words', () {
        final client = Client(
          id: 'client-1',
          name: 'Анна Иванова',
          contacts: ClientContact(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(client.initials, equals('АИ'));
      });

      test('returns first two letters for single word name', () {
        final client = Client(
          id: 'client-1',
          name: 'Анна',
          contacts: ClientContact(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(client.initials, equals('АН'));
      });

      test('returns single letter for single character name', () {
        final client = Client(
          id: 'client-1',
          name: 'А',
          contacts: ClientContact(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(client.initials, equals('А'));
      });

      test('handles three word names', () {
        final client = Client(
          id: 'client-1',
          name: 'Анна Петровна Иванова',
          contacts: ClientContact(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(client.initials, equals('АП'));
      });
    });

    group('isVip', () {
      test('returns true when totalSpent > 50000', () {
        final client = Client(
          id: 'client-1',
          name: 'Test Client',
          contacts: ClientContact(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          totalSpent: 50001,
        );

        expect(client.isVip, isTrue);
      });

      test('returns true when ordersCount > 10', () {
        final client = Client(
          id: 'client-1',
          name: 'Test Client',
          contacts: ClientContact(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          ordersCount: 11,
        );

        expect(client.isVip, isTrue);
      });

      test('returns false when below thresholds', () {
        final client = Client(
          id: 'client-1',
          name: 'Test Client',
          contacts: ClientContact(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          totalSpent: 30000,
          ordersCount: 5,
        );

        expect(client.isVip, isFalse);
      });

      test('returns false when values are null', () {
        final client = Client(
          id: 'client-1',
          name: 'Test Client',
          contacts: ClientContact(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(client.isVip, isFalse);
      });

      test('returns true when exactly at 50000', () {
        final client = Client(
          id: 'client-1',
          name: 'Test Client',
          contacts: ClientContact(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          totalSpent: 50000,
        );

        // > 50000, not >=
        expect(client.isVip, isFalse);
      });
    });
  });
}
