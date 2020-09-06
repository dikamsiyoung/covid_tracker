import 'package:flutter/material.dart';
import 'package:new_go_app/screens/login_screen.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../screens/profile_screen.dart';
import '../screens/home_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/map_view_screen.dart';
// import '../screens/ml_kit.dart';

enum DrawerOptions { Report, Maps, Settings, EditProfile, ViewReports }

class CurrentScreen {
  static DrawerOptions _currentState = DrawerOptions.Report;
  static bool _isExpanded = false;

  static void setCurrentScreen(DrawerOptions selectedOption) {
    _currentState = selectedOption;
  }

  static void setDropDownState() {
    _isExpanded = !_isExpanded;
  }

  static bool checkDropDownState() {
    return _isExpanded;
  }

  static bool checkScreen(DrawerOptions selectedOption) {
    if (selectedOption == _currentState) {
      return true;
    } else {
      return false;
    }
  }
}

class AppDrawer extends StatefulWidget {
  AppDrawer();

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  Widget _buildListTile(
    String title,
    IconData icon,
    DrawerOptions selectedOption,
    Function handler,
    BuildContext context,
  ) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        ListTile(
          leading: Icon(
            icon,
            color: Theme.of(context).primaryColor.withOpacity(0.95),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontFamily: 'RobotoCondensed',
              fontSize: 16,
              fontWeight: CurrentScreen.checkScreen(selectedOption)
                  ? selectedOption != null ? FontWeight.bold : FontWeight.w400
                  : FontWeight.w400,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
          trailing: Icon(Icons.arrow_right),
          onTap: () {
            CurrentScreen.setCurrentScreen(selectedOption);
            return handler();
          },
        ),
        if (CurrentScreen.checkScreen(selectedOption) && selectedOption != null)
          Container(
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Theme.of(context).primaryColor.withOpacity(0.15),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileDropDown(
    String title,
    IconData icon,
    DrawerOptions selectedOption,
    Function handler,
    BuildContext context,
  ) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        ListTile(
          leading: Icon(
            icon,
            color: Theme.of(context).primaryColor.withOpacity(0.95),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontFamily: 'RobotoCondensed',
              fontSize: 16,
              fontWeight: CurrentScreen.checkScreen(selectedOption)
                  ? FontWeight.bold
                  : FontWeight.w400,
              color: Theme.of(context).primaryColorDark,
            ),
          ),
          onTap: () {
            CurrentScreen.setCurrentScreen(selectedOption);
            return handler();
          },
        ),
        if (CurrentScreen.checkScreen(selectedOption) && selectedOption != null)
          Container(
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Theme.of(context).primaryColor.withOpacity(0.15),
            ),
          ),
      ],
    );
  }

  Widget _buildDrawerOption(
    String title,
    IconData icon,
    DrawerOptions selectedOption,
    Function handler,
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      child: _buildListTile(
        title,
        icon,
        selectedOption,
        handler,
        context,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 3,
      child: ListView(
        children: <Widget>[
          Consumer<UserProvider>(
            builder: (ctx, userData, _) => UserAccountsDrawerHeader(
              onDetailsPressed: () {
                setState(() {
                  CurrentScreen.setDropDownState();
                });
              },
              accountName: userData.currentUser == null
                  ? SizedBox()
                  : Text(
                      userData.currentUser.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
              accountEmail: userData.currentUser == null
                  ? SizedBox()
                  : Text(userData.currentUser.email),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Theme.of(context).accentColor,
                child: userData.currentUser == null
                    ? Container(
                        height: 25,
                        width: 25,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        userData.currentUser.name != null
                            ? userData.currentUser.name[0]
                            : '-',
                        style: TextStyle(
                          fontSize: 40.0,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
          CurrentScreen.checkDropDownState()
              ? Column(
                  children: <Widget>[
                    _buildProfileDropDown(
                      'My Profile',
                      Icons.person,
                      DrawerOptions.EditProfile,
                      () => Navigator.of(context)
                          .pushReplacementNamed(ProfileScreen.routeName),
                      context,
                    ),
                    _buildProfileDropDown(
                      'My Reports',
                      Icons.report,
                      DrawerOptions.ViewReports,
                      () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (ctx) => MapViewScreen(
                            isSelecting: false,
                            onlyUserReport: true,
                          ),
                        ),
                      ),
                      context,
                    ),
                  ],
                )
              : SizedBox(),
          CurrentScreen.checkDropDownState() ? Divider() : SizedBox(),
          _buildDrawerOption(
            'Home',
            Icons.home,
            DrawerOptions.Report,
            () => Navigator.of(context)
                .pushReplacementNamed(HomeScreen.routeName),
            context,
          ),

          _buildDrawerOption(
            'Maps',
            Icons.map,
            DrawerOptions.Maps,
            () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (ctx) => MapViewScreen(isSelecting: false),
              ),
            ),
            context,
          ),
          // _buildDrawerOption(
          //   'ML Training',
          //   Icons.zoom_in,
          //   DrawerOptions.Ml,
          //   () => Navigator.of(context).pushReplacementNamed(MlKit.routeName),
          //   context,
          // ),
          _buildDrawerOption(
            'Settings',
            Icons.settings,
            DrawerOptions.Settings,
            () => Navigator.of(context)
                .pushReplacementNamed(SettingsScreen.routeName),
            context,
          ),
          _buildDrawerOption(
            'Sign out',
            Icons.exit_to_app,
            null,
            () {
              Provider.of<AuthProvider>(context, listen: false).logOut().then(
                  (_) => Navigator.of(context)
                      .pushReplacementNamed(LoginScreen.routeName));
            },
            context,
          ),
        ],
      ),
    );
  }
}
