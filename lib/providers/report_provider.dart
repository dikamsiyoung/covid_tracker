import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:location/location.dart';
import 'package:date_format/date_format.dart';

import '../helpers/image_helper.dart';
import '../helpers/location_helper.dart';
import '../helpers/firebase_helper.dart';
import '../helpers/db_helper.dart';
import '../models/report.dart';
import '../models/user.dart';

class ReportProvider with ChangeNotifier {
  User _userData;
  List<Report> _items = [];
  List<IncidentLocation> _crashLocations = [];
  List<String> _recipientList = [
    'young.udochi@stu.cu.edu.ng',
    // 'kog300@gmail.com',
    // 'oluniyi.kofoworola@stu.cu.edu.ng'
  ];
  List<String> _emailSubject = [
    'New Accident Report',
    'Potential Accident',
  ];

  //UI Updaters
  bool isLoading = false;
  bool isDoneSending = false;

  List<Report> get items {
    return [..._items];
  }

  List<IncidentLocation> get crashLocations {
    return [..._crashLocations];
  }

  void update(List<Report> items, User userData) {
    _items = items;
    _userData = userData;
    notifyListeners();
  }

  Future<void> addReport(
    Map<String, File> selectedImage,
    String description,
    String injuryLevel,
    String natureOfAccident,
  ) async {
    final timeStamp = DateTime.now();
    try {
      isLoading = true;
      notifyListeners();
      Map<String, ExifData> exifItem =
          await ImageHelper.getExifData(selectedImage);
      final userLoc = await Location().getLocation();
      final userLocation = await LocationHelper.getLocationAddress(
        userLoc.latitude,
        userLoc.longitude,
      );
      final response = await FirebaseHelper.uploadToDatabase(
        _userData.name,
        _userData.id,
        selectedImage,
        description,
        timeStamp.toIso8601String(),
        userLocation,
        exifItem,
        natureOfAccident,
        injuryLevel,
      );
      // print(response);
      final reportId = response['firebaseRef'].documentID;
      Map<String, String> imageUrl = response['url'];
      final newReport = await addToReports(
        imageUrl['victims'],
        imageUrl['vehicles'],
        reportId,
        userLocation,
        description,
        exifItem,
      );
      DBHelper.addToDb(
        newReport,
        selectedImage,
        userLocation,
        natureOfAccident,
        injuryLevel,
      );
      // print(currentLabels);
      notifyListeners();
      FirebaseHelper.sendEmail(
        userLocation.address,
        formatDate(timeStamp, [dd, '-', mm, '-', yy, ' ', HH, ':', nn]),
        _recipientList,
        _emailSubject[0],
      );
      isLoading = false;
      isDoneSending = true;
      notifyListeners();
      Timer(
        Duration(milliseconds: 3000),
        () {
          isDoneSending = false;
          notifyListeners();
        },
      );
    } catch (error) {
      isLoading = false;
      notifyListeners();
      throw error;
    }
  }

  Future<Report> addToReports(
    String victimImageUrl,
    String vehicleImageUrl,
    String reportId,
    IncidentLocation userLocation,
    String description,
    Map<String, ExifData> exifItem,
  ) async {
    final newReport = Report(
      id: reportId,
      vehicleImageUrl: victimImageUrl,
      victimImageUrl: vehicleImageUrl,
      description: description,
      userLocation: userLocation,
      victimImageExif: exifItem['victims'],
      vehicleImageExif: exifItem['vehicles'],
    );
    _items.add(newReport);
    return newReport;
  }

  Future<void> fetchAndSetReports({bool onlyUserReport = false}) async {
    try {
      final loadedReports = await FirebaseHelper.getReports(
        onlyUserReport ? _userData.id : null,
      );
      _items = loadedReports;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
