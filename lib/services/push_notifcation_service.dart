import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationServices {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  Future<String> getNotificationToken() async {
    try {
      _firebaseMessaging.requestNotificationPermissions();
      return await _firebaseMessaging.getToken();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future initialise() async {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
  }

  register() {
    _firebaseMessaging.getToken().then((token) => print(token));
  }
}
