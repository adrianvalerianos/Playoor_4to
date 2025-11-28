import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:spooky_bloc/views/home.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    cargando();
  }

  void cargando() async {
    debugPrint("Cargando");

    await Future.delayed(const Duration(milliseconds: 2000));

    debugPrint("Ya jaló :)");
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "SimpMusic",
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xff221930),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xff3d289f),
          surface: Color(0xff373242),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xff221930),
          elevation: 0,
          centerTitle: true,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontFamily: "DMSerif",
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const Home(),
    );
  }
}