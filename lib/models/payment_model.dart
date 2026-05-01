enum PaymentMethod { cash, qris }

class Payment {
  final String orderNumber;
  final PaymentMethod paymentMethod;
  final double amount;
  final double? cashAmount;
  final double? changeAmount;
  final String status;

  const Payment({
    required this.orderNumber,
    required this.paymentMethod,
    required this.amount,
    this.cashAmount,
    this.changeAmount,
    required this.status,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      orderNumber: json['orderNumber'] as String,
      paymentMethod: _parseMethod(json['paymentMethod'] as String?),
      amount: (json['amount'] as num).toDouble(),
      cashAmount: json['cashAmount'] != null
          ? (json['cashAmount'] as num).toDouble()
          : null,
      changeAmount: json['changeAmount'] != null
          ? (json['changeAmount'] as num).toDouble()
          : null,
      status: json['status'] as String? ?? '',
    );
  }

  static PaymentMethod _parseMethod(String? value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.name.toUpperCase() == value,
      orElse: () => PaymentMethod.cash,
    );
  }
}
