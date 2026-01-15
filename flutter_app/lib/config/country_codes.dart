/// 国家/地区代码配置
class CountryCode {
  final String name;
  final String code;
  final String dialCode;
  final String flag;
  final String phonePattern;
  final int phoneLength;

  const CountryCode({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
    required this.phonePattern,
    required this.phoneLength,
  });
}

/// 常用国家/地区列表
class CountryCodes {
  static const List<CountryCode> popularCountries = [
    CountryCode(
      name: '中国大陆',
      code: 'CN',
      dialCode: '+86',
      flag: '🇨🇳',
      phonePattern: r'^1[3-9]\d{9}$',
      phoneLength: 11,
    ),
    CountryCode(
      name: '中国香港',
      code: 'HK',
      dialCode: '+852',
      flag: '🇭🇰',
      phonePattern: r'^[5-9]\d{7}$',
      phoneLength: 8,
    ),
    CountryCode(
      name: '中国澳门',
      code: 'MO',
      dialCode: '+853',
      flag: '🇲🇴',
      phonePattern: r'^6\d{7}$',
      phoneLength: 8,
    ),
    CountryCode(
      name: '中国台湾',
      code: 'TW',
      dialCode: '+886',
      flag: '🇹🇼',
      phonePattern: r'^9\d{8}$',
      phoneLength: 9,
    ),
    CountryCode(
      name: '美国',
      code: 'US',
      dialCode: '+1',
      flag: '🇺🇸',
      phonePattern: r'^\d{10}$',
      phoneLength: 10,
    ),
    CountryCode(
      name: '日本',
      code: 'JP',
      dialCode: '+81',
      flag: '🇯🇵',
      phonePattern: r'^\d{10}$',
      phoneLength: 10,
    ),
    CountryCode(
      name: '韩国',
      code: 'KR',
      dialCode: '+82',
      flag: '🇰🇷',
      phonePattern: r'^1[0-9]\d{7,8}$',
      phoneLength: 10,
    ),
    CountryCode(
      name: '新加坡',
      code: 'SG',
      dialCode: '+65',
      flag: '🇸🇬',
      phonePattern: r'^[89]\d{7}$',
      phoneLength: 8,
    ),
    CountryCode(
      name: '马来西亚',
      code: 'MY',
      dialCode: '+60',
      flag: '🇲🇾',
      phonePattern: r'^1[0-9]\d{7,8}$',
      phoneLength: 10,
    ),
    CountryCode(
      name: '英国',
      code: 'GB',
      dialCode: '+44',
      flag: '🇬🇧',
      phonePattern: r'^7\d{9}$',
      phoneLength: 10,
    ),
  ];

  /// 默认国家（中国大陆）
  static const CountryCode defaultCountry = CountryCode(
    name: '中国大陆',
    code: 'CN',
    dialCode: '+86',
    flag: '🇨🇳',
    phonePattern: r'^1[3-9]\d{9}$',
    phoneLength: 11,
  );

  /// 根据区号查找国家
  static CountryCode? findByDialCode(String dialCode) {
    try {
      return popularCountries.firstWhere(
        (country) => country.dialCode == dialCode,
      );
    } catch (e) {
      return null;
    }
  }

  /// 根据国家代码查找国家
  static CountryCode? findByCode(String code) {
    try {
      return popularCountries.firstWhere(
        (country) => country.code == code,
      );
    } catch (e) {
      return null;
    }
  }
}
