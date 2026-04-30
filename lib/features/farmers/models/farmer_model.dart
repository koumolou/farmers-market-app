class FarmerModel {
  final int id;
  final String identifier;
  final String firstname;
  final String lastname;
  final String phone;
  final double creditLimit;

  FarmerModel({
    required this.id,
    required this.identifier,
    required this.firstname,
    required this.lastname,
    required this.phone,
    required this.creditLimit,
  });

  String get fullName => '$firstname $lastname';

  factory FarmerModel.fromJson(Map<String, dynamic> json) => FarmerModel(
    id: json['id'],
    identifier: json['identifier'],
    firstname: json['firstname'],
    lastname: json['lastname'],
    phone: json['phone'],
    creditLimit: double.parse(json['credit_limit'].toString()),
  );
}
