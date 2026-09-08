import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/inventory_item.dart';
import '../../providers/item_providers.dart';
import 'add_edit_item_screen.dart';
import 'item_detail_screen.dart';

/// Plain, scheme-agnostic item list. Phase 2 replaces this with
/// `activeScheme.buildHomeScreen()`; this screen exists to prove the data
/// layer works before any theming is built.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itemListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      body: itemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No items yet. Tap + to add one.'));
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) => _ItemTile(item: items[index]),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Failed to load items: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AddEditItemScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.item});

  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    final subtitleParts = <String>[
      item.category.displayName,
      'Qty ${item.quantity}',
      if (item.location != null && item.location!.isNotEmpty) item.location!,
    ];

    return ListTile(
      title: Text(item.name),
      subtitle: Text(subtitleParts.join(' • ')),
      trailing: _StatusIcon(item: item),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ItemDetailScreen(itemId: item.id)),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.item});

  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    if (item.isExpired) {
      return const Icon(Icons.error, color: Colors.red);
    }
    if (item.isExpiringSoon()) {
      return const Icon(Icons.warning_amber, color: Colors.orange);
    }
    if (item.isLowStock) {
      return const Icon(
        Icons.production_quantity_limits,
        color: Colors.blueGrey,
      );
    }
    return const SizedBox.shrink();
  }
}
