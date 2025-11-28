import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import '../blocs/player_bloc.dart';
import '../events/player_events.dart';
import '../states/player_states.dart';

class MenuDrawer extends StatelessWidget {
  final Color primaryColor;
  final PlayerBloc playerBloc;
  final GlobalKey<SliderDrawerState> drawerKey;

  const MenuDrawer({
    Key? key,
    required this.primaryColor,
    required this.playerBloc,
    required this.drawerKey,
  }) : super(key: key);

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff2d2438),
        title: const Text(
          'Acerca de',
          style: TextStyle(color: Colors.white, fontFamily: "DMSerif"),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'SimpMusic',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: "DMSerif",
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Versión 1.6.7',
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(height: 16),
              Text(
                'Reproductor de música desarrollado con Flutter y arquitectura BLoC. '
                    'Hecho por Ángel Gabriel Eugenio Herrera y Adrián Valeriano Sáenz para la materia de '
                    'Desarrollo de Aplicaciones Móviles.',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cerrar',
              style: TextStyle(color: primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  void _exitApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff2d2438),
        title: const Text(
          'Salir de la aplicación',
          style: TextStyle(color: Colors.white, fontFamily: "DMSerif"),
        ),
        content: const Text(
          '¿Estás seguro de que quieres salir?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              if (Platform.isAndroid) {
                await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              } else {
                exit(0);
              }
            },
            child: Text(
              'Salir',
              style: TextStyle(color: primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff2d2438),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xff1a1123),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.music_note,
                  size: 48,
                  color: primaryColor,
                ),
                const SizedBox(height: 12),
                const Text(
                  'SimpMusic',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: "DMSerif",
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Reproductor de música',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.white),
            title: const Text(
              'Inicio',
              style: TextStyle(color: Colors.white, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
            splashColor: Colors.white.withOpacity(0.1),
            onTap: () {
              drawerKey.currentState?.closeSlider();
            },
          ),
          const Divider(color: Colors.white24, height: 1),
          BlocBuilder<PlayerBloc, PlayState>(
            bloc: playerBloc,
            builder: (context, state) {
              bool isPlaying = false;
              if (state is PlayingState) {
                isPlaying = state.isPlaying;
              }
              return Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.skip_previous_rounded, color: Colors.white),
                    title: const Text(
                      'Canción anterior',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => playerBloc.add(PreviousEvent()),
                  ),
                  const Divider(color: Colors.white24, height: 1),
                  ListTile(
                    leading: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow_rounded,
                      color: Colors.white,
                    ),
                    title: Text(
                      isPlaying ? 'Pausar' : 'Reproducir',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      if (isPlaying) {
                        playerBloc.add(PlayingPauseEvent());
                      } else {
                        playerBloc.add(PlayingEvent());
                      }
                    },
                  ),
                  const Divider(color: Colors.white24, height: 1),
                  ListTile(
                    leading: const Icon(Icons.skip_next_rounded, color: Colors.white),
                    title: const Text(
                      'Canción siguiente',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => playerBloc.add(NextEvent()),
                  ),
                ],
              );
            },
          ),
          const Divider(color: Colors.white24, height: 1),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.white),
            title: const Text(
              'Acerca de',
              style: TextStyle(color: Colors.white, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _showAboutDialog(context),
          ),
          const Divider(color: Colors.white24, height: 1),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.white),
            title: const Text(
              'Salir de la aplicación',
              style: TextStyle(color: Colors.white, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _exitApp(context),
          ),
        ],
      ),
    );
  }
}