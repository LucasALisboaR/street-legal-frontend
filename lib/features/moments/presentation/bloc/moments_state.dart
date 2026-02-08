part of 'moments_bloc.dart';

enum MomentsStatus { initial, loading, success, failure }

class MomentsState extends Equatable {
  const MomentsState({
    this.status = MomentsStatus.initial,
    this.moments = const [],
    this.errorMessage,
  });

  final MomentsStatus status;
  final List<MomentEntity> moments;
  final String? errorMessage;

  MomentsState copyWith({
    MomentsStatus? status,
    List<MomentEntity>? moments,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MomentsState(
      status: status ?? this.status,
      moments: moments ?? this.moments,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, moments, errorMessage];
}
