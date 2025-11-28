import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:spooky_bloc/events/player_events.dart';
import 'package:spooky_bloc/states/player_states.dart';
import '../blocs/player_bloc.dart';
import '../models/audio_item.dart';

class Swiper extends StatefulWidget {
  final PageController pageController;
  final List<AudioItem> audioList;
  final PlayerBloc bloc;
  final Color color;
  final Function(bool)? onPageChanging;

  const Swiper({
    Key? key,
    required this.pageController,
    required this.audioList,
    required this.color,
    required this.bloc,
    this.onPageChanging,
  }) : super(key: key);

  @override
  _SwiperState createState() => _SwiperState();
}

class _SwiperState extends State<Swiper> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBloc, PlayState>(
      builder: (context, state) {
        return Column(
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * .3,
              child: PageView.builder(
                controller: widget.pageController,
                onPageChanged: (indice) {
                  widget.onPageChanging?.call(true);

                  final currentState = widget.bloc.state;
                  if (currentState is PlayingState) {
                    if (indice != currentState.currentIndex) {
                      widget.bloc.add(LoadingEvent(index: indice));
                    }
                  }

                  Future.delayed(const Duration(milliseconds: 350), () {
                    widget.onPageChanging?.call(false);
                  });
                },
                itemCount: widget.audioList.length,
                itemBuilder: (context, index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      widget.audioList[index].imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[800],
                          child: const Icon(
                            Icons.music_note,
                            size: 64,
                            color: Colors.white54,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            SmoothPageIndicator(
              controller: widget.pageController,
              count: widget.audioList.length,
              axisDirection: Axis.horizontal,
              effect: ScrollingDotsEffect(
                spacing: 8.0,
                radius: 10.0,
                dotWidth: 16.0,
                dotHeight: 16.0,
                paintStyle: PaintingStyle.stroke,
                strokeWidth: 1.5,
                dotColor: Colors.grey,
                activeDotColor: widget.color,
              ),
            ),
          ],
        );
      },
    );
  }
}