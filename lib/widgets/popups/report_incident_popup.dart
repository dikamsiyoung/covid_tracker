import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/report_provider.dart';
import '../../screens/home_screen.dart';
import '../../widgets/image_input.dart';
import '../../widgets/drop_down_menu.dart';

class ReportIncidentPopup extends StatefulWidget {
  static const routeName = '/home-screen';

  final Function showErrorDialog;
  ReportIncidentPopup(this.showErrorDialog);

  @override
  _ReportIncidentPopupState createState() => _ReportIncidentPopupState();
}

class _ReportIncidentPopupState extends State<ReportIncidentPopup> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  var _autoValidate = false;
  final _descriptionFocusNode = FocusNode();

  Map<String, File> _selectedImage = {};

  var _crashDescription;
  var _selectedNatureOfAccident;
  var _selectedInjuryLevel;

  //UI Updaters
  var _isPageOne = true;
  var _isIncomplete = false;
  var _isTextInputted = false;

  void _saveVehicleImage(File selectedImage) {
    _selectedImage.addAll({'vehicles': selectedImage});
  }

  void _saveVictimImage(File selectedImage) {
    _selectedImage.addAll({'victims': selectedImage});
  }

  String validateDescription(String value) {
    if (value.isEmpty) {
      FocusScope.of(context).requestFocus(_descriptionFocusNode);
      _descriptionFocusNode.requestFocus();
      return '';
    }
    return null;
  }

  void setCrashDescrition(String value) {
    _crashDescription = value;
  }

  void _saveReport(BuildContext context) async {
    final report = Provider.of<ReportProvider>(context);
    if (_isPageOne &&
        _formKey.currentState.validate() &&
        _selectedInjuryLevel != null &&
        _selectedNatureOfAccident != null) {
      _formKey.currentState.save();
      setState(() {
        _isPageOne = false;
      });
      return;
    }
    if (!_isPageOne && _selectedImage.isNotEmpty) {
      setState(() {
        _isIncomplete = false;
      });
      try {
        await report.addReport(
          _selectedImage,
          _crashDescription,
          _selectedInjuryLevel,
          _selectedNatureOfAccident,
        );
        Timer(Duration(milliseconds: 1200), () {
          if (report.isDoneSending)
            Navigator.of(context).pop();
        });
      } catch (error) {
        widget.showErrorDialog('Sending failed', error.toString());
      }
    }
    return;
  }

  Widget textContainer(Widget widget) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18),
      child: Card(
        elevation: 0,
        child: widget,
      ),
    );
  }

  void setInjuryLevel(String newValue) {
    setState(() {
      _selectedInjuryLevel = newValue;
    });
    // print(_selectedInjuryLevel);
  }

  void setNatureOfAccident(String newValue) {
    setState(() {
      _selectedNatureOfAccident = newValue;
    });
    // print(_selectedNatureOfAccident);
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              _isPageOne
                  ? Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(
                            left: 9,
                            right: 9,
                            top: 20,
                          ),
                          margin: EdgeInsets.symmetric(
                            horizontal: 9,
                          ),
                          width: double.infinity,
                          child: DropDownMenu(
                            options: [
                              'Crash',
                              'Debris',
                            ],
                            hintText: 'Nature of Accident',
                            submit: setNatureOfAccident,
                            isReport: true,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: 18,
                            right: 18,
                            top: 10,
                            bottom: 6,
                          ),
                          width: double.infinity,
                          child: DropDownMenu(
                            options: [
                              'Serious',
                              'Minor',
                            ],
                            hintText: 'Injury Level',
                            submit: setInjuryLevel,
                            isReport: true,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            top: 4,
                          ),
                          // height: 50,
                          child: textContainer(
                            Form(
                              autovalidate: _autoValidate,
                              key: _formKey,
                              child: TextFormField(
                                onSaved: setCrashDescrition,
                                focusNode: _descriptionFocusNode,
                                validator: validateDescription,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color: _isTextInputted
                                        ? Colors.orange.withOpacity(0.5)
                                        : Colors.black.withOpacity(0.3),
                                  )),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    borderSide: BorderSide(
                                      width: 1.5,
                                      color: Colors.orange.withOpacity(0.5),
                                    ),
                                  ),
                                  labelText: 'Describe the accident',
                                ),
                                keyboardType: TextInputType.multiline,
                                autofocus: _isIncomplete ? true : false,
                                onChanged: (string) {
                                  setState(() {
                                    _isTextInputted = true;
                                  });
                                },
                                minLines: 4,
                                maxLines: 5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: <Widget>[
                        SizedBox(
                          width: 18,
                        ),
                        Expanded(
                          child: ImageInput(
                              _saveVictimImage, 'Passengers\nInvolved'),
                        ),
                        SizedBox(
                          width: 14,
                        ),
                        Expanded(
                          child: ImageInput(
                              _saveVehicleImage, 'Vehicles\nInvolved'),
                        ),
                        SizedBox(
                          width: 18,
                        ),
                      ],
                    ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: EdgeInsets.only(
                    top: 312,
                    left: 22,
                    right: 22,
                    bottom: 8,
                  ),
                  width: double.infinity,
                  child: Provider.of<ReportProvider>(context).isLoading
                      ? OutlineButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          disabledBorderColor: Theme.of(context).accentColor,
                          onPressed: null,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(
                                  right: 8,
                                ),
                                child: Provider.of<ReportProvider>(context)
                                        .isDoneSending
                                    ? Icon(Icons.check)
                                    : Container(
                                        height: 16,
                                        width: 16,
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation(
                                            Theme.of(context).accentColor,
                                          ),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        )
                      : RaisedButton(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          elevation: 1.5,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              _isPageOne
                                  ? SizedBox()
                                  : Container(
                                      margin: EdgeInsets.only(
                                        right: 6,
                                      ),
                                      child: Icon(
                                        Icons.send,
                                        size: 18,
                                      ),
                                    ),
                              Text(
                                _isPageOne ? 'Next' : 'Send Report',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              _isPageOne
                                  ? Container(
                                      margin: EdgeInsets.only(left: 6),
                                      child: Icon(
                                        Icons.arrow_forward,
                                        size: 18,
                                      ),
                                    )
                                  : SizedBox(),
                            ],
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          color: Theme.of(context).accentColor,
                          onPressed: () => _saveReport(context),
                        ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
