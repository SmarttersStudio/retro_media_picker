///
/// Created by Sunil Kumar on 20-08-2020 10:34 AM.
///

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'data/album.dart';
import 'data/media_file.dart';

class RetroMediaMethodHandler {
  static const MethodChannel _channel =
      const MethodChannel('retro_media_picker');

  static Future<List<Album>> getAlbums(
      {@required bool withImages,
      @required bool withVideos,
      bool loadIOSPaths = true}) async {
    final String json = await _channel.invokeMethod(
      "getAlbums",
      {
        "withImages": withImages,
        "withVideos": withVideos,
        "loadIOSPaths": loadIOSPaths,
      },
    );
    final encoded = jsonDecode(json);
    return encoded.map<Album>((album) => Album.fromJson(album)).toList();
  }

  /// Returns the thumbnail path of the media file returned in method [getAlbums].
  /// If there is no cached thumbnail for the file, it will generate one and return it.
  /// Android thumbnails will need to be rotated based on the file orientation.
  /// iOS thumbnails have the correct orientation
  /// i.e. RotatedBox(
  ///                  quarterTurns: Platform.isIOS
  ///                      ? 0
  ///                      : orientationToQuarterTurns(mediaFile.orientation),
  ///                  child: Image.file(
  ///                    File(mediaFile.thumbnailPath),
  ///                    fit: BoxFit.cover,
  ///                    )
  static Future<String> getThumbnail({
    @required String fileId,
    @required MediaType type,
  }) async {
    final String path = await _channel.invokeMethod(
      'getThumbnail',
      {
        "fileId": fileId,
        "type": type.index,
      },
    );
    return path;
  }

  /// Returns the [MediaFile] of a file by the unique identifier
  /// [loadIOSPath] Whether or not to try and fetch path & video duration for iOS.
  /// Android always returns the path & duration
  /// [loadThumbnail] Whether or not to generate a thumbnail
  static Future<MediaFile> getMediaFile({
    @required String fileId,
    @required MediaType type,
    bool loadIOSPath = true,
    bool loadThumbnail = false,
  }) async {
    final String json = await _channel.invokeMethod(
      'getMediaFile',
      {
        "fileId": fileId,
        "type": type.index,
        "loadIOSPath": loadIOSPath,
        "loadThumbnail": loadThumbnail,
      },
    );
    final encoded = jsonDecode(json);
    return MediaFile.fromJson(encoded);
  }

  /// A convenient function that converts image orientation to quarter turns for widget [RotatedBox]
  /// i.e. RotatedBox(
  ///                  quarterTurns: orientationToQuarterTurns(mediaFile.orientation),
  ///                  child: Image.file(
  ///                    File(mediaFile.thumbnailPath),
  ///                    fit: BoxFit.cover,
  ///                    )
  static int orientationToQuarterTurns(int orientationInDegrees) {
    switch (orientationInDegrees) {
      case 90:
        return 1;
      case 180:
        return 2;
      case 270:
        return 3;
      default:
        return 0;
    }
  }
}
