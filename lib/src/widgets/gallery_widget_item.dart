part of retro_media_picker;

class GalleryWidgetItem extends StatefulWidget {
  final MediaFile? mediaFile;
  final bool? allowMultiple;

  GalleryWidgetItem({this.mediaFile, this.allowMultiple});

  @override
  State<StatefulWidget> createState() => GalleryWidgetItemState();
}

class GalleryWidgetItemState extends State<GalleryWidgetItem> {
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
                opacity: selector.isSelected(widget.mediaFile!) ? 0.7 : 1.0,
                child: child,
              ),
              selector.isSelected(widget.mediaFile!)
                  ? Positioned(
                      right: 10,
                      bottom: 10,
                      child: CircleCheckWidget(selector.selectedItems
                          .toList()
                          .indexOf(widget.mediaFile!)),
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
          ThumbnailWidget(widget.mediaFile!),
          widget.mediaFile!.type == MediaType.VIDEO
              ? Icon(Icons.play_circle_filled, color: Colors.white, size: 24)
              : const SizedBox()
        ],
      ),
    );
  }
}

class CircleCheckWidget extends StatelessWidget {
  final int index;
  const CircleCheckWidget(this.index);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).primaryColor,
      shape: StadiumBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text('$index', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
