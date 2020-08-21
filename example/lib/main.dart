import 'package:flutter/material.dart';

import 'package:retro_media_picker/retro_media_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Demo',
        theme: ThemeData(
            primarySwatch: Colors.amber, buttonTheme: ButtonThemeData()),
        home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: RaisedButton(
                  onPressed: () {
                    RetroMediaPicker.pickImage(
                            context: context,
                            pickerType: RetroMediaPickerType.bottomSheet)
                        .then(_setResult);
                  },
                  child: Text('Choose single image bottom sheet')),
            ),
            RaisedButton(
                onPressed: () {
                  RetroMediaPicker.pickImages(
                          context: context,
                          pickerType: RetroMediaPickerType.fullscreen)
                      .then(_setResult);
                },
                child: Text('Choose multi image fullscreen')),
            RaisedButton(
                onPressed: () {
                  RetroMediaPicker.pickVideo(
                          context: context,
                          pickerType: RetroMediaPickerType.bottomSheet)
                      .then(_setResult);
                },
                child: Text('Choose single video bottom sheet')),
            RaisedButton(
                onPressed: () {
                  RetroMediaPicker.pickVideos(
                          context: context,
                          pickerType: RetroMediaPickerType.fullscreen)
                      .then(_setResult);
                },
                child: Text('Choose multiple videos fullscreen')),
            RaisedButton(
                onPressed: () {
                  RetroMediaPicker.pickImageWithVideos(
                          context: context,
                          pickerType: RetroMediaPickerType.fullscreen)
                      .then(_setResult);
                },
                child: Text('Choose both image and video fullscreen')),
            Spacer(),
            if (result != null)
              Text(result, style: Theme.of(context).textTheme.subtitle2),
            Spacer(),
          ]),
    );
  }

  _setResult(result) {
    setState(() {
      this.result = result.toString();
    });
  }
}
