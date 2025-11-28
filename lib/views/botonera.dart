import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class Botonera extends StatefulWidget {
  final Function() play, next, previous;
  final bool playing;
  final Duration position, duration;
  final double progressPercent;
  final Color color;

  const Botonera(
      {super.key,
        required this.play,
        required this.next,
        required this.previous,
        required this.playing,
        required this.position,
        required this.duration,
        required this.progressPercent,
        required this.color});

  @override
  State<Botonera> createState() => _BotoneraState();
}

class _BotoneraState extends State<Botonera> {
  String timeFormat(int seconds) {
    final int min = (seconds / 60).floor();
    final res = seconds % 60;
    return "${min.toString().padLeft(2, '0')}:${res.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    final double clampedPercent = widget.progressPercent.clamp(0.0, 1.0);
    final double circleRadius = screenH * .1;

    return SizedBox(
      width: screenW * .65,
      height: screenH * .30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(
            width: 40,
            child: Text(
              timeFormat(widget.position.inSeconds),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularPercentIndicator(
                  progressColor: widget.color,
                  backgroundColor: Colors.blueGrey,
                  circularStrokeCap: CircularStrokeCap.round,
                  arcType: ArcType.FULL_REVERSED,
                  radius: circleRadius,
                  lineWidth: 3,
                  percent: clampedPercent,
                ),
                // overflow overflow overflow stack overflow xdxdxdx
                Positioned.fill(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: widget.previous,
                            icon: const Icon(Icons.skip_previous_rounded, color: Colors.white),
                            iconSize: 28,
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                            splashRadius: 20,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.color,
                          ),
                          child: IconButton(
                            onPressed: widget.play,
                            icon: Icon(
                              widget.playing ? Icons.pause : Icons.play_arrow_rounded,
                              color: Colors.white,
                            ),
                            iconSize: 28,
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                            splashRadius: 20,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: widget.next,
                            icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
                            iconSize: 28,
                            padding: const EdgeInsets.all(8),
                            constraints: const BoxConstraints(),
                            splashRadius: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 45,
            child: Text(
              timeFormat(widget.duration.inSeconds),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
    );
  }
}