///
/// Created by Sunil Kumar on 20-08-2020 10:39 AM.
///
part of retro_media_picker;

class MultiSelectorModel extends ChangeNotifier {
  Set<MediaFile> _selectedItems = Set();

  void toggle(MediaFile file, bool isMultiple) {
    if (_selectedItems.contains(file)) {
      _selectedItems.remove(file);
    } else {
      if (!isMultiple) _selectedItems.clear();
      _selectedItems.add(file);
    }
    _selectedItems.forEach(
        (element) => element.index = _selectedItems.toList().indexOf(element));
    notifyListeners();
  }

  bool isSelected(MediaFile file) {
    return _selectedItems.contains(file);
  }

  Set<MediaFile> get selectedItems => _selectedItems;
}
