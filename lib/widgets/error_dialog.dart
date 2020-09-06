import 'package:flutter/material.dart';

class NormalErrorDialog extends StatelessWidget {
  final title;
  final message;

  NormalErrorDialog({this.title, this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        FlatButton(
          child: const Text('OKAY'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class LoginErrorDialog extends StatelessWidget {
  final Function function;
  final title;
  final message;
  final actionText;

  LoginErrorDialog({
    this.title,
    this.message,
    this.function,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        FlatButton(
          child: Text(actionText),
          onPressed: () {
            function();
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text('CLOSE'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
