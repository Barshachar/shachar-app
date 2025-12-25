import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ashachar_marketplace/src/features/orders/domain/cart_line.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/checkout_options.dart';
import 'package:ashachar_marketplace/src/features/orders/domain/order_models.dart';

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return SupabaseOrdersRepository(Supabase.instance.client);
});

abstract class OrdersRepository {
  Future<List<OrderSummary>> fetchOrders();
  Future<OrderDetail> getOrder(String orderId);
  Future<String> submitDraftOrder(String orderId);
  Future<String> createDraftIfMissing();
  Future<List<CartLine>> fetchCartLines(String orderId);
  Future<void> addLineToOrder({
    required String orderId,
    required String variantId,
    required double qty,
  });
  Future<void> updateLineQty({
    required String orderItemId,
    required double qty,
  });
  Future<void> deleteLine({
    required String orderItemId,
  });
  Future<List<CheckoutAccountOption>> fetchBillToAccounts({
    required String companyId,
  });
  Future<List<CheckoutLocationOption>> fetchShipToLocations({
    required String companyId,
  });
  Future<List<CheckoutPaymentTermOption>> fetchPaymentTerms({
    required String companyId,
  });
}

class SupabaseOrdersRepository implements OrdersRepository {
  SupabaseOrdersRepository(this.client);

  final SupabaseClient client;

  @override
  Future<List<OrderSummary>> fetchOrders() async {
    final response = await client
        .from('orders')
        .select('id, order_number, status, total, created_at')
        .order('created_at', ascending: false)
        .limit(50);
    return (response as List<dynamic>)
        .map((row) => OrderSummary(
              id: row['id'] as String,
              orderNumber: row['order_number'] as String,
              status: row['status'] as String,
              total: (row['total'] as num).toDouble(),
              createdAt: DateTime.parse(row['created_at'] as String),
            ))
        .toList();
  }

  @override
  Future<OrderDetail> getOrder(String orderId) async {
    final head = await client
        .from('orders')
        .select(
            'id, order_number, status, subtotal, tax_total, total, created_at, cancelled_at, cancelled_by, cancellation_reason')
        .eq('id', orderId)
        .single();
    final dynamic itemsResponse = await client
        .from('order_items')
        .select(
          'id, variant_id, vendor_company_id, qty, unit_price, line_total,'
          ' product_variants!left(sku, products!inner(name))',
        )
        .eq('order_id', orderId)
        .order('id', ascending: true);

    final dynamic shipmentsResponse = await client
        .from('shipments')
        .select(
            'id, vendor_company_id, status, created_at, tracking, companies!shipments_vendor_company_id_fkey(name)')
        .eq('order_id', orderId)
        .order('created_at', ascending: true);
    final List<OrderShipment> shipments = shipmentsResponse is List
        ? shipmentsResponse
            .map(
                (dynamic row) => _mapOrderShipment(row as Map<String, dynamic>))
            .toList()
        : const <OrderShipment>[];
    final List<OrderItem> items = itemsResponse is List
        ? itemsResponse
            .map((dynamic row) => _mapOrderItem(row as Map<String, dynamic>))
            .toList()
        : const <OrderItem>[];
    return OrderDetail(
      id: head['id'] as String,
      orderNumber: head['order_number'] as String,
      status: head['status'] as String,
      subtotal: (head['subtotal'] as num).toDouble(),
      tax: (head['tax_total'] as num).toDouble(),
      total: (head['total'] as num).toDouble(),
      createdAt: DateTime.parse(head['created_at'] as String),
      items: items,
      shipments: shipments,
      cancelledAt: head['cancelled_at'] != null
          ? DateTime.parse(head['cancelled_at'] as String)
          : null,
      cancelledBy: head['cancelled_by'] as String?,
      cancellationReason: head['cancellation_reason'] as String?,
    );
  }

  @override
  Future<String> submitDraftOrder(String orderId) async {
    final String? rpcResult = await client.rpc<String?>(
      'rpc_submit_order',
      params: <String, dynamic>{'p_order_id': orderId},
    );
    final String finalId =
        (rpcResult != null && rpcResult.isNotEmpty) ? rpcResult : orderId;
    try {
      await client.rpc<int?>(
        'rpc_split_order',
        params: <String, dynamic>{'p_order_id': finalId},
      );
    } catch (_) {
      // Best-effort safety net for shipment creation.
    }
    try {
      await client.functions.invoke(
        'order_splitter',
        body: <String, dynamic>{'order_id': finalId},
      );
    } catch (_) {
      // Non-fatal: order submission succeeded even if splitting fails.
    }
    return finalId;
  }

