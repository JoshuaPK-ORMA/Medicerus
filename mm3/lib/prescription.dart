class PrescriptionFields {
  static final List<String?> values = [
    id.toString(),
    name,
    totalAmount.toString(),
    unit,
    daySupply.toString(),
    // reqAmountPerDay.toString(),
    rxNumber,
    fillDate.toString(),
    expDate.toString(),
    details,
    pharmPhoneNum,
    substanceName,
    pinned.toString(),
  ];
  static final int id = 0;
  static String name = 'name';
  static final int totalAmount = 0;
  static final String unit = ''; //ml, tablets?
  static final int daySupply = 0;
  // static final int reqAmountPerDay = 0;
  static final String? rxNumber = 'rxNum';
  static final DateTime fillDate = DateTime.now();
  static final DateTime? expDate = null;
  static final String? details = '';
  static final String? pharmPhoneNum = '';
  static final String? substanceName = 'SubstanceName'; //multi-valued
  static final bool pinned = false;
}

class Prescription {
  final int? id;
  String name;
  int totalAmount;
  String unit; //ml, tablets?
  int daySupply;
  // final int reqAmountPerDay;
  final String? rxNumber;
  DateTime fillDate;
  final DateTime? expDate;
  String? details;
  final String? pharmPhoneNum;
  final String? substanceName; //multi-valued
  bool pinned;

  Prescription({
    this.id,
    required this.name,
    required this.totalAmount,
    required this.unit,
    required this.daySupply,
    // required this.reqAmountPerDay,
    this.rxNumber,
    required this.fillDate,
    this.expDate,
    this.details,
    this.pharmPhoneNum,
    this.substanceName,
    required this.pinned,
  });
  @override
  operator ==(other) => other is Prescription && other.id == id;

  @override
  int get hashCode => (id != null) ? id! : 0;
}

// enum frequency {
//   twicedaily,
//   daily,
//   everyotherday,
// }
