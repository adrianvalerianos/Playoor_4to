import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/player_bloc.dart';
import '../events/player_events.dart';
import '../states/player_states.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final Color wormColor = const Color(0xffcd1170);

    return BlocBuilder<PlayerBloc, PlayState>(
      builder: (context, playerState) {
        bool isPlaying = false;
        Duration duration = Duration.zero;
        Duration position = Duration.zero;
        double volume = 1.0;
        double pitch = 1.0;

        if (playerState is PlayingState) {
          isPlaying = playerState.isPlaying;
          duration = playerState.duration;
          position = playerState.position;
          volume = playerState.volume;
          pitch = playerState.pitch;
        }

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          padding: const EdgeInsets.all(24.0),
          decoration: const BoxDecoration(
            color: Color(0xff2d2438),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Configuración de Audio',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.volume_down, color: Colors.white70),
                      onPressed: () {
                        context.read<PlayerBloc>().add(
                          const ChangeVolumeEvent(volume: 0.0),
                        );
                      },
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: wormColor,
                          inactiveTrackColor: Colors.grey[700],
                          thumbColor: wormColor,
                          overlayColor: wormColor.withOpacity(0.2),
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 10,
                          ),
                        ),
                        child: Slider(
                          value: volume,
                          min: 0.0,
                          max: 1.0,
                          onChanged: (value) {
                            context.read<PlayerBloc>().add(
                              ChangeVolumeEvent(volume: value),
                            );
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up, color: Colors.white70),
                      onPressed: () {
                        context.read<PlayerBloc>().add(
                          const ChangeVolumeEvent(volume: 1.0),
                        );
                      },
                    ),
                  ],
                ),
                Center(
                  child: Text(
                    'Volumen: ${(volume * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  'Velocidad de Reproducción',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: wormColor,
                    inactiveTrackColor: Colors.grey[200],
                    thumbColor: wormColor,
                    overlayColor: wormColor.withOpacity(0.2),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 10,
                    ),
                    valueIndicatorColor: wormColor,
                    valueIndicatorTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Slider(
                    value: pitch,
                    min: 0.25,
                    max: 2.0,
                    divisions: 35,
                    label: '${pitch.toStringAsFixed(2)}x',
                    onChanged: (value) {
                      double roundedValue = (value / 0.05).round() * 0.05;
                      context.read<PlayerBloc>().add(
                        ChangePitchEvent(pitch: roundedValue),
                      );
                    },
                  ),
                ),
                Center(
                  child: Text(
                    'Velocidad: ${pitch.toStringAsFixed(2)}x',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 30),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xff3d3349),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información del Audio',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: _InfoItem(
                              label: 'Estado',
                              value: isPlaying ? 'Reproduciendo' : 'Pausado',
                            ),
                          ),
                          Flexible(
                            child: _InfoItem(
                              label: 'Duración',
                              value: _formatDuration(duration),
                            ),
                          ),
                          Flexible(
                            child: _InfoItem(
                              label: 'Posición',
                              value: _formatDuration(position),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 12,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}