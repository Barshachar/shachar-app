import 'package:ashachar_marketplace/src/core/localization/localization.dart';
import 'package:ashachar_marketplace/src/features/ratings/data/supabase_vendor_rating_repository.dart';
import 'package:ashachar_marketplace/src/features/ratings/domain/vendor_rating.dart';
import 'package:ashachar_marketplace/src/features/ratings/domain/vendor_rating_repository.dart';
import 'package:ashachar_marketplace/src/features/ratings/presentation/order_vendor_rating_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_harness.dart';

void main() {
  testWidgets('rating submit enables after star selection', (tester) async {
    final VendorRatingRepository repository = _FakeVendorRatingRepository();
    const VendorRatingTarget vendor = VendorRatingTarget(
      vendorId: 'vendor-1',
      vendorName: 'Vendor One',
    );

    await tester.pumpWidget(
      makeTestApp(
        Scaffold(
          body: SingleChildScrollView(
            child: OrderVendorRatingSection(
              orderId: 'order-1',
              vendors: [vendor],
            ),
          ),
        ),
        overrides: [
          vendorRatingRepositoryProvider.overrideWithValue(repository),
        ],
        extraDelegates: const [_FakeMarketplaceLocalizationsDelegate()],
      ),
    );

    await tester.pumpAndSettle();

    final Finder submitFinder =
        find.byKey(const ValueKey('order_vendor_rating_submit_vendor-1'));
    ElevatedButton submitButton = tester.widget(submitFinder);
    expect(submitButton.onPressed, isNull);

    await tester.tap(
      find.byKey(const ValueKey('order_vendor_rating_star_vendor-1-4')),
    );
    await tester.pump();

    submitButton = tester.widget(submitFinder);
    expect(submitButton.onPressed, isNotNull);
  });
}

class _FakeVendorRatingRepository implements VendorRatingRepository {
  @override
  Future<VendorRatingSummary?> fetchSummary(String vendorCompanyId) async {
    return const VendorRatingSummary(
      vendorCompanyId: 'vendor-1',
      averageRating: 4.5,
      ratingsCount: 12,
    );
  }

  @override
  Future<VendorRating?> fetchRatingForOrder({
    required String orderId,
    required String vendorCompanyId,
  }) async {
    return null;
  }

  @override
  Future<VendorRatingSubmission> submitRating({
    required String orderId,
    required String vendorCompanyId,
    required int rating,
    String? comment,
  }) async {
    return VendorRatingSubmission(
      rating: VendorRating(
        id: 'rating-1',
        vendorCompanyId: vendorCompanyId,
        customerCompanyId: 'customer-1',
        orderId: orderId,
        rating: rating,
        createdAt: DateTime.now(),
        createdBy: 'user-1',
        comment: comment,
      ),
    );
  }
}

class _FakeMarketplaceLocalizations extends MarketplaceLocalizations {
  _FakeMarketplaceLocalizations(super.locale);

  @override
  Future<void> load() async {}

  @override
  String translate(String key) => key;
}

class _FakeMarketplaceLocalizationsDelegate
    extends LocalizationsDelegate<MarketplaceLocalizations> {
  const _FakeMarketplaceLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MarketplaceLocalizations> load(Locale locale) async {
    final localization = _FakeMarketplaceLocalizations(locale);
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(
    covariant LocalizationsDelegate<MarketplaceLocalizations> old,
  ) =>
      false;
}
