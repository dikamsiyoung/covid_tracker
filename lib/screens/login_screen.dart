import 'dart:async';

import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:firebase_auth/firebase_auth_provider.dart';
// import 'package:google_sign_in/google_sign_in.dart';

import '../lang/en.dart';
import '../providers/auth_provider.dart';
import '../widgets/login_text_input.dart';
import '../widgets/splash_icon.dart';
import '../widgets/error_dialog.dart';
import '../widgets/form_builder.dart';
import '../widgets/sign_up_buttons.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  final errors = English.errors['firebase_helper_errors'];
  var _authMode = AuthMode.Login;
  var _countryCode = '+234';
  String _country = 'NG';

  //UI Updaters
  bool _isLoading = false;
  bool _signInWithEmail = false;
  bool _autoValidate = false;
  bool _confirmPhoneNumber = false;
  bool _isSignedUp = false;
  bool _isSignedIn = false;
  bool _isPhoneCodeReceived = false;

  //Sign Up Pages
  bool _isPageOne = true;
  bool _isPageTwo = false;
  bool _isPageThree = false;

  //Controllers
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  //User Data
  final Map<String, dynamic> _authData = {
    'email': null,
    'password': null,
    'name': null,
    'phoneNumber': null,
    'gender': null,
    'ageGroup': null,
    'country': null,
  };

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
    super.dispose();
  }

  Future<void> _showNormalErrorDialog(String title, String message) {
    return showDialog(
      context: _scaffoldKey.currentContext,
      builder: (BuildContext context) {
        return NormalErrorDialog(
          title: title,
          message: message,
        );
      },
    );
  }

  Future<void> _showLoginErrorDialog({
    String title,
    String message,
    Function function,
    String actionText,
  }) {
    return showDialog(
      context: _scaffoldKey.currentContext,
      builder: (BuildContext context) => LoginErrorDialog(
        title: title,
        message: message,
        function: function,
        actionText: actionText,
      ),
    );
  }

  void signUp() {
    setState(() {
      _authMode = AuthMode.Signup;
    });
  }

  void _onEmailButtonPressed() {
    setState(() {
      _signInWithEmail = true;
    });
  }

  void logIn() {
    setState(() {
      _authMode = AuthMode.Login;
      _isLoading = false;
    });
  }

  void resetLoginPage() {
    setState(() {
      _authMode = AuthMode.Login;
      _isPageOne = true;
      _isPageTwo = false;
      _isPageThree = false;
      _countryCode = '+234';
      _country = 'NG';
      _isLoading = false;
      _signInWithEmail = false;
      _autoValidate = false;
      _passwordController.text = '';
      _confirmPhoneNumber = false;
      _isPageOne = true;
      _isPageTwo = false;
      _isPageThree = false;
    });
  }

  void _onSignInModeButtonPressed() {
    if (_authMode == AuthMode.Login) {
      signUp();
    } else {
      resetLoginPage();
      logIn();
    }
  }

  void setEmail(String value) {
    _authData['email'] = value;
  }

  void setPassword(String value) {
    _authData['password'] = value;
  }

  void setName(String value) {
    _authData['name'] = value;
  }

  void setGender(String value) {
    _authData['gender'] = value;
  }

  void setAgeGroup(String value) {
    _authData['ageGroup'] = value;
  }

  void setVerificationCode(String value) async {
    final authObject = Provider.of<AuthProvider>(context);
    authObject.smsCode = value;
    try {
      setState(() {
        _isLoading = true;
      });
      final response = await authObject.signUp(_authData);
      if (response) {
        setState(() {
          _isLoading = false;
          _isSignedUp = true;
          resetLoginPage();
        });
        Provider.of<AuthProvider>(context).tryAutoLogIn().then(
          (bool response) {
            if (response)
              Timer(
                Duration(milliseconds: 3000),
                () => Navigator.of(_scaffoldKey.currentContext)
                    .pushReplacementNamed(HomeScreen.routeName),
              );
          },
        );
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      if (error.toString().contains('Phone is already in use.'))
        _showLoginErrorDialog(
            title: 'Phone number unavailable',
            message: error.toString(),
            actionText: 'Try another',
            function: () {
              setState(() {
                _isPageOne = false;
                _isPageTwo = false;
                _isPageThree = true;
                _isPhoneCodeReceived = false;
              });
            });
      _showNormalErrorDialog('Sign up failed', error.toString());
    }
  }

  Future<void> sendVerificationCode(String value) async {
    final authData = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authData.verifyPhone(value);
      if (authData.sentOtp) {
        setState(() {
          _confirmPhoneNumber = true;
        });
      }
      return;
    } catch (error) {
      throw error;
    }
  }

  void setPhoneNumber(String value) async {
    int numberWithoutLeadingZero = int.parse(value);
    _authData['phoneNumber'] = '$_countryCode$numberWithoutLeadingZero';
    if (_authData['phoneNumber'] == null) return;
    setState(() {
      _isLoading = true;
    });
    try {
      await sendVerificationCode(_authData['phoneNumber']);
      setState(() {
        _isLoading = false;
        _confirmPhoneNumber = true;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      _showNormalErrorDialog('Failed to send OTP', error);
    }
  }

  Widget buildDialogItem(Country country) {
    return Row(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 6),
          child: CountryPickerUtils.getDefaultFlagImage(country),
        ),
        SizedBox(width: 12.0),
        Text("+${country.phoneCode}"),
        SizedBox(width: 8.0),
        Flexible(
          child: Text(
            country.name,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  void showCountryList(BuildContext context) {
    showDialog(
      context: _scaffoldKey.currentContext,
      builder: (context) => Theme(
        data: Theme.of(context).copyWith(primaryColor: Colors.pink),
        child: CountryPickerDialog(
          isDividerEnabled: true,
          popOnPick: true,
          contentPadding:
              EdgeInsets.only(top: 24, bottom: 32, left: 4, right: 4),
          titlePadding: EdgeInsets.only(top: 4.0, bottom: 10),
          searchCursorColor: Colors.pinkAccent,
          searchInputDecoration: InputDecoration(
            hintText: 'Search...',
          ),
          isSearchable: true,
          title: Text(
            'Select your country code',
            style: TextStyle(color: Colors.deepOrangeAccent),
          ),
          onValuePicked: (Country country) {
            setState(() {
              _country = country.isoCode;
              _countryCode = country.phoneCode;
            });
            _authData['country'] = country.name;
            Provider.of<AuthProvider>(context, listen: false)
                .setUserCountry(country.isoCode, country.name)
                .catchError(
                  (error) => _showNormalErrorDialog(
                    "Couldn't change country",
                    error.toString(),
                  ),
                );
          },
          priorityList: [
            CountryPickerUtils.getCountryByIsoCode('NG'),
            CountryPickerUtils.getCountryByIsoCode('US'),
          ],
          itemBuilder: (country) => buildDialogItem(country),
        ),
      ),
    );
  }

  Future<void> _signInFlow(BuildContext context) async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      setState(() {
        _autoValidate = true;
      });
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        // Log user in
        await Provider.of<AuthProvider>(_scaffoldKey.currentContext,
                listen: false)
            .logIn(_authData);
      }
      setState(() {
        _isLoading = false;
        _isSignedIn = true;
      });
      Navigator.of(_scaffoldKey.currentContext).pop();
      return;
    } on String catch (errorMessage) {
      if (errorMessage.contains(errors['ERROR_USER_NOT_FOUND'])) {
        setState(() {
          _isLoading = false;
        });
        _showLoginErrorDialog(
          title: 'Sign in failed',
          message: errorMessage,
          function: signUp,
          actionText: 'SIGN UP',
        );
      } else if (errorMessage.contains(errors['ERROR_WRONG_PASSWORD'])) {
        setState(() {
          _isLoading = false;
        });
        _showNormalErrorDialog('Sign in failed', errorMessage).then(
          (_) => FocusScope.of(_scaffoldKey.currentContext)
              .requestFocus(_passwordFocusNode),
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        await _showNormalErrorDialog('Sign in failed', errorMessage);
      }
      return;
    } catch (error) {
      _showNormalErrorDialog('Sign in failed', error.toString());
    }
  }

  void signUpFlow() async {
    var authObject =
        Provider.of<AuthProvider>(_scaffoldKey.currentContext, listen: false);
    if (_isPageOne && _formKey.currentState.validate()) {
      _formKey.currentState.save();
      try {
        setState(() {
          _isLoading = true;
        });
        final response = await authObject.checkEmail(_authData['email']);
        if (!response) {
          setState(() {
            _isLoading = false;
            _isPageOne = false;
            _isPageTwo = true;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          _showLoginErrorDialog(
              title: 'Registered Email',
              message:
                  'This email is registered already\nDo you want to log in?',
              function: logIn,
              actionText: 'LOG IN');
        }
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        _showNormalErrorDialog("Couldn't connect to internet", error);
      }
    } else if (_isPageTwo && _formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        _isPageTwo = false;
        _isPageThree = true;
      });
    } else if (_isPageThree &&
        !_isPhoneCodeReceived &&
        _formKey.currentState.validate()) {
      _formKey.currentState.save();
    } else if (_isPageThree &&
        _isPhoneCodeReceived &&
        _formKey.currentState.validate()) _formKey.currentState.save();
  }

  @override
  Widget build(BuildContext context) {
    final authData = Provider.of<AuthProvider>(context);
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        color: Colors.white,
        child: Consumer<AuthProvider>(
          builder: (consumerContext, auth, _) {
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SplashIcon(_signInWithEmail),
                    SizedBox(
                      height: _signInWithEmail ? 28 : 0,
                    ),
                    auth.isDoneLoading
                        ? Padding(
                            padding: const EdgeInsets.only(
                              left: 18,
                              right: 18,
                              bottom: 18,
                            ),
                            child: _isSignedUp || _isSignedIn
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox(
                                        height: 24,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(
                                            Icons.check_circle,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Text(
                                            _isSignedUp
                                                ? "You're all signed up!"
                                                : "Welcome back!",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Theme.of(context)
                                                    .primaryColor),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                    ],
                                  )
                                : !_signInWithEmail
                                    ? SignUpButtons(_onEmailButtonPressed)
                                    : FormBuilder(
                                        context: context,
                                        authData: authData,
                                        authMode: _authMode,
                                        formKey: _formKey,
                                        country: _country,
                                        isLoading: _isLoading,
                                        autoValidate: _autoValidate,
                                        phoneNumber: _authData['phoneNumber'],
                                        isPageOne: _isPageOne,
                                        isPageTwo: _isPageTwo,
                                        isPageThree: _isPageThree,
                                        emailFocusNode: _emailFocusNode,
                                        passwordFocusNode: _passwordFocusNode,
                                        passwordController: _passwordController,
                                        setEmail: setEmail,
                                        setPassword: setPassword,
                                        setName: setName,
                                        setAgeGroup: setAgeGroup,
                                        setGender: setGender,
                                        setPhoneNumber: setPhoneNumber,
                                        signInFlow: _signInFlow,
                                        signUpFlow: signUpFlow,
                                        confirmPhoneNumber: _confirmPhoneNumber,
                                        showCountryList: showCountryList,
                                        setVerificationCode:
                                            setVerificationCode,
                                        sendVerificationCode:
                                            sendVerificationCode,
                                        onSignInModeButtonPressed:
                                            _onSignInModeButtonPressed,
                                      ),
                          )
                        : Container(
                            margin: EdgeInsets.symmetric(vertical: 24),
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation(Colors.orangeAccent),
                            ),
                          ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
