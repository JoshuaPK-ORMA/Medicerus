import 'package:flutter/material.dart';
import '../drug.dart';
import '../main.dart';
import '../otcdrug.dart';
import '../userDbHelper.dart';
import 'mv_page.dart';

class OTCFormPage extends StatefulWidget {
  const OTCFormPage({Key? key, this.drug}) : super(key: key);
  final Drug? drug;

  @override
  OTCFormPageState createState() {
    return OTCFormPageState();
  }
}

class OTCFormPageState extends State<OTCFormPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  final timeController = TextEditingController();
  final detailsController = TextEditingController();
  final userdbHelper = UserDatabaseHelper.instance;
  String unitDropdown = 'tablet';
  String timetypeDropdown = 'hours';

  Widget buildForm(OTCDrug otcDrug, bool nullDrug) {
    Widget nameField;
    if (nullDrug) {
      nameField = TextFormField(
        controller: nameController,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.all(20.0),
          labelText: 'Name of drug',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a name';
          }
          return null;
        },
      );
    } else {
      nameField = Container();
    }
    return Form(
      key: _formKey,
      child: Container(
          margin: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              nameField,
              const SizedBox(height: 8.0),
              TextFormField(
                autofocus: true,
                controller: amountController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(20.0),
                  labelText: 'Enter the recommended dosage amount',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8.0),
              const Text('Please choose the drug unit:'),
              Container(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                child: DropdownButtonFormField<String>(
                  value: unitDropdown,
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
                      unitDropdown = newValue!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: timeController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(20.0),
                  labelText: 'Enter the recommended interval time:',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a time';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8.0),
              const Text('Please choose a time type:'),
              Container(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                child: DropdownButtonFormField<String>(
                  value: timetypeDropdown,
                  icon: const Icon(Icons.arrow_drop_down),
                  items: <String>['hours', 'days']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      timetypeDropdown = newValue!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: detailsController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(20.0),
                  labelText: 'Enter any warnings or details (optional)',
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
                                      'Added Over the Counter Drug to Medview Tab')),
                            );
                            if (nullDrug) {
                              otcDrug.name = nameController.text;
                            }
                            otcDrug.recAmount =
                                int.parse(amountController.text);
                            otcDrug.unit = unitDropdown;
                            otcDrug.recTime = int.parse(timeController.text);
                            otcDrug.recTimeType = timetypeDropdown;
                            otcDrug.details = detailsController.text;
                            userdbHelper.insertOrUpdateOTCDrug(otcDrug);
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        MyHomePage(selectedPage: 1)),
                                (route) => false);
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Over the Counter Drug'))),
              ),
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    String drugName = '';
    Widget nameWidget;
    bool nullDrug = (widget.drug == null);
    print(nullDrug);
    if (nullDrug) {
      nameWidget = Container();
    } else {
      drugName = widget.drug!.proprietaryName;
      nameWidget = Text(
        widget.drug!.proprietaryName,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    OTCDrug otcDrug = OTCDrug(
        name: drugName,
        recAmount: 0,
        unit: '',
        recTime: 0,
        recTimeType: '',
        details: '',
        pinned: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Over the Counter Medication'),
      ),
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          nameWidget,
          buildForm(otcDrug, nullDrug),
        ],
      ),
    );
  }
}
