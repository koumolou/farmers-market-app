class DebtModel {
  final int id;
  final double originalAmount;
  final double remainingAmount;
  final String status;
  final DateTime createdAt;

  DebtModel({
    required this.id,
    required this.originalAmount,
    required this.remainingAmount,
    required this.status,
    required this.createdAt,
  });

  factory DebtModel.fromJson(Map<String, dynamic> json) => DebtModel(
    id: json['id'],
    originalAmount: double.parse(json['original_amount'].toString()),
    remainingAmount: double.parse(json['remaining_amount'].toString()),
    status: json['status'],
    createdAt: DateTime.parse(json['created_at']),
  );
}
