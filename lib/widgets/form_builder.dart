import 'package:flutter/material.dart';

import './login_text_input.dart';

class FormBuilder extends StatelessWidget {
  final BuildContext context;

  //Form Data
  final formKey;
  final phoneNumber;
  final country;
  final authData;

  //UI Updaters
  final AuthMode authMode;
  final bool isLoading;
  final bool unknownEmail;
  final bool autoValidate;
  final bool isPageOne;
  final bool isPageTwo;
  final bool isPageThree;
  final bool confirmPhoneNumber;

  //Controllers and Focus Nodes
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final TextEditingController passwordController;

  //UI Functions
  final Function showCountryList;
  final Function setVerificationCode;
  final Function sendVerificationCode;
  final Function signUpFlow;
  final Function setEmail;
  final Function setPassword;
  final Function setName;
  final Function setAgeGroup;
  final Function setGender;
  final Function setPhoneNumber;
  final Function signInFlow;
  final Function onSignInModeButtonPressed;

  FormBuilder({
    this.authData,
    this.context,
    this.isPageOne,
    this.isPageTwo,
    this.isPageThree,
    this.setEmail,
    this.setPassword,
    this.setName,
    this.setGender,
    this.setAgeGroup,
    this.setPhoneNumber,
    this.phoneNumber,
    this.authMode,
    this.emailFocusNode,
    this.country,
    this.showCountryList,
    this.formKey,
    this.confirmPhoneNumber,
    this.isLoading,
    this.onSignInModeButtonPressed,
    this.setVerificationCode,
    this.passwordController,
    this.passwordFocusNode,
    this.sendVerificationCode,
    this.signInFlow,
    this.unknownEmail,
    this.autoValidate,
    this.signUpFlow,
  });

  String validateName(String value) {
    if (value.length == 0) {
      return 'Tell us your name';
    } else if (value.length < 6) {
      return "That's a bit too short...";
    }
    return null;
  }

  String validatePassword(String value) {
    if (value.length == 0) {
      return 'Password is required';
    } else if (value.length < 4) {
      return 'Incorrect password';
    }
    return null;
  }

  String confirmPassword(String value) {
    if (value != passwordController.text) {
      return 'Passwords do not match!';
    }
    return null;
  }

  String confirmVerificationCode(String value) {
    if (value == null) return 'Enter the OTP sent';
    return null;
  }

  String validateEmail(String value) {
    if (value.isEmpty) {
      return "Enter email address";
    }
    String p = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
        "\\@" +
        "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
        "(" +
        "\\." +
        "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
        ")+";
    RegExp regExp = new RegExp(p);
    if (!regExp.hasMatch(value)) {
      return 'Email is not valid';
    }
    return null;
  }

  String validatePhone(String value) {
    String patttern = r'(^(?:[+0]9)?[0-9]{10,11}$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return 'Please enter mobile number';
    } else if (!regExp.hasMatch(value)) {
      return 'Please enter valid mobile number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      autovalidate: autoValidate,
      key: formKey,
      child: Column(
        children: <Widget>[
          isPageOne
              ? SignUpInputPageOne(
                  authMode: authMode,
                  emailFocusNode: emailFocusNode,
                  emailValidator: validateEmail,
                  passwordValidator: validatePassword,
                  passwordController: passwordController,
                  passwordFocusNode: passwordFocusNode,
                  confirmPassword: confirmPassword,
                  setEmail: setEmail,
                  setPassword: setPassword,
                )
              : isPageTwo
                  ? SignUpInputPageTwo(
                      nameValidator: validateName,
                      setAgeGroup: setAgeGroup,
                      setGender: setGender,
                      setName: setName,
                    )
                  : SignUpInputPageThree(
                      context: context,
                      confirmVerificationCode: confirmVerificationCode,
                      setVerificationCode: setVerificationCode,
                      sendVerificationCode: sendVerificationCode,
                      phoneValidator: validatePhone,
                      setPhoneNumber: setPhoneNumber,
                      confirmPhoneNumber: confirmPhoneNumber,
                      phoneNumber: phoneNumber,
                      country: country,
                      authData: authData,
                      showCountryList: showCountryList,
                    ),
          SizedBox(
            height: 8,
          ),
          Container(
            width: double.infinity,
            child: Card(
              elevation: 8,
              child: RaisedButton(
                elevation: 0,
                color: Colors.blueGrey,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                // highlightElevation: 2,
                // borderSide: BorderSide(color: Colors.grey[400], width: 1.5),
                onPressed: isLoading
                    ? null
                    : authMode == AuthMode.Login
                        ? () => signInFlow(context)
                        : signUpFlow,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 14, 0, 14),
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          isLoading
                              ? Container(
                                  margin: EdgeInsets.only(
                                    right: 12,
                                  ),
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    backgroundColor: Colors.transparent,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : SizedBox(),
                          Text(
                            isLoading
                                ? 'Loading...'
                                : authMode == AuthMode.Login
                                    ? 'Sign in'
                                    : isPageThree
                                        ? confirmPhoneNumber ? 'Verify' : 'Next'
                                        : 'Next',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: isLoading ? 18 : 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          authMode == AuthMode.Signup
                              ? !isLoading
                                  ? isPageOne || isPageTwo || isPageThree
                                      ? !confirmPhoneNumber
                                          ? Icon(
                                              Icons.arrow_forward,
                                              color: Colors.white,
                                            )
                                          : SizedBox()
                                      : SizedBox()
                                  : SizedBox()
                              : SizedBox(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 24,
          ),
          MaterialButton(
            child: Text(
              authMode == AuthMode.Login
                  ? 'Create an account'
                  : isPageThree && confirmPhoneNumber
                      ? 'Resend verfication code'
                      : 'Log in instead',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.grey[600],
              ),
            ),
            onPressed: isPageThree && confirmPhoneNumber
                ? () => sendVerificationCode(phoneNumber)
                : onSignInModeButtonPressed,
          ),
        ],
      ),
    );
  }
}
