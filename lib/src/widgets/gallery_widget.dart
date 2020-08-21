import 'package:flutter/material.dart';
import 'package:retro_media_picker/src/data/media_file.dart';
import 'gallery_widget_item.dart';

class GalleryWidget extends StatelessWidget {
  final List<MediaFile> mediaFiles;
  final bool allowMultiple;
  final ScrollController controller;

  GalleryWidget(
      {@required this.mediaFiles,
      this.controller,
      @required this.allowMultiple});

  @override
  Widget build(BuildContext context) {
    return mediaFiles.isEmpty
        ? Center(child: Text("Empty Folder"))
        : GridView.builder(
            controller: controller,
            padding: EdgeInsets.all(0),
            itemCount: mediaFiles.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
            ),
            itemBuilder: (BuildContext context, int index) {
              return GalleryWidgetItem(
                mediaFile: mediaFiles[index],
                allowMultiple: allowMultiple,
              );
            });
  }
}
