class English {
  static const Map<String, dynamic> errors = {
    "firebase_helper_errors": {
      //FirebaseHelper Errors
      "ERROR_USER_NOT_FOUND":
          "This email is not registered.\nDo you want to sign up?",
      "ERROR_WRONG_PASSWORD": "Password is incorrect...",
      "ERROR_NETWORK_REQUEST_FAILED": "Couldn't contact servers...",
      "DEFAULT_LOGIN_ERROR": "Couldn't sign in user...",
      "DEFAULT_SIGNUP_ERROR": "Couldn't sign up user...",
      "ANONYMOUS_LOGIN_ERROR": "Couldn't sign in anonymously...",
      "REGISTRATION_ERROR": "Couldn't register user...",
      "GET_USER_ERROR": "Couldn't obtain current user...",
      "SIGN_OUT_ERROR": "Couldn't sign out current user...",
      "VERIFY_EMAIL_ERROR": "Couldn't verify email...",
      "UPLOAD_ERROR": "Error occurred while uploading to database...",
      "FETCH_REPORT_ERROR": "Error occurred while fetching reports...",
      "SEND_EMAIL_ERROR": "Error occurred while sending email...",
      "SMS_AUTORETRIEVAL_ERROR": "Auto retrieval time out...",
      "SMS_PERMISSION_DENIED":
          "Some permission issues at the back, please try later...",
      "SMS_NETWORK_ERROR":
          "Please check your internet connection and try again...",
      "SMS_DEFAULT_ERROR": "Something has gone wrong, please try later"
    },
    "image_helper_errors": {
      //ImageHelper Errors
      "READ_EXIF_ERROR": "Couldn't obtain image exif data..."
    },
    "db_helper_errors": {
      //DBHelper Errors
      "DB_ACCESS_ERROR": "Couldn't obtain image exif data...",
      "DB_READ_ERROR": "Error reading from internal storage...",
      "DB_WRITE_ERROR": "Error writing to internal storage..."
    },
    "location_helper_errors": {
      //LocationHelper Errors
      "PERMISSION_DENIED": "Address API permission denied...",
      "CONNECTION_FAILED": "Address API connection failed...",
      "LOCATION_FETCH_ERROR": "Error fetching location data..."
    },
    "datetime_helper_errors": {
      //DateTimeHelper Errors
      "DATETIME_CONVERSION_ERROR": "Couldn't convert string to date-time..."
    },
    "auth_errors": {
      //AuthProvider Errors
      "SHARED_PREFERENCE_ERROR": "Couldn't read settings from internal storage...",
      "PASSWORD_UPDATE_FAILED": "Couldn't update password...",
      "GOOGLE_ERROR": {
        "SIGN_IN_ERROR": "Couldn't sign in with Google...",
        "SIGN_OUT_ERROR": "Couldn't sign out Google user..."
      }
    },
    "user_provider_errors": {
      "USER_DELETE_ERROR": "Couldn't delete user from database...",
      "EMAIL_UPDATE_FAILED": "Couldn't update email...",
    }
  };
}
