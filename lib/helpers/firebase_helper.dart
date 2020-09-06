import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:new_go_app/services/push_notifcation_service.dart';
import 'package:path/path.dart' as Path;

import '../lang/en.dart';
import '../models/report.dart';

class FirebaseAuthHelper {
  final FirebaseAuth firebaseAuth;

  var json = English.errors['firebase_helper_errors'];

  FirebaseAuthHelper({this.firebaseAuth});

  Future<FirebaseUser> signIn(String email, String password) async {
    try {
      AuthResult result = await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      print('Log in successful. User ID: ${user.uid}');
      return user;
    } on PlatformException catch (error) {
      final errorMessage = error.code.toString();
      print(error);
      if (errorMessage.contains('ERROR_NETWORK_REQUEST_FAILED')) {
        throw json['ERROR_NETWORK_REQUEST_FAILED'];
      } else if (errorMessage.contains('ERROR_WRONG_PASSWORD')) {
        throw json['ERROR_WRONG_PASSWORD'];
      } else if (errorMessage.contains('ERROR_USER_NOT_FOUND')) {
        throw json['ERROR_USER_NOT_FOUND'];
      }
      return null;
    } catch (error) {
      print(error);
      throw json['DEFAULT_LOGIN_ERROR'];
    }
  }

  Future<FirebaseUser> signInWithCredential(AuthCredential credential) async {
    try {
      final AuthResult authResult =
          await firebaseAuth.signInWithCredential(credential);
      final FirebaseUser user = authResult.user;
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);
      final FirebaseUser currentUser = await getCurrentUser();
      assert(user.uid == currentUser.uid);
      return currentUser;
    } catch (error) {
      print(error);
      throw json['DEFAULT_LOGIN_ERROR'];
    }
  }

  Future<FirebaseUser> signUp(String email, String password) async {
    try {
      if (email == null || password == null) throw 'No email or password...';
      AuthResult result = await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      print('Sign up successful. User ID: ${user.uid}');
      return user;
    } on PlatformException catch (error) {
      if (error.code.contains("ERROR_EMAIL_ALREADY_IN_USE")) throw error;
      return null;
    } catch (error) {
      throw json['DEFAULT_SIGNUP_ERROR'];
    }
  }

  Future<void> verifyPhoneNumber({
    String phoneNumber,
    Duration timeout,
    PhoneVerificationCompleted phoneVerificationCompleted,
    PhoneVerificationFailed phoneVerificationFailed,
    PhoneCodeAutoRetrievalTimeout phoneCodeAutoRetrievalTimeout,
    PhoneCodeSent phoneCodeSent,
  }) async {
    await firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: Duration(seconds: 60),
      verificationCompleted: phoneVerificationCompleted,
      verificationFailed: phoneVerificationFailed,
      codeSent: phoneCodeSent,
      codeAutoRetrievalTimeout: phoneCodeAutoRetrievalTimeout,
    );
  }

  Future<FirebaseUser> anonymousLogIn() async {
    try {
      FirebaseUser user = await firebaseAuth.currentUser();
      if (user == null) {
        firebaseAuth.signInAnonymously();
      }
      return await firebaseAuth.currentUser();
    } catch (error) {
      print(error);
      throw json['ANONYMOUS_LOGIN_ERROR'];
    }
  }

  Future<void> registerUser(
      Map<String, dynamic> userData, String userId) async {
    final databaseReference = Firestore.instance;

    try {
      final messagingService = PushNotificationServices();
      final token = await messagingService.getNotificationToken();
      print(token);
      userData.addAll(
        {
          'pushToken': token,
          'signUpTime': DateTime.now().toIso8601String(),
        },
      );
      await FirebaseAuth.instance.currentUser()
        ..updateProfile(UserUpdateInfo()..displayName = userData['name']);
      await databaseReference
          .collection('users')
          .document(userId)
          .setData(userData);
    } catch (error) {
      print(error);
      throw json['REGISTRATION_ERROR'];
    }
  }

  Future<FirebaseUser> getCurrentUser() async {
    try {
      FirebaseUser user = await firebaseAuth.currentUser();
      return user;
    } catch (error) {
      print(error);
      throw json['GET_USER_ERROR'];
    }
  }

  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
      print('Sign out successful');
    } catch (error) {
      print(error);
      throw json['SIGN_OUT_ERROR'];
    }
  }

  AuthCredential verifySmsCode(String verificationCode, String smsCode) {
    try {
      AuthCredential credential = PhoneAuthProvider.getCredential(
          verificationId: verificationCode, smsCode: smsCode);
      return credential;
    } catch (error) {
      throw error;
    }
  }

  Future<bool> isEmailRegistered(String email) async {
    bool databaseResponse;
    bool firebaseResponse;
    try {
      databaseResponse = await checkDatabase(email);
      firebaseResponse = await checkFirebaseUser(email);
      if (!firebaseResponse && databaseResponse != null && !databaseResponse)
        return false;
      if (!firebaseResponse && databaseResponse ||
          firebaseResponse && !databaseResponse)
        throw 'Data mismatch in Firebase...';
      return true;
    } catch (error) {
      if (error.toString().contains('Data mismatch in Firebase...'))
        throw error.toString();
      throw 'Invalid email...';
    }
  }

  Future<bool> checkDatabase(String email) async {
    final firestore = Firestore.instance;
    bool databaseResponse;
    try {
      final response = await firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .getDocuments();
      response.documents.isEmpty
          ? databaseResponse = false
          : databaseResponse = true;
      return databaseResponse;
    } catch (error) {
      throw error;
    }
  }

  Future<bool> checkFirebaseUser(String email) async {
    var firebase;
    bool firebaseResponse;
    try {
      firebase = await firebaseAuth.fetchSignInMethodsForEmail(email: email);
      firebase != null && firebase.isEmpty
          ? firebaseResponse = false
          : firebaseResponse = true;
      return firebaseResponse;
    } catch (error) {
      throw error;
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      FirebaseUser user = await firebaseAuth.currentUser();
      user.sendEmailVerification();
    } catch (error) {
      print(error);
      throw json['VERIFY_EMAIL_ERROR'];
    }
  }

  Future<bool> isEmailVerified() async {
    try {
      FirebaseUser user = await firebaseAuth.currentUser();
      return user.isEmailVerified;
    } catch (error) {
      print(error);
      throw json['VERIFY_EMAIL_ERROR'];
    }
  }
}

