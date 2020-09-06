import 'package:flutter/material.dart';
import 'package:new_go_app/providers/auth_provider.dart';
import 'package:new_go_app/providers/user_provider.dart';
import 'package:provider/provider.dart';

import '../error_dialog.dart';

class EditProfilePopup extends StatefulWidget {
  @override
  _EditProfilePopupState createState() => _EditProfilePopupState();
}

class _EditProfilePopupState extends State<EditProfilePopup> {
  GlobalKey<FormState> _formKey = GlobalKey();
  GlobalKey<FormState> _formKeyTwo = GlobalKey();

  @override
  void dispose() {
    _passwordController.dispose();
    _oldPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  //UI Updaters
  bool _isLoading = false;
  bool _smsSent = false;
  bool _isChangePassword = false;
  bool _isPhoneNumberEdit = false;
  bool _isUsernameEdit = false;
  bool _isEmailEdit = false;
  bool _isPhoneEditDone = false;
  bool _autovalidate = false;
  bool _isDoneEditing = false;
  bool _isAnyChange = false;

  //Form Data
  String _phoneNumber;
  String _email;
  String _username;
  String _smsCode;
  String _password;

  //Form Controllers
  var _passwordController = TextEditingController();
  var _oldPasswordController = TextEditingController();
  var _confirmPasswordController = TextEditingController();

  //Form Setters
  void _setPhoneNumber(String value) {
    if (value.isNotEmpty &&
        value != Provider.of<AuthProvider>(context).firebaseUser.phoneNumber)
      setState(() {
        _phoneNumber = value;
        _isPhoneNumberEdit = true;
        _isAnyChange = true;
      });
  }

  void _setUsername(String value) {
    if (value.isNotEmpty &&
        value != Provider.of<AuthProvider>(context).firebaseUser.phoneNumber)
      setState(() {
        _username = value;
        _isUsernameEdit = true;
        _isAnyChange = true;
      });
  }

  void _setEmail(String value) {
    if (value.isNotEmpty &&
        value != Provider.of<AuthProvider>(context).firebaseUser.phoneNumber)
      setState(() {
        _email = value;
        _isEmailEdit = true;
        _isAnyChange = true;
      });
  }

  void _setSmsCode(String value) {
    _smsCode = value;
  }

  void _setPassword(String value) {
    _password = value;
    _isAnyChange = true;
  }

  //Form Validators
  String _validateSmsCode(String value) {
    if (value.isEmpty) return 'Please enter the code received';
    return null;
  }

  String _validateOldPassword(String value) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (value == null || value.isEmpty) return 'Enter your old password';
    authProvider.logIn({
      'email': authProvider.firebaseUser.email,
      'password': value
    }).catchError((error) {
      return 'This password is not correct';
    });
    return null;
  }

  String _validateNewPassword(String value) {
    if (value.length == 0) {
      return 'Password is required';
    } else if (value.length < 4) {
      return 'Incorrect password';
    }
    return null;
  }

  String _validateConfirmPassword(String value) {
    if (value != _passwordController.text) {
      return 'Passwords do not match!';
    }
    return null;
  }

