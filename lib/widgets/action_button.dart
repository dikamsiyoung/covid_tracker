import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final isLoading;
  final isDoneLoading;
  final loadingText;
  final normalText;
  final normalIcon;
  final Function action;

  ActionButton({
    this.isDoneLoading,
    this.isLoading,
    this.action,
    this.loadingText,
    this.normalText,
    this.normalIcon,
  });

  @override
  Widget build(BuildContext context) {
    return RaisedButton.icon(
      icon: isLoading
          ? Container(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            )
          : isDoneLoading
              ? Icon(
                  Icons.check,
                  color: Colors.white,
                )
              : Icon(
                  normalIcon,
                  color: Colors.white,
                ),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      color: Colors.orangeAccent,
      label: Text(
        isLoading ? loadingText : isDoneLoading ? 'Done' : normalText,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      onPressed: action,
    );
  }
}
