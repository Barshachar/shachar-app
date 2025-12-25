import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ashachar_marketplace/src/features/returns/data/supabase_return_request_repository.dart';
import 'package:ashachar_marketplace/src/features/returns/domain/return_request.dart';
import 'package:ashachar_marketplace/src/features/returns/domain/return_request_repository.dart';

final returnRequestsProvider =
    FutureProvider.autoDispose.family<List<ReturnRequest>, String>(
  (ref, orderId) async {
    final ReturnRequestRepository repository =
        ref.watch(returnRequestRepositoryProvider);
    return repository.fetchReturnRequests(orderId);
  },
);
