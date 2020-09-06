import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class IncidentLocation {
  final double latitude;
  final double longitude;
  final String address;
  final String locatity;
  final String state;
  final String country;

  const IncidentLocation({
    @required this.latitude,
    @required this.longitude,
    this.address,
    this.locatity,
    this.state,
    this.country,
  });
}

class ExifData {
  final LatLng imageCoordinates;
  final DateTime imageDateTime;
  final String imageUrl;

  ExifData({
    this.imageCoordinates,
    this.imageDateTime,
    this.imageUrl,
  });
}

class Report {
  final String id;
  final String description;
  final IncidentLocation userLocation;
  final DateTime time;
  final String victimImageUrl;
  final String vehicleImageUrl;
  final ExifData victimImageExif;
  final ExifData vehicleImageExif;

  Report({
    @required this.id,
    this.description,
    this.time,
    this.userLocation,
    this.victimImageExif,
    this.vehicleImageExif,
    this.vehicleImageUrl,
    this.victimImageUrl,
  });
}
