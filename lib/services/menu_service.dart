import 'package:dio/dio.dart';
import 'package:menu_ordering_flutter/core/api_client.dart';
import 'package:menu_ordering_flutter/models/api_response.dart';
import 'package:menu_ordering_flutter/models/category_model.dart';
import 'package:menu_ordering_flutter/models/menu_model.dart';

class MenuService {
  final Dio _dio = ApiClient.instance;

  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('/cashier/api/categories');
      final wrapped = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => (data as List<dynamic>)
            .map((e) => Category.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      return wrapped.data ?? [];
    } on DioException catch (e) {
      throw e.error is Exception ? e.error as Exception : e;
    }
  }

  Future<List<MenuItem>> getMenuItems({int? categoryId}) async {
    try {
      final response = await _dio.get(
        '/customer/api/menu',
        queryParameters: categoryId != null ? {'categoryId': categoryId} : null,
      );
      final wrapped = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => (data as List<dynamic>)
            .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      return wrapped.data ?? [];
    } on DioException catch (e) {
      throw e.error is Exception ? e.error as Exception : e;
    }
  }
}
