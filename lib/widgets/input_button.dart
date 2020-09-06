import 'package:flutter/material.dart';

class InputButton extends StatelessWidget {
  final widget;
  InputButton({this.widget});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: 18,
        bottom: 18,
      ),
      child: Card(
        elevation: 1,
        child: widget,
      ),
    );
  }
}
