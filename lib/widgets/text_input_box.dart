import 'package:flutter/material.dart';

class TextInputBox extends StatelessWidget {
  final String label;

  final Function validator;
  final Function action;

  final FocusNode focusNode;

  final bool obsure;
  final bool keyboardInteraction;
  final bool autocorrect;

  final TextEditingController controller;
  final TextInputType inputType;

  TextInputBox({
    this.action,
    this.autocorrect,
    this.controller,
    this.focusNode,
    this.inputType,
    this.keyboardInteraction,
    this.label,
    this.obsure,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: TextFormField(
        focusNode: focusNode,
        obscureText: obsure,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.orange.withOpacity(0.5),
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: BorderSide(
              width: 1.5,
            ),
          ),
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[500],
          ),
        ),
        controller: controller,
        keyboardType: inputType,
        validator: validator,
        onSaved: action,
        enableInteractiveSelection: keyboardInteraction,
        autocorrect: autocorrect,
      ),
    );
  }
}
