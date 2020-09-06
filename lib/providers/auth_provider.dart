import 'dart:async';

import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/firebase_helper.dart';
import '../lang/en.dart';

enum SignInMethod {
  Google,
  Email,
}

class AuthProvider with ChangeNotifier {
  FirebaseUser _firebaseUser;
  FirebaseUser _tempUser;
  String _firebaseUserId;
  String countryCode;
  String countryName;

  var errors = English.errors['auth_errors'];

  //UI Updaters
  bool signedOut;
  bool sentOtp = false;
  bool isDoneLoading = false;
  bool isPhoneNumberInvalid = false;
  String phoneVerificationStatus;

  bool fakeOfflineUser =
      false; /////////////////////////////////////////////////////////////////

  //Phone Verification
  var _verificationCode;
  var smsCode;
  var resendToken; //Currently unsused
  AuthCredential _authCredential;

  AuthProvider() {
    isSignedOut();
  }

  @override
  void dispose() {
    if (isPhoneNumberInvalid) _firebaseUser.delete();
    super.dispose();
  }

  final GoogleSignIn googleSignIn = GoogleSignIn();
  FirebaseAuthHelper _firebaseHelper =
      FirebaseAuthHelper(firebaseAuth: FirebaseAuth.instance);

  void isSignedOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      signedOut = prefs.getBool('signedOut');
    } catch (error) {
      print(error);
      throw errors['SHARED_PREFERENCE_ERROR'];
    }
  }

  bool get isAuth {
    return _firebaseUser != null;
  }

  String get firebaseUserId {
    return _firebaseUserId;
  }

  FirebaseUser get firebaseUser {
    return _firebaseUser;
  }

  Future<bool> signInWithGoogle() async {
    isDoneLoading = false;
    notifyListeners();
    try {
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      _firebaseUser = await _firebaseHelper.signInWithCredential(credential);

      isDoneLoading = true;
      notifyListeners();
      return true;
    } catch (error) {
      isDoneLoading = true;
      notifyListeners();
      print(error);
      throw errors['GOOGLE_ERROR']['SIGN_IN_ERROR'];
    }
  }

  void signOutGoogle() async {
    try {
      await googleSignIn.signOut();
      print("User Sign Out");
    } catch (error) {
      print(error);
      throw errors['GOOGLE_ERROR']['SIGN_OUT_ERROR'];
    }
  }

  Future<void> setUserCountry([String countryCode, String countryName]) async {
    try {
      if (countryCode != null && countryName != null) {
        final pref = await SharedPreferences.getInstance();
        pref.setString('countryCode', countryCode);
        pref.setString('countryName', countryName);
      } else {
        final pref = await SharedPreferences.getInstance();
        this.countryCode = pref.getString('countryCode');
        this.countryName = pref.getString('countryName');
      }
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<bool> checkEmail(String email) async {
    try {
      return await _firebaseHelper.isEmailRegistered(email);
    } catch (error) {
      print(error);
      throw 'Unable to reach servers...';
    }
  }

  Future<bool> signUp(Map<String, dynamic> userData) async {
    try {
      _tempUser =
          await _firebaseHelper.signUp(userData['email'], userData['password']);
      if (!fakeOfflineUser) {
        final credential =
            _firebaseHelper.verifySmsCode(_verificationCode, smsCode);
        await _tempUser.linkWithCredential(credential);
      }
      if (_tempUser != null) {
        _firebaseUserId = _tempUser.uid;
        userData.remove('password');
        await _firebaseHelper.registerUser(userData, _firebaseUserId);
        await _firebaseHelper.sendEmailVerification();
        signedOut = false;
        await SharedPreferences.getInstance()
          ..setBool('signedOut', signedOut);
        sentOtp = false;
        isDoneLoading = true;
        notifyListeners();
        return true;
      } else {
        throw "Couldn't obtain user ID";
      }
    } on PlatformException catch (error) {
      if (error.code.contains("ERROR_EMAIL_ALREADY_IN_USE")) {
        final databaseResponse =
            await _firebaseHelper.checkDatabase(userData['email']);
        if (!databaseResponse) {
          _firebaseHelper.registerUser(userData, firebaseUser.uid);
          if (!fakeOfflineUser) {
            final credential =
                _firebaseHelper.verifySmsCode(_verificationCode, smsCode);
            await _tempUser.linkWithCredential(credential);
          }
          await _firebaseHelper.sendEmailVerification();
          signedOut = false;
          await SharedPreferences.getInstance()
            ..setBool('signedOut', signedOut);
          isDoneLoading = true;
          notifyListeners();
        }
      } else if (error.code.contains("ERROR_CREDENTIAL_ALREADY_IN_USE")) {
        isPhoneNumberInvalid = true;
        throw 'Phone number is already in use.';
      }
      throw error.code;
    } catch (error) {
      throw error;
    }
  }

  Future<void> logIn(Map<String, dynamic> userData) async {
    try {
      _firebaseUser =
          await _firebaseHelper.signIn(userData['email'], userData['password']);
      _firebaseUserId = _firebaseUser.uid;
      final response = await _firebaseHelper.isEmailVerified();
      if (response != null && response) {
        notifyListeners();
      }
      signedOut = false;
      await SharedPreferences.getInstance()
        ..setBool('signedOut', signedOut);
      sentOtp = false;
      isDoneLoading = true;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<bool> tryAutoLogIn() async {
    try {
      _firebaseUser = await _firebaseHelper.getCurrentUser();
      if (_firebaseUser == null) return false;
      _firebaseUserId = _firebaseUser.uid;
      sentOtp = false;
      signedOut = false;
      await SharedPreferences.getInstance()
        ..setBool('signedOut', signedOut);
      isDoneLoading = true;
      notifyListeners();
      print('Auto-login');
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<void> verifyPhone(String phoneNumber) async {
    if (fakeOfflineUser) return true;
    final PhoneCodeSent phoneCodeSent =
        (String verificationId, [int forceResendingToken]) {
      _verificationCode = verificationId;
      resendToken = forceResendingToken;
      sentOtp = true;
      notifyListeners();
      print('Code sent to $phoneNumber');
    };

    final PhoneVerificationFailed phoneVerificationFailed =
        (AuthException authException) {
      print('${authException.message}');
      if (authException.message.contains('not authorized'))
        phoneVerificationStatus = _firebaseHelper.json['SMS_PERMISSION_DENIED'];
      else if (authException.message.contains('Network'))
        phoneVerificationStatus = _firebaseHelper.json["SMS_NETWORK_ERROR"];
      else
        phoneVerificationStatus = _firebaseHelper.json["SMS_DEFAULT_ERROR"];
      notifyListeners();
    };

    final PhoneVerificationCompleted phoneVerificationCompleted =
        (AuthCredential auth) {
      _authCredential = auth;
    };
    final PhoneCodeAutoRetrievalTimeout phoneCodeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationCode = verificationId;
      phoneVerificationStatus = _firebaseHelper.json['SMS_AUTORETRIEVAL_ERROR'];
    };
    try {
      await _firebaseHelper.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 60),
        phoneVerificationCompleted: phoneVerificationCompleted,
        phoneVerificationFailed: phoneVerificationFailed,
        phoneCodeSent: phoneCodeSent,
        phoneCodeAutoRetrievalTimeout: phoneCodeAutoRetrievalTimeout,
      );
    } catch (error) {
      throw error;
    }
  }

  Future<bool> updatePhoneNumber(String smsCode) async {
    try {
      final credential =
          _firebaseHelper.verifySmsCode(_verificationCode, smsCode);
      _firebaseUser.updatePhoneNumberCredential(credential);
      return true;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updatePassword(String password) async {
    try {
      await _firebaseUser.updatePassword(password);
    } catch (error) {
      print(error);
      throw errors['PASSWORD_UPDATE_FAILED'];
    }
  }

  Future<void> logOut() async {
    try {
      final pref = await SharedPreferences.getInstance();
      await _firebaseHelper.signOut();
      _firebaseUser = null;
      _firebaseUserId = null;
      isDoneLoading = true;
      signedOut = true;
      sentOtp = false;
      pref.setBool('signedOut', signedOut);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
