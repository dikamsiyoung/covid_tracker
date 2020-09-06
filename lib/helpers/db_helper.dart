import 'dart:io';

import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;

import '../lang/en.dart';
import '../models/report.dart';

class DBHelper {
  static var errors = English.errors['db_helper_errors'];

  static Future<sql.Database> accessDatabase() async {
    try {
      final dbPath = await sql.getDatabasesPath();
      return sql.openDatabase(
        path.join(
          dbPath,
          'reports.db',
        ),
        onCreate: (db, version) {
          return db.execute(
            'CREATE TABLE user_reports(id TEXT PRIMARY KEY, description TEXT, vehicleImagePath TEXT, victimImagePath TEXT, latitude REAL, longitude REAL, nature TEXT, injury TEXT)',
          );
        },
        version: 1,
      );
    } catch (error) {
      print(error);
      throw errors['DB_ACCESS_ERROR'];
    }
  }

  static Future<void> insert(String table, Map<String, Object> data) async {
    final dbAccess = await DBHelper.accessDatabase();
    dbAccess.insert(
      table,
      data,
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getData(String table) async {
    try {
      final dbAccess = await DBHelper.accessDatabase();
      return dbAccess.query(table);
    } catch (error) {
      print(error);
      throw errors['DB_READ_ERROR'];
    }
  }

  static void addToDb(
    Report newReport,
    Map<String, File> selectedImage,
    IncidentLocation userLocation,
    String natureOfAccident,
    String injuryLevel,
  ) {
    try {
      DBHelper.insert(
        'user_reports',
        {
          'id': newReport.id,
          'description': newReport.description,
          'victimImagePath': selectedImage['victims'].path,
          'vehicleImagePath': selectedImage['vehicles'].path,
          'latitude': userLocation.latitude,
          'longitude': userLocation.longitude,
          'nature': natureOfAccident,
          'injury': injuryLevel,
        },
      );
    } catch (error) {
      print(error);
      throw errors['DB_WRITE_ERROR'];
    }
  }
}
