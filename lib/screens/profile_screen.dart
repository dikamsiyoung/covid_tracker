import 'package:flutter/material.dart';
import 'package:new_go_app/providers/auth_provider.dart';
import 'package:new_go_app/providers/user_provider.dart';
import 'package:new_go_app/screens/login_screen.dart';
import 'package:new_go_app/widgets/popups/edit_profile_popup.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool _autoValidate = false;

  void _editProfile() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(8),
        ),
      ),
      useRootNavigator: true,
      context: context,
      builder: (_) => EditProfilePopup(),
    );
  }

  Future<void> confirmDeleteAccount() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text('Delete Account?', style: TextStyle(color: Colors.redAccent)),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
                "You are about to delete this account of which there's no turning back...\n"),
            Text('If you wish to continue,'),
            Row(
              children: <Widget>[
                Text('Type '),
                Text(
                  "'DELETE' ",
                  style: TextStyle(
                    color: Theme.of(context).accentColor,
                  ),
                ),
                Text('in the text box below'),
              ],
            ),
            SizedBox(
              height: 8,
            ),
            Form(
              key: _formKey,
              autovalidate: _autoValidate,
              child: TextFormField(
                decoration: InputDecoration(),
                validator: (value) {
                  if (value.toUpperCase() == 'DELETE') {
                    return null;
                  } else {
                    return 'Invalid...';
                  }
                },
              ),
            ),
          ],
        ),
        actions: <Widget>[
          FlatButton(
              highlightColor: Colors.grey.withOpacity(0.1),
              splashColor: Colors.grey[200],
              child: Text(
                'CONTINUE',
                style: TextStyle(
                  color: Colors.redAccent,
                ),
              ),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  Provider.of<UserProvider>(context)
                      .deleteCurrentUser()
                      .then(
                        (_) => Navigator.of(context)
                            .pushReplacementNamed(LoginScreen.routeName),
                      )
                      .catchError(
                    (error) {
                      Navigator.of(context).pop();
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Delete failed'),
                          content: Text(error.toString()),
                          actions: <Widget>[
                            FlatButton(
                              child: Text('CLOSE'),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              }),
          FlatButton(
            highlightColor: Colors.grey.withOpacity(0.1),
            splashColor: Colors.grey[200],
            child: Text(
              'CANCEL',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            onPressed: Navigator.of(context).pop,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          FlatButton.icon(
            label: Text(
              'Edit',
              style: TextStyle(color: Colors.white),
            ),
            icon: Icon(
              Icons.edit,
              color: Colors.white,
            ),
            onPressed: _editProfile,
          )
        ],
        title: Text('Profile'),
      ),
      body: Consumer<UserProvider>(
        builder: (ctx, userData, _) => ListView(
          padding: EdgeInsets.only(top: 32),
          children: <Widget>[
            CircleAvatar(
              child: userData.currentUser == null
                  ? Container(
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Text(
                      userData.currentUser.name[0],
                      style: TextStyle(
                        fontSize: 50.0,
                      ),
                    ),
              radius: 60,
            ),
            SizedBox(
              height: 23,
            ),
            Divider(),
            ListTile(
              leading: Icon(
                Icons.person,
                size: 32,
              ),
              title: Text('Username'),
              subtitle: Text(
                userData.currentUser == null ? '-' : userData.currentUser.name,
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.alternate_email,
                size: 32,
              ),
              title: Text('Email'),
              subtitle: Text(
                userData.currentUser == null ? '-' : userData.currentUser.email,
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.phone_android,
                size: 32,
              ),
              title: Text('Phone Number'),
              subtitle: Text(
                userData.currentUser == null
                    ? '-'
                    : userData.currentUser.phoneNumber,
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(null),
              title: Text(
                'Sign out',
                style: TextStyle(color: Colors.black.withOpacity(0.7)),
              ),
              onTap: () {
                Provider.of<AuthProvider>(context, listen: false).logOut().then(
                      (_) => Navigator.of(context)
                          .pushReplacementNamed(LoginScreen.routeName),
                    );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(null),
              title: Text(
                'Delete account',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: confirmDeleteAccount,
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
