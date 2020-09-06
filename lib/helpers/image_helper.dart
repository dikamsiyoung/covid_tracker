import 'dart:io';

import 'package:exif/exif.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../lang/en.dart';
import '../models/report.dart';
import '../helpers/datetime_helper.dart';

class ImageHelper {
  static var errors = English.errors['image_helper_errors'];

  static var dateTimeErrors = English.errors['datetime_helper_errors'];

  

  static Future<Map<String, ExifData>> getExifData(
      Map<String, File> selectedImage) async {
    Map<String, ExifData> exifItem = {};

    selectedImage.forEach(
      (string, selectedImage) async {
        var extractedLatitude = [];
        var extractedLongitude = [];
        var exifGpsData;
        String exifDateTime;
        try {
          var extractedExifData =
              await readExifFromBytes(await selectedImage.readAsBytes());
          // print(extractedExifData);
          if (extractedExifData == null || extractedExifData.isEmpty) {
            print('No image in that location');
          } else {
            if (extractedExifData['GPS GPSLatitude'] != null) {
              extractedLatitude = extractedExifData['GPS GPSLatitude']
                  .values
                  .map<double>((item) =>
                      (item.numerator.toDouble() / item.denominator.toDouble()))
                  .toList();
              extractedLongitude = extractedExifData['GPS GPSLongitude']
                  .values
                  .map<double>((item) =>
                      (item.numerator.toDouble() / item.denominator.toDouble()))
                  .toList();
              // print(extractedLatitude);
              final LatLng exifGps = LatLng(
                extractedLatitude[0] +
                    (extractedLatitude[1] / 60) +
                    (extractedLatitude[2] / 3600),
                extractedLongitude[0] +
                    (extractedLongitude[1] / 60) +
                    (extractedLongitude[2] / 3600),
              );
              exifGpsData = exifGps;
            }
          }
          if (extractedExifData['Image DateTime'] != null) {
            exifDateTime = extractedExifData['Image DateTime'].toString();
          }
          exifItem.addAll(
            {
              string: ExifData(
                imageCoordinates: exifGpsData,
                imageDateTime: DateTimeHelper.exifDateTimeConverter(exifDateTime),
              ),
            },
          );
        } catch (error) {
          print(error);
          throw dateTimeErrors['READ_EXIF_ERROR'];
        }
      },
    );
    return exifItem;
  }
}
