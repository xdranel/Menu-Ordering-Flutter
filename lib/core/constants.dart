import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

const double kTaxRate = 0.10;
const String kCurrencyLocale = 'id_ID';

String get kBaseUrl =>
    dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8080';

// Takes pre-tax total, applies 10% tax, then rounds up to nearest IDR 1,000.
int roundCashAmount(double preTaxTotal) =>
    ((preTaxTotal * (1 + kTaxRate)) / 1000).ceil() * 1000;

String formatIDR(double amount) {
  return NumberFormat.currency(
    locale: kCurrencyLocale,
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(amount);
}
