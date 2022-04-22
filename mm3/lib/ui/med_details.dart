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

class MedDetailsPage extends StatelessWidget {
  const MedDetailsPage({Key? key, required this.drug}) : super(key: key);
  final Drug drug;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(drug.proprietaryName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: [
          Container(
              //color: Colors.blue[600],
              width: 500,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: RichText(
                text: TextSpan(
                    style: const TextStyle(fontSize: 15, color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                        text: "Substance Name: ",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: drug.substanceName,
                      )
                    ]),
              )),
          Container(
            //left empty for padding
            width: 500,
            height: 2,
            //padding: const EdgeInsets.symmetric(vertical: 100),
            color: Colors.grey[300],
            child: const Text(" "),
          ),
          // Container(
          //     width: 500,
          //     padding: const EdgeInsets.symmetric(vertical: 10),
          //     // color: Colors.pink[600],
          //     //padding: EdgeInsets.only(top: 150, bottom: 150),
          //     child: Text("NonProprietary Name: " + drug.nonproprietaryName)),
          // Container(
          //   //Left empty for padding
          //   width: 500,
          //   height: 2,
          //   color: Colors.grey[300],
          //   child: const Text(" "),
          // ),
          Container(
              //color: Colors.red[600],
              width: 500,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: RichText(
                text: TextSpan(
                    style: const TextStyle(fontSize: 15, color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                        text: "NDC Number: ",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: drug.prodNDC,
                      )
                    ]),
              )),
          Container(
            //Left empty for padding
            width: 500,
            height: 2,
            color: Colors.grey[300],
            child: const Text(" "),
          ),
          Container(
              //color: Colors.red[600],
              width: 500,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: RichText(
                text: TextSpan(
                    style: const TextStyle(fontSize: 15, color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                        text: "Dosage Form Name: ",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: drug.dosageFormName,
                      )
                    ]),
              )),
          Container(
            //Left empty for padding
            width: 500,
            height: 2,
            color: Colors.grey[300],
            child: const Text(" "),
          ),
          Container(
              //color: Colors.red[600],
              width: 500,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: RichText(
                text: TextSpan(
                    style: const TextStyle(fontSize: 15, color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                        text: "Route: ",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: drug.routeName,
                      )
                    ]),
              )),
        ]
            //     child: ElevatedButton.icon(
            //   icon: const Icon(Icons.arrow_back_ios_new),
            //   label: Text('Back'),
            //   onPressed: () {
            //     Navigator.pop(context);
            //   },
            // )
            ),
      ),
    );
  }
}
