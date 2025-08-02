class QrData {
  late double amount;
  late DateTime expired;
  late String token;
  late String? passKey;
  QrData({required this.amount, required this.expired, required this.token, required this.passKey});

  @override
  String toString() {
    return 'QrData(amount: $amount, expired: $expired, token: $token, passKey: $passKey)';
  }
}
