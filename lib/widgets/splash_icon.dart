import 'package:flutter/material.dart';

class SplashIcon extends StatelessWidget {
  final signInWithEmail;

  SplashIcon(this.signInWithEmail);

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Image(
        image: AssetImage('assets/splash_screen.png'),
        height: signInWithEmail ? 65 : 85,
      ),
      Text(
        'Traffic Works',
        style: TextStyle(
            fontFamily: 'Lato',
            fontSize: signInWithEmail? 21 : 22,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(255, 122, 38, 1),
            shadows: [
              Shadow(
                color: Colors.black26,
                // offset: Offset.fromDirection(0.5, 0.5),
                blurRadius: 1.2,
              ),
            ]),
      )
    ]);
  }
}
