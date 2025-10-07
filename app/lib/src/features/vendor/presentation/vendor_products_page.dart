import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:ashachar_marketplace/src/app/theme/theme.dart';

class VendorProduct {
  const VendorProduct({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.minOrder,
    required this.imageUrl,
    required this.inStock,
  });

  final String id;
  final String name;
  final String sku;
  final double price;
  final int minOrder;
  final String imageUrl;
  final bool inStock;
}

final _demoProductsProvider = Provider<List<VendorProduct>>((ref) {
  return const <VendorProduct>[
    VendorProduct(
      id: '1',
      name: '1" Natural Bristle Paint Brush',
      sku: 'PX3952034128',
      price: 7.99,
      minOrder: 50,
      imageUrl:
          'https://images.unsplash.com/photo-1521412644187-c49fa049e84d?auto=format&fit=crop&w=200&q=60',
      inStock: true,
    ),
    VendorProduct(
      id: '2',
      name: '1.5" Natural Bristle Paint Brush',
      sku: 'PX3952034129',
      price: 12.75,
      minOrder: 50,
      imageUrl:
          'https://images.unsplash.com/photo-1503389152951-9f343605f61e?auto=format&fit=crop&w=200&q=60',
      inStock: true,
    ),
    VendorProduct(
      id: '3',
      name: '2" Natural Bristle Paint Brush',
      sku: 'PX3952034130',
      price: 15.50,
      minOrder: 30,
      imageUrl:
          'https://images.unsplash.com/photo-1472745433479-4556f22e32c2?auto=format&fit=crop&w=200&q=60',
      inStock: true,
    ),
    VendorProduct(
      id: '4',
      name: '3" Natural Bristle Paint Brush',
      sku: 'PX3952034131',
      price: 18.90,
      minOrder: 20,
      imageUrl:
          'https://images.unsplash.com/photo-1528738064268-22fb14722c5a?auto=format&fit=crop&w=200&q=60',
      inStock: false,
    ),
  ];
});

class VendorProductsPage extends ConsumerStatefulWidget {
  const VendorProductsPage({super.key});

  @override
  ConsumerState<VendorProductsPage> createState() => _VendorProductsPageState();
}

class _VendorProductsPageState extends ConsumerState<VendorProductsPage> {
  final Map<String, int> _quantities = <String, int>{};
  final Map<String, bool> _cartonSelected = <String, bool>{};

  @override
  Widget build(BuildContext context) {
    final List<VendorProduct> products = ref.watch(_demoProductsProvider);
    final NumberFormat currencyFormat =
        NumberFormat.simpleCurrency(locale: 'en_US');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Catalog'),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        foregroundColor: AColors.foreground,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AColors.primary,
        foregroundColor: Colors.white,
        onPressed: () {},
        child: const Icon(Icons.qr_code_scanner),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ASpacing.page,
            vertical: ASpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: ASpacing.sm,
                runSpacing: ASpacing.sm,
                children: const [
                  _FilterChip(label: 'Price breaks', icon: Icons.trending_up),
                  _FilterChip(label: 'Sort', icon: Icons.sort),
                  _FilterChip(
                      label: 'Vendor', icon: Icons.store_mall_directory),
                ],
              ),
              const SizedBox(height: ASpacing.lg),
              Expanded(
                child: ListView.separated(
                  itemCount: products.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: ASpacing.lg),
                  itemBuilder: (BuildContext context, int index) {
                    final VendorProduct product = products[index];
                    final int quantity = _quantities[product.id] ?? 0;
                    final bool asCarton = _cartonSelected[product.id] ?? false;
                    return _ProductCard(
                      product: product,
                      priceLabel: currencyFormat.format(product.price),
                      quantity: quantity,
                      asCarton: asCarton,
                      onQuantityChanged: (int value) {
                        setState(() {
                          _quantities[product.id] = value;
                        });
                      },
                      onCartonChanged: (bool value) {
                        setState(() {
                          _cartonSelected[product.id] = value;
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: false,
      onSelected: (_) {},
      backgroundColor: AColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.priceLabel,
    required this.quantity,
    required this.asCarton,
    required this.onQuantityChanged,
    required this.onCartonChanged,
  });

  final VendorProduct product;
  final String priceLabel;
  final int quantity;
  final bool asCarton;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<bool> onCartonChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AElevation.shadowSoft,
        border: Border.all(color: AColors.borderSubtle),
      ),
      child: Padding(
        padding: const EdgeInsets.all(ASpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: ATypography.titleSm,
                        ),
                      ),
                      const SizedBox(width: ASpacing.sm),
                      _StockBadge(inStock: product.inStock),
                    ],
                  ),
                  const SizedBox(height: ASpacing.xs),
                  Text(
                    'MOQ: ${product.minOrder} | ${product.sku}',
                    style: ATypography.bodySm
                        .copyWith(color: AColors.mutedForeground),
                  ),
                  const SizedBox(height: ASpacing.sm),
                  Text(
                    priceLabel,
                    style: ATypography.titleSm.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: ASpacing.md),
                  Row(
                    children: [
                      _QuantitySelector(
                        value: quantity,
                        onChanged: onQuantityChanged,
                      ),
                      const SizedBox(width: ASpacing.lg),
                      SegmentedButton<bool>(
                        segments: const <ButtonSegment<bool>>[
                          ButtonSegment<bool>(
                              value: false, label: Text('Unit')),
                          ButtonSegment<bool>(
                              value: true, label: Text('Carton')),
                        ],
                        selected: <bool>{asCarton},
                        onSelectionChanged: (Set<bool> value) {
                          if (value.isNotEmpty) {
                            onCartonChanged(value.first);
                          }
                        },
                        style: ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          backgroundColor:
                              WidgetStateProperty.resolveWith<Color?>(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.selected)) {
                                return AColors.primary.withValues(alpha: 0.12);
                              }
                              return AColors.surface;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: ASpacing.lg),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                product.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80,
                  height: 80,
                  color: AColors.surfaceSubtle,
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported,
                      color: AColors.mutedForeground),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _QuantityButton(
          icon: Icons.remove,
          onPressed: value > 0 ? () => onChanged(value - 1) : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: ASpacing.sm),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: ATypography.titleSm,
          ),
        ),
        _QuantityButton(
          icon: Icons.add,
          onPressed: () => onChanged(value + 1),
        ),
      ],
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.inStock});

  final bool inStock;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: inStock
            ? AColors.primary.withValues(alpha: 0.12)
            : AColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            inStock ? Icons.check_circle : Icons.warning,
            size: 14,
            color: inStock ? AColors.primary : AColors.warning,
          ),
          const SizedBox(width: 6),
          Text(
            inStock ? 'In stock' : 'Out of stock',
            style: ATypography.bodySm.copyWith(
              color: inStock ? AColors.primary : AColors.warning,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
