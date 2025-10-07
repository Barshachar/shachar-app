import 'dart:collection';

import 'package:ashachar_marketplace/src/features/catalog/domain/catalog_models.dart';

const Set<String> _imageKeyHints = <String>{
  'image',
  'image_url',
  'imageurl',
  'thumbnail',
  'thumb',
  'photo',
  'picture',
  'gallery',
  'images',
  'media',
};

const Set<String> _imageValueKeys = <String>{
  'url',
  'src',
  'image',
  'image_url',
  'thumbnail',
};

const Set<String> _nonDisplayAttributeKeys = <String>{
  'sku',
};

const Set<String> _variantLabelKeys = <String>{
  'label',
  'name',
  'title',
  'variant',
  'display_name',
  'variant_name',
};

List<String> collectVariantImages(ProductVariant variant) {
  final LinkedHashSet<String> urls = LinkedHashSet<String>();
  variant.attributes.forEach((key, value) {
    final String lowerKey = key.toString().toLowerCase();
    if (_looksLikeImageKey(lowerKey)) {
      urls.addAll(_extractImageValues(value));
    }
  });
  return urls.toList(growable: false);
}

List<String> collectProductImages(
  Product product, {
  ProductVariant? primaryVariant,
}) {
  final LinkedHashSet<String> urls = LinkedHashSet<String>();
  if (primaryVariant != null) {
    urls.addAll(collectVariantImages(primaryVariant));
  }
  for (final ProductVariant variant in product.variants) {
    if (primaryVariant != null && variant.id == primaryVariant.id) {
      continue;
    }
    urls.addAll(collectVariantImages(variant));
  }
  return urls.toList(growable: false);
}

String? resolvePrimaryImage(
  Product product, {
  ProductVariant? variant,
}) {
  final List<String> images = collectProductImages(
    product,
    primaryVariant: variant,
  );
  if (images.isEmpty) {
    return null;
  }
  return images.first;
}

Map<String, String> extractDisplayAttributes(ProductVariant variant) {
  final Map<String, String> result = <String, String>{};
  variant.attributes.forEach((key, value) {
    final String loweredKey = key.toString().toLowerCase();
    if (_looksLikeImageKey(loweredKey) ||
        _nonDisplayAttributeKeys.contains(loweredKey)) {
      return;
    }
    final String formattedValue = _stringifyAttributeValue(value);
    if (formattedValue.isEmpty) {
      return;
    }
    result[key.toString()] = formattedValue;
  });
  return result;
}

String variantLabel(ProductVariant variant, {String? fallbackSku}) {
  final Map<String, dynamic> attributes = variant.attributes;
  for (final MapEntry<String, dynamic> entry in attributes.entries) {
    final String loweredKey = entry.key.toString().toLowerCase();
    if (_variantLabelKeys.contains(loweredKey)) {
      final String label = _stringifyAttributeValue(entry.value);
      if (label.isNotEmpty) {
        return label;
      }
    }
  }
  if (variant.barcode != null && variant.barcode!.trim().isNotEmpty) {
    return variant.barcode!.trim();
  }
  if (fallbackSku != null && fallbackSku.trim().isNotEmpty) {
    return fallbackSku.trim();
  }
  final String id = variant.id;
  return id.length <= 6 ? '#$id' : '#${id.substring(0, 6)}';
}

bool _looksLikeImageKey(String key) {
  if (_imageKeyHints.contains(key)) {
    return true;
  }
  return key.contains('image');
}

Iterable<String> _extractImageValues(dynamic raw) sync* {
  if (raw == null) {
    return;
  }
  if (raw is String) {
    final String candidate = raw.trim();
    if (candidate.isNotEmpty) {
      yield candidate;
    }
    return;
  }
  if (raw is List) {
    for (final dynamic item in raw) {
      yield* _extractImageValues(item);
    }
    return;
  }
  if (raw is Map) {
    for (final MapEntry<dynamic, dynamic> entry in raw.entries) {
      final String key = entry.key.toString().toLowerCase();
      if (_imageValueKeys.contains(key) || _looksLikeImageKey(key)) {
        yield* _extractImageValues(entry.value);
      }
    }
  }
}

String _stringifyAttributeValue(dynamic value) {
  if (value == null) {
    return '';
  }
  if (value is String) {
    return value.trim();
  }
  if (value is num || value is bool) {
    return value.toString();
  }
  if (value is List) {
    final List<String> parts = <String>[];
    for (final dynamic item in value) {
      final String part = _stringifyAttributeValue(item);
      if (part.isNotEmpty) {
        parts.add(part);
      }
    }
    return parts.join(', ');
  }
  if (value is Map) {
    final dynamic prioritized =
        value['value'] ?? value['label'] ?? value['name'] ?? value['title'];
    if (prioritized != null) {
      final String prioritizedValue = _stringifyAttributeValue(prioritized);
      if (prioritizedValue.isNotEmpty) {
        return prioritizedValue;
      }
    }
    final List<String> parts = <String>[];
    value.forEach((dynamic key, dynamic val) {
      final String part = _stringifyAttributeValue(val);
      if (part.isNotEmpty) {
        parts.add(part);
      }
    });
    return parts.join(', ');
  }
  return value.toString();
}
