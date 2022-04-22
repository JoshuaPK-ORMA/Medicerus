import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/widgets.dart';

import '../drug.dart';
import '../dbHelper.dart';
import '../medlog.dart';
import '../otcdrug.dart';
import '../prescription.dart';
import '../otcdrug.dart';
import '../userDbHelper.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';

// import '../data/drift_database.dart';
// import 'widget/add_mv_item_input_widget.dart';

class MedviewPage extends StatefulWidget {
  const MedviewPage({Key? key}) : super(key: key);

  @override
  _MedviewPageState createState() => _MedviewPageState();
}

class _MedviewPageState extends State<MedviewPage> {
  late Future<List<Prescription>> prescriptions;
  late Future<List<OTCDrug>> otcdrugs;
  List<Prescription> loggedPrescriptions = [];
  final userdbHelper = UserDatabaseHelper.instance;

  @protected
  @mustCallSuper
  void initState() {
    prescriptions = userdbHelper.getPrescriptions();
    otcdrugs = userdbHelper.getOTCDrugs();
    getLoggedPrescriptions().then((value) {
      if (value != null) {
        setState(() {
          loggedPrescriptions = value;
        });
      }
    });
  }

  setLoggedPrescriptions() {
    getLoggedPrescriptions().then((value) {
      if (value != null) {
        setState(() {
          loggedPrescriptions = value;
        });
      }
    });
  }

  Future<List<Prescription>> getLoggedPrescriptions() async {
    List<Prescription> logged =
        await userdbHelper.getLoggedPrescriptions().then((value) {
      return value;
    });
    return logged;
  }

  Widget _otcMedication(OTCDrug otcDrug) {
    Icon pinIcon = Icon(Icons.push_pin_outlined);
    if (otcDrug.pinned != null && otcDrug.pinned == true) {
      pinIcon = Icon(Icons.push_pin);
    }
    return Container(
      height: 106,
      width: double.infinity,
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.lightBlue[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                flex: 2,
                child: Text(
                  otcDrug.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  "Amount Limit: ${otcDrug.recAmount.toString()} ${otcDrug.unit} Time Limit: ${otcDrug.recTime.toString()} per ${otcDrug.recTimeType}",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                  ),
                ),
              ),
            ]),
          ),

          //Text(otcDrug.recTime.toString()),
          //           Text(otcDrug.recTimeType),
          //         Text(otcDrug.details!),

          Column(children: [
            IconButton(
                icon: pinIcon,
                onPressed: () {
                  otcDrug.pinned = !otcDrug.pinned;
                  userdbHelper.insertOrUpdateOTCDrug(otcDrug);
                  setState(() {
                    // _medicationWidgets.removeAt(index);
                    // prescriptions = userdbHelper.getPrescriptions();
                    otcdrugs = userdbHelper.getOTCDrugs();
                  });
                }),
            IconButton(
                icon: const Icon(Icons.check),
                onPressed: () {
                  MedLog newlog = MedLog.withOTC(otcDrug);
                  userdbHelper.insertOrUpdateMedLog(newlog);
                  // userdbHelper.insertOrUpdatePrescription(presc);
                  // setState(() {
                  //   // _medicationWidgets.removeAt(index);
                  //   prescriptions = userdbHelper.getPrescriptions();
                  // });
                })
          ]),
        ],
      ),
    );
  }

  Widget _prescMedication(Prescription presc) {
    Icon pinIcon = Icon(Icons.push_pin_outlined);
    if (presc.pinned != null && presc.pinned == true) {
      pinIcon = Icon(Icons.push_pin);
    }
    Widget logbutton;
    if (loggedPrescriptions.contains(presc)) {
      logbutton = Container();
    } else {
      logbutton = IconButton(
          icon: const Icon(Icons.check),
          onPressed: () {
            MedLog newlog = MedLog.withPresc(presc);
            userdbHelper.insertOrUpdateMedLog(newlog);
            // userdbHelper.insertOrUpdatePrescription(presc);
            setState(() {
              prescriptions = userdbHelper.getPrescriptions();
              setLoggedPrescriptions();
            });
          });
    }
    return Container(
      height: 106,
      width: double.infinity,
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.lightBlue[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                flex: 2,
                child: Text(
                  presc.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  "Take ${presc.totalAmount.toString()} ${presc.unit} per day",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                  ),
                ),
              ),
            ]),
          ),
          Column(
            children: [
              IconButton(
                  icon: pinIcon,
                  onPressed: () {
                    presc.pinned = !presc.pinned;
                    userdbHelper.insertOrUpdatePrescription(presc);
                    setState(() {
                      // _medicationWidgets.removeAt(index);
                      prescriptions = userdbHelper.getPrescriptions();
                    });
                  }),
              logbutton,
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('MedView'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
            child: Column(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.medication),
              tileColor: Colors.grey[700],
              title: Text(
                'Prescriptions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
            // Expanded(
            FutureBuilder(
                future: prescriptions,
                builder: (BuildContext context,
                    AsyncSnapshot<List<Prescription>> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.isEmpty) {
                      return Container(
                          height: 75,
                          child: const Text(
                            'No current prescriptions.',
                            style: TextStyle(fontSize: 20),
                          ));
                    }
                    return ListView.builder(
                        // itemCount: _medicationWidgets.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return Dismissible(
                            child: _prescMedication(snapshot.data![index]),
                            key: UniqueKey(),
                            onDismissed: (DismissDirection direction) {
                              userdbHelper
                                  .deletePrescription(snapshot.data![index]);
                              setState(() {
                                // _medicationWidgets.removeAt(index);
                                prescriptions = userdbHelper.getPrescriptions();
                              });
                            },
                            secondaryBackground: Container(
                              child: const Center(
                                child: Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                              color: Colors.red,
                            ),
                            background: Container(),
                            direction: DismissDirection.endToStart,
                          );
                        });
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                }),
            // ),
            // Expanded(
            ListTile(
              leading: Icon(Icons.medication),
              tileColor: Colors.grey[700],
              title: Text(
                'Over the counter drugs',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
            FutureBuilder(
                future: otcdrugs,
                builder: (BuildContext context,
                    AsyncSnapshot<List<OTCDrug>> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.isEmpty) {
                      return Container(
                          height: 75,
                          child: const Text(
                            'No current over the counter drugs.',
                            style: TextStyle(fontSize: 20),
                          ));
                    }
                    return ListView.builder(
                        // itemCount: _medicationWidgets.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return Dismissible(
                            child: _otcMedication(snapshot.data![index]),
                            key: UniqueKey(),
                            onDismissed: (DismissDirection direction) {
                              userdbHelper.deleteOTCDrug(snapshot.data![index]);
                              setState(() {
                                // _medicationWidgets.removeAt(index);
                                otcdrugs = userdbHelper.getOTCDrugs();
                              });
                            },
                            secondaryBackground: Container(
                              child: const Center(
                                child: Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                              color: Colors.red,
                            ),
                            background: Container(),
                            direction: DismissDirection.endToStart,
                          );
                        });
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                }),
            // ),
          ],
        )));
  }
}
