import 'package:equatable/equatable.dart';

abstract class PlayerEvents extends Equatable {
  const PlayerEvents();

  @override
  List<Object> get props => [];
}

class LoadingEvent extends PlayerEvents {
  final int index;

  const LoadingEvent({required this.index});

  @override
  List<Object> get props => [index];
}

class PlayingEvent extends PlayerEvents {}

class PlayingPauseEvent extends PlayerEvents {}

class NextEvent extends PlayerEvents {}

class PreviousEvent extends PlayerEvents {}

class SeekEvent extends PlayerEvents {
  final Duration position;

  const SeekEvent({required this.position});

  @override
  List<Object> get props => [position];
}

class ChangeVolumeEvent extends PlayerEvents {
  final double volume;

  const ChangeVolumeEvent({required this.volume});

  @override
  List<Object> get props => [volume];
}

class ChangePitchEvent extends PlayerEvents {
  final double pitch;

  const ChangePitchEvent({required this.pitch});

  @override
  List<Object> get props => [pitch];
}