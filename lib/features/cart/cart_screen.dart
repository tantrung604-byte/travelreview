import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';
import 'cart_providers.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final items = ref.watch(cartControllerProvider);
    final total = ref.watch(cartTotalProvider);
    final controller = ref.read(cartControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giá» hÃ ng'),
        actions: [
          if (items.isNotEmpty)
            TextButton.icon(
              onPressed: () => _confirmClear(context, controller),
              icon: const Icon(Icons.delete_sweep_outlined),
              label: const Text('XoÃ¡ háº¿t'),
            ),
        ],
      ),
      body: items.isEmpty
          ? _EmptyCart()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final item = items[i];
                return _CartTile(
                  item: item,
                  onQty: (q) => controller.setQuantity(item.tourId, q),
                  onRemove: () => controller.remove(item.tourId),
                  onDate: (d) => controller.setDeparture(item.tourId, d),
                );
              },
            ),
      bottomNavigationBar: items.isEmpty
          ? null
          : SafeArea(
              minimum: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text('Tá»•ng cá»™ng',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      const Spacer(),
                      Text(
                        formatVnd(total),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: () => context.goNamed(AppRouteNames.checkout),
                      icon: const Icon(Icons.payment),
                      label: const Text('Tiáº¿n hÃ nh thanh toÃ¡n'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _confirmClear(BuildContext context, CartController c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('XoÃ¡ giá» hÃ ng?'),
        content: const Text('HÃ nh Ä‘á»™ng nÃ y khÃ´ng thá»ƒ hoÃ n tÃ¡c.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Huá»·')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('XoÃ¡')),
        ],
      ),
    );
    if (ok == true) c.clear();
  }
}

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 12),
            Text('Giá» hÃ ng trá»‘ng', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text('KhÃ¡m phÃ¡ tour vÃ  thÃªm vÃ o giá» Ä‘á»ƒ báº¯t Ä‘áº§u chuyáº¿n Ä‘i.',
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.goNamed(AppRouteNames.discover),
              icon: const Icon(Icons.explore_outlined),
              label: const Text('KhÃ¡m phÃ¡ tour'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartTile extends StatelessWidget {
  const _CartTile({
    required this.item,
    required this.onQty,
    required this.onRemove,
    required this.onDate,
  });

  final CartItem item;
  final ValueChanged<int> onQty;
  final VoidCallback onRemove;
  final ValueChanged<DateTime> onDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 84, height: 84,
                child: item.imageUrl.isNotEmpty
                    ? Image.network(item.imageUrl, fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _placeholder(theme))
                    : _placeholder(theme),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(formatVnd(item.priceVnd),
                      style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: now,
                        lastDate: now.add(const Duration(days: 365)),
                        initialDate: item.departureDate ?? now.add(const Duration(days: 7)),
                      );
                      if (picked != null) onDate(picked);
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.event, size: 16),
                        const SizedBox(width: 4),
                        Text(item.departureDate != null
                            ? '${item.departureDate!.day}/${item.departureDate!.month}/${item.departureDate!.year}'
                            : 'Chá»n ngÃ y khá»Ÿi hÃ nh'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _QtyButton(icon: Icons.remove, onTap: () => onQty(item.quantity - 1)),
                      Container(
                        width: 36,
                        alignment: Alignment.center,
                        child: Text('${item.quantity}',
                            style: const TextStyle(fontWeight: FontWeight.w800)),
                      ),
                      _QtyButton(icon: Icons.add, onTap: () => onQty(item.quantity + 1)),
                      const Spacer(),
                      IconButton(
                        tooltip: 'XoÃ¡',
                        onPressed: onRemove,
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(ThemeData t) => Container(
        color: t.colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.image_outlined, color: Colors.grey),
      );
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18),
        ),
      ),
    );
  }
}

