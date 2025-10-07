import 'package:flutter/widgets.dart';

/// Stable widget keys for Vendor Console presentation elements.
abstract final class VendorKeys {
  static const ValueKey<String> shipmentEditButton =
      ValueKey<String>('shipment_edit_btn');

  static const ValueKey<String> shipmentStatusField =
      ValueKey<String>('shipment_status_field');

  static const ValueKey<String> shipmentTrackingField =
      ValueKey<String>('shipment_tracking_field');

  static const ValueKey<String> shipmentUpdateSaveButton =
      ValueKey<String>('shipment_update_save');

  static const ValueKey<String> shipmentUpdateSuccessSnackBar =
      ValueKey<String>('shipment_update_success_snackbar');

  static const ValueKey<String> shipmentUpdateErrorSnackBar =
      ValueKey<String>('shipment_update_error_snackbar');
}
