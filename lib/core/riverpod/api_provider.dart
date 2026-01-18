import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import 'storage_provider.dart';

/// Provider for ApiService.
/// Creates ApiService with the storage service dependency.
final apiServiceProvider = Provider<ApiService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ApiService(storage);
});
