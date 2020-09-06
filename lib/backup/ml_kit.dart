// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:firebase_ml_vision/firebase_ml_vision.dart';
// import 'package:new_go_app/widgets/action_button.dart';

// import '../widgets/app_drawer.dart';
// import '../widgets/image_input.dart';

// class MlKit extends StatefulWidget {
//   static const routeName = '/ml-kit';

//   @override
//   _MlKitState createState() => _MlKitState();
// }

// class _MlKitState extends State<MlKit> {
//   File _selectedImage;
//   String _imageText;
//   var _isLoading = false;
//   var _isDoneLoading = false;
//   // var _isIncomplete = true;

//   void _saveImage(File selectedImage) {
//     _selectedImage = selectedImage;
//   }

//   void _uploadImage(BuildContext context) async {
//     if (_selectedImage == null) {
//       Scaffold.of(context).showSnackBar(
//         SnackBar(
//             content: Text('Please select an image'),
//             action: SnackBarAction(
//               label: 'OK',
//               onPressed: () => Scaffold.of(context).hideCurrentSnackBar(),
//             )),
//       );
//       return;
//     } else {
//       // _isIncomplete = false;
//       setState(() {
//         _isLoading = true;
//       });

//       final FirebaseVisionImage visionImage =
//           FirebaseVisionImage.fromFile(_selectedImage);
//       final TextRecognizer textRecognizerInstance =
//           FirebaseVision.instance.textRecognizer();
//       try {
//         final VisionText visionText =
//             await textRecognizerInstance.processImage(visionImage);
//         setState(() {
//           _imageText = visionText.text;
//           _isDoneLoading = true;
//           _isLoading = false;
//         });
//       } catch (error) {
//         print(error);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: AppDrawer(),
//       appBar: AppBar(
//         title: Text('ML Training'),
//       ),
//       body: Builder(
//         builder: (context) => Column(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: <Widget>[
//             Container(
//               margin: EdgeInsets.symmetric(
//                 horizontal: 18,
//               ),
//               width: double.infinity,
//               child: ImageInput(_saveImage),
//             ),
//             Expanded(
//               child: Container(
//                 height: 60,
//                 margin: EdgeInsets.only(
//                   left: 16,
//                   right: 16,
//                   top: 20,
//                   bottom: 20,
//                 ),
//                 width: double.infinity,
//                 child: Card(
//                   elevation: 4,
//                   child: Padding(
//                     padding: EdgeInsets.all(16),
//                     child: Align(
//                         alignment: Alignment.topLeft,
//                         child: _imageText == null
//                             ? Text(
//                                 'Results go here...',
//                                 style: TextStyle(color: Colors.grey),
//                               )
//                             : SingleChildScrollView(
//                                 child: Text(_imageText),
//                               )),
//                   ),
//                 ),
//               ),
//             ),
//             Container(
//               height: 50,
//               padding: EdgeInsets.symmetric(
//                 horizontal: 18,
//               ),
//               margin: EdgeInsets.symmetric(
//                 vertical: 18,
//               ),
//               width: double.infinity,
//               child: ActionButton(
//                 isDoneLoading: _isDoneLoading,
//                 isLoading: _isLoading,
//                 normalIcon: Icons.file_upload,
//                 loadingText: 'Uploading...',
//                 normalText: 'Upload Image',
//                 action: () => _uploadImage(context),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
