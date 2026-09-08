import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inventory_app/presentation/screens/add_edit_item_screen.dart';
import 'package:inventory_app/presentation/screens/home_screen.dart';
import 'package:inventory_app/providers/item_providers.dart';

import '../support/fake_item_repository.dart';

void main() {
  testWidgets('shows empty state when there are no items', (tester) async {
    final fakeRepository = FakeItemRepository();
    addTearDown(fakeRepository.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [itemRepositoryProvider.overrideWithValue(fakeRepository)],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('No items yet. Tap + to add one.'), findsOneWidget);
  });

  testWidgets('tapping + opens the add item form', (tester) async {
    final fakeRepository = FakeItemRepository();
    addTearDown(fakeRepository.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [itemRepositoryProvider.overrideWithValue(fakeRepository)],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.byType(AddEditItemScreen), findsOneWidget);
  });
}
