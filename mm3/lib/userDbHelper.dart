import 'dart:async';
import 'dart:io';
import 'package:medicerus/medlog.dart';
import 'package:medicerus/otcdrug.dart';
import 'package:medicerus/prescription.dart';

import 'drug.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart';

class UserDatabaseHelper {
  static final UserDatabaseHelper instance = UserDatabaseHelper._init();
  static Database? _database;
  UserDatabaseHelper._init();

  Future<Database> get database async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    if (_database != null) {
      return _database!;
    } else {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}
      _database = await openDatabase(path,
          version: _databaseVersion, onCreate: _onCreate);
      return _database!;
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future _onCreate(Database db, int version) async {
    print('create user db');
    await db.execute('''
      CREATE TABLE prescriptions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        totalamount INTEGER NOT NULL,
        unit TEXT NOT NULL,
        daysupply INTEGER NOT NULL,
        rxnumber TEXT,
        filldate TEXT NOT NULL,
        expdate TEXT,
        details TEXT,
        pharmphonenum TEXT,
        substancename TEXT,
        pinned INTEGER NOT NULL DEFAULT 0
      );
      ''');
    await db.execute('''
      CREATE TABLE otcdrugs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        recamount INTEGER NOT NULL,
        unit TEXT NOT NULL,
        rectime INTEGER NOT NULL,
        rectimetype TEXT NOT NULL,
        details TEXT,
        substancename TEXT,
        pinned INTEGER NOT NULL DEFAULT 0
      )
      ''');
    await db.execute('''
      CREATE TABLE medlog (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        timetaken TEXT NOT NULL,
        prescriptionstatus INTEGER NOT NULL DEFAULT 0,
        prescid INTEGER,
        otcid INTEGER,
        amounttaken INTEGER NOT NULL,
        unit TEXT NOT NULL,
        substancename TEXT,
        FOREIGN KEY(prescid) REFERENCES prescription (id),
        FOREIGN KEY(otcid) REFERENCES otcdrug (id)
      )
    ''');
  }

  Future<List<Prescription>> getPrescriptions() async {
    final db = await instance.database;
    List<Map<String, dynamic>> presclist =
        await db.rawQuery('SELECT * from prescriptions');
    return List.generate(presclist.length, (i) {
      return Prescription(
          id: presclist[i]['id'],
          name: presclist[i]['name'],
          totalAmount: presclist[i]['totalamount'],
          unit: presclist[i]['unit'],
          daySupply: presclist[i]['daysupply'],
          fillDate: DateTime.parse(presclist[i]['filldate']),
          rxNumber: presclist[i]['rxnumber'],
          expDate: DateTime.tryParse(presclist[i]['expdate']),
          details: presclist[i]['details'],
          pharmPhoneNum: presclist[i]['pharmphonenum'],
          substanceName: presclist[i]['substancename'],
          pinned: presclist[i]['pinned'] == 0 ? false : true);
    });
  }

  Future<List<Prescription>> getPinnedPrescriptions() async {
    final db = await instance.database;
    List<Map<String, dynamic>> presclist =
        await db.rawQuery('SELECT * from prescriptions WHERE pinned = 1');
    return List.generate(presclist.length, (i) {
      return Prescription(
          id: presclist[i]['id'],
          name: presclist[i]['name'],
          totalAmount: presclist[i]['totalamount'],
          unit: presclist[i]['unit'],
          daySupply: presclist[i]['daysupply'],
          fillDate: DateTime.parse(presclist[i]['filldate']),
          rxNumber: presclist[i]['rxnumber'],
          expDate: DateTime.tryParse(presclist[i]['expdate']),
          details: presclist[i]['details'],
          pharmPhoneNum: presclist[i]['pharmphonenum'],
          substanceName: presclist[i]['substancename'],
          pinned: presclist[i]['pinned'] == 0 ? false : true);
    });
  }

  Future<List<OTCDrug>> getPinnedOTCDrugs() async {
    final db = await instance.database;
    List<Map<String, dynamic>> otclist =
        await db.rawQuery('SELECT * from otcdrugs WHERE pinned = 1');
    return List.generate(otclist.length, (i) {
      return OTCDrug(
          id: otclist[i]['id'],
          name: otclist[i]['name'],
          unit: otclist[i]['unit'],
          details: otclist[i]['details'],
          substanceName: otclist[i]['substancename'],
          recAmount: otclist[i]['recamount'],
          recTime: otclist[i]['rectime'],
          recTimeType: otclist[i]['rectimetype'],
          pinned: otclist[i]['pinned'] == 0 ? false : true);
    });
  }

  Future<List<Prescription>> getLoggedPrescriptions() async {
    final db = await instance.database;
    List<Map<String, dynamic>> presclist = await db.rawQuery(
        'SELECT * from prescriptions, medlog WHERE medlog.prescid = prescriptions.id AND DATE(datetime(medlog.timetaken)) = DATE(\'now\', \'localtime\')'); //where NO instance of medlog WHERE medlog.prescid = prescription.id and timetaken > last midnight
    return List.generate(presclist.length, (i) {
      return Prescription(
          id: presclist[i]['prescid'],
          name: presclist[i]['name'],
          totalAmount: presclist[i]['totalamount'],
          unit: presclist[i]['unit'],
          daySupply: presclist[i]['daysupply'],
          fillDate: DateTime.parse(presclist[i]['filldate']),
          rxNumber: presclist[i]['rxnumber'],
          expDate: DateTime.tryParse(presclist[i]['expdate']),
          details: presclist[i]['details'],
          pharmPhoneNum: presclist[i]['pharmphonenum'],
          substanceName: presclist[i]['substancename'],
          pinned: presclist[i]['pinned'] == 0 ? false : true);
    });
  }

