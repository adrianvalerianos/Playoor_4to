class AudioItem {
  final int? id;
  final String assetPath;
  final String title;
  final String artist;
  final String imagePath;

  AudioItem({
    this.id,
    required this.assetPath,
    required this.title,
    required this.artist,
    required this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'assetPath': assetPath,
      'title': title,
      'artist': artist,
      'imagePath': imagePath,
    };
  }

  factory AudioItem.fromMap(Map<String, dynamic> map) {
    return AudioItem(
      id: map['id'] as int?,
      assetPath: map['assetPath'] as String,
      title: map['title'] as String,
      artist: map['artist'] as String,
      imagePath: map['imagePath'] as String,
    );
  } // se tenía que hacer con un map xdddd

  AudioItem copyWith({
    int? id,
    String? assetPath,
    String? title,
    String? artist,
    String? imagePath,
  }) {
    return AudioItem(
      id: id ?? this.id,
      assetPath: assetPath ?? this.assetPath,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  @override
  String toString() {
    return 'AudioItem{id: $id, title: $title, artist: $artist}';
  }
}