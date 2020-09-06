import 'package:flutter/material.dart';
import 'package:new_go_app/screens/web_view_screen.dart';
import 'package:provider/provider.dart';

import './services/push_notifcation_service.dart';
import './providers/auth_provider.dart';
import './providers/report_provider.dart';
import './providers/user_provider.dart';
import './providers/update_provider.dart';
import './screens/profile_screen.dart';
import './screens/login_screen.dart';
import './screens/settings_screen.dart';
import './screens/map_view_screen.dart';
import './screens/home_screen.dart';
// import './screens/ml_kit.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _pushNotification = PushNotificationServices();

  @override
  void initState() {
    super.initState();
    _pushNotification.initialise();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: AuthProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
          create: (ctx) => UserProvider(),
          update: (ctx, authData, previousUserData) =>
              previousUserData..setCurrentUser(authData.firebaseUser),
        ),
        ChangeNotifierProxyProvider<UserProvider, UpdateProvider>(
          create: (ctx) => UpdateProvider(),
          update: (ctx, userData, previousUpdateProvider) =>
              previousUpdateProvider..setCountryUpdates(userData.country),
        ),
        ChangeNotifierProxyProvider<UserProvider, ReportProvider>(
          create: (ctx) => ReportProvider(),
          update: (ctx, userData, previousReportedIncidents) =>
              previousReportedIncidents
                ..update(
                  previousReportedIncidents == null
                      ? []
                      : previousReportedIncidents.items,
                  userData.currentUser,
                ),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (ctx, authData, _) => MaterialApp(
          title: 'Go App',
          theme: ThemeData(
            accentColor: Colors.amber,
            primarySwatch: Colors.blueGrey,
            appBarTheme: AppBarTheme(
              elevation: 3,
            ),
            textTheme: TextTheme(
              bodyText1: TextStyle(
                fontFamily: 'Lato',
              ),
              button: TextStyle(
                fontFamily: 'Lato',
              ),
              headline6: TextStyle(
                fontFamily: 'Lato',
              ),
            ),
          ),
          home: authData.isAuth
              ? HomeScreen()
              : FutureBuilder(
                  future: authData.tryAutoLogIn(),
                  builder: (ctx, authResultSnapshot) {
                    if (authResultSnapshot == null) {
                      authData.isDoneLoading = true;
                      return LoginScreen();
                    } else if (authResultSnapshot.data != null &&
                        !authResultSnapshot.data) {
                      authData.isDoneLoading = true;
                      return LoginScreen();
                    }
                    return HomeScreen();
                  },
                ),
          routes: {
            WebViewScreen.routeName: (ctx) => WebViewScreen(),
            LoginScreen.routeName: (ctx) => LoginScreen(),
            ProfileScreen.routeName: (ctx) => ProfileScreen(),
            HomeScreen.routeName: (ctx) => HomeScreen(),
            MapViewScreen.routeName: (ctx) => MapViewScreen(),
            SettingsScreen.routeName: (ctx) => SettingsScreen(),
            // MlKit.routeName: (ctx) => MlKit(),
          },
        ),
      ),
    );
  }
}
