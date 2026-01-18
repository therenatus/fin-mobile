import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import '../services/api_service.dart';
import 'api_provider.dart';

void _log(String message) {
  debugPrint('[QcNotifier] $message');
}

/// State enum for QC operations
enum QcLoadingState {
  initial,
  loading,
  loaded,
  error,
}

/// QC state data
class QcStateData {
  final QcLoadingState loadingState;

  // Templates
  final List<QcTemplate> templates;
  final QcTemplate? currentTemplate;

  // Checks
  final List<QcCheck> checks;
  final List<QcCheck> pendingChecks;
  final QcCheck? currentCheck;

  // Defects
  final List<Defect> defects;
  final List<Defect> myDefects;
  final Defect? currentDefect;

  // Stats
  final QcStats? stats;

  final String? error;

  // Pagination
  final int templatesPage;
  final int templatesTotalPages;
  final bool hasMoreTemplates;

  final int checksPage;
  final int checksTotalPages;
  final bool hasMoreChecks;

  final int defectsPage;
  final int defectsTotalPages;
  final bool hasMoreDefects;

  const QcStateData({
    this.loadingState = QcLoadingState.initial,
    this.templates = const [],
    this.currentTemplate,
    this.checks = const [],
    this.pendingChecks = const [],
    this.currentCheck,
    this.defects = const [],
    this.myDefects = const [],
    this.currentDefect,
    this.stats,
    this.error,
    this.templatesPage = 1,
    this.templatesTotalPages = 1,
    this.hasMoreTemplates = true,
    this.checksPage = 1,
    this.checksTotalPages = 1,
    this.hasMoreChecks = true,
    this.defectsPage = 1,
    this.defectsTotalPages = 1,
    this.hasMoreDefects = true,
  });

  bool get isLoading => loadingState == QcLoadingState.loading;

  QcStateData copyWith({
    QcLoadingState? loadingState,
    List<QcTemplate>? templates,
    QcTemplate? currentTemplate,
    List<QcCheck>? checks,
    List<QcCheck>? pendingChecks,
    QcCheck? currentCheck,
    List<Defect>? defects,
    List<Defect>? myDefects,
    Defect? currentDefect,
    QcStats? stats,
    String? error,
    int? templatesPage,
    int? templatesTotalPages,
    bool? hasMoreTemplates,
    int? checksPage,
    int? checksTotalPages,
    bool? hasMoreChecks,
    int? defectsPage,
    int? defectsTotalPages,
    bool? hasMoreDefects,
    bool clearCurrentTemplate = false,
    bool clearCurrentCheck = false,
    bool clearCurrentDefect = false,
    bool clearError = false,
    bool clearStats = false,
  }) {
    return QcStateData(
      loadingState: loadingState ?? this.loadingState,
      templates: templates ?? this.templates,
      currentTemplate:
          clearCurrentTemplate ? null : (currentTemplate ?? this.currentTemplate),
      checks: checks ?? this.checks,
      pendingChecks: pendingChecks ?? this.pendingChecks,
      currentCheck:
          clearCurrentCheck ? null : (currentCheck ?? this.currentCheck),
      defects: defects ?? this.defects,
      myDefects: myDefects ?? this.myDefects,
      currentDefect:
          clearCurrentDefect ? null : (currentDefect ?? this.currentDefect),
      stats: clearStats ? null : (stats ?? this.stats),
      error: clearError ? null : (error ?? this.error),
      templatesPage: templatesPage ?? this.templatesPage,
      templatesTotalPages: templatesTotalPages ?? this.templatesTotalPages,
      hasMoreTemplates: hasMoreTemplates ?? this.hasMoreTemplates,
      checksPage: checksPage ?? this.checksPage,
      checksTotalPages: checksTotalPages ?? this.checksTotalPages,
      hasMoreChecks: hasMoreChecks ?? this.hasMoreChecks,
      defectsPage: defectsPage ?? this.defectsPage,
      defectsTotalPages: defectsTotalPages ?? this.defectsTotalPages,
      hasMoreDefects: hasMoreDefects ?? this.hasMoreDefects,
    );
  }
}

/// QC Notifier for managing Quality Control operations
class QcNotifier extends Notifier<QcStateData> {
  @override
  QcStateData build() {
    return const QcStateData();
  }

  ApiService get _api => ref.read(apiServiceProvider);

  // ==================== TEMPLATES ====================

