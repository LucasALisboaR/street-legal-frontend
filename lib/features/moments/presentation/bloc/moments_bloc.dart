import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gearhead_br/core/storage/session_storage.dart';
import 'package:gearhead_br/features/moments/data/services/moments_service.dart';
import 'package:gearhead_br/features/moments/domain/entities/moment_entity.dart';

part 'moments_event.dart';
part 'moments_state.dart';

class MomentsBloc extends Bloc<MomentsEvent, MomentsState> {
  MomentsBloc({
    required MomentsService momentsService,
    required SessionStorage sessionStorage,
  })  : _momentsService = momentsService,
        _sessionStorage = sessionStorage,
        super(const MomentsState()) {
    on<MomentsRequested>(_onMomentsRequested);
    on<MomentLikeToggled>(_onMomentLikeToggled);
    on<MomentCreated>(_onMomentCreated);
  }

  final MomentsService _momentsService;
  final SessionStorage _sessionStorage;

  Future<void> _onMomentsRequested(
    MomentsRequested event,
    Emitter<MomentsState> emit,
  ) async {
    emit(state.copyWith(status: MomentsStatus.loading, clearError: true));
    final result = await _momentsService.getMoments();
    result.fold(
      (error) => emit(state.copyWith(
        status: MomentsStatus.failure,
        errorMessage: error.message,
      )),
      (moments) => emit(state.copyWith(
        status: MomentsStatus.success,
        moments: moments,
      )),
    );
  }

  Future<void> _onMomentLikeToggled(
    MomentLikeToggled event,
    Emitter<MomentsState> emit,
  ) async {
    final userId = await _sessionStorage.getUserId();
    if (userId == null || userId.isEmpty) {
      emit(state.copyWith(
        status: MomentsStatus.failure,
        errorMessage: 'Sessão expirada. Faça login novamente.',
      ));
      return;
    }

    final shouldUnlike = event.moment.isLikedBy(userId);
    final result = shouldUnlike
        ? await _momentsService.unlikeMoment(event.moment.id)
        : await _momentsService.likeMoment(event.moment.id);

    result.fold(
      (error) => emit(state.copyWith(
        status: MomentsStatus.failure,
        errorMessage: error.message,
      )),
      (updated) => emit(state.copyWith(
        status: MomentsStatus.success,
        moments: state.moments
            .map((moment) => moment.id == updated.id ? updated : moment)
            .toList(),
      )),
    );
  }

  Future<void> _onMomentCreated(
    MomentCreated event,
    Emitter<MomentsState> emit,
  ) async {
    emit(state.copyWith(status: MomentsStatus.loading, clearError: true));
    final result = await _momentsService.createMoment(event.payload);
    await result.fold(
      (error) async => emit(state.copyWith(
        status: MomentsStatus.failure,
        errorMessage: error.message,
      )),
      (_) async => add(const MomentsRequested()),
    );
  }
}
