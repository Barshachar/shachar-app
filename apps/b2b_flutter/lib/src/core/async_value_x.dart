import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Compatibility helper: provide `valueOrNull` on AsyncValue for toolchains
/// שבהן המזהה לא קיים. מפחית את הצורך לשנות קוד קיים בכל המסכים.
extension AsyncValueX<T> on AsyncValue<T> {
  T? get valueOrNull {
    return when<T?>(
      data: (v) => v,
      loading: () => null,
      error: (_, __) => null,
    );
  }
}