  @override
  Future<String> createDraftIfMissing() async {
    final dynamic response = await client.rpc<dynamic>('rpc_create_draft');
    if (response is String && response.isNotEmpty) {
      return response;
    }
    if (response is Map && response['id'] is String) {
      return response['id'] as String;
    }
    throw StateError('Failed to create draft via rpc_create_draft()');
  }

  @override
  Future<void> addLineToOrder({
    required String orderId,
    required String variantId,
    required double qty,
  }) async {
    debugPrint(
        '[CART] addLineToOrder order=$orderId variant=$variantId qty=$qty');
    try {
      final dynamic existing = await client
          .from('order_items')
          .select('id, qty')
          .eq('order_id', orderId)
          .eq('variant_id', variantId)
          .maybeSingle();

      if (existing is Map<String, dynamic>) {
        final double currentQty = _toDouble(existing['qty']);
        final String existingId = existing['id'] as String;
        await updateLineQty(orderItemId: existingId, qty: currentQty + qty);
        return;
      }

      final dynamic variantRow = await client
          .from('product_variants')
          .select('id,uom,products!inner(vendor_company_id)')
          .eq('id', variantId)
          .maybeSingle();

      if (variantRow is! Map) {
        throw StateError('Variant not found: $variantId');
      }

      final Map<String, dynamic> variantMap = _stringKeyMap(variantRow);
      final Map<String, dynamic> productMap =
          _stringKeyMap(variantMap['products']);
      final String? vendorCompanyId =
          productMap['vendor_company_id'] as String?;
      if (vendorCompanyId == null || vendorCompanyId.isEmpty) {
        throw StateError('Variant $variantId missing vendor_company_id');
      }
      final String uom = (variantMap['uom'] as String?) ?? 'EA';

      await client.from('order_items').insert(<String, dynamic>{
        'order_id': orderId,
        'vendor_company_id': vendorCompanyId,
        'variant_id': variantId,
        'qty': qty,
        'uom': uom,
        'unit_price': 0,
        'discount_pct': 0,
        'tax_rate': 17.0,
      });
      debugPrint(
          '[CART] addLineToOrder inserted variant=$variantId order=$orderId');
    } on PostgrestException catch (e) {
      debugPrint(
          '[CART][ERROR] addLineToOrder PG error: ${e.message} code=${e.code}');
      rethrow;
    } catch (e) {
      debugPrint('[CART][ERROR] addLineToOrder error: $e');
      rethrow;
    }
  }

  @override
  Future<List<CartLine>> fetchCartLines(String orderId) async {
    debugPrint('[CART] fetchCartLines order=$orderId');
    final dynamic response = await client
        .from('order_items')
        .select(
          'id, order_id, vendor_company_id, variant_id, qty, unit_price, line_total,'
          ' product_variants!left(sku, attributes_json, products!left(name))',
        )
        .eq('order_id', orderId)
        .order('id', ascending: true);

    if (response is! List) {
      return const <CartLine>[];
    }

    final List<CartLine> lines = response
        .map((dynamic row) {
          try {
            return _mapCartLine(row as Map<String, dynamic>);
          } catch (e) {
            debugPrint('[CART][WARN] failed to map cart line: $e row=$row');
            return null;
          }
        })
        .whereType<CartLine>()
        .toList();
    debugPrint('[CART] fetchCartLines order=$orderId count=${lines.length}');
    return lines;
  }

  @override
  Future<void> updateLineQty({
    required String orderItemId,
    required double qty,
  }) async {
    await client
        .from('order_items')
        .update(<String, dynamic>{'qty': qty}).eq('id', orderItemId);
  }

  @override
  Future<void> deleteLine({required String orderItemId}) async {
    await client.from('order_items').delete().eq('id', orderItemId);
  }

