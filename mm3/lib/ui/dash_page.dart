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
import 'package:medicerus/prescription.dart';
import 'package:medicerus/userDbHelper.dart';
import 'package:sqflite/sqflite.dart';

import '../medlog.dart';
import '../otcdrug.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final userdbHelper = UserDatabaseHelper.instance;
  late Future<List<Prescription>> prescriptions;
  late Future<List<Prescription>> pinnedLoggedPrescriptions;
  late Future<List<Prescription>> pinnedUnloggedPrescriptions;
  late Future<List<Prescription>> loggedPrescriptions;
  late Future<List<Prescription>> unloggedPrescriptions;
  late Future<List<OTCDrug>> otcDrugs;
  late Future<List<OTCDrug>> pinnedOTCDrugs;
  int numberPinned = 0;

  @protected
  @mustCallSuper
  void initState() {
    prescriptions = userdbHelper.getPrescriptions();
    loggedPrescriptions = userdbHelper.getLoggedPrescriptions();
    unloggedPrescriptions = getUnloggedPrescriptions();
    pinnedLoggedPrescriptions = getPinnedLoggedPrescriptions();
    pinnedUnloggedPrescriptions = getPinnedUnloggedPrescriptions();
    otcDrugs = userdbHelper.getOTCDrugs();
    pinnedOTCDrugs = userdbHelper.getPinnedOTCDrugs();
    getNumberPinned().then((value) {
      if (value != null) {
        setState(() {
          numberPinned = value;
        });
        print('number pinned: ' + numberPinned.toString());
      }
    });
  }

  setNumberPinned() async {
    int pinned = await getNumberPinned();
    setState(() {
      numberPinned = pinned;
    });
  }

  Future<int> getNumberPinned() async {
    int unlogged = await pinnedUnloggedPrescriptions.then((value) {
      return value.length;
    });
    int logged = await pinnedLoggedPrescriptions.then((value) {
      return value.length;
    });
    int pinnedotc = await pinnedOTCDrugs.then((value) {
      return value.length;
    });
    return unlogged + logged + pinnedotc;
  }

  Future<List<Prescription>> getPinnedLoggedPrescriptions() async {
    List<Prescription> presc = await loggedPrescriptions;
    List<Prescription> pinned =
        presc.where((element) => element.pinned == true).toList();
    return pinned;
  }

  Future<List<Prescription>> getPinnedUnloggedPrescriptions() async {
    List<Prescription> presc = await unloggedPrescriptions;
    List<Prescription> pinned =
        presc.where((element) => element.pinned == true).toList();
    return pinned;
  }

  Future<List<Prescription>> getUnloggedPrescriptions() async {
    List<Prescription> presc = await prescriptions;
    List<Prescription> logged = await loggedPrescriptions;
    List<Prescription> unlogged =
        presc.toSet().difference(logged.toSet()).toList();
    return unlogged;
  }

  List<Prescription> getLoggedList() {
    List<Prescription> logged = loggedPrescriptions as List<Prescription>;
    return logged;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              medDisplayPinned(),
              ListView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.medication),
                    tileColor: Colors.grey[700],
                    title: const Text(
                      'Current Medications',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  medDisplayCurrent()
                ],
              ),
              ListView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
                children: <Widget>[
                  ListTile(
                    tileColor: Colors.grey[700],
                    leading: Icon(Icons.medication),
                    title: const Text(
                      'Recent Medications',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  medDisplayLogged(),
                ],
              ),
            ],
          ),
        ));
  }

  Widget medDisplayPinned() {
    Widget pinnedTitle;
    if (numberPinned > 0) {
      pinnedTitle = ListTile(
        leading: Icon(Icons.medication),
        tileColor: Colors.grey[700],
        title: Text(
          'Pinned Medications',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      );
    } else {
      pinnedTitle = Container();
    }
    return Column(
      children: [
        pinnedTitle,
        FutureBuilder(
            future: pinnedUnloggedPrescriptions,
            builder: (BuildContext context,
                AsyncSnapshot<List<Prescription>> snapshot) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
                  children: <Widget>[
                    pinnedListDisplay(snapshot, false),
                  ],
                );
              } else {
                return Container();
              }
            }),
        FutureBuilder(
            future: pinnedLoggedPrescriptions,
            builder: (BuildContext context,
                AsyncSnapshot<List<Prescription>> snapshot) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
                  children: <Widget>[
                    pinnedListDisplay(snapshot, true),
                  ],
                );
              } else {
                return Container();
              }
            }),
        FutureBuilder(
            future: pinnedOTCDrugs,
            builder:
                (BuildContext context, AsyncSnapshot<List<OTCDrug>> snapshot) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
                  children: <Widget>[
                    pinnedOTCListDisplay(snapshot),
                  ],
                );
              } else {
                return Container();
              }
            }),
      ],
    );
  }

  Widget medDisplayLogged() {
    return FutureBuilder(
        future: loggedPrescriptions,
        builder:
            (BuildContext context, AsyncSnapshot<List<Prescription>> snapshot) {
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return ListView(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
              children: <Widget>[
                medListDisplay(snapshot, true),
              ],
            );
          } else {
            return Container();
          }
        });
  }

  Widget pinnedListDisplay(
      AsyncSnapshot<List<Prescription>> presclist, bool logged) {
    int length = presclist.data!.length;
    return Container(
        child: Container(
            child: ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical, //allows list to be scrollable vertically
      shrinkWrap: true,
      itemCount: length,
      itemBuilder: (context, position) {
        return Material(
          child: InkWell(
              child: Container(
                width: 50, //sets width for the text boxes
                alignment: Alignment.centerLeft, //sets text aligned to the left
                child: displayPinnedPrescription(
                    presclist.data![position], logged),
                padding: const EdgeInsets.all(3.0),
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.blueAccent)),
              ),
              onTap: () {}),
          color: Colors.transparent,
        );
      },
    )));
  }

  Widget pinnedOTCListDisplay(AsyncSnapshot<List<OTCDrug>> otclist) {
    int length = otclist.data!.length;
    return Container(
        child: Container(
            child: ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical, //allows list to be scrollable vertically
      shrinkWrap: true,
      itemCount: length,
      itemBuilder: (context, position) {
        return Material(
          child: InkWell(
              child: Container(
                width: 50, //sets width for the text boxes
                alignment: Alignment.centerLeft, //sets text aligned to the left
                child: displayPinnedOTC(otclist.data![position]),
                padding: const EdgeInsets.all(3.0),
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.blueAccent)),
              ),
              onTap: () {}),
          color: Colors.transparent,
        );
      },
    )));
  }

  Widget medListDisplay(
      AsyncSnapshot<List<Prescription>> presclist, bool logged) {
    int length = presclist.data!.length;
    return Container(
        child: Container(
            child: ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical, //allows list to be scrollable vertically
      shrinkWrap: true,
      itemCount: length,
      itemBuilder: (context, position) {
        return Material(
          child: InkWell(
              child: Container(
                width: 50, //sets width for the text boxes
                alignment: Alignment.centerLeft, //sets text aligned to the left
                child: displayPrescription(presclist.data![position], logged),
                padding: const EdgeInsets.all(3.0),
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.blueAccent)),
              ),
              onTap: () {
                // print(presclist.data![position].name);
              }),
          color: Colors.transparent,
        );
      },
    )));
  }

  Widget medDisplayCurrent() {
    return FutureBuilder(
      future: unloggedPrescriptions,
      builder:
          (BuildContext context, AsyncSnapshot<List<Prescription>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return Container(
                padding: const EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 10.0),
                child: const Text(
                  'No prescriptions left to take.',
                  style: TextStyle(fontSize: 14),
                ));
          }
          return medListDisplay(snapshot, false);
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget displayPrescription(Prescription presc, bool logged) {
    Widget checkbutton;
    Color backColor = Colors.lightBlue.shade100;
    if (logged) {
      backColor = Colors.grey.shade300;
      checkbutton = Container();
    } else {
      checkbutton = SizedBox(
        height: 30,
        width: 30,
        child: IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              MedLog newlog = MedLog.withPresc(presc);
              userdbHelper.insertOrUpdateMedLog(newlog);
              setState(() {
                loggedPrescriptions = userdbHelper.getLoggedPrescriptions();
                unloggedPrescriptions = getUnloggedPrescriptions();
                pinnedUnloggedPrescriptions = getPinnedUnloggedPrescriptions();
                pinnedLoggedPrescriptions = getPinnedLoggedPrescriptions();
              });
            }),
      );
    }
    return Builder(builder: (BuildContext context) {
      return Container(
          color: backColor,
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Container(
                constraints: BoxConstraints(maxWidth: 25),
                child: Icon(Icons.medication)),
            Column(children: [
              Container(
                  width: 325,
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    presc.name,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.left,
                  )),
              Container(
                  width: 325,
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    presc.totalAmount.toString() + ' ' + presc.unit,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.left,
                  )),
            ]),
            checkbutton
          ]));
    });
  }

  Widget displayPinnedPrescription(Prescription presc, bool logged) {
    Icon pinIcon = Icon(Icons.push_pin_outlined);
    if (presc.pinned != null && presc.pinned == true) {
      pinIcon = Icon(Icons.push_pin);
    }
    Color backColor = Colors.lightBlue.shade100;
    Widget logButton;
    if (logged) {
      backColor = Colors.grey.shade300;
      logButton = Container();
    } else {
      logButton = SizedBox(
        height: 30,
        width: 30,
        child: IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              MedLog newlog = MedLog.withPresc(presc);
              userdbHelper.insertOrUpdateMedLog(newlog);
              setState(() {
                loggedPrescriptions = userdbHelper.getLoggedPrescriptions();
                unloggedPrescriptions = getUnloggedPrescriptions();
                pinnedLoggedPrescriptions = getPinnedLoggedPrescriptions();
                pinnedUnloggedPrescriptions = getPinnedUnloggedPrescriptions();
              });
            }),
      );
    }
    return Builder(builder: (BuildContext context) {
      return Container(
          color: backColor,
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Container(
                constraints: BoxConstraints(maxWidth: 25),
                child: Icon(Icons.medication)),
            Column(children: [
              Container(
                  width: 300,
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    presc.name,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.left,
                  )),
              Container(
                  width: 300,
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    presc.totalAmount.toString() + ' ' + presc.unit,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.left,
                  )),
            ]),
            logButton,
            SizedBox(
              height: 30,
              width: 30,
              child: IconButton(
                  icon: pinIcon,
                  onPressed: () {
                    presc.pinned = !presc.pinned;
                    userdbHelper.insertOrUpdatePrescription(presc);
                    setState(() {
                      prescriptions = userdbHelper.getPrescriptions();
                      pinnedLoggedPrescriptions =
                          getPinnedLoggedPrescriptions();
                      pinnedUnloggedPrescriptions =
                          getPinnedUnloggedPrescriptions();
                      setNumberPinned();
                    });
                  }),
            ),
          ]));
    });
  }

  Widget displayPinnedOTC(OTCDrug otc) {
    Icon pinIcon = Icon(Icons.push_pin_outlined);
    if (otc.pinned != null && otc.pinned == true) {
      pinIcon = Icon(Icons.push_pin);
    }
    return Builder(builder: (BuildContext context) {
      return Container(
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Container(
            constraints: BoxConstraints(maxWidth: 25),
            child: Icon(Icons.medication)),
        Column(children: [
          Container(
              width: 300,
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                otc.name,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                textAlign: TextAlign.left,
              )),
          Container(
              width: 300,
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                (otc.recAmount).toString() + ' ' + otc.unit,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.left,
              )),
        ]),
        SizedBox(
          height: 30,
          width: 30,
          child: IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                MedLog newlog = MedLog.withOTC(otc);
                userdbHelper.insertOrUpdateMedLog(newlog);
                setState(() {
                  otcDrugs = userdbHelper.getOTCDrugs();
                });
              }),
        ),
        SizedBox(
          height: 30,
          width: 30,
          child: IconButton(
              icon: pinIcon,
              onPressed: () {
                otc.pinned = !otc.pinned;
                userdbHelper.insertOrUpdateOTCDrug(otc);
                setState(() {
                  pinnedOTCDrugs = userdbHelper.getPinnedOTCDrugs();
                  setNumberPinned();
                });
              }),
        ),
      ]));
    });
  }
}
