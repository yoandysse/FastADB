import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models/app_update.dart';
import '../core/services/update_service.dart';

final updateProvider = StateNotifierProvider<UpdateNotifier, UpdateState>(
  (ref) => UpdateNotifier(UpdateService())..check(),
);

class UpdateState {
  final bool checking;
  final AppUpdate? update;
  final String? error;

  const UpdateState({this.checking = false, this.update, this.error});

  const UpdateState.initial() : this();

  UpdateState copyWith({
    bool? checking,
    AppUpdate? update,
    String? error,
    bool clearUpdate = false,
    bool clearError = false,
  }) {
    return UpdateState(
      checking: checking ?? this.checking,
      update: clearUpdate ? null : update ?? this.update,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class UpdateNotifier extends StateNotifier<UpdateState> {
  final UpdateService _service;

  UpdateNotifier(this._service) : super(const UpdateState.initial());

  Future<void> check() async {
    state = state.copyWith(checking: true, clearError: true);
    try {
      final update = await _service.checkForUpdate();
      state = UpdateState(update: update);
    } catch (e) {
      state = UpdateState(error: e.toString());
    }
  }

  Future<bool> openUpdate() async {
    final update = state.update;
    if (update == null) return false;
    return _service.openUpdate(update);
  }
}