  @override
  Future<List<CheckoutAccountOption>> fetchBillToAccounts({
    required String companyId,
  }) async {
    final String trimmed = companyId.trim();
    if (trimmed.isEmpty) {
      return const <CheckoutAccountOption>[];
    }

    final dynamic companyRow = await client
        .from('companies')
        .select('id,name')
        .eq('id', trimmed)
        .maybeSingle();
    final String companyName = (companyRow is Map && companyRow['name'] != null)
        ? companyRow['name'].toString()
        : 'Account';

    final dynamic profileResponse = await client
        .from('customer_profiles')
        .select(
          'customer_id, account_tier, sales_rep_name, sales_rep_email, phone, street_address, city, postal_code, country',
        )
        .eq('customer_id', trimmed);

    final List<Map<String, dynamic>> rows = _coerceRows(profileResponse);
    if (rows.isEmpty) {
      return <CheckoutAccountOption>[
        CheckoutAccountOption(
          id: '$trimmed:primary',
          title: companyName,
          subtitle: 'Primary billing',
        ),
      ];
    }

    final Map<String, dynamic> row = rows.first;
    final String? tier = row['account_tier']?.toString();
    final String? salesRep = row['sales_rep_name']?.toString();
    final String addressLine = _formatAddress(
      row['street_address'],
      row['city'],
      row['postal_code'],
      row['country'],
    );

    final List<CheckoutAccountOption> options = <CheckoutAccountOption>[
      CheckoutAccountOption(
        id: '$trimmed:primary',
        title: '$companyName • HQ',
        subtitle: tier?.isNotEmpty == true ? tier : 'Primary billing account',
        addressLine: addressLine,
      ),
    ];

    if (salesRep != null && salesRep.trim().isNotEmpty) {
      options.add(
        CheckoutAccountOption(
          id: '$trimmed:finance',
          title: '$companyName • Finance',
          subtitle: 'Attn: $salesRep',
          addressLine: addressLine,
        ),
      );
    }

    return options;
  }

  @override
  Future<List<CheckoutLocationOption>> fetchShipToLocations({
    required String companyId,
  }) async {
    final String trimmed = companyId.trim();
    if (trimmed.isEmpty) {
      return const <CheckoutLocationOption>[];
    }

    final dynamic profileResponse = await client
        .from('customer_profiles')
        .select('customer_id, street_address, city, postal_code, country')
        .eq('customer_id', trimmed);

    final List<Map<String, dynamic>> rows = _coerceRows(profileResponse);
    if (rows.isEmpty) {
      return <CheckoutLocationOption>[
        CheckoutLocationOption(
          id: '$trimmed:default_ship',
          label: 'Primary delivery',
        ),
      ];
    }

    final Map<String, dynamic> row = rows.first;
    final String addressLine = _formatAddress(
      row['street_address'],
      row['city'],
      row['postal_code'],
      row['country'],
    );
    final String city = row['city']?.toString() ?? '';

    final List<CheckoutLocationOption> locations = <CheckoutLocationOption>[
      CheckoutLocationOption(
        id: '$trimmed:main',
        label: city.isNotEmpty ? 'Main warehouse · $city' : 'Main warehouse',
        addressLine: addressLine,
        notes: 'Default delivery location',
      ),
    ];

    if (city.isNotEmpty) {
      locations.add(
        CheckoutLocationOption(
          id: '$trimmed:branch',
          label: '$city Distribution Hub',
          addressLine: addressLine,
          notes: 'Secondary branch, contact receiving for scheduling',
        ),
      );
    }

    return locations;
  }

  @override
  Future<List<CheckoutPaymentTermOption>> fetchPaymentTerms({
    required String companyId,
  }) async {
    final dynamic response = await client
        .from('payment_terms_templates')
        .select('id, code, display_name, description, net_days')
        .order('net_days');

    final List<Map<String, dynamic>> rows = _coerceRows(response);
    if (rows.isEmpty) {
      return const <CheckoutPaymentTermOption>[
        CheckoutPaymentTermOption(
          id: 'due_on_receipt',
          code: 'due_on_receipt',
          label: 'תשלום מיידי',
          description: 'התשלום נדרש בעת המסירה',
          netDays: 0,
        ),
      ];
    }

    return rows
        .map((Map<String, dynamic> row) => CheckoutPaymentTermOption(
              id: row['id'].toString(),
              code: row['code'].toString(),
              label: row['display_name']?.toString() ?? row['code'].toString(),
              description: row['description']?.toString(),
              netDays: (row['net_days'] as int?) ??
                  int.tryParse(row['net_days']?.toString() ?? '') ??
                  0,
            ))
        .toList(growable: false);
  }