  //Form Functions
  Future<void> _saveUsername() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (_username == null || _username == userProvider.currentUser.name) return;
    try {
      await userProvider.updateUsername(_username);
    } catch (error) {
      _showErrorDialog('Edit failed', error.toString());
    }
    return;
  }

  Future<void> _saveEmail() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (_email == null || _email == userProvider.currentUser.email) return;
    try {
      await userProvider.updateEmail(_email);
    } catch (error) {
      _showErrorDialog('Edit failed', error.toString());
    }
  }

  Future<void> _verifyPhoneNumber() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (_phoneNumber == null ||
        _phoneNumber == authProvider.firebaseUser.phoneNumber) return;
    try {
      await authProvider.verifyPhone(_phoneNumber);
      if (authProvider.sentOtp) {
        setState(() {
          _smsSent = true;
        });
      }
    } catch (error) {
      _showErrorDialog('Edit failed', error.toString());
    }
  }

  Future<void> _savePhoneNumber() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      final response = await authProvider.updatePhoneNumber(_smsCode);
      if (response) await userProvider.updatePhoneNumber(_phoneNumber);
    } catch (error) {
      _showErrorDialog('Edit failed', error.toString());
    }
  }

  Future<void> _savePassword() async {
    final authProvider = Provider.of<AuthProvider>(context);
    try {
      await authProvider.updatePassword(_password);
    } catch (error) {
      _showErrorDialog('Edit failed', error.toString());
    }
  }

  void _saveEditFlow() async {
    setState(() {
        _isLoading = true;
      });
    try {
      if (_isChangePassword && _formKeyTwo.currentState.validate()) {
        _formKeyTwo.currentState.save();
        await _savePassword();
        setState(() {
          _isChangePassword = false;
        });
        return;
      }
      if (_formKey.currentState.validate()) {
        _formKey.currentState.save();
        if (!_isAnyChange) Navigator.of(context).pop();
        if (_isDoneEditing) Navigator.of(context).pop();
        if (_isPhoneNumberEdit) {
          _verifyPhoneNumber();
          setState(() {
            _isPhoneEditDone = true;
          });
          return;
        }
        if (_isPhoneNumberEdit && _isPhoneEditDone) await _savePhoneNumber();
        if (_isEmailEdit) await _saveEmail();
        if (_isUsernameEdit) await _saveUsername();
        setState(() {
          _isDoneEditing = true;
        });
      }
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Edit failed', error.toString());
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => NormalErrorDialog(
        title: 'Edit failed',
        message: message,
      ),
    );
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
              Container(
                margin: EdgeInsets.only(
                  left: 18,
                  right: 18,
                  top: 18,
                ),
                child: _isChangePassword
                    ? Form(
                        key: _formKeyTwo,
                        autovalidate: _autovalidate,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              enabled: !_isLoading,
                              validator: _validateOldPassword,
                              obscureText: true,
                              enableInteractiveSelection: false,
                              controller: _oldPasswordController,
                              autocorrect: false,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(color: Colors.black26),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                labelText: 'Enter old password',
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            TextFormField(
                              enabled: !_isLoading,
                              onSaved: _setPassword,
                              validator: _validateNewPassword,
                              keyboardType: TextInputType.text,
                              enableInteractiveSelection: false,
                              autocorrect: false,
                              obscureText: true,
                              controller: _passwordController,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(color: Colors.black26),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                labelText: 'New password',
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            TextFormField(
                              enabled: !_isLoading,
                              validator: _validateConfirmPassword,
                              controller: _confirmPasswordController,
                              enableInteractiveSelection: false,
                              keyboardType: TextInputType.text,
                              autocorrect: false,
                              obscureText: true,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: BorderSide(color: Colors.black26),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                labelText: 'Confirm new password',
                              ),
                            ),
                            SizedBox(
                              height: 68,
                            ),
                          ],
                        ),
                      )
                    : Form(
                        key: _formKey,
                        autovalidate: _autovalidate,
                        child: Consumer<UserProvider>(
                          builder: (context, userProvider, _) => _smsSent
                              ? Padding(
                                  padding: EdgeInsets.only(
                                    top: 100,
                                    bottom: 56,
                                  ),
                                  child: TextFormField(
                                    validator: _validateSmsCode,
                                    onSaved: _setSmsCode,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                        borderSide:
                                            BorderSide(color: Colors.black26),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      labelText: 'Enter verification code',
                                    ),
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    TextFormField(
                                      enabled: !_isLoading,
                                      onSaved: _setUsername,
                                      initialValue:
                                          userProvider.currentUser.name,
                                      keyboardType: TextInputType.text,
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          borderSide:
                                              BorderSide(color: Colors.black26),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        labelText: 'Username',
                                      ),
                                    ),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    TextFormField(
                                      enabled: !_isLoading,
                                      onSaved: _setEmail,
                                      initialValue:
                                          userProvider.currentUser.email,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          borderSide:
                                              BorderSide(color: Colors.black26),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        labelText: 'Email',
                                      ),
                                    ),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    TextFormField(
                                      enabled: !_isLoading,
                                      onSaved: (phoneNumber) {
                                        _setPhoneNumber(phoneNumber);
                                      },
                                      initialValue:
                                          userProvider.currentUser.phoneNumber,
                                      keyboardType: TextInputType.phone,
                                      decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          borderSide:
                                              BorderSide(color: Colors.black26),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        labelText: 'Phone number',
                                        suffixText: "Verification required",
                                        suffixStyle: TextStyle(
                                          color: Colors.black38,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(
                        top: 246,
                        left: 18,
                        right: 18,
                      ),
                      width: double.infinity,
                      child: OutlineButton(
                        padding: EdgeInsets.symmetric(
                          vertical: 18,
                        ),
                        child: Text(
                          _isChangePassword ? 'Cancel' : 'Change Password',
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                        onPressed: _isLoading
                            ? null
                            : _isChangePassword
                                ? () {
                                    setState(() {
                                      _isChangePassword = false;
                                    });
                                  }
                                : () {
                                    setState(() {
                                      _isChangePassword = true;
                                      _formKey.currentState.save();
                                    });
                                  },
                        borderSide: BorderSide(
                          width: 1.5,
                          color: Colors.orange.withOpacity(0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    _isLoading
                        ? Container(
                            margin: EdgeInsets.only(
                              left: 18,
                              right: 18,
                              bottom: 18,
                              top: 16,
                            ),
                            width: double.infinity,
                            child: OutlineButton(
                              disabledBorderColor:
                                  Theme.of(context).accentColor,
                              padding: EdgeInsets.all(16),
                              child: Container(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(
                                      Theme.of(context).accentColor),
                                ),
                              ),
                              onPressed: null,
                            ),
                          )
                        : Container(
                            margin: EdgeInsets.only(
                              left: 18,
                              right: 18,
                              bottom: 18,
                              top: 16,
                            ),
                            width: double.infinity,
                            child: RaisedButton(
                              color: Theme.of(context).accentColor,
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'Submit',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: _saveEditFlow,
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