class FirebaseHelper {
  static Map<String, dynamic> json;

  static Future<String> storageUploadTask(File selectedImage) async {
    String url;
    try {
      StorageReference firebaseReference = FirebaseStorage.instance
          .ref()
          .child('accident_images/${Path.basename(selectedImage.path)}');
      StorageUploadTask uploadTask = firebaseReference.putFile(selectedImage);
      await uploadTask.onComplete;
      url = await firebaseReference.getDownloadURL();
      return url;
    } catch (error) {
      throw error;
    }
  }

  static Future<Map<String, dynamic>> uploadToDatabase(
    String username,
    String userId,
    Map<String, File> selectedImage,
    String description,
    String timeStamp,
    IncidentLocation userLocation,
    Map<String, ExifData> exifItem,
    String natureOfAccident,
    String injuryLevel,
  ) async {
    Map<String, String> fileUrl = {};
    final databaseReference = Firestore.instance;
    Map<String, dynamic> finalResponse = {};
    // http.Response finalResponse;
    try {
      for (var entries in selectedImage.entries) {
        fileUrl.addAll({entries.key: await storageUploadTask(entries.value)});
      }
      DocumentReference ref = await databaseReference.collection('reports').add(
        {
          'username': username,
          'userId': userId,
          'description_of_report': description,
          'image_data': {
            'victims': {
              'url': fileUrl['victims'],
              'time_taken': exifItem['victims'].imageDateTime.toIso8601String(),
              'coordinates': exifItem['victims'].imageCoordinates == null
                  ? null
                  : {
                      'lat': exifItem['victims'].imageCoordinates.latitude,
                      'lng': exifItem['victims'].imageCoordinates.longitude,
                    },
            },
            'vehicles': {
              'url': fileUrl['vehicles'],
              'time_taken':
                  exifItem['vehicles'].imageDateTime.toIso8601String(),
              'coordinates': exifItem['vehicles'].imageCoordinates == null
                  ? null
                  : {
                      'lat': exifItem['vehicles'].imageCoordinates.latitude,
                      'lng': exifItem['vehicles'].imageCoordinates.longitude,
                    },
            },
          },
          'time_of_report': timeStamp,
          'location_of_user': {
            'coordinates': {
              'lat': userLocation.latitude,
              'lng': userLocation.longitude,
            },
            'address': userLocation.address,
            'locality': userLocation.locatity,
            'state': userLocation.state,
            'country': userLocation.country,
          },
          'nature': natureOfAccident,
          'injury': injuryLevel,
        },
      );
      finalResponse = {
        'firebaseRef': ref,
        'url': fileUrl,
      };
      return finalResponse;
    } catch (error) {
      print(error);
      throw json['UPLOAD_ERROR'];
    }
  }

