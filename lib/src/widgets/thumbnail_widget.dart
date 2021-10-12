part of retro_media_picker;

///
/// Created by Sunil Kumar on 22-08-2020 01:57 PM.
///
class ThumbnailWidget extends StatelessWidget {
  final MediaFile mediaFile;

  ThumbnailWidget(this.mediaFile);

  @override
  Widget build(BuildContext context) {
    return mediaFile.thumbnailPath != null
        ? RotatedBox(
            quarterTurns: Platform.isIOS
                ? 0
                : RetroMediaMethodHandler.orientationToQuarterTurns(
                    mediaFile.orientation!),
            child: Image.file(
              File(mediaFile.thumbnailPath!),
              fit: BoxFit.cover,
            ),
          )
        : FutureBuilder(
            future: RetroMediaMethodHandler.getThumbnail(
              fileId: mediaFile.id!,
              type: mediaFile.type!,
            ),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                var thumbnail = snapshot.data;
                mediaFile.thumbnailPath = thumbnail;
                return RotatedBox(
                  quarterTurns: Platform.isIOS
                      ? 0 // iOS thumbnails have correct orientation
                      : RetroMediaMethodHandler.orientationToQuarterTurns(
                          mediaFile.orientation!),
                  child: Image.file(
                    File(thumbnail!),
                    fit: BoxFit.cover,
                  ),
                );
              } else if (snapshot.hasError) {
                return Icon(Icons.error, color: Colors.red, size: 24);
              } else {
                return SizedBox();
              }
            });
  }
}
