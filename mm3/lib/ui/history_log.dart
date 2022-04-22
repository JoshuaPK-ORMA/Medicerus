/************************************************************
    Medicerus Mobile: Medical Charting App
    Copyright (C) <2022> Joshua Kramer, et. al.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

*************************************************************/

import 'package:flutter/material.dart';
import '../drug.dart';
import '../medlog.dart';
import '../userDbHelper.dart';
import 'package:intl/intl.dart';

class HistoryLogPage extends StatefulWidget {
  HistoryLogPage({
    Key? key,
  }) : super(key: key);
  @override
  _HistoryLogPage createState() => _HistoryLogPage();
}

class _HistoryLogPage extends State<HistoryLogPage> {
  final userdbHelper = UserDatabaseHelper.instance;
  late Future<List<MedLog>> loglist;
  String searchQuery = '';

  @protected
  @mustCallSuper
  void initState() {
    loglist = userdbHelper.getMedLog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('History Log'),
      ),
      body: Column(
        children: [
          AppBar(
            backgroundColor: Colors.indigo[900],
            title: TextField(
              decoration: InputDecoration(
                hintText: 'Search log',
                hintStyle: TextStyle(
                  color: Colors.black54,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                fillColor: Colors.white,
                filled: true,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 7.0, horizontal: 10.0),
              ),
              style: TextStyle(
                color: Colors.black,
              ),
              onChanged: (text) {
                searchQuery = text;
              },
              onSubmitted: (text) {
                setState(() {
                  searchQuery = text;
                  loglist = userdbHelper.searchMedLog(searchQuery);
                });
              },
            ),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  setState(() {
                    searchQuery = searchQuery;
                    loglist = userdbHelper.searchMedLog(searchQuery);
                  });
                },
              )
            ],
          ),
          Expanded(
            child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(children: <Widget>[historyLogDisplay()])),
          )
        ],
      ),
    );
  }

  Widget historyLogDisplay() {
    return FutureBuilder(
      future: loglist,
      builder: (BuildContext context, AsyncSnapshot<List<MedLog>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return Container(
                // resizeToAvoidBottomInset: false,
                height: 450,
                child: const Text(
                  'No logged medications.',
                  style: TextStyle(fontSize: 20),
                ));
          }
          return medLogDisplayList(snapshot);
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget medLogDisplayList(AsyncSnapshot<List<MedLog>> loglist) {
    int length = loglist.data!.length;
    return Expanded(
        child: Container(
            height:
                450, //sets height for total list field, prevents overflowing
            child: ListView.builder(
              scrollDirection:
                  Axis.vertical, //allows list to be scrollable vertically
              shrinkWrap: true,
              itemCount: length,
              itemBuilder: (context, position) {
                return Material(
                  child: InkWell(
                    child: Container(
                      width: 50, //sets width for the text boxes
                      alignment:
                          Alignment.centerLeft, //sets text aligned to the left
                      child: medLogDisplayLine(loglist.data![position]),
                      padding: const EdgeInsets.all(3.0),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueAccent)),
                    ),
                  ),
                  color: Colors.transparent,
                );
              },
            )));
  }

  Widget medLogDisplayLine(MedLog log) {
    String substancename = '';
    if (log.substanceName != null) {
      substancename = log.substanceName!;
    }
    return Builder(builder: (BuildContext context) {
      return Row(
        //mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child:
                // Container(constraints: BoxConstraints(maxWidth: 25), child: Icons.medIcon),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  //width: 325,
                  padding: const EdgeInsets.only(
                      left: 5, bottom: 5, right: 5, top: 15),
                  child: Text(
                    log.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.left,
                  )), //),
              Container(
                  //width: 325,
                  padding: const EdgeInsets.only(
                      left: 5, bottom: 5, right: 5, top: 5),
                  child: Text(
                    log.amounttaken.toString() + ' ' + log.unit,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.left,
                  )),
              Container(
                  //width: 325,
                  padding: const EdgeInsets.only(
                      left: 5, bottom: 5, right: 5, top: 5),
                  child: Text(
                    substancename,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.left,
                  ))
            ]),
          ),
          Column(children: [
            Container(
                //width: 325,
                padding: const EdgeInsets.only(
                    left: 10, bottom: 5, right: 5, top: 5),
                child: Text(
                  DateFormat.yMd()
                      .add_jm()
                      .format(DateTime.parse(log.timetaken)),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.right,
                ))
          ]),
        ],
      );
    });
  }

  _insertMedLog() async {
    MedLog testlog = MedLog(
        name: 'other drug name',
        timetaken: DateTime.now().toString(),
        prescriptionstatus: false,
        prescid: 2,
        otcid: null,
        amounttaken: 20,
        unit: 'mg',
        substanceName: 'acetaminophen');
    userdbHelper.insertOrUpdateMedLog(testlog);
  }
}
