import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../events/player_events.dart';
import '../models/audio_item.dart';
import '../states/player_states.dart';

class PlayerBloc extends Bloc<PlayerEvents, PlayState> {
  final AudioPlayer audioPlayer;
  final List<AudioItem> canciones;
  StreamSubscription? duracion, posicion, estado;

  bool _isChangingTrack = false;

  PlayerBloc({required this.audioPlayer, required this.canciones})
      : super(IniState()) {
    on<LoadingEvent>(loading);
    on<PlayingEvent>(playing);
    on<PlayingPauseEvent>(playingPause);
    on<NextEvent>(next);
    on<PreviousEvent>(previous);
    on<SeekEvent>(seek);

    on<ChangeVolumeEvent>(changeVolume);
    on<ChangePitchEvent>(changePitch);

    setup();
  }

  Future<void> loading(LoadingEvent event, Emitter<PlayState> emit) async {
    try {
      _isChangingTrack = true;
      emit(LodingState());

      await audioPlayer.stop();

      double currentVolume = 1.0;
      double currentPitch = 1.0;

      if (state is PlayingState) {
        final PlayingState actual = state as PlayingState;
        currentVolume = actual.volume;
        currentPitch = actual.pitch;
      }

      await audioPlayer.setSourceAsset(canciones[event.index].assetPath);

      Duration? audioDuration;
      int attempts = 0;
      const maxAttempts = 20; // 2 segundos máximo

      while (audioDuration == null && attempts < maxAttempts) {
        audioDuration = await audioPlayer.getDuration();
        if (audioDuration == null) {
          await Future.delayed(const Duration(milliseconds: 100));
          attempts++;
        }
      }
      // para q funcione en android
      final finalDuration = audioDuration ?? Duration.zero;

      emit(
        PlayingState(
          currentIndex: event.index,
          duration: finalDuration,
          position: Duration.zero,
          isPlaying: false,
          volume: currentVolume,
          pitch: currentPitch,
        ),
      );

      add(PlayingEvent());

      Future.delayed(const Duration(milliseconds: 300), () {
        _isChangingTrack = false;
      });
    } catch (e) {
      _isChangingTrack = false;
      debugPrint("Error al cargar audio: $e");
      emit(ErrorState(error: "Error: Audio no cargado"));
    }
  }

  Future<void> playing(PlayingEvent event, Emitter<PlayState> emit) async {
    if (state is PlayingState) {
      try {
        await audioPlayer.resume();
        final PlayingState actual = state as PlayingState;
        emit(actual.copy(isPlaying: true));
      } catch (e) {
        debugPrint("Error al reproducir: $e");
        emit(ErrorState(error: "Error: Audio no se pudo reproducir"));
      }
    } else if (state is LodingState) {
      await Future.delayed(const Duration(milliseconds: 500));
      add(PlayingEvent());
    }
  }

  Future<void> playingPause(
      PlayingPauseEvent event,
      Emitter<PlayState> emit,
      ) async {
    if (state is PlayingState) {
      try {
        await audioPlayer.pause();
        final PlayingState actual = state as PlayingState;
        emit(actual.copy(isPlaying: false));
      } catch (e) {
        emit(ErrorState(error: "Error: No se pudo pausar"));
      }
    }
  }

  Future<void> next(NextEvent event, Emitter<PlayState> emit) async {
    if (_isChangingTrack) return;

    if (state is PlayingState) {
      final PlayingState actual = state as PlayingState;
      final int nextIndex = (actual.currentIndex + 1) % canciones.length;
      add(LoadingEvent(index: nextIndex));
    }
  }

  Future<void> previous(PreviousEvent event, Emitter<PlayState> emit) async {
    if (_isChangingTrack) return;

    if (state is PlayingState) {
      final PlayingState actual = state as PlayingState;
      final int previousIndex =
          (actual.currentIndex - 1 + canciones.length) % canciones.length;
      add(LoadingEvent(index: previousIndex));
    }
  }

  Future<void> seek(SeekEvent event, Emitter<PlayState> emit) async {
    if (state is PlayingState) {
      try {
        await audioPlayer.seek(event.position);
        final PlayingState actual = state as PlayingState;
        emit(actual.copy(position: event.position));
      } catch (e) {
        emit(ErrorState(error: "Error: No se pudo buscar posición"));
      }
    }
  }

  Future<void> changeVolume(
      ChangeVolumeEvent event, Emitter<PlayState> emit) async {
    try {
      await audioPlayer.setVolume(event.volume);

      if (state is PlayingState) {
        final PlayingState actual = state as PlayingState;
        emit(actual.copy(volume: event.volume));
      }
    } catch (e) {
      debugPrint('Error al cambiar volumen: $e');
    }
  }

  Future<void> changePitch(
      ChangePitchEvent event, Emitter<PlayState> emit) async {
    try {
      await audioPlayer.setPlaybackRate(event.pitch);

      if (state is PlayingState) {
        final PlayingState actual = state as PlayingState;
        emit(actual.copy(pitch: event.pitch));
      }
    } catch (e) {
      debugPrint('Error al cambiar pitch: $e');
    }
  }

  void setup() {
    estado = audioPlayer.onPlayerStateChanged.listen((playerState) {
      if (_isChangingTrack) return;

      if (state is PlayingState) {
        if (playerState == PlayerState.completed) {
          add(NextEvent());
        }
      }
    });

    posicion = audioPlayer.onPositionChanged.listen((event) {
      if (state is PlayingState) {
        final PlayingState actual = state as PlayingState;
        emit(actual.copy(position: event));
      }
    });

    duracion = audioPlayer.onDurationChanged.listen((event) {
      if (state is PlayingState) {
        final PlayingState actual = state as PlayingState;
        emit(actual.copy(duration: event));
      }
    });
  }

  @override
  Future<void> close() {
    duracion?.cancel();
    posicion?.cancel();
    estado?.cancel();
    audioPlayer.dispose();
    return super.close();
  }
}