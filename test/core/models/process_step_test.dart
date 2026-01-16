import 'package:flutter_test/flutter_test.dart';
import 'package:clothing_dashboard/core/models/process_step.dart';

void main() {
  group('ProcessStep', () {
    final baseStepJson = {
      'id': 'step-1',
      'modelId': 'model-1',
      'stepOrder': 1,
      'name': 'Раскрой',
      'estimatedTime': 60,
      'executorRole': 'cutter',
      'createdAt': '2024-01-01T00:00:00Z',
      'updatedAt': '2024-01-02T00:00:00Z',
    };

    test('fromJson parses complete JSON correctly', () {
      final json = {
        ...baseStepJson,
        'rate': 500,
        'rateType': 'per_unit',
      };

      final step = ProcessStep.fromJson(json);

      expect(step.id, equals('step-1'));
      expect(step.modelId, equals('model-1'));
      expect(step.stepOrder, equals(1));
      expect(step.name, equals('Раскрой'));
      expect(step.estimatedTime, equals(60));
      expect(step.executorRole, equals('cutter'));
      expect(step.rate, equals(500.0));
      expect(step.rateType, equals('per_unit'));
      expect(step.createdAt, equals(DateTime.parse('2024-01-01T00:00:00Z')));
      expect(step.updatedAt, equals(DateTime.parse('2024-01-02T00:00:00Z')));
    });

    test('fromJson handles null optional fields', () {
      final step = ProcessStep.fromJson(baseStepJson);

      expect(step.rate, isNull);
      expect(step.rateType, isNull);
    });

    group('toJson', () {
      test('serializes all fields', () {
        final step = ProcessStep(
          id: 'step-1',
          modelId: 'model-1',
          stepOrder: 1,
          name: 'Раскрой',
          estimatedTime: 60,
          executorRole: 'cutter',
          rate: 500,
          rateType: 'per_unit',
          createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
          updatedAt: DateTime.parse('2024-01-02T00:00:00Z'),
        );

        final json = step.toJson();

        expect(json['id'], equals('step-1'));
        expect(json['modelId'], equals('model-1'));
        expect(json['stepOrder'], equals(1));
        expect(json['name'], equals('Раскрой'));
        expect(json['estimatedTime'], equals(60));
        expect(json['executorRole'], equals('cutter'));
        expect(json['rate'], equals(500));
        expect(json['rateType'], equals('per_unit'));
        expect(json['createdAt'], isNotNull);
        expect(json['updatedAt'], isNotNull);
      });

      test('omits rate and rateType when null', () {
        final step = ProcessStep(
          id: 'step-1',
          modelId: 'model-1',
          stepOrder: 1,
          name: 'Раскрой',
          estimatedTime: 60,
          executorRole: 'cutter',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final json = step.toJson();

        expect(json.containsKey('rate'), isFalse);
        expect(json.containsKey('rateType'), isFalse);
      });
    });

    group('rateTypeLabel', () {
      test('returns "за единицу" for per_unit', () {
        final step = ProcessStep.fromJson({...baseStepJson, 'rateType': 'per_unit'});
        expect(step.rateTypeLabel, equals('за единицу'));
      });

      test('returns "за час" for per_hour', () {
        final step = ProcessStep.fromJson({...baseStepJson, 'rateType': 'per_hour'});
        expect(step.rateTypeLabel, equals('за час'));
      });

      test('returns empty string for unknown/null rateType', () {
        final step = ProcessStep.fromJson(baseStepJson);
        expect(step.rateTypeLabel, equals(''));
      });
    });

    group('executorRoleLabel', () {
      test('returns Russian labels for known roles', () {
        expect(
          ProcessStep.fromJson({...baseStepJson, 'executorRole': 'tailor'}).executorRoleLabel,
          equals('Портной'),
        );
        expect(
          ProcessStep.fromJson({...baseStepJson, 'executorRole': 'designer'}).executorRoleLabel,
          equals('Дизайнер'),
        );
        expect(
          ProcessStep.fromJson({...baseStepJson, 'executorRole': 'cutter'}).executorRoleLabel,
          equals('Раскройщик'),
        );
        expect(
          ProcessStep.fromJson({...baseStepJson, 'executorRole': 'seamstress'}).executorRoleLabel,
          equals('Швея'),
        );
        expect(
          ProcessStep.fromJson({...baseStepJson, 'executorRole': 'finisher'}).executorRoleLabel,
          equals('Отделочник'),
        );
        expect(
          ProcessStep.fromJson({...baseStepJson, 'executorRole': 'presser'}).executorRoleLabel,
          equals('Гладильщик'),
        );
        expect(
          ProcessStep.fromJson({...baseStepJson, 'executorRole': 'quality'}).executorRoleLabel,
          equals('ОТК'),
        );
      });

      test('returns raw role for unknown roles', () {
        final step = ProcessStep.fromJson({...baseStepJson, 'executorRole': 'custom_role'});
        expect(step.executorRoleLabel, equals('custom_role'));
      });
    });

    group('formattedRate', () {
      test('returns "Не указана" when rate is null', () {
        final step = ProcessStep.fromJson(baseStepJson);
        expect(step.formattedRate, equals('Не указана'));
      });

      test('formats rate with rateType label', () {
        final step = ProcessStep.fromJson({
          ...baseStepJson,
          'rate': 500,
          'rateType': 'per_unit',
        });
        expect(step.formattedRate, equals('500 руб. за единицу'));
      });

      test('formats rate with per_hour label', () {
        final step = ProcessStep.fromJson({
          ...baseStepJson,
          'rate': 300,
          'rateType': 'per_hour',
        });
        expect(step.formattedRate, equals('300 руб. за час'));
      });
    });

    group('formattedTime', () {
      test('formats minutes only when < 60', () {
        final step = ProcessStep.fromJson({...baseStepJson, 'estimatedTime': 45});
        expect(step.formattedTime, equals('45 мин'));
      });

      test('formats hours only when exact hours', () {
        final step = ProcessStep.fromJson({...baseStepJson, 'estimatedTime': 120});
        expect(step.formattedTime, equals('2 ч'));
      });

      test('formats hours and minutes when mixed', () {
        final step = ProcessStep.fromJson({...baseStepJson, 'estimatedTime': 90});
        expect(step.formattedTime, equals('1 ч 30 мин'));
      });

      test('formats large times correctly', () {
        final step = ProcessStep.fromJson({...baseStepJson, 'estimatedTime': 150});
        expect(step.formattedTime, equals('2 ч 30 мин'));
      });
    });

    group('copyWith', () {
      test('creates copy with updated fields', () {
        final original = ProcessStep.fromJson({
          ...baseStepJson,
          'rate': 500,
          'rateType': 'per_unit',
        });

        final copy = original.copyWith(
          name: 'Пошив',
          estimatedTime: 120,
          rate: 700,
        );

        expect(copy.id, equals(original.id));
        expect(copy.modelId, equals(original.modelId));
        expect(copy.name, equals('Пошив'));
        expect(copy.estimatedTime, equals(120));
        expect(copy.rate, equals(700));
        expect(copy.rateType, equals(original.rateType));
      });

      test('preserves original values when not specified', () {
        final original = ProcessStep.fromJson(baseStepJson);
        final copy = original.copyWith();

        expect(copy.id, equals(original.id));
        expect(copy.modelId, equals(original.modelId));
        expect(copy.stepOrder, equals(original.stepOrder));
        expect(copy.name, equals(original.name));
        expect(copy.estimatedTime, equals(original.estimatedTime));
        expect(copy.executorRole, equals(original.executorRole));
        expect(copy.rate, equals(original.rate));
        expect(copy.rateType, equals(original.rateType));
      });
    });
  });
}
