import '../lang/en.dart';

class DateTimeHelper {
  static var errors = English.errors['datetime_helper_errors'];

  static DateTime exifDateTimeConverter(String dateTime) {
    try {
      dateTime = dateTime.replaceFirst(new RegExp(r':'), '-');
      dateTime = dateTime.replaceFirst(new RegExp(r':'), '-');
      dateTime = dateTime.replaceFirst(new RegExp(r' '), 'T');
      // print(intermediate);
      return DateTime.parse(dateTime);
    } catch (error) {
      print(error);
      throw errors['DATETIME_CONVERSION_ERROR'];
    }
  }

  static DateTime newsFeedDateTimeConverter(String dateTime) {
    var monthNumber;
    final dateTimeComponents = dateTime.split(' ');
    final day = dateTimeComponents[0];
    final month = dateTimeComponents[1];
    final year = dateTimeComponents[2];
    final time = dateTimeComponents[3].split(':');
    if (month.toLowerCase() == 'january') monthNumber = '01';
    if (month.toLowerCase() == 'february') monthNumber = '02';
    if (month.toLowerCase() == 'march') monthNumber = '03';
    if (month.toLowerCase() == 'april') monthNumber = '04';
    if (month.toLowerCase() == 'may') monthNumber = '05';
    if (month.toLowerCase() == 'june') monthNumber = '06';
    if (month.toLowerCase() == 'july') monthNumber = '07';
    if (month.toLowerCase() == 'august') monthNumber = '08';
    if (month.toLowerCase() == 'september') monthNumber = '09';
    if (month.toLowerCase() == 'october') monthNumber = '10';
    if (month.toLowerCase() == 'november') monthNumber = '11';
    if (month.toLowerCase() == 'december') monthNumber = '12';
    return DateTime(int.parse(year), int.parse(monthNumber), int.parse(day),
        int.parse(time[0]), int.parse(time[1]));
  }
}