  /// Load QC templates
  Future<void> loadTemplates({
    bool refresh = false,
    String? type,
    bool? isActive,
    String? sortBy,
    String? sortOrder,
  }) async {
    if (refresh) {
      state = state.copyWith(
        templatesPage: 1,
        templates: [],
        hasMoreTemplates: true,
      );
    }

    if (!state.hasMoreTemplates && !refresh) return;

    state = state.copyWith(
      loadingState: QcLoadingState.loading,
      clearError: true,
    );

    try {
      final page = refresh ? 1 : state.templatesPage;
      final response = await _api.getQcTemplates(
        page: page,
        limit: 20,
        type: type,
        isActive: isActive,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      final newTemplates =
          refresh ? response.data : [...state.templates, ...response.data];

      state = state.copyWith(
        templates: newTemplates,
        templatesTotalPages: response.meta.totalPages,
        hasMoreTemplates: page < response.meta.totalPages,
        templatesPage: page + 1,
        loadingState: QcLoadingState.loaded,
      );
    } catch (e) {
      _log('loadTemplates error: $e');
      state = state.copyWith(
        error: e.toString(),
        loadingState: QcLoadingState.error,
      );
    }
  }

  /// Refresh templates
  Future<void> refreshTemplates({String? type}) async {
    await loadTemplates(refresh: true, type: type);
  }

  /// Get template by ID
  Future<QcTemplate?> getTemplate(String templateId) async {
    try {
      final template = await _api.getQcTemplate(templateId);
      state = state.copyWith(currentTemplate: template);
      return template;
    } catch (e) {
      _log('getTemplate error: $e');
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Create template
  Future<QcTemplate?> createTemplate({
    required String name,
    required String type,
    String? description,
    String? modelId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final template = await _api.createQcTemplate(
        name: name,
        type: type,
        description: description,
        modelId: modelId,
        items: items,
      );
      state = state.copyWith(
        templates: [template, ...state.templates],
        currentTemplate: template,
      );
      return template;
    } catch (e) {
      _log('createTemplate error: $e');
      rethrow;
    }
  }

  /// Update template
  Future<QcTemplate?> updateTemplate(
    String templateId, {
    String? name,
    String? description,
    String? type,
    String? modelId,
    bool? isActive,
    List<Map<String, dynamic>>? items,
  }) async {
    try {
      final template = await _api.updateQcTemplate(
        templateId,
        name: name,
        description: description,
        type: type,
        modelId: modelId,
        isActive: isActive,
        items: items,
      );
      _updateTemplateInList(template);
      return template;
    } catch (e) {
      _log('updateTemplate error: $e');
      rethrow;
    }
  }

  /// Delete template
  Future<bool> deleteTemplate(String templateId) async {
    try {
      await _api.deleteQcTemplate(templateId);
      final templates = List<QcTemplate>.from(state.templates);
      templates.removeWhere((t) => t.id == templateId);
      state = state.copyWith(
        templates: templates,
        clearCurrentTemplate: state.currentTemplate?.id == templateId,
      );
      return true;
    } catch (e) {
      _log('deleteTemplate error: $e');
      return false;
    }
  }

  void _updateTemplateInList(QcTemplate template) {
    final templates = List<QcTemplate>.from(state.templates);
    final index = templates.indexWhere((t) => t.id == template.id);
    if (index != -1) {
      templates[index] = template;
    }
    state = state.copyWith(
      templates: templates,
      currentTemplate: template,
    );
  }

  // ==================== CHECKS ====================

  /// Load QC checks
  Future<void> loadChecks({
    bool refresh = false,
    String? status,
    String? type,
    String? orderId,
    String? inspectorId,
    String? dateFrom,
    String? dateTo,
    String? sortBy,
    String? sortOrder,
  }) async {
    if (refresh) {
      state = state.copyWith(
        checksPage: 1,
        checks: [],
        hasMoreChecks: true,
      );
    }

    if (!state.hasMoreChecks && !refresh) return;

    state = state.copyWith(
      loadingState: QcLoadingState.loading,
      clearError: true,
    );

    try {
      final page = refresh ? 1 : state.checksPage;
      final response = await _api.getQcChecks(
        page: page,
        limit: 20,
        status: status,
        type: type,
        orderId: orderId,
        inspectorId: inspectorId,
        dateFrom: dateFrom,
        dateTo: dateTo,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      final newChecks =
          refresh ? response.data : [...state.checks, ...response.data];

      state = state.copyWith(
        checks: newChecks,
        checksTotalPages: response.meta.totalPages,
        hasMoreChecks: page < response.meta.totalPages,
        checksPage: page + 1,
        loadingState: QcLoadingState.loaded,
      );
    } catch (e) {
      _log('loadChecks error: $e');
      state = state.copyWith(
        error: e.toString(),
        loadingState: QcLoadingState.error,
      );
    }
  }

  /// Refresh checks
  Future<void> refreshChecks({String? status}) async {
    await loadChecks(refresh: true, status: status);
  }

  /// Load pending checks
  Future<void> loadPendingChecks() async {
    try {
      final response = await _api.getPendingQcChecks();
      state = state.copyWith(pendingChecks: response.data);
    } catch (e) {
      _log('loadPendingChecks error: $e');
    }
  }

  /// Get check by ID
  Future<QcCheck?> getCheck(String checkId) async {
    try {
      final check = await _api.getQcCheck(checkId);
      state = state.copyWith(currentCheck: check);
      return check;
    } catch (e) {
      _log('getCheck error: $e');
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Create check
  Future<QcCheck?> createCheck({
    required String templateId,
    String? orderId,
    String? taskId,
    String? inspectorId,
    String? scheduledAt,
  }) async {
    try {
      final check = await _api.createQcCheck(
        templateId: templateId,
        orderId: orderId,
        taskId: taskId,
        inspectorId: inspectorId,
        scheduledAt: scheduledAt,
      );
      state = state.copyWith(
        checks: [check, ...state.checks],
        pendingChecks: [check, ...state.pendingChecks],
        currentCheck: check,
      );
      return check;
    } catch (e) {
      _log('createCheck error: $e');
      rethrow;
    }
  }

  /// Start check
  Future<QcCheck?> startCheck(String checkId) async {
    try {
      final check = await _api.startQcCheck(checkId);
      _updateCheckInLists(check);
      return check;
    } catch (e) {
      _log('startCheck error: $e');
      rethrow;
    }
  }

  /// Submit check results
  Future<QcCheck?> submitCheckResults(
    String checkId, {
    required String decision,
    required List<Map<String, dynamic>> results,
    String? notes,
  }) async {
    try {
      final check = await _api.submitQcCheckResults(
        checkId,
        decision: decision,
        results: results,
        notes: notes,
      );
      _updateCheckInLists(check);
      // Remove from pending
      final pendingChecks = List<QcCheck>.from(state.pendingChecks);
      pendingChecks.removeWhere((c) => c.id == checkId);
      state = state.copyWith(pendingChecks: pendingChecks);
      return check;
    } catch (e) {
      _log('submitCheckResults error: $e');
      rethrow;
    }
  }

  /// Cancel check
  Future<QcCheck?> cancelCheck(String checkId) async {
    try {
      final check = await _api.cancelQcCheck(checkId);
      _updateCheckInLists(check);
      final pendingChecks = List<QcCheck>.from(state.pendingChecks);
      pendingChecks.removeWhere((c) => c.id == checkId);
      state = state.copyWith(pendingChecks: pendingChecks);
      return check;
    } catch (e) {
      _log('cancelCheck error: $e');
      rethrow;
    }
  }

  void _updateCheckInLists(QcCheck check) {
    final checks = List<QcCheck>.from(state.checks);
    final index = checks.indexWhere((c) => c.id == check.id);
    if (index != -1) {
      checks[index] = check;
    }
    state = state.copyWith(
      checks: checks,
      currentCheck: check,
    );
  }

  // ==================== DEFECTS ====================

  /// Load defects
  Future<void> loadDefects({
    bool refresh = false,
    String? status,
    String? severity,
    String? type,
    String? orderId,
    String? assigneeId,
    String? sortBy,
    String? sortOrder,
  }) async {
    if (refresh) {
      state = state.copyWith(
        defectsPage: 1,
        defects: [],
        hasMoreDefects: true,
      );
    }

    if (!state.hasMoreDefects && !refresh) return;

    state = state.copyWith(
      loadingState: QcLoadingState.loading,
      clearError: true,
    );

    try {
      final page = refresh ? 1 : state.defectsPage;
      final response = await _api.getDefects(
        page: page,
        limit: 20,
        status: status,
        severity: severity,
        type: type,
        orderId: orderId,
        assigneeId: assigneeId,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      final newDefects =
          refresh ? response.data : [...state.defects, ...response.data];

      state = state.copyWith(
        defects: newDefects,
        defectsTotalPages: response.meta.totalPages,
        hasMoreDefects: page < response.meta.totalPages,
        defectsPage: page + 1,
        loadingState: QcLoadingState.loaded,
      );
    } catch (e) {
      _log('loadDefects error: $e');
      state = state.copyWith(
        error: e.toString(),
        loadingState: QcLoadingState.error,
      );
    }
  }

  /// Refresh defects
  Future<void> refreshDefects({String? status}) async {
    await loadDefects(refresh: true, status: status);
  }

  /// Load my assigned defects
  Future<void> loadMyDefects({String? status}) async {
    try {
      final response = await _api.getMyDefects(status: status);
      state = state.copyWith(myDefects: response.data);
    } catch (e) {
      _log('loadMyDefects error: $e');
    }
  }

  /// Get defect by ID
  Future<Defect?> getDefect(String defectId) async {
    try {
      final defect = await _api.getDefect(defectId);
      state = state.copyWith(currentDefect: defect);
      return defect;
    } catch (e) {
      _log('getDefect error: $e');
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Create defect
  Future<Defect?> createDefect({
    required String title,
    required String type,
    required String severity,
    String? description,
    String? location,
    String? orderId,
    String? checkId,
    String? assigneeId,
    List<String>? photos,
  }) async {
    try {
      final defect = await _api.createDefect(
        title: title,
        type: type,
        severity: severity,
        description: description,
        location: location,
        orderId: orderId,
        checkId: checkId,
        assigneeId: assigneeId,
        photos: photos,
      );
      state = state.copyWith(
        defects: [defect, ...state.defects],
        currentDefect: defect,
      );
      return defect;
    } catch (e) {
      _log('createDefect error: $e');
      rethrow;
    }
  }

  /// Update defect
  Future<Defect?> updateDefect(
    String defectId, {
    String? title,
    String? description,
    String? type,
    String? severity,
    String? location,
    String? assigneeId,
    List<String>? photos,
    String? status,
  }) async {
    try {
      final defect = await _api.updateDefect(
        defectId,
        title: title,
        description: description,
        type: type,
        severity: severity,
        location: location,
        assigneeId: assigneeId,
        photos: photos,
        status: status,
      );
      _updateDefectInLists(defect);
      return defect;
    } catch (e) {
      _log('updateDefect error: $e');
      rethrow;
    }
  }

  /// Assign defect
  Future<Defect?> assignDefect(String defectId, String assigneeId) async {
    try {
      final defect = await _api.assignDefect(defectId, assigneeId);
      _updateDefectInLists(defect);
      return defect;
    } catch (e) {
      _log('assignDefect error: $e');
      rethrow;
    }
  }

  /// Resolve defect
  Future<Defect?> resolveDefect(String defectId, String resolution) async {
    try {
      final defect = await _api.resolveDefect(defectId, resolution);
      _updateDefectInLists(defect);
      return defect;
    } catch (e) {
      _log('resolveDefect error: $e');
      rethrow;
    }
  }

  /// Close defect
  Future<Defect?> closeDefect(String defectId) async {
    try {
      final defect = await _api.closeDefect(defectId);
      _updateDefectInLists(defect);
      return defect;
    } catch (e) {
      _log('closeDefect error: $e');
      rethrow;
    }
  }

  /// Mark defect as won't fix
  Future<Defect?> wontFixDefect(String defectId, String reason) async {
    try {
      final defect = await _api.wontFixDefect(defectId, reason);
      _updateDefectInLists(defect);
      return defect;
    } catch (e) {
      _log('wontFixDefect error: $e');
      rethrow;
    }
  }

  /// Reopen defect
  Future<Defect?> reopenDefect(String defectId) async {
    try {
      final defect = await _api.reopenDefect(defectId);
      _updateDefectInLists(defect);
      return defect;
    } catch (e) {
      _log('reopenDefect error: $e');
      rethrow;
    }
  }

  /// Delete defect
  Future<bool> deleteDefect(String defectId) async {
    try {
      await _api.deleteDefect(defectId);
      final defects = List<Defect>.from(state.defects);
      defects.removeWhere((d) => d.id == defectId);
      final myDefects = List<Defect>.from(state.myDefects);
      myDefects.removeWhere((d) => d.id == defectId);
      state = state.copyWith(
        defects: defects,
        myDefects: myDefects,
        clearCurrentDefect: state.currentDefect?.id == defectId,
      );
      return true;
    } catch (e) {
      _log('deleteDefect error: $e');
      return false;
    }
  }

  void _updateDefectInLists(Defect defect) {
    final defects = List<Defect>.from(state.defects);
    final index = defects.indexWhere((d) => d.id == defect.id);
    if (index != -1) {
      defects[index] = defect;
    }
    final myDefects = List<Defect>.from(state.myDefects);
    final myIndex = myDefects.indexWhere((d) => d.id == defect.id);
    if (myIndex != -1) {
      myDefects[myIndex] = defect;
    }
    state = state.copyWith(
      defects: defects,
      myDefects: myDefects,
      currentDefect: defect,
    );
  }

  // ==================== STATS ====================

  /// Load QC statistics
  Future<void> loadStats({String? dateFrom, String? dateTo}) async {
    try {
      final stats = await _api.getQcStats(
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
      state = state.copyWith(stats: stats);
    } catch (e) {
      _log('loadStats error: $e');
    }
  }

  // ==================== HELPERS ====================

  /// Clear current template
  void clearCurrentTemplate() {
    state = state.copyWith(clearCurrentTemplate: true);
  }

  /// Clear current check
  void clearCurrentCheck() {
    state = state.copyWith(clearCurrentCheck: true);
  }

  /// Clear current defect
  void clearCurrentDefect() {
    state = state.copyWith(clearCurrentDefect: true);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Reset state
  void reset() {
    state = const QcStateData();
  }
}

/// Provider for QC state
final qcNotifierProvider = NotifierProvider<QcNotifier, QcStateData>(
  QcNotifier.new,
);

// ============ Convenience Providers ============

/// Provider for QC templates list
final qcTemplatesProvider = Provider<List<QcTemplate>>((ref) {
  return ref.watch(qcNotifierProvider).templates;
});

/// Provider for current QC template
final currentQcTemplateProvider = Provider<QcTemplate?>((ref) {
  return ref.watch(qcNotifierProvider).currentTemplate;
});

/// Provider for QC checks list
final qcChecksProvider = Provider<List<QcCheck>>((ref) {
  return ref.watch(qcNotifierProvider).checks;
});

/// Provider for pending QC checks
final pendingQcChecksProvider = Provider<List<QcCheck>>((ref) {
  return ref.watch(qcNotifierProvider).pendingChecks;
});

/// Provider for current QC check
final currentQcCheckProvider = Provider<QcCheck?>((ref) {
  return ref.watch(qcNotifierProvider).currentCheck;
});

/// Provider for defects list
final defectsProvider = Provider<List<Defect>>((ref) {
  return ref.watch(qcNotifierProvider).defects;
});

/// Provider for my defects
final myDefectsProvider = Provider<List<Defect>>((ref) {
  return ref.watch(qcNotifierProvider).myDefects;
});

/// Provider for current defect
final currentDefectProvider = Provider<Defect?>((ref) {
  return ref.watch(qcNotifierProvider).currentDefect;
});

/// Provider for QC stats
final qcStatsProvider = Provider<QcStats?>((ref) {
  return ref.watch(qcNotifierProvider).stats;
});

/// Provider for QC loading state
final qcLoadingStateProvider = Provider<QcLoadingState>((ref) {
  return ref.watch(qcNotifierProvider).loadingState;
});

/// Provider for QC error
final qcErrorProvider = Provider<String?>((ref) {
  return ref.watch(qcNotifierProvider).error;
});

/// Provider for is QC loading
final isQcLoadingProvider = Provider<bool>((ref) {
  return ref.watch(qcNotifierProvider).isLoading;
});

/// Provider for has more templates
final hasMoreTemplatesProvider = Provider<bool>((ref) {
  return ref.watch(qcNotifierProvider).hasMoreTemplates;
});

/// Provider for has more checks
final hasMoreChecksProvider = Provider<bool>((ref) {
  return ref.watch(qcNotifierProvider).hasMoreChecks;
});

/// Provider for has more defects
final hasMoreDefectsProvider = Provider<bool>((ref) {
  return ref.watch(qcNotifierProvider).hasMoreDefects;
});
