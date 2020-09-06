import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../helpers/location_helper.dart';
import '../widgets/input_button.dart';

class LocationInput extends StatefulWidget {
  final Function action;
  final LatLng coordinates;
  final LatLng displayCoordinates;

  LocationInput({
    this.action,
    this.coordinates,
    this.displayCoordinates,
  });

  @override
  _LocationInputState createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  LatLng _receivedCoordinates;

  Widget setMapLabel(Color color, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.my_location,
          color: color,
          size: 32,
        ),
        SizedBox(
          height: 8,
        ),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget setMapImage() {
    if (widget.coordinates == null) {
      return SizedBox(
        width: 1,
        height: 1,
      );
    }
    setState(() {
      _receivedCoordinates = widget.coordinates;
    });
    return Image.network(
      LocationHelper.generateLocationPreviewImageUrl(_receivedCoordinates),
      fit: BoxFit.fill,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InputButton(
      widget: SizedBox(
        height: 200,
        child: OutlineButton(
          padding: EdgeInsets.zero,
          onPressed: widget.action,
          child: widget.coordinates == null
              ? setMapLabel(Colors.black45, 'Select Location')
              : Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Container(
                      child: setMapImage(),
                    ),
                    Container(
                      color: Colors.black12,
                    ),
                    setMapLabel(
                        Colors.white.withOpacity(0.9), 'Change Location')
                  ],
                ),
        ),
      ),
    );
  }
}
