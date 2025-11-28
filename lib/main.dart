import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:spooky_bloc/views/app.dart';
import 'package:window_size/window_size.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    pantalla();
  }

  if (Platform.isAndroid || Platform.isIOS) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  runApp(const App());
}

void pantalla() {
  const Size size = Size(500, 800);
  setWindowMaxSize(size);
  setWindowMinSize(size);

  getWindowInfo().then((window) {
    final Screen? screen = window.screen;
    if (screen != null) {
      final Rect screenFrame = screen.visibleFrame;
      final double left =
          screenFrame.left + (screenFrame.width - size.width) / 2;
      final double top = screenFrame.top + (screenFrame.height - size.height) / 2;
      setWindowFrame(Rect.fromLTWH(left, top, size.width, size.height));
    }
  });
}