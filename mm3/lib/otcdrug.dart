class OTCDrugFields {
  static final List<String?> values = [
    id.toString(),
    name,
    recAmount.toString(), //recommended Amount
    unit,
    recTime.toString(),
    recTimeType,
    details,
    substanceName,
    pinned.toString()
  ];
  static final int? id = 0;
  static final String name = 'name';
  static final int recAmount = 0;
  static final String unit = ''; //ml, tablets?
  static final int recTime = 0; //amount of hours/days, etc.
  static final String recTimeType = ''; //hours/days/weeks, etc.
  static final String? details = '';
  static final String? substanceName = 'SubstanceName'; //multi-valued
  static final bool pinned = false;
}

class OTCDrug {
  final int? id;
  String name;
  int recAmount;
  String unit; //ml, tablets?
  int recTime; //amount of hours/days, etc.
  String recTimeType; //hours/days/weeks, etc.
  String? details;
  final String? substanceName; //multi-valued
  bool pinned;

  OTCDrug(
      {this.id,
      required this.name,
      required this.recAmount,
      required this.unit,
      required this.recTime,
      required this.recTimeType,
      this.details,
      this.substanceName,
      required this.pinned});
}
