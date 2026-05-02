enum PaymentMethod {
  cash,
  qrCode;

  String get toApiString {
    switch (this) {
      case PaymentMethod.cash:
        return 'CASH';
      case PaymentMethod.qrCode:
        return 'QR_CODE';
    }
  }
}
