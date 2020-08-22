part of retro_media_picker;

///
/// Created by Sunil Kumar on 20-08-2020 10:38 AM.
///

typedef OnFileChoose = Function(Set<MediaFile> selectedFiles);

class RetroMediaPickerWidget extends StatefulWidget {
  final bool withImages;
  final bool withVideos;
  final bool allowMultiple;
  final OnFileChoose onFileChoose;
  final Function() onCancel;
  final ScrollController scrollController;

  RetroMediaPickerWidget(
      {@required this.withImages,
      @required this.withVideos,
      @required this.onFileChoose,
      @required this.onCancel,
      this.scrollController,
      this.allowMultiple = false});

  @override
  State<StatefulWidget> createState() => PickerWidgetState();
}

class PickerWidgetState extends State<RetroMediaPickerWidget> {
  Album _selectedAlbum;
  List<Album> _albums;
  MultiSelectorModel _selector = MultiSelectorModel();
  Future albumFuture;
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    print('init ${DateTime.now()} $_isLoading');
    RetroMediaMethodHandler.getAlbums(
            withImages: widget.withImages, withVideos: widget.withVideos)
        .then((value) {
      setState(() {
        _albums = value;
        _isLoading = false;
        _selectedAlbum = value.isNotEmpty ? value.first : null;
      });
      print('get ${DateTime.now()} $_isLoading');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return Center(child: CircularProgressIndicator());
    else if (_albums.isEmpty) {
      return Center(child: Text("You have no folders to select from"));
    } else {
      return ChangeNotifierProvider<MultiSelectorModel>(
        create: (context) => _selector,
        child: DefaultTabController(
          length: widget.withVideos && widget.withImages ? 2 : 1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: Icon(Icons.close),
                  ),
                  Spacer(flex: 2),
                  DropdownButton<Album>(
                    value: _selectedAlbum,
                    onChanged: (Album newValue) {
                      setState(() {
                        _selectedAlbum = newValue;
                      });
                    },
                    items: _albums.map<DropdownMenuItem<Album>>((Album album) {
                      return DropdownMenuItem<Album>(
                        value: album,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 200),
                          child: Text(
                            "${album.name} (${album.files.length})",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  Spacer(flex: 3)
                ],
              ),
              PreferredSize(
                  child: TabBar(
                    tabs: [
                      if (widget.withVideos) Tab(text: 'Videos'),
                      if (widget.withImages) Tab(text: 'Photos')
                    ],
                  ),
                  preferredSize: Size(double.infinity, 32)),
              Expanded(
                  child: TabBarView(
                children: [
                  if (widget.withVideos)
                    GalleryWidget(
                        allowMultiple: widget.allowMultiple,
                        mediaFiles: _selectedAlbum.files
                            .where((e) => e.type == MediaType.VIDEO)
                            .toList(),
                        controller: widget.scrollController),
                  if (widget.withImages)
                    GalleryWidget(
                        allowMultiple: widget.allowMultiple,
                        mediaFiles: _selectedAlbum.files
                            .where((e) => e.type == MediaType.IMAGE)
                            .toList(),
                        controller: widget.scrollController),
                ],
              )),
              Consumer<MultiSelectorModel>(builder: (context, selector, child) {
                return AnimatedContainer(
                  color: Colors.white,
                  duration: const Duration(milliseconds: 200),
                  height: _selector.selectedItems.isNotEmpty ? 154 : 54,
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: _selector.selectedItems
                              .map((e) => SelectedItemWidget(e, onRemove: () {
                                    _selector.toggle(e, widget.allowMultiple);
                                  }))
                              .toList(),
                        ),
                      ),
                      Row(
                        children: [
                          SizedBox(width: 16),
                          Expanded(
                              child: Text(
                            'You can select both videos and photos.',
                            style: Theme.of(context).textTheme.caption,
                          )),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 2),
                            child: Consumer<MultiSelectorModel>(
                              builder: (context, selector, child) {
                                return RaisedButton(
                                  padding: EdgeInsets.zero,
                                  elevation: 1,
                                  disabledElevation: 0,
                                  focusElevation: 2,
                                  highlightElevation: 1.4,
                                  onPressed: selector.selectedItems.isEmpty
                                      ? null
                                      : () => widget.onFileChoose(
                                          _selector.selectedItems),
                                  child: Text(
                                    "Next (${_selector.selectedItems.length})",
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      );
    }
  }
}

class SelectedItemWidget extends StatelessWidget {
  SelectedItemWidget(this.file, {this.onRemove});
  final MediaFile file;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          Positioned.fill(
            child: ThumbnailWidget(file),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: GestureDetector(
              onTap: onRemove,
              child: Material(
                  color: Colors.black87,
                  type: MaterialType.circle,
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Icon(Icons.close, size: 22, color: Colors.white),
                  )),
            ),
          )
        ],
      ),
    );
  }
}
