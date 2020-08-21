import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:retro_media_picker/src/retro_permission_handler.dart';
import 'package:retro_media_picker/src/widgets/retro_media_picker_widget.dart';

import 'src/data/media_file.dart';

enum RetroMediaPickerType { bottomSheet, fullscreen }

class RetroMediaPicker {
  static Future<MediaFile> pickImage(
      {BuildContext context, RetroMediaPickerType pickerType}) async {
    return _showSinglePicker(context, pickerType, true, false);
  }

  static Future<Set<MediaFile>> pickImages(
      {BuildContext context, RetroMediaPickerType pickerType}) {
    return _showMultiPicker(context, pickerType, true, false);
  }

  static Future<MediaFile> pickVideo(
      {BuildContext context, RetroMediaPickerType pickerType}) {
    return _showSinglePicker(context, pickerType, false, true);
  }

  static Future<Set<MediaFile>> pickVideos(
      {BuildContext context, RetroMediaPickerType pickerType}) {
    return _showMultiPicker(context, pickerType, false, true);
  }

  static Future<Set<MediaFile>> pickImageWithVideos(
      {BuildContext context, RetroMediaPickerType pickerType}) {
    return _showMultiPicker(context, pickerType, true, true);
  }

  static Future<MediaFile> _showSinglePicker(BuildContext context,
      RetroMediaPickerType pickerType, bool withImages, bool withVideos) async {
    final permissionResult =
        await RetroPermissionHandler.checkStoragePermission();
    if (permissionResult) {
      if (pickerType == RetroMediaPickerType.bottomSheet) {
        return showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return DraggableScrollableSheet(
                initialChildSize: 0.6,
                minChildSize: 0.6,
                maxChildSize: 1.0,
                expand: false,
                builder: (ctx, controller) {
                  return RetroMediaPickerWidget(
                    withImages: withImages,
                    withVideos: withVideos,
                    scrollController: controller,
                    onFileChoose: (Set<MediaFile> selectedFiles) {
                      print(selectedFiles);
                      Navigator.pop(context, selectedFiles.first);
                    },
                    onCancel: () {
                      Navigator.pop(context);
                    },
                  );
                });
          },
        );
      } else {
        return Navigator.push(
            context,
            MaterialPageRoute(
                builder: (c) => Material(
                        child: SafeArea(
                            child: RetroMediaPickerWidget(
                      withImages: withImages,
                      withVideos: withVideos,
                      onFileChoose: (Set<MediaFile> selectedFiles) {
                        print(selectedFiles);
                        Navigator.pop(context, selectedFiles.first);
                      },
                      onCancel: () {
                        Navigator.pop(context);
                      },
                    ))),
                fullscreenDialog: true));
      }
    } else {
      throw PlatformException(
          message: 'Permission denied',
          details: 'User has denied storage permission.',
          code: '504');
    }
  }

  static Future<Set<MediaFile>> _showMultiPicker(BuildContext context,
      RetroMediaPickerType pickerType, bool withImages, bool withVideos) async {
    final permissionResult =
        await RetroPermissionHandler.checkStoragePermission();
    if (permissionResult) {
      if (pickerType == RetroMediaPickerType.bottomSheet) {
        return showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return DraggableScrollableSheet(
                initialChildSize: 0.6,
                minChildSize: 0.6,
                maxChildSize: 1.0,
                expand: false,
                builder: (ctx, controller) {
                  return RetroMediaPickerWidget(
                    withImages: withImages,
                    allowMultiple: true,
                    withVideos: withVideos,
                    scrollController: controller,
                    onFileChoose: (Set<MediaFile> selectedFiles) {
                      print(selectedFiles);
                      Navigator.pop(context, selectedFiles);
                    },
                    onCancel: () {
                      Navigator.pop(context);
                    },
                  );
                });
          },
        );
      } else {
        return Navigator.push(
            context,
            MaterialPageRoute(
                builder: (c) => Material(
                        child: SafeArea(
                            child: RetroMediaPickerWidget(
                      withImages: withImages,
                      allowMultiple: true,
                      withVideos: withVideos,
                      onFileChoose: (Set<MediaFile> selectedFiles) {
                        print(selectedFiles);
                        Navigator.pop(context, selectedFiles);
                      },
                      onCancel: () {
                        Navigator.pop(context);
                      },
                    ))),
                fullscreenDialog: true));
      }
    } else {
      throw PlatformException(
          message: 'Permission denied',
          details: 'User has denied storage permission.',
          code: '504');
    }
  }
}
