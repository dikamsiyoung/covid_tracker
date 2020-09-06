import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../lang/en.dart';

class UserProvider with ChangeNotifier {
  User _currentUser;
  Country country;

  //UI Updaters
  bool _isLoggedIn;

  bool fakeOfflineUser = false; /////////////////////////////////////////////

  final errors = English.errors['user_provider_errors'];

  UserProvider() {
    _setLoginStatus();
    _setUserCountry();
  }

  User get currentUser {
    return _currentUser;
  }

  bool get isLoggedIn {
    return _isLoggedIn;
  }

  void _setLoginStatus() async {
    final pref = await SharedPreferences.getInstance();
    _isLoggedIn = pref.getBool('isLoggedIn');
  }

  Future<void> setCurrentUser(FirebaseUser firebaseDetails) async {
    var response;
    try {
      if (fakeOfflineUser) {
        _currentUser = User(
          email: 'fakeuser@fakemail.com',
          id: 'jfYUfnnfk89475nd987aljfk',
          name: 'Fake User',
          phoneNumber: '+2341234567890',
        );
        notifyListeners();
        ///////////////////////////////////////////////////////////////////
        print('Using fake offline user...');
        return;
      }
      if (firebaseDetails == null) {
        onUserSignOut();
        print('No current user.');
        return;
      }
      if (firebaseDetails != null) {
        if (firebaseDetails.displayName == null ||
            firebaseDetails.email == null ||
            firebaseDetails.phoneNumber == null) {
          response = await Firestore.instance
              .collection('users')
              .document(firebaseDetails.uid)
              .get();
          await firebaseDetails.updateProfile(
              UserUpdateInfo().displayName = response.data['name']);
        }

        _currentUser = User(
          id: firebaseDetails.uid,
          firebaseDetails: firebaseDetails,
          email: firebaseDetails.email,
          name: firebaseDetails.displayName != null
              ? firebaseDetails.displayName
              : response.data['name'] != null
                  ? response.data['name']
                  : fakeOfflineUser /////////////////////////////////////////////////////////////////////
                      ? 'Fake Name...'
                      : '-',
          phoneNumber: firebaseDetails.phoneNumber != null
              ? firebaseDetails.phoneNumber
              : response.data['phoneNumber'] != null
                  ? response.data['phoneNumber']
                  : fakeOfflineUser /////////////////////////////////////////////////////////////////////
                      ? 'Fake Number...'
                      : '-',
        );
        print(
            'Current user: ${_currentUser == null ? null : _currentUser.name}');
        if (_isLoggedIn == false) {
          await updateCurrentUser(
            {
              'isEmailVerified': _currentUser.firebaseDetails.isEmailVerified,
              'lastSignIn': DateTime.now().toIso8601String()
            },
            setLastSignIn: true,
          );
          _isLoggedIn = true;
          final pref = await SharedPreferences.getInstance();
          pref.setBool('isLoggedIn', _isLoggedIn);
        }
      }
      notifyListeners();
    } catch (error) {
      print(error);
      return;
    }
  }

  Future<void> updateCurrentUser(Map<String, dynamic> userData,
      {bool setLastSignIn}) async {
    try {
      if (fakeOfflineUser) {}
      if (userData != null) {
        await Firestore.instance
            .collection('users')
            .document(_currentUser.id)
            .setData(
              userData,
              merge: true,
            );
        if (userData['email'] != null)
          _currentUser.firebaseDetails.updateEmail(userData['email']);
        if (userData['password'] != null)
          _currentUser.firebaseDetails.updatePassword(userData['password']);
        if (userData['name'] != null)
          _currentUser.firebaseDetails
              .updateProfile(UserUpdateInfo()..displayName = userData['name']);
      }
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> _setUserCountry() async {
    try {
      final pref = await SharedPreferences.getInstance();
      if (pref.containsKey('countryCode') && pref.containsKey('countryName')) {
        this.country = CountryPickerUtils.getCountryByIsoCode(
            pref.getString('countryCode'));
        notifyListeners();
      }
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateUserCountry([Country country]) async {
    try {
      final pref = await SharedPreferences.getInstance();
      pref.setString('countryCode', country.isoCode);
      pref.setString('countryName', country.name);
      _setUserCountry();
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  void onUserSignOut() async {
    final pref = await SharedPreferences.getInstance();
    _currentUser = null;
    _isLoggedIn = false;
    pref.setBool('isLoggedIn', _isLoggedIn);
  }

  Future<void> deleteCurrentUser() async {
    try {
      if (_currentUser == null)
        throw 'No user signed in. You are in dev mode...';
      await Firestore.instance
          .collection('users')
          .document(_currentUser.id)
          .delete();
      await _currentUser.firebaseDetails.delete();
      onUserSignOut();
      notifyListeners();
    } catch (error) {
      print(error);
      throw errors['USER_DELETE_ERROR'];
    }
  }

  Future<void> updateUsername(String username) async {
    try {
      await _currentUser.firebaseDetails
          .updateProfile(UserUpdateInfo()..displayName = username);
      await updateCurrentUser({'name': username});
    } catch (error) {
      print(error);
      throw "Couldn't update username...";
    }
  }

  Future<void> updateEmail(String email) async {
    try {
      await updateCurrentUser({'email': email});
      await _currentUser.firebaseDetails.updateEmail(email);
      await _currentUser.firebaseDetails.sendEmailVerification();
    } on PlatformException catch (error) {
      if (error.code == 'ERROR_EMAIL_ALREADY_IN_USE')
        throw 'Email already in use. Try another email...';
    } catch (error) {
      print(error);
      throw errors['EMAIL_UPDATE_FAILED'];
    }
  }

  Future<void> updatePhoneNumber(String phoneNumber) async {
    try {
      await updateCurrentUser({'phoneNumber': phoneNumber});
    } catch (error) {
      print(error);
      throw "Couldn't update phone number...";
    }
  }
}
