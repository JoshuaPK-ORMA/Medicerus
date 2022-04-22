import 'dart:async';
import 'dart:io';
import 'drug.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    if (_database != null) {
      return _database!;
    } else {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      ByteData data = await rootBundle.load(join("assets", "ndc.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await File(path).writeAsBytes(bytes, flush: true);
      _database = await openDatabase(path, readOnly: true);
      return _database!;
    }
  }

  static const _databaseName = "ndc.db";

  static const table = 'drugs';

  // this opens the database (and creates it if it doesn't exist)
  // Future<Database> _initDatabase() async {
  //   final dbPath = await getDatabasesPath();
  //   final path = _databaseName;
  //   return await openDatabase(path, version: 1, onCreate: _createDB);
  // }

  //Future _createDB(Database db, int version) async {}

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // void printQuery() async {
  //   final db = await instance.database;
  //   List<Map<String, dynamic>> medlist =
  //       await db.rawQuery('SELECT * from drugs LIMIT 10');
  //   medlist.forEach(print);
  // }

  Future<List<Drug>> getDrugs() async {
    final db = await instance.database;
    List<Map<String, dynamic>> medlist =
        await db.rawQuery('SELECT * from drugs LIMIT 10');
    return List.generate(medlist.length, (i) {
      return Drug(
          id: medlist[i]['PRODUCTID'],
          prodNDC: medlist[i]['PRODUCTNDC'],
          prodTypeName: medlist[i]['PRODUCTTYPENAME'],
          proprietaryName: medlist[i]['PROPRIETARYNAME'],
          proprietaryNameSuffix: medlist[i]['PROPRIETARYNAMESUFFIX'],
          nonproprietaryName: medlist[i]['NONPROPRIETARYNAME'],
          dosageFormName: medlist[i]['DOSAGEFORMNAME'],
          routeName: medlist[i]['ROUTENAME'],
          startMarketDate: medlist[i]['STARTMARKETINGDATE'],
          endMarketDate: medlist[i]['ENDMARKETINGDATE'],
          marketCatName: medlist[i]['MARKETINGCATEGORYNAME'],
          applicationNum: medlist[i]['APPLICATIONNUMBER'],
          labelerName: medlist[i]['LABELERNAME'],
          substanceName: medlist[i]['SUBSTANCENAME'],
          strengthNumber: medlist[i]['ACTIVE_NUMERATOR_STRENGTH'],
          strengthUnit: medlist[i]['ACTIVE_INGRED_UNIT'],
          pharmClasses: medlist[i]['PHARM_CLASSES'],
          deaSchedule: medlist[i]['DEASCHEDULE'],
          ndcExcludeFlag: medlist[i]['NDC_EXCLUDE_FLAG'],
          listingRecordCertifiedThrough: medlist[i]
              ['LISTING_RECORD_CERTIFIED_THROUGH']);
    });
  }

  Future<List<Drug>> getRecentDrugs() async {
    final db = await instance.database;
    List<Map<String, dynamic>> medlist =
        await db.rawQuery('SELECT * from drugs LIMIT 16 OFFSET 200');
    return List.generate(medlist.length, (i) {
      return Drug(
          id: medlist[i]['PRODUCTID'],
          prodNDC: medlist[i]['PRODUCTNDC'],
          prodTypeName: medlist[i]['PRODUCTTYPENAME'],
          proprietaryName: medlist[i]['PROPRIETARYNAME'],
          proprietaryNameSuffix: medlist[i]['PROPRIETARYNAMESUFFIX'],
          nonproprietaryName: medlist[i]['NONPROPRIETARYNAME'],
          dosageFormName: medlist[i]['DOSAGEFORMNAME'],
          routeName: medlist[i]['ROUTENAME'],
          startMarketDate: medlist[i]['STARTMARKETINGDATE'],
          endMarketDate: medlist[i]['ENDMARKETINGDATE'],
          marketCatName: medlist[i]['MARKETINGCATEGORYNAME'],
          applicationNum: medlist[i]['APPLICATIONNUMBER'],
          labelerName: medlist[i]['LABELERNAME'],
          substanceName: medlist[i]['SUBSTANCENAME'],
          strengthNumber: medlist[i]['ACTIVE_NUMERATOR_STRENGTH'],
          strengthUnit: medlist[i]['ACTIVE_INGRED_UNIT'],
          pharmClasses: medlist[i]['PHARM_CLASSES'],
          deaSchedule: medlist[i]['DEASCHEDULE'],
          ndcExcludeFlag: medlist[i]['NDC_EXCLUDE_FLAG'],
          listingRecordCertifiedThrough: medlist[i]
              ['LISTING_RECORD_CERTIFIED_THROUGH']);
    });
  }

  Future<List<Drug>> searchDrugs(search) async {
    final db = await instance.database;
    List<Map<String, dynamic>> medlist = await db.rawQuery(
        'SELECT * from drugs WHERE LOWER(PROPRIETARYNAME) like LOWER(\"%' +
            search +
            '%\") OR LOWER(NONPROPRIETARYNAME) like LOWER(\"%' +
            search +
            '%\")');
    return List.generate(medlist.length, (i) {
      return Drug(
          id: medlist[i]['PRODUCTID'],
          prodNDC: medlist[i]['PRODUCTNDC'],
          prodTypeName: medlist[i]['PRODUCTTYPENAME'],
          proprietaryName: medlist[i]['PROPRIETARYNAME'],
          proprietaryNameSuffix: medlist[i]['PROPRIETARYNAMESUFFIX'],
          nonproprietaryName: medlist[i]['NONPROPRIETARYNAME'],
          dosageFormName: medlist[i]['DOSAGEFORMNAME'],
          routeName: medlist[i]['ROUTENAME'],
          startMarketDate: medlist[i]['STARTMARKETINGDATE'],
          endMarketDate: medlist[i]['ENDMARKETINGDATE'],
          marketCatName: medlist[i]['MARKETINGCATEGORYNAME'],
          applicationNum: medlist[i]['APPLICATIONNUMBER'],
          labelerName: medlist[i]['LABELERNAME'],
          substanceName: medlist[i]['SUBSTANCENAME'],
          strengthNumber: medlist[i]['ACTIVE_NUMERATOR_STRENGTH'],
          strengthUnit: medlist[i]['ACTIVE_INGRED_UNIT'],
          pharmClasses: medlist[i]['PHARM_CLASSES'],
          deaSchedule: medlist[i]['DEASCHEDULE'],
          ndcExcludeFlag: medlist[i]['NDC_EXCLUDE_FLAG'],
          listingRecordCertifiedThrough: medlist[i]
              ['LISTING_RECORD_CERTIFIED_THROUGH']);
    });
  }
}
