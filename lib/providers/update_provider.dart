import 'dart:convert';

import 'package:country_pickers/country.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:html_character_entities/html_character_entities.dart';
import 'package:http/http.dart' as http;
import 'package:new_go_app/test/test_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/datetime_helper.dart';
import '../models/update.dart';

class UpdateProvider with ChangeNotifier {
  Country country;

  GlobalStat _globalStat;
  List<CountryStat> _countryList = [];
  Map<String, NewsItem> _countryNews = {};

  //Tests
  bool isOffline = true;

  UpdateProvider() {
    loadPreviousUpdates();
  }

  void setCountryUpdates(Country country) async {
    this.country = country;
  }

  GlobalStat get globalStat {
    return _globalStat;
  }

  List<CountryStat> get countryStatList {
    return [..._countryList];
  }

  List<NewsItem> get countryNews {
    return [..._countryNews.values].reversed.toList();
  }

  Future<void> fetchAndSetUpdates() async {
    try {
      await updateGlobalStat();
      await updateCountryStat();
      await updateNewsFeed();
      notifyListeners();
    } catch (error) {
      print(error);
      isOffline = true;
      throw error;
    }
  }

  //API Requirements
  final String urlBase = 'https://thevirustracker.com/free-api?';

  void loadPreviousUpdates() async {
    final prefs = await SharedPreferences.getInstance();
    var userCountry;
    if (prefs.getString('countryCode') != null)
    userCountry =
        CountryPickerUtils.getCountryByIsoCode(prefs.getString('countryCode'));
    if (prefs.containsKey('globalStat') &&
        prefs.containsKey('countryStat') &&
        prefs.getStringList('globalStat').length == 6 &&
        prefs.getStringList('countryStat').length == 6) {
      _globalStat = GlobalStat(
        newRecoveredCases: int.parse(prefs.getStringList('globalStat')[5]),
        deathCases: int.parse(prefs.getStringList('globalStat')[2]),
        newCases: int.parse(prefs.getStringList('globalStat')[4]),
        newDeaths: int.parse(prefs.getStringList('globalStat')[3]),
        totalCases: int.parse(prefs.getStringList('globalStat')[0]),
        recoveredCases: int.parse(prefs.getStringList('globalStat')[1]),
      );
      _countryList.add(
        CountryStat(
          countryName: userCountry.name,
          totalCases: int.parse(prefs.getStringList('countryStat')[0]),
          recoveredCases: int.parse(prefs.getStringList('countryStat')[1]),
          deathCases: int.parse(prefs.getStringList('countryStat')[2]),
          newDeaths: int.parse(prefs.getStringList('countryStat')[3]),
          newCases: int.parse(prefs.getStringList('countryStat')[4]),
          newRecoveredCases: int.parse(prefs.getStringList('countryStat')[5]),
        ),
      );
    }
  }

  Future<void> updateGlobalStat() async {
    Map<String, dynamic> extractedData;
    Function backupDataSource = () {};
    if (isOffline) {
      final pref = await SharedPreferences.getInstance();
      // _globalStat = GlobalStat(
      //   deathCases: 45383,
      //   newCases: 2834,
      //   newDeaths: 2003,
      //   totalCases: 938494,
      //   recoveredCases: 191232,
      //   newRecoveredCases: 938494 - 2834 - 860000,
      // );
      if (pref.containsKey('globalStat'))
        _globalStat = GlobalStat(
            deathCases: int.parse(pref.getStringList('globalStat')[2]),
            newCases: int.parse(pref.getStringList('globalStat')[4]),
            newDeaths: int.parse(pref.getStringList('globalStat')[3]),
            totalCases: int.parse(pref.getStringList('globalStat')[0]),
            recoveredCases: int.parse(pref.getStringList('globalStat')[1]),
            newRecoveredCases: int.parse(pref.getStringList('globalStat')[5]));
      pref.setStringList(
        'globalStat',
        [
          '${_globalStat.totalCases}',
          '${_globalStat.recoveredCases}',
          '${_globalStat.deathCases}',
          '${_globalStat.newDeaths}',
          '${_globalStat.newCases}',
          '${_globalStat.newRecoveredCases}',
        ],
      );
      notifyListeners();
      return;
    }
    final urlEndPoint = 'global=stats';
    try {
      final response = await http.get('$urlBase$urlEndPoint');
      if (json.decode(response.body).toString() == 'developing') {
        return;
      } else {
        extractedData = json.decode(response.body);
      }
      if (extractedData == null) throw 'Response is null';
      if (extractedData != null && extractedData['stat'] == 'ok') {
        _globalStat = GlobalStat(
          totalCases: extractedData['results'][0]['total_cases'],
          deathCases: extractedData['results'][0]['total_deaths'],
          newCases: extractedData['results'][0]['total_new_cases_today'],
          newDeaths: extractedData['results'][0]['total_new_deaths_today'],
          recoveredCases: extractedData['results'][0]['total_recovered'],
          newRecoveredCases: extractedData['results'][0]['total_cases'] -
              extractedData['results'][0]['total_deaths'] -
              extractedData['results'][0]['total_active_cases'],
        );
      }
      final pref = await SharedPreferences.getInstance();
      pref.setStringList(
        'globalStat',
        [
          '${_globalStat.totalCases}',
          '${_globalStat.recoveredCases}',
          '${_globalStat.deathCases}',
          '${_globalStat.newDeaths}',
          '${_globalStat.newCases}',
          '${_globalStat.newRecoveredCases}',
        ],
      );
      notifyListeners();
    } catch (error) {
      print(error);
      throw "Couldn't update stats";
    }
  }

