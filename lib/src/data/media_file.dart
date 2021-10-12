part of retro_media_picker;

class MediaFile {
  String? id;
  int? dateAdded;
  String? path;
  String? thumbnailPath;
  int? orientation;
  int? duration;
  int? index;
  String? mimeType;
  MediaType? type;

  MediaFile(
      {this.id,
      this.dateAdded,
      this.path,
      this.thumbnailPath,
      this.orientation,
      this.type});

  MediaFile.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        dateAdded = json['dateAdded'],
        path = json['path'],
        thumbnailPath = json['thumbnailPath'],
        orientation = json['orientation'],
        duration = json['duration'],
        mimeType = json['mimeType'],
        type = MediaType.values[json['type']],
        index = json['index'];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaFile && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MediaFile{id: $id, dateAdded: $dateAdded, path: $path, thumbnailPath: $thumbnailPath, orientation: $orientation, duration: $duration, mimeType: $mimeType, type: $type}';
  }
}

enum MediaType { IMAGE, VIDEO }
enum RetroMediaPickerType { bottomSheet, fullscreen }
