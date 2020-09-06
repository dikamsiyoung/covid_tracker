import 'package:flutter/material.dart';

class PageLoadWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Please wait...',
            style: TextStyle(
              color: Colors.black54,
            ),
          )
        ],
      ),
    );
  }
}

class LoadWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      margin: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Please wait...',
            style: TextStyle(
              color: Colors.black54,
            ),
          )
        ],
      ),
    );
  }
}
