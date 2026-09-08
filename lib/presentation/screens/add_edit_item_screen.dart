import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/durable_good_attributes.dart';
import '../../models/grocery_attributes.dart';
import '../../models/inventory_item.dart';
import '../../models/item_category.dart';
import '../../providers/item_providers.dart';

/// Add/edit form for an inventory item. Scheme-agnostic — data entry, not
/// game aesthetic — so every inventory scheme reuses this same screen.
class AddEditItemScreen extends ConsumerStatefulWidget {
  const AddEditItemScreen({super.key, this.existingItem});

  final InventoryItem? existingItem;

  @override
  ConsumerState<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends ConsumerState<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateFormat = DateFormat.yMMMd();

  late ItemCategory _category;
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _expirationDate;
  bool _perishable = false;
  final _unitOfMeasureController = TextEditingController();
  final _lowStockThresholdController = TextEditingController();

  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _serialNumberController = TextEditingController();
  DateTime? _purchaseDate;
  DateTime? _warrantyExpiration;
  final _warrantyProviderController = TextEditingController();
  final _conditionController = TextEditingController();

  bool get _isEditing => widget.existingItem != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingItem;
    _category = existing?.category ?? ItemCategory.grocery;
    _nameController.text = existing?.name ?? '';
    _quantityController.text = '${existing?.quantity ?? 1}';
    _locationController.text = existing?.location ?? '';
    _notesController.text = existing?.notes ?? '';

    final grocery = existing?.groceryAttributes;
    _expirationDate = grocery?.expirationDate;
    _perishable = grocery?.perishable ?? false;
    _unitOfMeasureController.text = grocery?.unitOfMeasure ?? '';
    _lowStockThresholdController.text =
        grocery?.lowStockThreshold?.toString() ?? '';

    final durable = existing?.durableGoodAttributes;
    _brandController.text = durable?.brand ?? '';
    _modelController.text = durable?.model ?? '';
    _serialNumberController.text = durable?.serialNumber ?? '';
    _purchaseDate = durable?.purchaseDate;
    _warrantyExpiration = durable?.warrantyExpiration;
    _warrantyProviderController.text = durable?.warrantyProvider ?? '';
    _conditionController.text = durable?.condition ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _unitOfMeasureController.dispose();
    _lowStockThresholdController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _serialNumberController.dispose();
    _warrantyProviderController.dispose();
    _conditionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(
    DateTime? initial,
    ValueChanged<DateTime> onPicked,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) onPicked(picked);
  }

  String? _emptyToNull(String value) =>
      value.trim().isEmpty ? null : value.trim();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final quantity = int.parse(_quantityController.text.trim());
    final location = _emptyToNull(_locationController.text);
    final notes = _emptyToNull(_notesController.text);

    final groceryAttributes = _category == ItemCategory.grocery
        ? GroceryAttributes(
            expirationDate: _expirationDate,
            perishable: _perishable,
            unitOfMeasure: _emptyToNull(_unitOfMeasureController.text),
            lowStockThreshold: int.tryParse(
              _lowStockThresholdController.text.trim(),
            ),
          )
        : null;

    final durableGoodAttributes = _category != ItemCategory.grocery
        ? DurableGoodAttributes(
            brand: _emptyToNull(_brandController.text),
            model: _emptyToNull(_modelController.text),
            serialNumber: _emptyToNull(_serialNumberController.text),
            purchaseDate: _purchaseDate,
            warrantyExpiration: _warrantyExpiration,
            warrantyProvider: _emptyToNull(_warrantyProviderController.text),
            condition: _emptyToNull(_conditionController.text),
          )
        : null;

    final notifier = ref.read(itemsNotifierProvider.notifier);

    if (_isEditing) {
      await notifier.updateItem(
        widget.existingItem!.copyWith(
          name: _nameController.text.trim(),
          quantity: quantity,
          location: location,
          notes: notes,
          clearLocation: location == null,
          clearNotes: notes == null,
          groceryAttributes: groceryAttributes,
          durableGoodAttributes: durableGoodAttributes,
        ),
      );
    } else {
      await notifier.addItem(
        InventoryItem.draft(
          category: _category,
          name: _nameController.text.trim(),
          quantity: quantity,
          location: location,
          notes: notes,
          groceryAttributes: groceryAttributes,
          durableGoodAttributes: durableGoodAttributes,
        ),
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Item' : 'Add Item')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<ItemCategory>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: ItemCategory.values
                  .map(
                    (c) =>
                        DropdownMenuItem(value: c, child: Text(c.displayName)),
                  )
                  .toList(),
              onChanged: _isEditing
                  ? null
                  : (value) => setState(() => _category = value ?? _category),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Name is required'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
              validator: (value) {
                final n = int.tryParse((value ?? '').trim());
                if (n == null || n < 0) return 'Enter a valid quantity';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location (optional)',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            if (_category == ItemCategory.grocery)
              ..._groceryFields()
            else
              ..._durableGoodFields(),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              child: Text(_isEditing ? 'Save Changes' : 'Add Item'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _groceryFields() {
    return [
      Text('Grocery details', style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 8),
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          _expirationDate == null
              ? 'No expiration date'
              : 'Expires ${_dateFormat.format(_expirationDate!)}',
        ),
        trailing: const Icon(Icons.calendar_today),
        onTap: () => _pickDate(
          _expirationDate,
          (d) => setState(() => _expirationDate = d),
        ),
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Perishable'),
        value: _perishable,
        onChanged: (value) => setState(() => _perishable = value),
      ),
      TextFormField(
        controller: _unitOfMeasureController,
        decoration: const InputDecoration(
          labelText: 'Unit of measure (optional)',
        ),
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _lowStockThresholdController,
        decoration: const InputDecoration(
          labelText: 'Low stock threshold (optional)',
        ),
        keyboardType: TextInputType.number,
      ),
    ];
  }

  List<Widget> _durableGoodFields() {
    return [
      Text('Item details', style: Theme.of(context).textTheme.titleSmall),
      const SizedBox(height: 8),
      TextFormField(
        controller: _brandController,
        decoration: const InputDecoration(labelText: 'Brand (optional)'),
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _modelController,
        decoration: const InputDecoration(labelText: 'Model (optional)'),
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _serialNumberController,
        decoration: const InputDecoration(
          labelText: 'Serial number (optional)',
        ),
      ),
      const SizedBox(height: 12),
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          _purchaseDate == null
              ? 'No purchase date'
              : 'Purchased ${_dateFormat.format(_purchaseDate!)}',
        ),
        trailing: const Icon(Icons.calendar_today),
        onTap: () =>
            _pickDate(_purchaseDate, (d) => setState(() => _purchaseDate = d)),
      ),
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          _warrantyExpiration == null
              ? 'No warranty on file'
              : 'Warranty until ${_dateFormat.format(_warrantyExpiration!)}',
        ),
        trailing: const Icon(Icons.calendar_today),
        onTap: () => _pickDate(
          _warrantyExpiration,
          (d) => setState(() => _warrantyExpiration = d),
        ),
      ),
      TextFormField(
        controller: _warrantyProviderController,
        decoration: const InputDecoration(
          labelText: 'Warranty provider (optional)',
        ),
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _conditionController,
        decoration: const InputDecoration(labelText: 'Condition (optional)'),
      ),
    ];
  }
}
