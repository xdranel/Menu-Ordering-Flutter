import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:menu_ordering_flutter/core/constants.dart';
import 'package:menu_ordering_flutter/models/order_model.dart';
import 'package:menu_ordering_flutter/models/payment_model.dart';
import 'package:menu_ordering_flutter/providers/order_provider.dart';
import 'package:provider/provider.dart';

const Color _paymentPrimary = Color(0xFF9E3636);
const Color _paymentAccent = Color(0xFF963333);
const Color _paymentBackground = Color(0xFFF8F3F3);

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod _selectedMethod = PaymentMethod.cash;
  final TextEditingController _cashAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final order = context.read<OrderProvider>().currentOrder;
    if (order != null) {
      _cashAmountController.text = roundCashAmount(order.total).toString();
    }
  }

  @override
  void dispose() {
    _cashAmountController.dispose();
    super.dispose();
  }

  Future<void> _confirmPayment() async {
    final orderProvider = context.read<OrderProvider>();
    final order = orderProvider.currentOrder;

    if (order == null) {
      return;
    }

    double? cashAmount;
    if (_selectedMethod == PaymentMethod.cash) {
      final parsed = double.tryParse(
        _cashAmountController.text.replaceAll(RegExp(r'[^0-9]'), ''),
      );
      if (parsed == null || parsed < order.totalWithTax) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cash amount must cover the total payment'),
          ),
        );
        return;
      }
      cashAmount = parsed;
    }

    await orderProvider.submitPayment(
      orderNumber: order.orderNumber,
      method: _selectedMethod,
      cashAmount: cashAmount,
    );

    if (!mounted) {
      return;
    }

    if (orderProvider.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(orderProvider.error!)));
      return;
    }

    context.push('/order-tracking/${order.orderNumber}');
  }

  Future<void> _loadQrCode() async {
    await context.read<OrderProvider>().loadQrCode();
    if (!mounted) {
      return;
    }

    final error = context.read<OrderProvider>().error;
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, _) {
        final order = orderProvider.currentOrder;

        if (order == null) {
          return Scaffold(
            backgroundColor: _paymentBackground,
            appBar: AppBar(
              backgroundColor: _paymentPrimary,
              foregroundColor: Colors.white,
              title: const Text('Payment'),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.receipt_long_outlined,
                      size: 64,
                      color: _paymentPrimary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No active order found',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _paymentAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.go('/menu'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _paymentPrimary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Back to Menu'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: _paymentBackground,
          appBar: AppBar(
            backgroundColor: _paymentPrimary,
            foregroundColor: Colors.white,
            title: const Text('Payment'),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _OrderSummaryCard(order: order),
                const SizedBox(height: 16),
                Text(
                  'Choose Payment Method',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _paymentAccent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _MethodTile(
                  title: 'Cash',
                  subtitle: 'Pay directly with rounded cash suggestion',
                  icon: Icons.payments_outlined,
                  selected: _selectedMethod == PaymentMethod.cash,
                  onTap: () {
                    setState(() {
                      _selectedMethod = PaymentMethod.cash;
                    });
                  },
                ),
                const SizedBox(height: 12),
                _MethodTile(
                  title: 'QRIS',
                  subtitle: 'Display QR code from backend payment service',
                  icon: Icons.qr_code_2_rounded,
                  selected: _selectedMethod == PaymentMethod.qrCode,
                  onTap: () {
                    setState(() {
                      _selectedMethod = PaymentMethod.qrCode;
                    });
                    if (orderProvider.qrCodeBytes == null) {
                      _loadQrCode();
                    }
                  },
                ),
                const SizedBox(height: 16),
                if (_selectedMethod == PaymentMethod.cash)
                  _CashPaymentCard(
                    controller: _cashAmountController,
                    suggestedAmount: roundCashAmount(order.total),
                    totalWithTax: order.totalWithTax,
                  )
                else
                  _QrPaymentCard(
                    qrCodeBytes: orderProvider.qrCodeBytes,
                    isLoading:
                        orderProvider.isLoading &&
                        orderProvider.qrCodeBytes == null,
                    onReload: _loadQrCode,
                  ),
                const SizedBox(height: 16),
                Text(
                  _selectedMethod == PaymentMethod.cash
                      ? 'Cash amount is sent to the payment endpoint and should be at least the total payment.'
                      : 'This mobile client loads the QR image from the backend and confirms payment using the existing payment provider contract.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                ),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: ElevatedButton(
              onPressed: orderProvider.isLoading ? null : _confirmPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: _paymentPrimary,
                foregroundColor: Colors.white,
              ),
              child: orderProvider.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Confirm Payment'),
            ),
          ),
        );
      },
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order ${order.orderNumber}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: _paymentAccent,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            order.customerName,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          _PaymentRow(label: 'Items', value: '${order.items.length} item(s)'),
          const SizedBox(height: 8),
          _PaymentRow(label: 'Total', value: formatIDR(order.totalWithTax)),
        ],
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? _paymentPrimary
                  : _paymentAccent.withValues(alpha: 0.12),
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _paymentPrimary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: _paymentPrimary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: _paymentAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected ? _paymentPrimary : Colors.black38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CashPaymentCard extends StatelessWidget {
  const _CashPaymentCard({
    required this.controller,
    required this.suggestedAmount,
    required this.totalWithTax,
  });

  final TextEditingController controller;
  final int suggestedAmount;
  final double totalWithTax;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cash Payment',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: _paymentAccent,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Cash amount',
              hintText: suggestedAmount.toString(),
              helperText: 'Total due: ${formatIDR(totalWithTax)}',
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => controller.text = suggestedAmount.toString(),
            style: OutlinedButton.styleFrom(
              foregroundColor: _paymentPrimary,
              side: const BorderSide(color: _paymentPrimary),
            ),
            child: Text(
              'Use suggested ${formatIDR(suggestedAmount.toDouble())}',
            ),
          ),
        ],
      ),
    );
  }
}

class _QrPaymentCard extends StatelessWidget {
  const _QrPaymentCard({
    required this.qrCodeBytes,
    required this.isLoading,
    required this.onReload,
  });

  final Uint8List? qrCodeBytes;
  final bool isLoading;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'QRIS Payment',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: _paymentAccent,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (qrCodeBytes != null)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.memory(
                  qrCodeBytes!,
                  width: 220,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F1F1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.qr_code_rounded,
                    size: 48,
                    color: _paymentPrimary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'QR code is not loaded yet.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onReload,
            style: OutlinedButton.styleFrom(
              foregroundColor: _paymentPrimary,
              side: const BorderSide(color: _paymentPrimary),
            ),
            child: const Text('Reload QR'),
          ),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: _paymentAccent,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
