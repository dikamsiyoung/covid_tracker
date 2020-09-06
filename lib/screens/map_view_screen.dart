import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:new_go_app/helpers/location_helper.dart';
import 'package:new_go_app/widgets/error_dialog.dart';
import 'package:provider/provider.dart';

import '../providers/report_provider.dart';

class MapViewScreen extends StatefulWidget {
  static const routeName = '/map-view';
  final bool isSelecting;
  final LatLng selectedLocation;
  final bool onlyUserReport;
  MapViewScreen(
      {this.isSelecting = true,
      this.selectedLocation,
      this.onlyUserReport = false});
  @override
  _MapViewScreenState createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  Completer<GoogleMapController> _controller = Completer();
  static const LatLng _center = const LatLng(6.6731, 3.1611);
  MapType _currentMapType = MapType.normal;
  List _markers = [];
  var pickedLocation;
  var _isInit = false;
  var _isLoading = false;
  var _useCurrentLocation = true;

  @override
  void didChangeDependencies() {
    if (!_isInit && !widget.isSelecting) {
      if (widget.selectedLocation != null) {
        setState(() {
          pickedLocation = widget.selectedLocation;
        });
      }
      _isLoading = true;
      _loadReports();
    }
    _isInit = true;
    super.didChangeDependencies();
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return NormalErrorDialog(
          title: title,
          message: message,
        );
      },
    );
  }

  Future<void> _loadReports() async {
    final provider = Provider.of<ReportProvider>(context, listen: false);
    try {
      await provider.fetchAndSetReports(onlyUserReport: widget.onlyUserReport);
      // print(_isLoading);
      var markers = [
        ...provider.items.map(
          (item) {
            LatLng location = LatLng(
              item.userLocation.latitude,
              item.userLocation.longitude,
            );
            // print(item.description);
            return Marker(
              markerId: MarkerId(item.id),
              position: location,
              infoWindow: InfoWindow(
                title: 'Vehicle Collision',
                snippet: item.description,
              ),
              icon: BitmapDescriptor.defaultMarker,
            );
          },
        )
      ];
      print(markers.length);
      _markers = markers;
      setState(() {
        _isLoading = false;
      });
      // print(_isLoading);
    } catch (error) {
      _showErrorDialog('Accidents not loaded', error);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void _selectLocation(LatLng coordinates) {
    setState(() {
      pickedLocation = coordinates;
      _useCurrentLocation = false;
    });
  }

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  void _setCurrentLocation() async {
    try {
      final currentLocation = LocationHelper.convertToLatLng(
        await Location().getLocation(),
      );
      setState(() {
        pickedLocation = currentLocation;
        _useCurrentLocation = false;
      });
    } catch (error) {
      print(error);
    }
  }

  void _submit(BuildContext context) {
    if (pickedLocation == null) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a location'),
          action: SnackBarAction(
            label: 'Okay',
            onPressed: () => SnackBarClosedReason.hide,
          ),
        ),
      );
      return;
    }
    Navigator.of(context).pop(pickedLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map View'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        isExtended: true,
        icon: widget.isSelecting
            ? _isLoading
                ? Container(
                    margin: EdgeInsets.all(4),
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    ),
                  )
                : pickedLocation == null
                    ? Icon(Icons.location_on, color: Colors.white)
                    : Icon(Icons.check_circle, color: Colors.white)
            : Icon(
                Icons.map,
                color: Colors.white,
              ),
        backgroundColor: Colors.deepOrangeAccent,
        onPressed: widget.isSelecting
            ? _useCurrentLocation ? _setCurrentLocation : () => _submit(context)
            : _onMapTypeButtonPressed,
        label: widget.isSelecting
            ? _isLoading
                ? Text(
                    'Loading...',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500),
                  )
                : pickedLocation == null
                    ? _useCurrentLocation
                        ? Text(
                            'My Location',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : Text(
                            'Use selected location',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                    : Text(
                        'Use selected location',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      )
            : _currentMapType == MapType.normal
                ? Text(
                    'Satellite',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : Text(
                    'Roads',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
      ),
      body: Builder(
        builder: (ctx) => Stack(
          children: <Widget>[
            GoogleMap(
              markers: widget.isSelecting
                  ? pickedLocation == null
                      ? null
                      : {
                          Marker(
                              position: pickedLocation,
                              markerId: MarkerId('Accident_Location'),
                              infoWindow:
                                  InfoWindow(title: 'Is this the location?'))
                        }
                  : Set.from(
                      _markers,
                    ),
              mapType: _currentMapType,
              onMapCreated: _onMapCreated,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              onTap: widget.isSelecting ? _selectLocation : null,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 11,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                right: 24,
                left: 10,
                bottom: 24,
                top: 16,
              ),
            ),
            widget.isSelecting
                ? SizedBox(
                    width: 1,
                  )
                : _isLoading
                    ? Padding(
                        padding: EdgeInsets.all(32),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Row(
                            children: <Widget>[
                              Container(
                                height: 12,
                                width: 12,
                                child: _currentMapType == MapType.normal
                                    ? CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(
                                          Colors.black.withOpacity(0.7),
                                        ),
                                      )
                                    : CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(
                                            Colors.white),
                                      ),
                              ),
                              SizedBox(width: 12),
                              _currentMapType == MapType.normal
                                  ? Text(
                                      'Loading...',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black.withOpacity(0.7),
                                      ),
                                    )
                                  : Text(
                                      'Loading...',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      )
                    : SizedBox(
                        width: 1,
                      ),
          ],
        ),
      ),
    );
  }
}
