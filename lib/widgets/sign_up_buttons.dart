import 'package:flutter/material.dart';
// import 'package:new_go_app/providers/auth_provider.dart';
// import 'package:provider/provider.dart';

import '../screens/home_screen.dart';

class SignUpButtons extends StatelessWidget {
  final Function function;

  SignUpButtons(this.function);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 50),
        Card(
          elevation: 8,
          child: RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            color: Colors.blueGrey,
            onPressed: () {
              Navigator.of(context)
                  .pushReplacementNamed(HomeScreen.routeName);
              // Provider.of<AuthProvider>(context).signInWithGoogle();
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 14, 0, 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image(
                    image: AssetImage("assets/google_icon.png"),
                    height: 28,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      'Sign in with Google',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontFamily: 'Lato',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 8,
        ),
        Card(
          elevation: 8,
          child: OutlineButton(
            highlightedBorderColor: Colors.blueGrey,
            textTheme: ButtonTextTheme.accent,
            splashColor: Colors.blueGrey.withOpacity(0.2),
            highlightColor: Colors.blueGrey.withOpacity(0.15),
            textColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onPressed: function,
            borderSide: BorderSide(
              color: Colors.blueGrey.withOpacity(0.5),
              width: 1.5
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 14, 0, 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.alternate_email,
                    size: 28,
                    color: Colors.blueGrey,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      'Sign in with Email',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.blueGrey,
                        fontFamily: 'Lato',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
