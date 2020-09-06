import 'package:flutter/material.dart';

class SelfCheckTab extends StatefulWidget {
  @override
  _SelfCheckTabState createState() => _SelfCheckTabState();
}

class _SelfCheckTabState extends State<SelfCheckTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Color.fromRGBO(245, 245, 245, 1),
      body: Center(
        child: Text('Self check details'),
      ),
    );
  }
}
