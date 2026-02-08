part of 'moments_bloc.dart';

abstract class MomentsEvent extends Equatable {
  const MomentsEvent();

  @override
  List<Object?> get props => [];
}

class MomentsRequested extends MomentsEvent {
  const MomentsRequested();
}

class MomentLikeToggled extends MomentsEvent {
  const MomentLikeToggled(this.moment);

  final MomentEntity moment;

  @override
  List<Object?> get props => [moment];
}

class MomentCreated extends MomentsEvent {
  const MomentCreated(this.payload);

  final Map<String, dynamic> payload;

  @override
  List<Object?> get props => [payload];
}
