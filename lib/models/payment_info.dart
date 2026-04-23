class PaymentInfo {
  final double amount;
  final String senderName;
  final String appName;
  final DateTime timestamp;
  final String rawText;
  final String? transactionId;

  PaymentInfo({
    required this.amount,
    required this.senderName,
    required this.appName,
    required this.timestamp,
    required this.rawText,
    this.transactionId,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'senderName': senderName,
      'appName': appName,
      'timestamp': timestamp.toIso8601String(),
      'rawText': rawText,
      'transactionId': transactionId,
    };
  }

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      amount: json['amount']?.toDouble() ?? 0.0,
      senderName: json['senderName'] ?? 'Unknown',
      appName: json['appName'] ?? 'Unknown App',
      timestamp: DateTime.parse(json['timestamp']),
      rawText: json['rawText'] ?? '',
      transactionId: json['transactionId'],
    );
  }
}
