import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';

import '../blocs/player_bloc.dart';
import '../events/player_events.dart';
import '../states/player_states.dart';
import '../views/artist.dart';
import '../views/botonera.dart';
import '../views/progress_slider.dart';
import '../views/swiper.dart';
import '../views/settings.dart';
import '../models/audio_item.dart';
import '../views/menu_drawer.dart';
import '../services/database_helper.dart';

class Player extends StatefulWidget {
  const Player({super.key});

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  List<AudioItem> audioList = [];

  // rolasss
  final List<AudioItem> defaultAudioList = [
    AudioItem(
      assetPath: "allthat.mp3",
      title: "All that",
      artist: "Don Juan",
      imagePath: "assets/allthat_colored.jpg",
    ),
    AudioItem(
      assetPath: "love.mp3",
      title: "Love",
      artist: "Pepito Alcachofa",
      imagePath: "assets/love_colored.jpg",
    ),
    AudioItem(
      assetPath: "thejazzpiano.mp3",
      title: "Jazz Piano",
      artist: "Michael Jackson",
      imagePath: "assets/thejazzpiano_colored.jpg",
    ),
    AudioItem(
      assetPath: "bones.mp3",
      title: "Bones",
      artist: "Imagine Dragons",
      imagePath: "assets/bones_colored.jpg",
    ),
    AudioItem(
      assetPath: "xtal.mp3",
      title: "Xtal",
      artist: "Aphex Twin",
      imagePath: "assets/xtal_colored.jpg",
    ),
    AudioItem(
      assetPath: "transition.mp3",
      title: "Transition",
      artist: "Detuned",
      imagePath: "assets/transition_colored.jpg",
    ),
    AudioItem(
      assetPath: "seasons.mp3",
      title: "Seasons",
      artist: "Sam Austins",
      imagePath: "assets/seasons_colored.jpg",
    ),
    AudioItem(
      assetPath: "vermillionpt2.mp3",
      title: "Vermillion Pt. 2",
      artist: "Slipknot",
      imagePath: "assets/vermillionpt2_colored.jpg",
    ),
    AudioItem(
      assetPath: "always.mp3",
      title: "Always",
      artist: "camoufly",
      imagePath: "assets/always_colored.jpg",
    ),
  ];

  PageController? pageController;
  AudioPlayer? audioPlayer;
  PlayerBloc? playerBloc;

  final GlobalKey<SliderDrawerState> _sliderDrawerKey =
  GlobalKey<SliderDrawerState>();

  final Color wormColor = const Color(0xffcd1170);
  bool _isPageChanging = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    pageController = PageController(viewportFraction: .75);
    audioPlayer = AudioPlayer();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    try {
      await DatabaseHelper.instance.initializeDefaultSongs(defaultAudioList);
      audioList = await DatabaseHelper.instance.read();

      playerBloc = PlayerBloc(audioPlayer: audioPlayer!, canciones: audioList);
      playerBloc?.add(LoadingEvent(index: 0));

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('bd no jaló :(  $e');
      audioList = defaultAudioList;
      playerBloc = PlayerBloc(audioPlayer: audioPlayer!, canciones: audioList);
      playerBloc?.add(LoadingEvent(index: 0));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    pageController?.dispose();
    playerBloc?.close();
    DatabaseHelper.instance.close();
    super.dispose();
  }

  void _showSettingsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BlocProvider.value(
        value: playerBloc!,
        child: const Settings(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xff221930),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(
                color: Color(0xffcd1170),
              ),
              SizedBox(height: 20),
              Text(
                'Cargando canciones...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SliderDrawer(
        key: _sliderDrawerKey,
        appBar: SliderAppBar(
          config: SliderAppBarConfig(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'SimpMusic',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white),
                  onPressed: _showSettingsModal,
                ),
              ],
            ),
            backgroundColor: const Color(0xff1a1123),
            drawerIconColor: Colors.white,
          ),
        ),
        slider: MenuDrawer(
          primaryColor: wormColor,
          playerBloc: playerBloc!,
          drawerKey: _sliderDrawerKey,
        ),
        child: Container(
          color: const Color(0xff221930),
          padding: const EdgeInsets.only(top: 16.0),
          child: BlocProvider.value(
            value: playerBloc!,
            child: BlocListener<PlayerBloc, PlayState>(
              listener: (context, state) {
                if (state is PlayingState && pageController!.hasClients) {
                  final currentPage = pageController!.page?.round() ?? 0;

                  if (currentPage != state.currentIndex && !_isPageChanging) {
                    _isPageChanging = true;
                    pageController!
                        .animateToPage(
                      state.currentIndex,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    )
                        .then((_) {
                      _isPageChanging = false;
                    });
                  }
                }
              },
              child: BlocBuilder<PlayerBloc, PlayState>(
                builder: (context, state) {
                  int currentIndex = 0;
                  Duration position = Duration.zero;
                  Duration duration = Duration.zero;
                  bool isPlaying = false;

                  if (state is PlayingState) {
                    currentIndex = state.currentIndex;
                    position = state.position;
                    duration = state.duration;
                    isPlaying = state.isPlaying;
                  }

                  if (state is LodingState) {
                    if (playerBloc?.state is PlayingState) {
                      currentIndex =
                          (playerBloc!.state as PlayingState).currentIndex;
                    }
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              children: <Widget>[
                                Swiper(
                                  pageController: pageController!,
                                  audioList: audioList,
                                  color: wormColor,
                                  bloc: playerBloc!,
                                  onPageChanging: (isChanging) {
                                    _isPageChanging = isChanging;
                                  },
                                ),
                                Artist(
                                  artist: audioList[currentIndex].artist,
                                  name: audioList[currentIndex].title,
                                ),
                                ProgressSlider(
                                  position: position,
                                  duration: duration,
                                  seek: (newpos) {
                                    playerBloc?.add(SeekEvent(position: newpos));
                                  },
                                  color: wormColor,
                                ),
                                Botonera(
                                  play: () {
                                    if (isPlaying) {
                                      playerBloc?.add(PlayingPauseEvent());
                                    } else {
                                      playerBloc?.add(PlayingEvent());
                                    }
                                  },
                                  next: () {
                                    playerBloc?.add(NextEvent());
                                  },
                                  previous: () {
                                    playerBloc?.add(PreviousEvent());
                                  },
                                  playing: isPlaying,
                                  position: position,
                                  duration: duration,
                                  progressPercent: (duration.inSeconds == 0)
                                      ? 0
                                      : (position.inSeconds /
                                      duration.inSeconds)
                                      .clamp(0.0, 1.0),
                                  color: wormColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}