import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/inventory_item.dart';
import '../../providers/item_providers.dart';
import 'add_edit_item_screen.dart';

InventoryItem? _findItem(List<InventoryItem> items, String id) {
  for (final item in items) {
    if (item.id == id) return item;
  }
  return null;
}

class ItemDetailScreen extends ConsumerWidget {
  const ItemDetailScreen({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itemListProvider);

    return itemsAsync.when(
      data: (items) {
        final item = _findItem(items, itemId);
        if (item == null) {
          // Deleted elsewhere — pop back to the list automatically.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.of(context).canPop()) Navigator.of(context).pop();
          });
          return const Scaffold(body: SizedBox.shrink());
        }
        return _ItemDetailBody(item: item);
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) =>
          Scaffold(body: Center(child: Text('Failed to load item: $error'))),
    );
  }
}

class _ItemDetailBody extends ConsumerWidget {
  const _ItemDetailBody({required this.item});

  final InventoryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat.yMMMd();

    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AddEditItemScreen(existingItem: item),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DetailRow(label: 'Category', value: item.category.displayName),
          _DetailRow(label: 'Quantity', value: '${item.quantity}'),
          if (item.location != null && item.location!.isNotEmpty)
            _DetailRow(label: 'Location', value: item.location!),
          if (item.groceryAttributes case final attrs?) ...[
            if (attrs.expirationDate != null)
              _DetailRow(
                label: 'Expires',
                value: dateFormat.format(attrs.expirationDate!),
              ),
            _DetailRow(
              label: 'Perishable',
              value: attrs.perishable ? 'Yes' : 'No',
            ),
            if (attrs.unitOfMeasure != null && attrs.unitOfMeasure!.isNotEmpty)
              _DetailRow(label: 'Unit', value: attrs.unitOfMeasure!),
            if (attrs.lowStockThreshold != null)
              _DetailRow(
                label: 'Low stock at',
                value: '${attrs.lowStockThreshold}',
              ),
          ],
          if (item.durableGoodAttributes case final attrs?) ...[
            if (attrs.brand != null && attrs.brand!.isNotEmpty)
              _DetailRow(label: 'Brand', value: attrs.brand!),
            if (attrs.model != null && attrs.model!.isNotEmpty)
              _DetailRow(label: 'Model', value: attrs.model!),
            if (attrs.serialNumber != null && attrs.serialNumber!.isNotEmpty)
              _DetailRow(label: 'Serial #', value: attrs.serialNumber!),
            if (attrs.purchaseDate != null)
              _DetailRow(
                label: 'Purchased',
                value: dateFormat.format(attrs.purchaseDate!),
              ),
            if (attrs.warrantyExpiration != null)
              _DetailRow(
                label: 'Warranty until',
                value: dateFormat.format(attrs.warrantyExpiration!),
              ),
            if (attrs.condition != null && attrs.condition!.isNotEmpty)
              _DetailRow(label: 'Condition', value: attrs.condition!),
          ],
          if (item.notes != null && item.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Notes', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(item.notes!),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete item?'),
        content: Text('Remove "${item.name}" from your inventory?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(itemsNotifierProvider.notifier).deleteItem(item.id);
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
