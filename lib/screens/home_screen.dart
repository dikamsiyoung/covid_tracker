import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/update_provider.dart';
import '../providers/report_provider.dart';
import '../screens/map_view_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../tabs/stats_tab.dart';
import '../tabs/self_check_tab.dart';
import '../tabs/news_feed_tab.dart';
import '../widgets/error_dialog.dart';
import '../widgets/popups/report_incident_popup.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home-screen';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  //UI Updaters
  var _isLoading = false;

  void _startNewReport() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(8),
        ),
      ),
      useRootNavigator: true,
      context: context,
      builder: (_) => ReportIncidentPopup(_showErrorDialog),
    );
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return NormalErrorDialog(
          title: title,
          message: message,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportProgress = Provider.of<ReportProvider>(context);
    final phoneProperties = MediaQuery.of(context).size;
    return Builder(
      builder: (context) => DefaultTabController(
        length: 2,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Color.fromRGBO(245, 245, 245, 1),
          appBar: AppBar(
            bottom: TabBar(
              indicatorColor: Colors.white,
              indicatorWeight: 3.5,
              labelStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.normal,
                fontFamily: 'Roboto',
              ),
              tabs: <Widget>[
                Tab(
                  child: Text('News Feed'),
                ),
                Tab(
                  child: Text('Stats'),
                ),
              ],
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
                onPressed: () =>
                    Navigator.of(context).pushNamed(ProfileScreen.routeName),
              ),
            ],
            title: Row(
              children: <Widget>[
                Text(
                  'Health',
                  style: TextStyle(
                      fontFamily: 'Lato', fontWeight: FontWeight.w600),
                ),
                Text(
                  'Works.',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Lato',
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
            elevation: 0,
          ),
          floatingActionButtonLocation: phoneProperties.width > 400
              ? FloatingActionButtonLocation.endFloat
              : FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Stack(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 60),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: FloatingActionButton.extended(
                    heroTag: 'maps',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (context) => MapViewScreen(
                          isSelecting: false,
                        ),
                      ),
                    ),
                    label: Text('View maps'),
                    icon: Icon(Icons.map),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton.extended(
                  heroTag: 'report',
                  isExtended: true,
                  icon: reportProgress.isLoading
                      ? Container(
                          margin: EdgeInsets.only(
                            right: 4,
                            left: 4,
                          ),
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.black),
                          ),
                        )
                      : Icon(
                          reportProgress.isDoneSending
                              ? Icons.check
                              : Icons.report,
                        ),
                  label: Text(
                    reportProgress.isLoading
                        ? 'Sending report...'
                        : reportProgress.isDoneSending
                            ? 'Report Sent'
                            : 'Report Incident',
                  ),
                  onPressed: () =>
                      reportProgress.isLoading ? null : _startNewReport(),
                ),
              ),
            ],
          ),
          body: TabBarView(
            children: <Widget>[
              Center(
                child: Text('Newsfeed'),
              ),
              Center(
                child: Text('Stats'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
