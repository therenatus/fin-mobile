import 'package:mockito/annotations.dart';
import 'package:clothing_dashboard/core/services/api_service.dart';
import 'package:clothing_dashboard/core/services/client_api_service.dart';
import 'package:clothing_dashboard/core/services/employee_api_service.dart';
import 'package:clothing_dashboard/core/services/storage_service.dart';
import 'package:clothing_dashboard/core/services/secure_storage_service.dart';

/// Generate mocks for all API services and storage services.
///
/// After modifying this file, run:
/// flutter pub run build_runner build
@GenerateMocks([
  ApiService,
  ClientApiService,
  EmployeeApiService,
  StorageService,
  SecureStorageService,
])
// ignore: unused_import
import 'mock_services.mocks.dart';
