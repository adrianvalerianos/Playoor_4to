import 'package:flutter/material.dart';

class ProgressSlider extends StatelessWidget {
  final Duration position, duration;
  final Function(Duration) seek;
  final Color color;

  const ProgressSlider(
      {Key? key,
        required this.position,
        required this.duration,
        required this.seek,
        required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double maxValue = duration.inSeconds.toDouble();
    final double currentValue = position.inSeconds.toDouble();
    final double safeMax = maxValue > 0 ? maxValue : 0.1;
    final double safeValue = maxValue > 0
        ? currentValue.clamp(0.0, maxValue)
        : 0.0;

    return SizedBox(
      width: MediaQuery.of(context).size.width * .75,
      child: SliderTheme(
        data: SliderThemeData(
          thumbColor: color,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          activeTickMarkColor: color,
          inactiveTickMarkColor: Colors.grey[200],
          overlayColor: color.withOpacity(0.2),
        ),
        child: Slider(
          value: safeValue,
          max: safeMax,
          min: 0,
          onChanged: (value) {
            if (maxValue > 0) {
              seek(Duration(seconds: value.toInt()));
            }
          },
        ),
      ),
    );
  }
}