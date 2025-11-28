import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart' as sqflite_mobile;
import '../models/audio_item.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? database;

  DatabaseHelper._init();

  Future<Database?> getDatabase() async {
    if (database != null) {
      return database!;
    } else {
      database = await initializeDatabase("playoor.db");
      return database;
    }
  }

  Future<Database?> initializeDatabase(String fileName) async {
    String databasePath, path;

    // desktoppp
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
    }

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      databasePath = await databaseFactoryFfi.getDatabasesPath();
      path = join(databasePath, fileName);
      return await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(version: 1, onCreate: createAudioItemTable),
      );
    }

    // movil
    if (Platform.isIOS || Platform.isAndroid) {
      databasePath = await sqflite_mobile.getDatabasesPath();
      path = join(databasePath, fileName);
      return sqflite_mobile.openDatabase(
        path,
        version: 1,
        onCreate: createAudioItemTable,
      );
    }

    return null;
  }

  // crear tabla
  FutureOr<void> createAudioItemTable(Database database, int version) async {
    await database.execute(
      """
        CREATE TABLE audioitem (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          assetPath TEXT NOT NULL,
          title TEXT NOT NULL,
          artist TEXT NOT NULL,
          imagePath TEXT NOT NULL
        )
      """,
    );
  }

  // CRUD
  // C - crate
  Future<AudioItem> create(AudioItem audioItem) async {
    final dataBase = await instance.getDatabase();
    final id = await dataBase?.insert("audioitem", audioItem.toMap());
    return audioItem.copyWith(id: id);
  }

  // R - read
  Future<List<AudioItem>> read() async {
    final dataBase = await instance.getDatabase();
    final result = await dataBase?.query('audioitem');
    return result!.map((json) => AudioItem.fromMap(json)).toList();
  }

  Future<bool> hasData() async {
    final dataBase = await instance.getDatabase();
    final result = await dataBase?.query('audioitem', limit: 1);
    return result != null && result.isNotEmpty;
  }

  // inicializacion de canciones
  Future<void> initializeDefaultSongs(List<AudioItem> defaultSongs) async {
    final hasExistingData = await hasData();

    // debuggeo
    if (!hasExistingData) {
      print('bd vacía, cargando canciones...');
      for (var song in defaultSongs) {
        await create(song);
      }
      print('${defaultSongs.length} canciones cargadas exitosamente');
    } else {
      print('canciones ya existen en la bd');
    }
  }

  void close() async {
    final dataBase = await instance.getDatabase();
    dataBase?.close();
  }
}