  static Future<List<Report>> getReports([String string]) async {
    final databaseReference = Firestore.instance;
    final List<Report> loadedReports = [];
    var firestoreResponse;
    try {
      // final getResponse = await http.get(databaseUrl);
      if (string != null) {
        firestoreResponse = await databaseReference
            .collection('reports')
            .where('userId', isEqualTo: string)
            .getDocuments();
      } else {
        firestoreResponse =
            await databaseReference.collection('reports').getDocuments();
        // print(firestoreResponse.documents);
        if (firestoreResponse != null) {
          firestoreResponse.documents.forEach(
            (document) => loadedReports.add(
              Report(
                description: document.data['description_of_report'] as String,
                id: document.documentID,
                victimImageUrl:
                    document.data['image_data']['victims']['url'] as String,
                vehicleImageUrl:
                    document.data['image_data']['vehicles']['url'] as String,
                userLocation: IncidentLocation(
                  latitude: document.data['location_of_user']['coordinates']
                      ['lat'],
                  longitude: document.data['location_of_user']['coordinates']
                      ['lng'],
                  address: document.data['location_of_user']['address'],
                  locatity: document.data['location_of_user']['locality'],
                  state: document.data['location_of_user']['state'],
                  country: document.data['location_of_user']['country'],
                ),
                time: DateTime.parse(
                  document.data['time_of_report'],
                ),
                vehicleImageExif: ExifData(
                  imageCoordinates: document.data['image_data']['vehicles']
                              ['coordinates'] ==
                          null
                      ? null
                      : LatLng(
                          document.data['image_data']['vehicles']['coordinates']
                              ['lat'],
                          document.data['image_data']['vehicles']['coordinates']
                              ['lng'],
                        ),
                  imageDateTime: DateTime.parse(
                    document.data['image_data']['vehicles']['time_taken'],
                  ),
                  imageUrl: document.data['image_data']['vehicles']['url'],
                ),
                victimImageExif: ExifData(
                  imageCoordinates: document.data['image_data']['victims']
                              ['coordinates'] ==
                          null
                      ? null
                      : LatLng(
                          document.data['image_data']['victims']['coordinates']
                              ['lat'],
                          document.data['image_data']['victims']['coordinates']
                              ['lng'],
                        ),
                  imageDateTime: DateTime.parse(
                    document.data['image_data']['victims']['time_taken'],
                  ),
                  imageUrl: document.data['image_data']['victims']['url'],
                ),
              ),
            ),
          );
        }
      }
    } catch (error) {
      print(error);
      throw json['FETCH_REPORT_ERROR'];
    }
    return loadedReports;
  }

  static void sendEmail(
    String location,
    String time,
    List<String> recipientList,
    String subject,
  ) async {
    final databaseReference = Firestore.instance;
    try {
      DocumentReference ref = await databaseReference.collection('mail').add(
        {
          'to':
              recipientList, //Convert to recipient list after you create userdata class
          'message': {
            'subject': subject,
            'html':
                '<p>An accident has been reported via Traffic Works.</p><b>Location</b>: $location<br><b>Time</b>: $time<br><br><p>Sent from Traffic Works.</p>'
          }
        },
      );
      Timer(Duration(milliseconds: 5000), () async {
        var response = (await ref.get()).data;
        if (response['delivery'] == null)
          Timer(Duration(milliseconds: 3000), () => {});
        if (response['delivery']['state'] == null)
          Timer(Duration(milliseconds: 3000), () => {});
        print(response['delivery']['state']);
      });
    } catch (error) {
      print(error);
      throw json['SEND_EMAIL_ERROR'];
    }
  }
}