  CartLine _mapCartLine(Map<String, dynamic> row) {
    final Map<String, dynamic> variant = _stringKeyMap(row['product_variants']);
    final Map<String, dynamic> product = _stringKeyMap(variant['products']);
    final dynamic nameField = product['name'];
    String productName;
    if (nameField is Map) {
      final Map<String, dynamic> nameMap = _stringKeyMap(nameField);
      productName = (nameMap['he'] as String?)?.trim().isNotEmpty == true
          ? nameMap['he'] as String
          : (nameMap['en'] as String?) ?? '';
    } else {
      productName = nameField?.toString() ?? '';
    }
    if (productName.isEmpty) {
      productName = 'SKU ${variant['sku'] ?? row['variant_id']}';
    }
    final Map<String, dynamic> attributes =
        _stringKeyMap(variant['attributes_json']);

    return CartLine(
      id: row['id'] as String,
      orderId: row['order_id'] as String,
      variantId: row['variant_id'] as String,
      vendorCompanyId: row['vendor_company_id'] as String,
      qty: _toDouble(row['qty']),
      unitPrice: _toDouble(row['unit_price']),
      lineTotal: _toDouble(row['line_total'] ??
          _toDouble(row['unit_price']) * _toDouble(row['qty'])),
      productName: productName,
      variantSku: variant['sku'] as String?,
      variantAttributes: attributes,
    );
  }

  List<Map<String, dynamic>> _coerceRows(dynamic source) {
    if (source is List) {
      return source
          .whereType<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> raw) => raw.map(
              (dynamic key, dynamic value) =>
                  MapEntry(key?.toString() ?? '', value)))
          .toList();
    }
    if (source is Map) {
      return <Map<String, dynamic>>[
        source.map((dynamic key, dynamic value) =>
            MapEntry(key?.toString() ?? '', value)),
      ];
    }
    return const <Map<String, dynamic>>[];
  }

  String _formatAddress(
    dynamic street,
    dynamic city,
    dynamic postal,
    dynamic country,
  ) {
    final List<String> parts = <String>[
      if (street != null && street.toString().trim().isNotEmpty)
        street.toString().trim(),
      if (city != null && city.toString().trim().isNotEmpty)
        city.toString().trim(),
      if (postal != null && postal.toString().trim().isNotEmpty)
        postal.toString().trim(),
      if (country != null && country.toString().trim().isNotEmpty)
        country.toString().trim(),
    ];
    return parts.join(', ');
  }

  double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString()) ?? 0;
  }

  Map<String, dynamic> _stringKeyMap(dynamic source) {
    if (source is Map) {
      return source.map(
        (dynamic key, dynamic value) => MapEntry(key?.toString() ?? '', value),
      );
    }
    return <String, dynamic>{};
  }

  OrderItem _mapOrderItem(Map<String, dynamic> row) {
    final Map<String, dynamic> variant = _stringKeyMap(row['product_variants']);
    final Map<String, dynamic> product = _stringKeyMap(variant['products']);
    final dynamic nameField = product['name'];
    String? productName;
    if (nameField is Map) {
      final Map<String, dynamic> nameMap = _stringKeyMap(nameField);
      productName = (nameMap['he'] as String?)?.trim().isNotEmpty == true
          ? nameMap['he'] as String
          : (nameMap['en'] as String?)?.trim().isNotEmpty == true
              ? nameMap['en'] as String
              : null;
    } else if (nameField is String && nameField.trim().isNotEmpty) {
      productName = nameField;
    }
    productName ??= variant['sku'] as String? ?? row['variant_id'] as String;

    return OrderItem(
      id: row['id'] as String,
      variantId: row['variant_id'] as String,
      vendorCompanyId: row['vendor_company_id'] as String,
      qty: _toDouble(row['qty']),
      unitPrice: _toDouble(row['unit_price']),
      lineTotal: _toDouble(row['line_total']),
      productName: productName,
      variantSku: variant['sku'] as String?,
    );
  }

  OrderShipment _mapOrderShipment(Map<String, dynamic> row) {
    return OrderShipment(
      id: row['id'] as String,
      vendorCompanyId: row['vendor_company_id'] as String,
      status: row['status'] as String,
      createdAt: DateTime.parse(row['created_at'] as String),
      tracking: row['tracking'] as String?,
      vendorName: _extractCompanyName(row['companies']) ??
          row['vendor_company_id']?.toString(),
    );
  }

  String? _extractCompanyName(dynamic companyValue) {
    if (companyValue is Map) {
      final Map<String, dynamic> companyMap = companyValue.map(
          (dynamic key, dynamic value) =>
              MapEntry(key?.toString() ?? '', value));
      if (companyMap['name'] is Map) {
        final Map<String, dynamic> names =
            Map<String, dynamic>.from(companyMap['name'] as Map); // he/en map
        final String? heName = names['he'] as String?;
        if (heName != null && heName.trim().isNotEmpty) {
          return heName;
        }
        final String? enName = names['en'] as String?;
        if (enName != null && enName.trim().isNotEmpty) {
          return enName;
        }
      }
      return companyMap['name']?.toString();
    }
    return null;
  }
}