  Future<void> updateCountryStat() async {
    if (isOffline) {
      // _countryList.add(
      //   CountryStat(
      //     countryName: 'Nigeria',
      //     deathCases: 2,
      //     newCases: 5,
      //     newDeaths: 122,
      //     totalCases: 141855,
      //     recoveredCases: 45,
      //     newRecoveredCases: 141855 - 5 - 120000,
      //   ),
      // );
      final pref = await SharedPreferences.getInstance();
      if (pref.containsKey('countryStat'))
        _countryList.add(
          CountryStat(
              countryName: 'Nigeria',
              deathCases: int.parse(pref.getStringList('countryStat')[2]),
              newCases: int.parse(pref.getStringList('countryStat')[4]),
              newDeaths: int.parse(pref.getStringList('countryStat')[3]),
              totalCases: int.parse(pref.getStringList('countryStat')[0]),
              recoveredCases: int.parse(pref.getStringList('countryStat')[1]),
              newRecoveredCases:
                  int.parse(pref.getStringList('countryStat')[5])),
        );
      pref.setStringList(
        'countryStat',
        [
          '${_countryList[0].totalCases}',
          '${_countryList[0].recoveredCases}',
          '${_countryList[0].deathCases}',
          '${_countryList[0].newDeaths}',
          '${_countryList[0].newCases}',
          '${_countryList[0].newRecoveredCases}'
        ],
      );
      notifyListeners();
      return;
    }
    final urlEndPoint = 'countryTotal=${country.isoCode}';
    try {
      final response = await http.get('$urlBase$urlEndPoint');
      final Map<String, dynamic> extractedData = json.decode(response.body);
      if (extractedData == null) throw 'Response is null';
      if (extractedData != null && extractedData['stat'] == 'ok') {
        _countryList.add(
          CountryStat(
            countryName: extractedData['countrydata'][0]['info']['title'],
            totalCases: extractedData['countrydata'][0]['total_cases'],
            deathCases: extractedData['countrydata'][0]['total_deaths'],
            newCases: extractedData['countrydata'][0]['total_new_cases_today'],
            newDeaths: extractedData['countrydata'][0]
                ['total_new_deaths_today'],
            recoveredCases: extractedData['countrydata'][0]['total_recovered'],
            newRecoveredCases: extractedData['countrydata'][0]['total_cases'] -
                extractedData['countrydata'][0]['total_new_deaths_today'] -
                extractedData['countrydata'][0]['total_active_cases'],
          ),
        );
      }
      final pref = await SharedPreferences.getInstance();
      pref.setStringList(
        'countryStat',
        [
          '${_countryList[0].totalCases}',
          '${_countryList[0].recoveredCases}',
          '${_countryList[0].deathCases}',
          '${_countryList[0].newDeaths}',
          '${_countryList[0].newCases}',
          "${_countryList[0].newRecoveredCases}",
        ],
      );
      notifyListeners();
    } catch (error) {
      print(error);
      throw "Couldn't update stats...";
    }
  }

  Future<void> updateNewsFeed(
      {String countryCode = 'NG', int numberOfDays = 5}) async {
    final urlEndPoint = 'countryNewsTotal=$countryCode';
    var response;
    Map<String, dynamic> extractedData;
    Map<String, dynamic> countryNewsItems;
    try {
      if (isOffline) {
        extractedData = news;
        countryNewsItems = extractedData['countrynewsitems'][0];
      } else {
        response = await http.get('$urlBase$urlEndPoint');
        extractedData = json.decode(response.body);
        countryNewsItems = extractedData['countrynewsitems'][0];
      }
      countryNewsItems.forEach(
        (string, item) {
          if (string != 'stat') {
            final itemDate = DateTimeHelper.newsFeedDateTimeConverter(
                item['time'].toString());
            final parsedTopic = HtmlCharacterEntities.decode(item['title']);
            if (itemDate.isAfter(
                    DateTime.now().subtract(Duration(days: numberOfDays))) &&
                !_countryNews.values.any((items) => items.title == parsedTopic))
              _countryNews.putIfAbsent(
                item['newsid'],
                () => NewsItem(
                  id: item['newsid'],
                  title: parsedTopic,
                  imageUrl: item['image'],
                  time: itemDate,
                  url: item['url'],
                ),
              );
          }
        },
      );
    } catch (error) {
      print(error);
      throw "Couldn't update feed...";
    }
  }
}
