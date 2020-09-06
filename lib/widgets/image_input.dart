import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as pathfinder;
import 'package:path_provider/path_provider.dart' as syspaths;

import '../widgets/input_button.dart';

class ImageInput extends StatefulWidget {
  final Function onSelectImage;
  final String displayText;

  ImageInput(this.onSelectImage, this.displayText);

  @override
  _ImageInputState createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File _storedImage;
  bool isSelected = false;

  Future<void> _takePicture() async {
    try {
      final selectedImage = await ImagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 600,
      );
      setState(() {
        if (selectedImage == null) return;
        _storedImage = selectedImage;
      });
      final appDir = await syspaths.getApplicationDocumentsDirectory();
      final fileName = pathfinder.basename(selectedImage.path);
      if (fileName != null) {
        final savedImage = await selectedImage.copy('${appDir.path}/$fileName');
        widget.onSelectImage(savedImage);
      }
      setState(() {
        isSelected = true;
      });
    } catch (error) {
      print(error);
    }
  }

  Widget setPictureLabel(Color color, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.camera_alt,
          color: color,
          size: 32,
        ),
        SizedBox(
          height: 8,
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return InputButton(
      widget: Container(
        height: 200,
        child: OutlineButton(
          borderSide: BorderSide(
            color: isSelected
                ? Colors.orange.withOpacity(0.5)
                : Colors.black.withOpacity(0.15),
          ),
          padding: EdgeInsets.zero,
          onPressed: _takePicture,
          child: _storedImage == null
              ? setPictureLabel(Colors.black45, widget.displayText)
              : Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Image.file(
                      _storedImage,
                      fit: BoxFit.contain,
                    ),
                    Container(
                      color: Colors.black26,
                    ),
                    setPictureLabel(
                        Colors.white.withOpacity(0.9), 'Change Image')
                  ],
                ),
        ),
      ),
    );
  }
}
