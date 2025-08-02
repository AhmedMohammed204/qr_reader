import 'package:qr_reader/data/models/qr_data.dart';

class ScannedQrDTO {
  final QrData qr;
  final bool isValid;

  ScannedQrDTO({required this.qr, required this.isValid});
}

class QrDTO {
  int id;
  double amount;
  DateTime expiresAt;
  bool isActive;
  String passKey;
  DateTime createdAt;
  QrDTO({
    required this.id,
    required this.amount,
    required this.expiresAt,
    this.isActive = true,
    required this.passKey,
    required this.createdAt,
  });

  factory QrDTO.fromJson(Map<String, dynamic> json) {
    return QrDTO(
      id: json['id'] as int? ?? 0,
      amount: (json['amount'] as num).toDouble(),
      expiresAt: DateTime.parse(json['expiresAt']),
      isActive: json['isActive'] ?? true,
      passKey: json['passKey'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
