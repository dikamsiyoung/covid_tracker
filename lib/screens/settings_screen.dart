import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/material.dart';
import 'package:new_go_app/providers/update_provider.dart';
import 'package:new_go_app/providers/user_provider.dart';
import 'package:new_go_app/widgets/error_dialog.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
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

    void updateUserCountry(Country country) async {
      try {
        await Provider.of<UserProvider>(context).updateUserCountry(country);
        await Provider.of<UpdateProvider>(context).fetchAndSetUpdates();
      } catch (error) {
        _showErrorDialog(
          context,
          'Update country failed',
          error.toString(),
        );
      }
    }

    Widget buildDialogItem(Country country) {
      return Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.symmetric(vertical: 6),
            child: CountryPickerUtils.getDefaultFlagImage(country),
          ),
          SizedBox(width: 12.0),
          SizedBox(width: 8.0),
          Flexible(
            child: Text(
              country.name,
              maxLines: 1,
            ),
          ),
        ],
      );
    }

    void showCountryList(BuildContext context) {
      showDialog(
        context: context,
        builder: (context) => Theme(
          data: Theme.of(context).copyWith(primaryColor: Colors.pink),
          child: CountryPickerDialog(
            isDividerEnabled: true,
            popOnPick: true,
            contentPadding:
                EdgeInsets.only(top: 24, bottom: 32, left: 4, right: 4),
            titlePadding: EdgeInsets.only(top: 4.0, bottom: 10),
            searchCursorColor: Colors.pinkAccent,
            searchInputDecoration: InputDecoration(
              hintText: 'Search...',
            ),
            isSearchable: true,
            title: Text(
              'Select your country',
              style: TextStyle(color: Colors.deepOrangeAccent),
            ),
            onValuePicked: updateUserCountry,
            priorityList: [
              CountryPickerUtils.getCountryByIsoCode('NG'),
              CountryPickerUtils.getCountryByIsoCode('US'),
            ],
            itemBuilder: (country) => buildDialogItem(country),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userObject, _) => ListView(
          padding: EdgeInsets.symmetric(vertical: 8),
          children: <Widget>[
            Divider(),
            ListTile(
              leading: Icon(null),
              title: Text('Change Country'),
              trailing: Text(
                userObject.country.isoCode,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => showCountryList(context),
            ),
            Divider(),
            ListTile(
              leading: Icon(null),
              title: Text(
                'Clear Data',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () {},
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
