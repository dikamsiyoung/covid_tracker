import 'package:flutter/material.dart';

enum Cases { Total, Recovered, Recovered_Background, Deaths, Deaths_Background }

class Styles {
  static final colors = {
    Cases.Recovered_Background: Colors.blueGrey.withOpacity(0.1),
    Cases.Deaths_Background: Colors.redAccent.withOpacity(0.1),
    Cases.Recovered: Colors.blueGrey.withOpacity(0.9),
    Cases.Deaths: Colors.redAccent.withOpacity(0.9),
  };
}
