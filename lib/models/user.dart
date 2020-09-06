import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class User {
  final String name;
  final String phoneNumber;
  final String id;
  final String gender;
  final String ageGroup;
  final String email;
  final String signUpTime;
  final bool isVerified;
  final FirebaseUser firebaseDetails;

  User({
    @required this.id,
    @required this.name,
    @required this.phoneNumber,
    @required this.email,
    this.firebaseDetails,
    this.isVerified = false,
    this.gender,
    this.ageGroup,
    this.signUpTime,
  });
}
