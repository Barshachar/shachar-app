/// Cache Management Service
/// Enterprise-grade caching with LRU and TTL support
library;

import 'dart:async';
import 'dart:collection';

/// Cache entry
class CacheEntry<T> {
  final T value;
  final DateTime createdAt;
  final Duration? ttl;

  CacheEntry({
    required this.value,
    DateTime? createdAt,
    this.ttl,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isExpired {
    if (ttl == null) return false;
    return DateTime.now().isAfter(createdAt.add(ttl!));
  }
}

/// LRU Cache
class LRUCache<K, V> {
  final int maxSize;
  final Duration? defaultTTL;
  final LinkedHashMap<K, CacheEntry<V>> _cache = LinkedHashMap();

  LRUCache({
    required this.maxSize,
    this.defaultTTL,
  });

  /// Get value from cache
  V? get(K key) {
    final entry = _cache.remove(key);
    if (entry == null) return null;

    if (entry.isExpired) {
      return null;
    }

    // Move to end (most recently used)
    _cache[key] = entry;
    return entry.value;
  }

  /// Put value in cache
  void put(K key, V value, {Duration? ttl}) {
    _cache.remove(key);

    // Evict oldest if at capacity
    if (_cache.length >= maxSize) {
      _cache.remove(_cache.keys.first);
    }

    _cache[key] = CacheEntry(
      value: value,
      ttl: ttl ?? defaultTTL,
    );
  }

  /// Check if key exists and is valid
  bool contains(K key) {
    final entry = _cache[key];
    if (entry == null) return false;
    if (entry.isExpired) {
      _cache.remove(key);
      return false;
    }
    return true;
  }

  /// Remove key
  void remove(K key) {
    _cache.remove(key);
  }

  /// Clear all entries
  void clear() {
    _cache.clear();
  }

  /// Get current size
  int get size => _cache.length;

  /// Get all keys
  Iterable<K> get keys => _cache.keys;

  /// Clean expired entries
  void cleanExpired() {
    final expiredKeys = <K>[];
    for (final entry in _cache.entries) {
      if (entry.value.isExpired) {
        expiredKeys.add(entry.key);
      }
    }
    for (final key in expiredKeys) {
      _cache.remove(key);
    }
  }
}

/// Memory cache manager
class MemoryCacheManager {
  static final MemoryCacheManager _instance = MemoryCacheManager._internal();
  factory MemoryCacheManager() => _instance;
  MemoryCacheManager._internal();

  final Map<String, LRUCache<String, dynamic>> _caches = {};
  Timer? _cleanupTimer;

  /// Get or create cache
  LRUCache<String, T> getCache<T>(
    String name, {
    int maxSize = 100,
    Duration? ttl,
  }) {
    if (!_caches.containsKey(name)) {
      _caches[name] = LRUCache<String, T>(
        maxSize: maxSize,
        defaultTTL: ttl,
      );
    }
    return _caches[name] as LRUCache<String, T>;
  }

  /// Start cleanup timer
  void startCleanup({Duration interval = const Duration(minutes: 5)}) {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(interval, (_) {
      for (final cache in _caches.values) {
        cache.cleanExpired();
      }
    });
  }

  /// Stop cleanup timer
  void stopCleanup() {
    _cleanupTimer?.cancel();
  }

  /// Clear all caches
  void clearAll() {
    for (final cache in _caches.values) {
      cache.clear();
    }
    _caches.clear();
  }
}

/// Global cache instance
final memoryCache = MemoryCacheManager();

/// Memoization helper
class Memoizer<T> {
  final Map<String, T> _cache = {};
  final Duration? ttl;
  final Map<String, DateTime> _timestamps = {};

  Memoizer({this.ttl});

  T call(String key, T Function() fn) {
    if (_cache.containsKey(key)) {
      if (ttl != null) {
        final timestamp = _timestamps[key];
        if (timestamp != null) {
          if (DateTime.now().difference(timestamp) > ttl!) {
            _cache.remove(key);
            _timestamps.remove(key);
          } else {
            return _cache[key]!;
          }
        }
      } else {
        return _cache[key]!;
      }
    }

    final value = fn();
    _cache[key] = value;
    if (ttl != null) {
      _timestamps[key] = DateTime.now();
    }
    return value;
  }

  void clear() {
    _cache.clear();
    _timestamps.clear();
  }
}

/// Async memoization
class AsyncMemoizer<T> {
  final Map<String, Future<T>> _pending = {};
  final Map<String, T> _cache = {};
  final Duration? ttl;
  final Map<String, DateTime> _timestamps = {};

  AsyncMemoizer({this.ttl});

  Future<T> call(String key, Future<T> Function() fn) async {
    // Check cache
    if (_cache.containsKey(key)) {
      if (ttl != null) {
        final timestamp = _timestamps[key];
        if (timestamp != null) {
          if (DateTime.now().difference(timestamp) > ttl!) {
            _cache.remove(key);
            _timestamps.remove(key);
          } else {
            return _cache[key]!;
          }
        }
      } else {
        return _cache[key]!;
      }
    }

    // Check if already pending
    if (_pending.containsKey(key)) {
      return _pending[key]!;
    }

    // Execute and cache
    final future = fn();
    _pending[key] = future;

    try {
      final value = await future;
      _cache[key] = value;
      if (ttl != null) {
        _timestamps[key] = DateTime.now();
      }
      return value;
    } finally {
      _pending.remove(key);
    }
  }

  void clear() {
    _cache.clear();
    _timestamps.clear();
    _pending.clear();
  }
}

/// Cache decorator
T cached<T>({
  required String key,
  required T Function() compute,
  Duration? ttl,
  String cacheName = 'default',
}) {
  final cache = memoryCache.getCache<T>(cacheName, ttl: ttl);

  final cached = cache.get(key);
  if (cached != null) return cached;

  final value = compute();
  cache.put(key, value);
  return value;
}

/// Async cache decorator
Future<T> cachedAsync<T>({
  required String key,
  required Future<T> Function() compute,
  Duration? ttl,
  String cacheName = 'default',
}) async {
  final cache = memoryCache.getCache<T>(cacheName, ttl: ttl);

  final cached = cache.get(key);
  if (cached != null) return cached;

  final value = await compute();
  cache.put(key, value);
  return value;
}
