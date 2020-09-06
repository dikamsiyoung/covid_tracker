import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:new_go_app/providers/update_provider.dart';
import 'package:new_go_app/providers/user_provider.dart';
import 'package:new_go_app/screens/web_view_screen.dart';
import 'package:provider/provider.dart';

class NewsFeedTab extends StatefulWidget {
  @override
  _NewsFeedTabState createState() => _NewsFeedTabState();
}

class _NewsFeedTabState extends State<NewsFeedTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Color.fromRGBO(245, 245, 245, 1),
      body: Consumer2<UserProvider, UpdateProvider>(
        builder: (context, userProvider, updateProvider, _) => ListView.builder(
          itemCount: updateProvider.countryNews.length,
          itemBuilder: (context, index) {
            final newsList = updateProvider.countryNews;
            return Container(
              margin: EdgeInsets.only(
                left: 12,
                right: 12,
                bottom: 8,
                top: index == 0 ? 12 : 0,
              ),
              child: Card(
                elevation: 3,
                child: InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (context) => WebViewScreen(newsList[index].url),
                    ),
                  ),
                  child: Stack(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              margin: EdgeInsets.only(
                                top: 16,
                                right: 16,
                                left: 168,
                                bottom: 16,
                              ),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${userProvider.country.name} News',
                                style: TextStyle(
                                  color: Colors.black54.withOpacity(0.4),
                                  fontFamily: 'Lato',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Container(
                              margin: EdgeInsets.only(
                                left: 168,
                                right: 24,
                                top: 80,
                              ),
                              child: Text(
                                newsList[index].title,
                                maxLines: 3,
                                overflow: TextOverflow.fade,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Lato'),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Container(
                              margin: EdgeInsets.only(
                                bottom: 16,
                                left: 168,
                                right: 16,
                                top: 12,
                              ),
                              child: Text(
                                DateFormat.d()
                                    .add_MMM()
                                    .add_jm()
                                    .format(newsList[index].time),
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          height: 150,
                          margin: EdgeInsets.only(
                            right: 230,
                            top: 16,
                            bottom: 16,
                            left: 16,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.asset(
                              'assets/test_image.jpg',   ///////////////////////////////////////////////////////////
                              fit: BoxFit.cover,
                              height: double.infinity,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
