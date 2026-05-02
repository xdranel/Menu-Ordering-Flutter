import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:menu_ordering_flutter/models/cart_item_model.dart';
import 'package:menu_ordering_flutter/models/order_model.dart';
import 'package:menu_ordering_flutter/models/payment_model.dart';
import 'package:menu_ordering_flutter/services/order_service.dart';
import 'package:menu_ordering_flutter/services/payment_service.dart';

class OrderProvider extends ChangeNotifier {
  final _orderService = OrderService();
  final _paymentService = PaymentService();

  Order? currentOrder;
  Uint8List? qrCodeBytes;
  bool isLoading = false;
  String? error;

  Timer? _pollingTimer;

  bool get isPolling => _pollingTimer?.isActive ?? false;

  Future<void> placeOrder({
    required String customerName,
    required String tableNumber,
    String? notes,
    required List<CartItem> items,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      currentOrder = await _orderService.createOrder(
        customerName: customerName,
        tableNumber: tableNumber,
        notes: notes,
        items: items,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitPayment({
    required String orderNumber,
    required PaymentMethod method,
    double? cashAmount,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _paymentService.submitPayment(
        orderNumber: orderNumber,
        method: method,
        cashAmount: cashAmount,
      );
      // Refresh order so paymentStatus reflects the change immediately.
      currentOrder = await _orderService.getOrder(orderNumber);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadQrCode() async {
    final orderNumber = currentOrder?.orderNumber;
    if (orderNumber == null) return;
    try {
      qrCodeBytes = await _paymentService.getQrCode(orderNumber);
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  void startPolling() {
    stopPolling();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final orderNumber = currentOrder?.orderNumber;
      if (orderNumber == null) return;
      try {
        currentOrder = await _orderService.getOrder(orderNumber);
        notifyListeners();
        // Stop once the order reaches a terminal state.
        if (currentOrder!.status == OrderStatus.completed ||
            currentOrder!.status == OrderStatus.cancelled) {
          stopPolling();
        }
      } catch (_) {
        // Polling errors are silent — keep trying until terminal state.
      }
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  // Call this when the user starts a new order after completion.
  void reset() {
    stopPolling();
    currentOrder = null;
    qrCodeBytes = null;
    error = null;
    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
