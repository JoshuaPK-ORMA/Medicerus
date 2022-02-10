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
import 'package:drift/drift.dart';
import 'package:provider/provider.dart';

import '../../data/drift_database.dart';

class AddMedviewItemInput extends StatefulWidget {
  const AddMedviewItemInput({
    Key? key,
  }) : super(key: key);

  @override
  _AddMedviewItemInputState createState() => _AddMedviewItemInputState();
}

class _AddMedviewItemInputState extends State<AddMedviewItemInput> {
  DateTime listEntryDate = DateTime.now();
  // JPK TODO: is 'late' correct here?
  late Medication selectedMed;
  late TextEditingController controller;

  //var mvItems = List.generate();

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _buildTextField(context),
          //_buildTagSelector(context),
          //_buildNdcList(context),
          _buildGoButton(context),
        ],
      ),
    );
  }

  Expanded _buildTextField(BuildContext context) {
    return Expanded(
      flex: 1,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
            hintText: 'NDC Number',
            labelText: 'NDC Number',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0)))),
        onSubmitted: (inputNDC) {
          // JPK This is how the thing gets back to the main list
          //final dao = Provider.of<MedicationsDao>(context);
          final medDao = Provider.of<MedicationsDao>(context);
          final ndcDao = Provider.of<NdcDao>(context);
          //final medication = MedicationsCompanion(
          //final ndcProduct = NdcProductsCompanion(
          //  product_ndc: Value(inputNDC),
          //);
          final ndcProduct = ndcDao.getMedicationByNdc(inputNDC);
          // The slider panel inserts the task, then Moor, which is watching
          // the database, will display it.

          final medication = ndcProduct as Medication;

          medDao.insertMedication(medication);
          resetValuesAfterSubmit();
        },
      ),
    );
  }

  // JPK #LearningFlutter
  // See this link: https://blog.usejournal.com/flutter-search-in-listview-1ffa40956685

  /*ListView _buildNdcList(BuildContext context) {

    String product_name = NdcProduct.

    return (ListView(
    itemCount: mvItems.length,
    itemBuilder: (context, index) {
    return ListTile(
        title: Text('${mvItems[index]}'),
    );
    });

  }*/

  IconButton _buildGoButton(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_forward),
      onPressed:
          () {}, /*async {
        newTaskDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2010),
          lastDate: DateTime(2050), */
    );
  }

  void resetValuesAfterSubmit() {
    //setState(() {
    //  newTaskDate = null;
    //  selectedTag = null;
    //  controller.clear();
    //});
  }
}