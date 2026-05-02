import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:menu_ordering_flutter/core/api_client.dart';
import 'package:menu_ordering_flutter/models/api_response.dart';
import 'package:menu_ordering_flutter/models/payment_model.dart';

class PaymentService {
  final Dio _dio = ApiClient.instance;

  Future<Payment> submitPayment({
    required String orderNumber,
    required PaymentMethod method,
    double? cashAmount,
  }) async {
    try {
      final body = {
        'orderNumber': orderNumber,
        'paymentMethod': method.name.toUpperCase(),
        'cashAmount': ?cashAmount,
      };

      final response = await _dio.post('/customer/api/payments', data: body);
      final wrapped = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => Payment.fromJson(data as Map<String, dynamic>),
      );
      return wrapped.data!;
    } on DioException catch (e) {
      throw e.error is Exception ? e.error as Exception : e;
    }
  }

  // Response data is "data:image/png;base64,<encoded>" — strip prefix and decode.
  Future<Uint8List> getQrCode(String orderNumber) async {
    try {
      final response = await _dio
          .get('/customer/api/payments/qr-code/$orderNumber');
      final wrapped = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => data as String,
      );

      final raw = wrapped.data ?? '';
      const prefix = 'data:image/png;base64,';
      final encoded = raw.startsWith(prefix) ? raw.substring(prefix.length) : raw;
      return base64Decode(encoded);
    } on DioException catch (e) {
      throw e.error is Exception ? e.error as Exception : e;
    }
  }
}
