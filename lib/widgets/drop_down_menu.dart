import 'package:flutter/material.dart';

class DropDownMenu extends StatefulWidget {
  final options;
  final hintText;
  final bool isReport;
  final Function submit;

  DropDownMenu({
    this.isReport = false,
    this.options,
    this.hintText,
    this.submit,
  });

  @override
  _DropDownMenuState createState() => _DropDownMenuState();
}

class _DropDownMenuState extends State<DropDownMenu> {
  String dropdownValue;
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: widget.isReport ? 0 : 2,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 2,
        ),
        decoration: ShapeDecoration(
          shape: OutlineInputBorder(
            borderSide: BorderSide(
              color: isSelected
                  ? Colors.orange.withOpacity(0.5)
                  : Colors.black.withOpacity(0.3),
            ),
          ),
        ),
        child: DropdownButton<String>(
          underline: SizedBox(),
          isExpanded: true,
          value: dropdownValue,
          hint: Text(widget.hintText),
          onChanged: (String newValue) {
            setState(() {
              isSelected = true;
              dropdownValue = newValue;
            });
            return widget.submit(newValue);
          },
          items: widget.options.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }
}
