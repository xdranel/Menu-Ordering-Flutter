import 'package:flutter/material.dart';
import 'package:menu_ordering_flutter/models/category_model.dart';
import 'package:menu_ordering_flutter/models/menu_model.dart';
import 'package:menu_ordering_flutter/services/menu_service.dart';

class MenuProvider extends ChangeNotifier {
  final _service = MenuService();

  List<Category> categories = [];
  List<MenuItem> menuItems = [];
  int? selectedCategoryId; // null = All
  bool isLoading = false;
  String? error;

  // Server-side filtering — menuItems already reflects the selected category.
  List<MenuItem> get filteredItems => menuItems;

  // Called once on screen init — loads both categories and items together.
  Future<void> loadAll() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final allCategories = await _service.getCategories();
      // "SEMUA" is a backend display-only category with no items; the app's
      // own "All" chip (null id) already covers it.
      categories = allCategories
          .where((c) => c.name.toUpperCase() != 'SEMUA')
          .toList();
      menuItems = await _service.getMenuItems();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Called when user taps a category chip — re-fetches with server-side filter.
  void selectCategory(int? id) {
    if (selectedCategoryId == id) return;
    selectedCategoryId = id;
    _loadMenuItems(categoryId: id);
  }

  Future<void> _loadMenuItems({int? categoryId}) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      menuItems = await _service.getMenuItems(categoryId: categoryId);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Retry after error — also resets any active category filter.
  Future<void> retry() {
    selectedCategoryId = null;
    return loadAll();
  }
}
