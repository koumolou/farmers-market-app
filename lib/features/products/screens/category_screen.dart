import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/product_provider.dart';
import '../models/product_model.dart';

class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Select Category')),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (categories) => ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _CategoryTile(category: categories[i]),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryModel category;
  const _CategoryTile({required this.category});

  static const _icons = {
    'Pesticides': Icons.bug_report_outlined,
    'Engrais': Icons.eco_outlined,
    'Semences': Icons.grain_outlined,
    'Herbicides': Icons.grass_outlined,
    'Insecticides': Icons.pest_control_outlined,
    'NPK': Icons.science_outlined,
    'Organique': Icons.compost_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasChildren = category.children.isNotEmpty;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.25)),
      ),
      child: hasChildren
          ? ExpansionTile(
              leading: _iconBox(context),
              title: Text(
                category.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              children: category.children
                  .map((child) => _SubcategoryTile(child: child))
                  .toList(),
            )
          : ListTile(
              leading: _iconBox(context),
              title: Text(
                category.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push('/products?category_id=${category.id}'),
            ),
    );
  }

  Widget _iconBox(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        _icons[category.name] ?? Icons.category_outlined,
        color: theme.colorScheme.primary,
        size: 20,
      ),
    );
  }
}

class _SubcategoryTile extends StatelessWidget {
  final CategoryModel child;
  const _SubcategoryTile({required this.child});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 72, right: 16),
      title: Text(child.name),
      trailing: const Icon(Icons.chevron_right_rounded, size: 18),
      onTap: () => context.push('/products?category_id=${child.id}'),
    );
  }
}
