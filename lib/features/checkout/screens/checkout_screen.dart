import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/cart_provider.dart';
import '../models/cart_model.dart';
import '../../farmers/providers/farmer_provider.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  static const _interestRate = 0.30;
  bool _loading = false;

  Future<void> _placeOrder() async {
    final farmer = ref.read(selectedFarmerProvider);
    if (farmer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a farmer first')),
      );
      context.go('/farmers');
      return;
    }

    final cartItems = ref.read(cartProvider);
    final paymentMethod = ref.read(paymentMethodProvider);

    setState(() => _loading = true);
    try {
      await DioClient.instance.post(
        ApiConstants.checkout,
        data: {
          'farmer_id': farmer.id,
          'payment_method': paymentMethod,
          'items': cartItems
              .map((i) => {'product_id': i.product.id, 'quantity': i.quantity})
              .toList(),
        },
      );

      ref.read(cartProvider.notifier).clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
        context.go('/farmers/${farmer.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final paymentMethod = ref.watch(paymentMethodProvider);
    final farmer = ref.watch(selectedFarmerProvider);
    final theme = Theme.of(context);

    final subtotal = cartItems.fold(0.0, (s, i) => s + i.subtotal);
    final interestAmt = paymentMethod == 'credit'
        ? subtotal * _interestRate
        : 0.0;
    final grandTotal = subtotal + interestAmt;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Farmer info
            if (farmer != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primary,
                      child: Text(
                        farmer.firstname[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          farmer.fullName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          farmer.identifier,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer
                                .withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // Order items
            Text(
              'Order items',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...cartItems.map((item) => _OrderItemRow(item: item)),
            const Divider(height: 28),

            // Payment method selector
            Text(
              'Payment method',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _PaymentOption(
                    label: 'Cash',
                    icon: Icons.payments_outlined,
                    selected: paymentMethod == 'cash',
                    onTap: () =>
                        ref.read(paymentMethodProvider.notifier).state = 'cash',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PaymentOption(
                    label: 'Credit',
                    icon: Icons.credit_card_outlined,
                    selected: paymentMethod == 'credit',
                    onTap: () =>
                        ref.read(paymentMethodProvider.notifier).state =
                            'credit',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Summary
            _SummaryRow(label: 'Subtotal', value: subtotal),
            if (paymentMethod == 'credit') ...[
              const SizedBox(height: 6),
              _SummaryRow(
                label: 'Interest (30%)',
                value: interestAmt,
                color: theme.colorScheme.error,
              ),
            ],
            const Divider(height: 20),
            _SummaryRow(label: 'Total', value: grandTotal, bold: true),
            const SizedBox(height: 28),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: (cartItems.isEmpty || _loading) ? null : _placeOrder,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Place Order — ${_fmt(grandTotal)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _OrderItemRow extends ConsumerWidget {
  final CartItem item;
  const _OrderItemRow({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.product.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            'x${item.quantity}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _fmt(item.subtotal),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _PaymentOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? theme.colorScheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool bold;
  final Color? color;
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      fontSize: bold ? 16 : 14,
      color: color,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(_fmt(value), style: style),
      ],
    );
  }
}

String _fmt(double v) =>
    '${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} FCFA';
