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
import 'package:medicerus/ui/med_details.dart';
import 'package:medicerus/ui/med_form.dart';
import 'package:medicerus/ui/otc_form.dart';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/widgets.dart';

import '../drug.dart';
import '../dbHelper.dart';

class QuicklistPage extends StatefulWidget {
  @override
  _QuicklistPageState createState() => _QuicklistPageState();
}

class _QuicklistPageState extends State<QuicklistPage> {
  Widget customSearchBar = const Text('Search Medications');
  Icon searchIcon = const Icon(Icons.search);
  String searchQuery = "";
  int searchOffset = 0;
  int searchLength = 0;
  final dbHelper = DatabaseHelper.instance;
  ListView llv = ListView(shrinkWrap: true);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Search medications',
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
              searchOffset = 0;
            });
          },
        ),
        backgroundColor: Colors.indigo[900],
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: searchIcon,
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              setState(() {
                searchQuery = searchQuery;
                searchOffset = 0;
              });
            },
          )
        ],
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          medDisplayWidgetCurrent(searchQuery),
          // const Spacer(),
          Container(
            color: Colors.indigo[900],
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    child: Text(
                      'Back',
                      style: TextStyle(fontSize: 20),
                    ),
                    //onPressed: _queryRecentDrugs,
                    onPressed: (searchOffset != 0)
                        ? () {
                            if (searchOffset - 10 >= 0) {
                              setState(() {
                                searchOffset = searchOffset - 10;
                              });
                            } else {
                              print("At beginning of query range");
                            }
                          }
                        : null,
                  ),
                  ElevatedButton(
                    child: Text(
                      'Next',
                      style: TextStyle(fontSize: 20),
                    ),
                    //onPressed: _queryRecentDrugs,
                    onPressed: (searchOffset == searchLength ||
                            (searchLength - searchOffset) <= 10)
                        // (searchOffset + 10) - searchLength < 10)
                        ? null
                        : () {
                            setState(() {
                              searchOffset = searchOffset + 10;
                              print(searchOffset);
                            });
                          },
                  ),
                  PopupMenuButton(
                    icon: const Icon(Icons.create, color: Colors.white),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15.0))),
                    itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                      const PopupMenuItem(
                        child: ListTile(
                          //leading: Icon(Icons.add),
                          title: Text("New Prescription"),
                        ),
                        value: 0,
                      ),
                      const PopupMenuItem(
                        child: ListTile(
                          //leading: Icon(Icons.add),
                          title: Text("New OTC Drug"),
                        ),
                        value: 1,
                      ),
                    ],
                    //onSelected block found at https://stackoverflow.com/questions/59478364/how-to-use-ontap-or-onpressed-in-popupmenuitem, user no_fate
                    onSelected: (result) {
                      if (result == 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MedFormPage()),
                        );
                      } else if (result == 1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OTCFormPage()),
                        );
                      }
                    },
                  ),
                ]),
          ),
        ],
      ),
    );
  }

  Widget medDisplayLine2(
      String proprietname, String nonproprietname, Drug drug) {
    Icon medIcon = Icon(Icons.medical_services);
    if (drug.dosageFormName.toLowerCase().contains('tablet')) {
      medIcon = Icon(Icons.medication);
    } else if (drug.dosageFormName.toLowerCase().contains('liquid') ||
        drug.dosageFormName.toLowerCase().contains('solution') ||
        drug.dosageFormName.toLowerCase().contains('syrup') ||
        drug.dosageFormName.toLowerCase().contains('suspension')) {
      medIcon = Icon(Icons.local_drink);
    }
    String medType = '';
    if (drug.prodTypeName.toLowerCase() == 'human otc drug') {
      medType = 'Over the Counter';
    } else {
      medType = 'Prescription Drug';
    }
    return Builder(builder: (BuildContext context) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(constraints: BoxConstraints(maxWidth: 25), child: medIcon),
          Column(children: [
            Container(
                width: 325,
                padding: const EdgeInsets.symmetric(vertical: 2),
                //child: new Flexible(
                //padding: const EdgeInsets.all(20.0),
                child: Text(
                  proprietname,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.left,
                )), //),
            Container(
                width: 325,
                padding: const EdgeInsets.symmetric(vertical: 2),
                //child: new Flexible(
                child: Text(
                  nonproprietname,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.left,
                )), //),
            Container(
                width: 325,
                padding: const EdgeInsets.symmetric(vertical: 2),
                //child: new Flexible(
                child: Text(
                  medType,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.left,
                )),
          ]),
          Stack(
            children: [
              PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                  const PopupMenuItem(
                    child: ListTile(
                      //leading: Icon(Icons.add),
                      title: Text("View Details"),
                    ),
                    value: 0,
                  ),
                  /*const PopupMenuItem(
                      child: ListTile(
                    //leading: Icon(Icons.add),
                    title: Text("Pin to Dashboard"),
                  )),*/
                ],
                //onSelected block found at https://stackoverflow.com/questions/59478364/how-to-use-ontap-or-onpressed-in-popupmenuitem, user no_fate
                onSelected: (result) {
                  if (result == 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MedDetailsPage(drug: drug)),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget medDisplayWidgetCurrent(String searchQuery) {
    print('runquery');
    Future<List<Drug>> drugs = this.dbHelper.searchDrugs(searchQuery);
    Future<int> druglistlength = _setDrugListLength(drugs);
    return FutureBuilder(
      future: drugs,
      builder: (BuildContext context, AsyncSnapshot<List<Drug>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return Container(
                height: 450,
                child: const Text(
                  'No results found.',
                  style: TextStyle(fontSize: 20),
                ));
          }
          return medDisplayList(snapshot);
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget medDisplayList(AsyncSnapshot<List<Drug>> druglist) {
    int length = druglist.data!.length;
    int itemDisplayCount = 10;
    if (length != null) {
      if (length - searchOffset < 10) {
        itemDisplayCount = length - searchOffset;
      }
    }
    List<Drug> paginatedList = druglist.data!.sublist(this.searchOffset);
    return Expanded(
        child: Container(
            height:
                450, //sets height for total list field, prevents overflowing
            child: ListView.builder(
              scrollDirection:
                  Axis.vertical, //allows list to be scrollable vertically
              shrinkWrap: true,
              itemCount: itemDisplayCount,
              itemBuilder: (context, position) {
                return Material(
                  child: InkWell(
                      child: Container(
                        width: 50, //sets width for the text boxes
                        alignment: Alignment
                            .centerLeft, //sets text aligned to the left
                        child: medDisplayLine2(
                            paginatedList[position]
                                .proprietaryName //inserts drug's proprietary name into box
                                .toString(),
                            paginatedList[position]
                                .nonproprietaryName //inserts drug's nonproprietary name into same box
                                .toString(),
                            paginatedList[position]),
                        padding: const EdgeInsets.all(3.0),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.blueAccent)),
                      ),
                      onTap: () {
                        print(paginatedList[position].prodNDC.toString());
                        if (paginatedList[position]
                                .prodTypeName
                                .toLowerCase() ==
                            'human otc drug') {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => OTCFormPage(
                                      drug: paginatedList[position])));
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MedFormPage(
                                      drug: paginatedList[position])));
                        }
                      }),
                  color: Colors.transparent,
                );
              },
            )));
  }

  Widget medDisplayWidgetRecent() {
    return FutureBuilder(
      future: this.dbHelper.getRecentDrugs(),
      builder: (BuildContext context, AsyncSnapshot<List<Drug>> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            shrinkWrap: true,
            //itemCount: snapshot.data?.length,
            itemCount: 10,
            itemBuilder: (context, position) {
              return InkWell(
                onTap: () {
                  print('hey I did the thing');
                },
                child: IgnorePointer(
                  child: Container(
                    //height: 3.0,
                    width: 50,
                    color: Colors.white,
                    alignment: Alignment.centerLeft,
                    child: medDisplayLine2(
                        snapshot.data![position].proprietaryName.toString(),
                        snapshot.data![position].nonproprietaryName.toString(),
                        snapshot.data![position]),
                  ),
                ),
              );
            },
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  void _queryDrugs() async {
    //dbHelper.printQuery();
    final drugs = await dbHelper.getRecentDrugs();
    //for (int i = 0; i < drugs.length; i++) {
    //  print(drugs[i].toString());
    // }
    //rows.forEach(print);
  }

  void _queryRecentDrugs() async {
    //dbHelper.printQuery();
    final drugs = await dbHelper.getRecentDrugs();
    //for (int i = 0; i < drugs.length; i++) {
    //  print(drugs[i].toString());
    // }
    //rows.forEach(print);
  }

  Future<int> _setDrugListLength(Future<List<Drug>> druglist) async {
    return await druglist.then((value) {
      if (value != null && value.length != searchLength) {
        setState(() {
          searchLength = value.length;
        });
        return value.length;
      } else {
        return 0;
      }
    });
  }
}
