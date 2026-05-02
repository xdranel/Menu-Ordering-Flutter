import 'package:dio/dio.dart';
import 'package:menu_ordering_flutter/core/api_client.dart';
import 'package:menu_ordering_flutter/models/api_response.dart';
import 'package:menu_ordering_flutter/models/cart_item_model.dart';
import 'package:menu_ordering_flutter/models/order_model.dart';

class OrderService {
  final Dio _dio = ApiClient.instance;

  Future<Order> createOrder({
    required String customerName,
    required List<CartItem> items,
  }) async {
    try {
      final body = {
        'orderType': 'CUSTOMER_SELF',
        'customerName': customerName,
        'items': items
            .map((item) => {
                  'menuId': item.menuItem.id,
                  'quantity': item.quantity,
                })
            .toList(),
      };

      final response = await _dio.post('/customer/api/orders', data: body);
      final wrapped = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => Order.fromJson(data as Map<String, dynamic>),
      );
      return wrapped.data!;
    } on DioException catch (e) {
      throw e.error is Exception ? e.error as Exception : e;
    }
  }

  Future<Order> getOrder(String orderNumber) async {
    try {
      final response = await _dio.get('/customer/api/orders/$orderNumber');
      final wrapped = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => Order.fromJson(data as Map<String, dynamic>),
      );
      return wrapped.data!;
    } on DioException catch (e) {
      throw e.error is Exception ? e.error as Exception : e;
    }
  }
}
