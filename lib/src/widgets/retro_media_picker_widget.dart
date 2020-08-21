import 'package:flutter/material.dart';
import 'package:retro_media_picker/src/data/multi_selector_model.dart';
import 'package:retro_media_picker/src/retro_media_methos_handler.dart';
import '../data/album.dart';
import '../data/media_file.dart';
import 'package:provider/provider.dart';

import 'gallery_widget.dart';

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
  List<Album> _albums;
  Album _selectedAlbum;
  bool _loading = true;
  MultiSelectorModel _selector = MultiSelectorModel();

  @override
  void initState() {
    super.initState();
    RetroMediaMethodHandler.getAlbums(
      withImages: widget.withImages,
      withVideos: widget.withVideos,
    ).then((albums) {
      if (mounted)
        setState(() {
          _loading = false;
          _albums = albums;
          if (albums.isNotEmpty) {
            albums.sort((a, b) => b.files.length.compareTo(a.files.length));
            _selectedAlbum = albums[0];
          }
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _loading ? ImageLoader() : _buildWidget();
  }

  _buildWidget() {
    if (_albums.isEmpty)
      return Center(child: Text("You have no folders to select from"));

    final dropDownAlbumsWidget = DropdownButton<Album>(
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
    );

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
                dropDownAlbumsWidget,
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
            Container(
              color: Colors.white,
              child: Row(
                children: [
                  SizedBox(width: 16),
                  Expanded(
                      child: Text(
                    'You can select both videos and photos.',
                    style: Theme.of(context).textTheme.caption,
                  )),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
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
                              : () =>
                                  widget.onFileChoose(_selector.selectedItems),
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
            )
          ],
        ),
      ),
    );
  }
}

class ImageLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.grey, child: Center(child: Icon(Icons.perm_media)));
  }
}
