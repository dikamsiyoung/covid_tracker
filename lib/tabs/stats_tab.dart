import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_go_app/providers/user_provider.dart';
import 'package:new_go_app/styles/colors.dart';
import 'package:provider/provider.dart';

import '../providers/update_provider.dart';

class StatsTab extends StatefulWidget {
  @override
  _StatsTabState createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Color.fromRGBO(245, 245, 245, 1),
      body: Consumer2<UserProvider, UpdateProvider>(
        builder: (context, userProvider, updateProvider, _) {
          final globalStat = updateProvider.globalStat;
          final countryStatList = updateProvider.countryStatList;
          return ListView(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(12),
                child: Card(
                  elevation: 3,
                  child: Stack(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          margin: EdgeInsets.all(16),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'World Stats',
                            style: TextStyle(
                              color: Colors.black54.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Spacer(
                              flex: 2,
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      Styles.colors[Cases.Recovered_Background],
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(4),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      '+ ${globalStat.newRecoveredCases}',
                                      style: TextStyle(
                                        color: Styles.colors[Cases.Recovered],
                                        fontFamily: "Lato",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withOpacity(0.1),
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(4),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      '+ ${globalStat.newDeaths}',
                                      style: TextStyle(
                                        color:
                                            Colors.redAccent.withOpacity(0.9),
                                        fontFamily: "Lato",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          padding:
                              EdgeInsets.only(top: 80, left: 20, bottom: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      NumberFormat.decimalPattern()
                                          .format(globalStat.totalCases),
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontFamily: 'Lato',
                                      ),
                                    ),
                                    Text(
                                      'Total',
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      NumberFormat.decimalPattern()
                                          .format(globalStat.recoveredCases),
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontFamily: 'Lato',
                                        fontWeight: FontWeight.bold,
                                        color: Styles.colors[Cases.Recovered],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                      'Recovered',
                                      style: TextStyle(
                                        color: Styles.colors[Cases.Recovered],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      NumberFormat.decimalPattern()
                                          .format(globalStat.deathCases),
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontFamily: 'Lato',
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                    Text(
                                      'Deaths',
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  bottom: 12,
                  left: 12,
                  right: 12,
                ),
                child: Card(
                  elevation: 3,
                  child: Stack(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          margin: EdgeInsets.all(16),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            userProvider.country.name,
                            style: TextStyle(
                              color: Colors.black54.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Spacer(
                              flex: 2,
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      Styles.colors[Cases.Recovered_Background],
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(4),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      '+ ${countryStatList[0].newRecoveredCases}',
                                      style: TextStyle(
                                        color: Styles.colors[Cases.Recovered],
                                        fontFamily: "Lato",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Styles.colors[Cases.Deaths_Background],
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(4),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      '+ ${countryStatList[0].newDeaths}',
                                      style: TextStyle(
                                        color: Styles.colors[Cases.Deaths],
                                        fontFamily: "Lato",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          padding:
                              EdgeInsets.only(top: 80, left: 20, bottom: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      '${NumberFormat.decimalPattern().format(countryStatList[0].totalCases)}',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontFamily: 'Lato',
                                      ),
                                    ),
                                    Text(
                                      'Total',
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      '${NumberFormat.decimalPattern().format(countryStatList[0].recoveredCases)}',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontFamily: 'Lato',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                      'Recovered',
                                      style: TextStyle(
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      NumberFormat.decimalPattern().format(
                                          countryStatList[0].deathCases),
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontFamily: 'Lato',
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                    Text(
                                      'Deaths',
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
