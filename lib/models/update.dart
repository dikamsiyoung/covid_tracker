import 'package:flutter/foundation.dart';

class CountryStat {
  final String countryName;
  final int totalCases;
  final int newCases;
  final int recoveredCases;
  final int deathCases;
  final int newDeaths;
  final int newRecoveredCases;

  CountryStat({
    @required this.countryName,
    @required this.newCases,
    @required this.deathCases,
    @required this.newDeaths,
    @required this.recoveredCases,
    @required this.totalCases,
    @required this.newRecoveredCases,
  });
}

class GlobalStat {
  final int totalCases;
  final int newCases;
  final int recoveredCases;
  final int deathCases;
  final int newDeaths;
  final int newRecoveredCases;

  GlobalStat({
    @required this.newCases,
    @required this.totalCases,
    @required this.recoveredCases,
    @required this.deathCases,
    @required this.newDeaths,
    @required this.newRecoveredCases,
  });
}

class NewsItem {
  final String id;
  final String title;
  final String url;
  final String imageUrl;
  final DateTime time;

  NewsItem({
    @required this.id,
    @required this.imageUrl,
    @required this.time,
    @required this.title,
    @required this.url,
  });
}
