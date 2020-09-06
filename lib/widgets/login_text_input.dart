import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/material.dart';

import '../widgets/drop_down_menu.dart';
import '../widgets/text_input_box.dart';

enum AuthMode { Signup, Login }

class SignUpInputPageOne extends StatelessWidget {
  final passwordController;
  final emailFocusNode;
  final passwordFocusNode;

  final Function confirmPassword;
  final Function passwordValidator;
  final Function emailValidator;
  final Function setEmail;
  final Function setPassword;
  final AuthMode authMode;

  SignUpInputPageOne({
    this.setPassword,
    this.emailFocusNode,
    this.passwordFocusNode,
    this.passwordController,
    this.passwordValidator,
    this.confirmPassword,
    this.emailValidator,
    this.authMode,
    this.setEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextInputBox(
          label: 'Email',
          validator: emailValidator,
          action: (value) => setEmail(value),
          focusNode: emailFocusNode,
          controller: null,
          inputType: TextInputType.emailAddress,
          keyboardInteraction: true,
          autocorrect: true,
          obsure: false,
        ),
        SizedBox(
          height: 8,
        ),
        TextInputBox(
          label: 'Password',
          validator: passwordValidator,
          action: (value) => setPassword(value),
          focusNode: passwordFocusNode,
          controller: passwordController,
          inputType: TextInputType.visiblePassword,
          keyboardInteraction: false,
          autocorrect: false,
          obsure: true,
        ),
        SizedBox(
          height: 8,
        ),
        if (authMode == AuthMode.Signup)
          TextInputBox(
            label: 'Confirm Password',
            validator: confirmPassword,
            action: null,
            focusNode: null,
            controller: null,
            inputType: TextInputType.visiblePassword,
            keyboardInteraction: false,
            autocorrect: false,
            obsure: true,
          )
      ],
    );
  }
}

class SignUpInputPageTwo extends StatelessWidget {
  final Function nameValidator;
  final Function setName;
  final Function setAgeGroup;
  final Function setGender;

  SignUpInputPageTwo({
    this.nameValidator,
    this.setAgeGroup,
    this.setGender,
    this.setName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextInputBox(
          label: 'Full Name',
          validator: nameValidator,
          action: (value) => setName(value),
          focusNode: null,
          controller: null,
          inputType: TextInputType.text,
          keyboardInteraction: true,
          autocorrect: true,
          obsure: false,
        ),
        SizedBox(
          height: 8,
        ),
        DropDownMenu(
          hintText: 'Age Group',
          options: ['Adolescence', 'Adult', 'Edlerly'],
          submit: setAgeGroup,
        ),
        SizedBox(
          height: 8,
        ),
        DropDownMenu(
          hintText: 'Gender',
          options: ['Male', 'Female', 'Rather not say'],
          submit: setGender,
        )
      ],
    );
  }
}

class SignUpInputPageThree extends StatelessWidget {
  final context;

  //Form Data
  final country;
  final authData;
  final phoneNumber;

  //UI Updater
  final bool confirmPhoneNumber;

  //Function
  final Function showCountryList;
  final Function setVerificationCode;
  final Function sendVerificationCode;
  final Function setPhoneNumber;
  final Function phoneValidator;
  final Function confirmVerificationCode;

  SignUpInputPageThree({
    this.authData,
    this.context,
    this.country,
    this.setVerificationCode,
    this.confirmVerificationCode,
    this.sendVerificationCode,
    this.phoneValidator,
    this.showCountryList,
    this.setPhoneNumber,
    this.confirmPhoneNumber,
    this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) => Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 12, bottom: 16),
            child: Text(
              !confirmPhoneNumber
                  ? 'Next, we will verify your phone number'
                  : 'Enter the code sent to $phoneNumber',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: 15,
              ),
            ),
          ),
          !confirmPhoneNumber
              ? Row(
                  children: <Widget>[
                    Expanded(
                      child: Card(
                        elevation: 3.5,
                        child: OutlineButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onPressed: () => showCountryList(context),
                          padding: EdgeInsets.symmetric(vertical: 19.5),
                          child: Align(
                            alignment: Alignment.center,
                            child: CountryPickerUtils.getDefaultFlagImage(
                              CountryPickerUtils.getCountryByIsoCode(country),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    Expanded(
                      flex: 3,
                      child: TextInputBox(
                        label: 'Enter phone Number',
                        validator: phoneValidator,
                        action: setPhoneNumber,
                        focusNode: null,
                        controller: null,
                        inputType: TextInputType.number,
                        keyboardInteraction: false,
                        autocorrect: false,
                        obsure: false,
                      ),
                    ),
                  ],
                )
              : SizedBox(
                  width: 1,
                ),
          confirmPhoneNumber
              ? Column(
                  children: <Widget>[
                    SizedBox(
                      width: 8,
                    ),
                    TextInputBox(
                      label: 'Enter verification code',
                      validator: confirmVerificationCode,
                      action: setVerificationCode,
                      focusNode: null,
                      controller: null,
                      inputType: TextInputType.number,
                      keyboardInteraction: true,
                      autocorrect: false,
                      obsure: false,
                    )
                  ],
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
