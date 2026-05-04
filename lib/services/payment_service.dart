import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:menu_ordering_flutter/core/api_client.dart';
import 'package:menu_ordering_flutter/models/api_response.dart';
import 'package:menu_ordering_flutter/models/payment_model.dart';

class PaymentService {
  final Dio _dio = ApiClient.instance;

  Future<void> submitPayment({
    required String orderNumber,
    required PaymentMethod method,
    double? cashAmount,
  }) async {
    try {
      final body = {
        'orderNumber': orderNumber,
        'paymentMethod': method.toApiString,
        if (cashAmount != null) 'cashAmount': cashAmount,
      };

      await _dio.post('/customer/api/payments', data: body);
    } on DioException catch (e) {
      throw e.error is Exception ? e.error as Exception : e;
    }
  }

  Future<Uint8List> getQrCode(String orderNumber) async {
    try {
      final response = await _dio.get(
        '/customer/api/orders/$orderNumber/qr-code',
      );
      final wrapped = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => (data as Map<String, dynamic>)['qrCodeImage'] as String?,
      );

      final raw = wrapped.data ?? '';
      const prefix = 'data:image/png;base64,';
      final encoded = raw.startsWith(prefix)
          ? raw.substring(prefix.length)
          : raw;
      return base64Decode(encoded);
    } on DioException catch (e) {
      throw e.error is Exception ? e.error as Exception : e;
    }
  }
}
