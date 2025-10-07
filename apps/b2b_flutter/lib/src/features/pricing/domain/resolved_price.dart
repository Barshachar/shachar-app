enum PriceSource { contract, priceList, base, fallback }

extension PriceSourceX on PriceSource {
  String get asTelemetryLabel {
    switch (this) {
      case PriceSource.contract:
        return 'contract';
      case PriceSource.priceList:
        return 'price_list';
      case PriceSource.base:
        return 'base';
      case PriceSource.fallback:
        return 'fallback';
    }
  }
}

PriceSource priceSourceFromString(String? value) {
  final String normalized = value?.trim().toLowerCase() ?? '';
  switch (normalized) {
    case 'contract':
    case 'contract_price':
    case 'contract_price_list':
      return PriceSource.contract;
    case 'price_list':
    case 'pricelist':
    case 'list':
      return PriceSource.priceList;
    case 'base':
    case 'base_price':
    case 'standard':
      return PriceSource.base;
    default:
      return PriceSource.fallback;
  }
}
