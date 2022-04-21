import 'package:flutter/material.dart';
import '../drug.dart';
import '../prescription.dart';
import '../userDbHelper.dart';

class MedFormPage extends StatefulWidget {
  const MedFormPage({Key? key, this.drug}) : super(key: key);
  final Drug? drug;

  @override
  MedFormPageState createState() {
    return MedFormPageState();
  }
}

class MedFormPageState extends State<MedFormPage> {
  final _formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final unitController = TextEditingController();
  final daysupplyController = TextEditingController();
  final detailsController = TextEditingController();
  final userdbHelper = UserDatabaseHelper.instance;
  String dropdownValue = 'tablet';
  DateTime selectedDate = DateTime.now();

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
      helpText: 'Enter the date the prescription was filled',
      fieldLabelText: 'Date Prescription Filled',
      fieldHintText: 'MM/DD/YYYY',
      errorFormatText: 'Enter valid date',
      errorInvalidText: 'Enter date in valid range',
      initialEntryMode: DatePickerEntryMode.input,
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Widget buildForm(Prescription presc) {
    return Form(
      key: _formKey,
      child: Container(
          margin: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: amountController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(20.0),
                  labelText: 'Enter a usage amount',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8.0),
              const Text('Please choose a unit:'),
              Container(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                child: DropdownButtonFormField<String>(
                  value: dropdownValue,
                  icon: const Icon(Icons.arrow_drop_down),
                  items: <String>['tablet', 'mg', 'mL', 'fl oz']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownValue = newValue!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: daysupplyController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(20.0),
                  labelText: 'Enter the days supplied',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a number of days';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8.0),
              Center(
                  child: ElevatedButton(
                child: const Text('Select Date'),
                onPressed: () => _selectDate(context),
              )),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: detailsController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(20.0),
                  labelText: 'Enter any warnings or details',
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Added Prescription Medication to Medview Tab')),
                        );
                        presc.totalAmount = int.parse(amountController.text);
                        presc.unit = dropdownValue;
                        presc.daySupply = int.parse(daysupplyController.text);
                        presc.fillDate = selectedDate;
                        presc.details = detailsController.text;
                        userdbHelper.insertOrUpdatePrescription(presc);
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add Prescription"),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    Prescription prescDrug = Prescription(
        name: widget.drug!.proprietaryName,
        totalAmount: 0,
        unit: '',
        daySupply: 0,
        fillDate: DateTime.now(),
        details: '',
        pinned: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Prescription Medication'),
      ),
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Text(
            prescDrug.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          buildForm(prescDrug),
        ],
      ),
    );
  }
}
