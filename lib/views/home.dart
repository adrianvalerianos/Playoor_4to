import 'package:flutter/material.dart';
import 'package:spooky_bloc/views/player.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Player();
  }

  @override
  void dispose() {
    super.dispose();
  }
}