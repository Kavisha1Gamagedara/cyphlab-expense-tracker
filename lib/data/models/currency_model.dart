/// Model representing a currency with code, symbol, name, and flag emoji.
class CurrencyModel {
  final String code;
  final String symbol;
  final String name;
  final String flag;

  const CurrencyModel({
    required this.code,
    required this.symbol,
    required this.name,
    required this.flag,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyModel &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

/// Curated list of world currencies available in the currency picker
const List<CurrencyModel> kCurrencies = [
  CurrencyModel(code: 'USD', symbol: '\$', name: 'US Dollar', flag: '🇺🇸'),
  CurrencyModel(code: 'LKR', symbol: 'Rs', name: 'Sri Lankan Rupee', flag: '🇱🇰'),
  CurrencyModel(code: 'EUR', symbol: '€', name: 'Euro', flag: '🇪🇺'),
  CurrencyModel(code: 'GBP', symbol: '£', name: 'British Pound', flag: '🇬🇧'),
  CurrencyModel(code: 'INR', symbol: '₹', name: 'Indian Rupee', flag: '🇮🇳'),
  CurrencyModel(code: 'AUD', symbol: 'A\$', name: 'Australian Dollar', flag: '🇦🇺'),
  CurrencyModel(code: 'CAD', symbol: 'C\$', name: 'Canadian Dollar', flag: '🇨🇦'),
  CurrencyModel(code: 'JPY', symbol: '¥', name: 'Japanese Yen', flag: '🇯🇵'),
  CurrencyModel(code: 'CNY', symbol: '¥', name: 'Chinese Yuan', flag: '🇨🇳'),
  CurrencyModel(code: 'SGD', symbol: 'S\$', name: 'Singapore Dollar', flag: '🇸🇬'),
  CurrencyModel(code: 'AED', symbol: 'AED', name: 'UAE Dirham', flag: '🇦🇪'),
  CurrencyModel(code: 'SAR', symbol: 'SAR', name: 'Saudi Riyal', flag: '🇸🇦'),
  CurrencyModel(code: 'QAR', symbol: 'QR', name: 'Qatari Riyal', flag: '🇶🇦'),
  CurrencyModel(code: 'KWD', symbol: 'KD', name: 'Kuwaiti Dinar', flag: '🇰🇼'),
  CurrencyModel(code: 'CHF', symbol: 'CHF', name: 'Swiss Franc', flag: '🇨🇭'),
  CurrencyModel(code: 'NZD', symbol: 'NZ\$', name: 'New Zealand Dollar', flag: '🇳🇿'),
  CurrencyModel(code: 'MYR', symbol: 'RM', name: 'Malaysian Ringgit', flag: '🇲🇾'),
  CurrencyModel(code: 'THB', symbol: '฿', name: 'Thai Baht', flag: '🇹🇭'),
  CurrencyModel(code: 'KRW', symbol: '₩', name: 'South Korean Won', flag: '🇰🇷'),
  CurrencyModel(code: 'BRL', symbol: 'R\$', name: 'Brazilian Real', flag: '🇧🇷'),
  CurrencyModel(code: 'ZAR', symbol: 'R', name: 'South African Rand', flag: '🇿🇦'),
  CurrencyModel(code: 'RUB', symbol: '₽', name: 'Russian Ruble', flag: '🇷🇺'),
  CurrencyModel(code: 'TRY', symbol: '₺', name: 'Turkish Lira', flag: '🇹🇷'),
  CurrencyModel(code: 'SEK', symbol: 'kr', name: 'Swedish Krona', flag: '🇸🇪'),
  CurrencyModel(code: 'NOK', symbol: 'kr', name: 'Norwegian Krone', flag: '🇳🇴'),
  CurrencyModel(code: 'DKK', symbol: 'kr', name: 'Danish Krone', flag: '🇩🇰'),
  CurrencyModel(code: 'PKR', symbol: 'Rs', name: 'Pakistani Rupee', flag: '🇵🇰'),
  CurrencyModel(code: 'BDT', symbol: '৳', name: 'Bangladeshi Taka', flag: '🇧🇩'),
  CurrencyModel(code: 'PHP', symbol: '₱', name: 'Philippine Peso', flag: '🇵🇭'),
  CurrencyModel(code: 'IDR', symbol: 'Rp', name: 'Indonesian Rupiah', flag: '🇮🇩'),
  CurrencyModel(code: 'VND', symbol: '₫', name: 'Vietnamese Dong', flag: '🇻🇳'),
  CurrencyModel(code: 'EGP', symbol: 'E£', name: 'Egyptian Pound', flag: '🇪🇬'),
  CurrencyModel(code: 'NGN', symbol: '₦', name: 'Nigerian Naira', flag: '🇳🇬'),
  CurrencyModel(code: 'KES', symbol: 'KSh', name: 'Kenyan Shilling', flag: '🇰🇪'),
  CurrencyModel(code: 'MXN', symbol: 'Mex\$', name: 'Mexican Peso', flag: '🇲🇽'),
];