  Future<List<OTCDrug>> getOTCDrugs() async {
    final db = await instance.database;
    List<Map<String, dynamic>> otclist =
        await db.rawQuery('SELECT * from otcdrugs');
    return List.generate(otclist.length, (i) {
      return OTCDrug(
          id: otclist[i]['id'],
          name: otclist[i]['name'],
          recAmount: otclist[i]['recamount'],
          unit: otclist[i]['unit'],
          recTime: otclist[i]['rectime'],
          recTimeType: otclist[i]['rectimetype'],
          details: otclist[i]['details'],
          substanceName: otclist[i]['substance'],
          pinned: otclist[i]['pinned'] == 0 ? false : true);
    });
  }

  Future<List<MedLog>> getMedLog() async {
    final db = await instance.database;
    List<Map<String, dynamic>> medloglist =
        await db.rawQuery('SELECT * from medlog ORDER BY timetaken DESC;');

    return List.generate(medloglist.length, (i) {
      return MedLog(
          id: medloglist[i]['id'],
          name: medloglist[i]['name'],
          timetaken: medloglist[i]['timetaken'],
          prescriptionstatus:
              medloglist[i]['prescriptionstatus'] == 0 ? false : true,
          prescid: medloglist[i]['prescid'],
          otcid: medloglist[i]['otcid'],
          amounttaken: medloglist[i]['amounttaken'],
          unit: medloglist[i]['unit'],
          substanceName: medloglist[i]['substancename']);
    });
  }

  Future<List<MedLog>> searchMedLog(search) async {
    final db = await instance.database;
    List<Map<String, dynamic>> medloglist = await db.rawQuery(
        'SELECT * from medlog WHERE LOWER(name) like LOWER(\"%' +
            search +
            '%\") OR LOWER(timetaken) like LOWER(\"%' +
            search +
            '%\") OR LOWER(substancename) like LOWER(\"%' +
            search +
            '%\") ORDER BY timetaken DESC');
    return List.generate(medloglist.length, (i) {
      return MedLog(
          id: medloglist[i]['id'],
          name: medloglist[i]['name'],
          timetaken: medloglist[i]['timetaken'],
          prescriptionstatus:
              medloglist[i]['prescriptionstatus'] == 0 ? false : true,
          prescid: medloglist[i]['prescid'],
          otcid: medloglist[i]['otcid'],
          amounttaken: medloglist[i]['amounttaken'],
          unit: medloglist[i]['unit'],
          substanceName: medloglist[i]['substancename']);
    });
  }

  insertOrUpdatePrescription(Prescription presc) async {
    final db = await instance.database;
    Map<String, dynamic> row = {
      'id': presc.id,
      'name': presc.name,
      'totalamount': presc.totalAmount,
      'unit': presc.unit,
      'daysupply': presc.daySupply,
      'filldate': presc.fillDate.toString(),
      'rxnumber': presc.rxNumber,
      'expdate': presc.expDate.toString(),
      'details': presc.details,
      'pharmphonenum': presc.pharmPhoneNum,
      'substancename': presc.substanceName,
      'pinned': presc.pinned ? 1 : 0
    };
    if (presc.id != null) {
      int updateCount = await db
          .update('prescriptions', row, where: 'id = ?', whereArgs: [presc.id]);
    } else {
      int id = await db.insert('prescriptions', row);
    }
  }

  insertOrUpdateOTCDrug(OTCDrug otc) async {
    final db = await instance.database;
    Map<String, dynamic> row = {
      'id': otc.id,
      'name': otc.name,
      'recamount': otc.recAmount,
      'unit': otc.unit,
      'rectime': otc.recTime,
      'rectimetype': otc.recTimeType,
      'details': otc.details,
      'substancename': otc.substanceName,
      'pinned': otc.pinned
    };
    if (otc.id != null) {
      int updateCount = await db
          .update('otcdrugs', row, where: 'id = ?', whereArgs: [otc.id]);
    } else {
      int id = await db.insert('otcdrugs', row);
    }
  }

  insertOrUpdateMedLog(MedLog medlog) async {
    final db = await instance.database;
    Map<String, dynamic> row = {
      'id': medlog.id,
      'name': medlog.name,
      'timetaken': medlog.timetaken,
      'prescriptionstatus': medlog.prescriptionstatus,
      'prescid': medlog.prescid,
      'otcid': medlog.prescid,
      'amounttaken': medlog.amounttaken,
      'unit': medlog.unit,
      'substancename': medlog.substanceName
    };
    if (medlog.id != null) {
      int updateCount = await db
          .update('medlog', row, where: 'id = ?', whereArgs: [medlog.id]);
    } else {
      int id = await db.insert('medlog', row);
    }
  }

  deletePrescription(Prescription presc) async {
    final db = await instance.database;
    if (presc.id != null) {
      int deleteCount = await db
          .delete('prescriptions', where: 'id = ?', whereArgs: [presc.id]);
    }
  }

  deleteOTCDrug(OTCDrug otc) async {
    final db = await instance.database;
    if (otc.id != null) {
      int deleteCount =
          await db.delete('otcdrugs', where: 'id = ?', whereArgs: [otc.id]);
    }
  }

  deleteMedLog(MedLog medlog) async {
    final db = await instance.database;
    if (medlog.id != null) {
      int deleteCount =
          await db.delete('medlog', where: 'id = ?', whereArgs: [medlog.id]);
    }
  }

  static const _databaseName = "usermed.db";

  static const _databaseVersion = 1;
}
