part of retro_media_picker;

class Album {
  /// Unique identifier for the album
  final String id;
  final String name;
  final List<MediaFile> files;

  Album({this.id, this.name, this.files});

  Album.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        files = json['files']
            .map<MediaFile>((json) => MediaFile.fromJson(json))
            .toList();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Album && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Album{id: $id, name: $name, files: $files}';
  }
}
