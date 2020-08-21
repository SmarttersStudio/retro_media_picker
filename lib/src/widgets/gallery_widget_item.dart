import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retro_media_picker/src/data/media_file.dart';
import 'package:retro_media_picker/src/data/multi_selector_model.dart';
import 'package:retro_media_picker/src/retro_media_methos_handler.dart';
import 'package:retro_media_picker/src/widgets/retro_media_picker_widget.dart';

class GalleryWidgetItem extends StatefulWidget {
  final MediaFile mediaFile;
  final bool allowMultiple;

  GalleryWidgetItem({this.mediaFile, this.allowMultiple});

  @override
  State<StatefulWidget> createState() => GalleryWidgetItemState();
}

class GalleryWidgetItemState extends State<GalleryWidgetItem> {
  Widget blueCheckCircle = Stack(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 24,
          height: 24,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
      Icon(Icons.check_circle, color: Colors.blue)
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Consumer<MultiSelectorModel>(
      builder: (context, selector, child) {
        return GestureDetector(
          onTap: () => selector.toggle(widget.mediaFile, widget.allowMultiple),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Opacity(
                opacity: selector.isSelected(widget.mediaFile) ? 0.7 : 1.0,
                child: child,
              ),
              selector.isSelected(widget.mediaFile)
                  ? Positioned(
                      right: 10,
                      bottom: 10,
                      child: blueCheckCircle,
                    )
                  : const SizedBox(),
            ],
          ),
        );
      },
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          widget.mediaFile.thumbnailPath != null
              ? RotatedBox(
                  quarterTurns: Platform.isIOS
                      ? 0
                      : RetroMediaMethodHandler.orientationToQuarterTurns(
                          widget.mediaFile.orientation),
                  child: Image.file(
                    File(widget.mediaFile.thumbnailPath),
                    fit: BoxFit.cover,
                  ),
                )
              : FutureBuilder(
                  future: RetroMediaMethodHandler.getThumbnail(
                    fileId: widget.mediaFile.id,
                    type: widget.mediaFile.type,
                  ),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasData) {
                      var thumbnail = snapshot.data;
                      widget.mediaFile.thumbnailPath = thumbnail;
                      return RotatedBox(
                        quarterTurns: Platform.isIOS
                            ? 0 // iOS thumbnails have correct orientation
                            : RetroMediaMethodHandler.orientationToQuarterTurns(
                                widget.mediaFile.orientation),
                        child: Image.file(
                          File(thumbnail),
                          fit: BoxFit.cover,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Icon(Icons.error, color: Colors.red, size: 24);
                    } else {
                      return ImageLoader();
                    }
                  }),
          widget.mediaFile.type == MediaType.VIDEO
              ? Icon(Icons.play_circle_filled, color: Colors.white, size: 24)
              : const SizedBox()
        ],
      ),
    );
  }
}
