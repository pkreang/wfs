class CompanyAddress {
  final String? companyAddressID;
  final String? companyID;
  final String? address;
  final int? subDistrictID;
  final int? districtID;
  final int? provinceID;
  final int? countryID;
  final double? latitude;
  final double? longitude;
  final bool isPrimary;
  final bool isActive;

  final String? subDistrictName;
  final String? districtName;
  final String? provinceName;
  final String? countryName;
  final String? postCode;

  const CompanyAddress({
    this.companyAddressID,
    this.companyID,
    this.address,
    this.subDistrictID,
    this.districtID,
    this.provinceID,
    this.countryID,
    this.latitude,
    this.longitude,
    this.isPrimary = false,
    this.isActive = false,
    this.subDistrictName,
    this.districtName,
    this.provinceName,
    this.countryName,
    this.postCode,
  });

  factory CompanyAddress.fromJson(Map<String, dynamic> json) {
    return CompanyAddress(
      companyAddressID: json['CompanyAddressID'] as String?,
      companyID: json['CompanyID'] as String?,
      address: json['Address'] as String?,
      subDistrictID: json['SubDistrictID'] as int?,
      districtID: json['DistrictID'] as int?,
      provinceID: json['ProvinceID'] as int?,
      countryID: json['CountryID'] as int?,
      latitude: json['Latitude'] ?? 0.0,
      longitude: json['Longitude'] ?? 0.0,
      isPrimary: (json['IsPrimary'] as bool?) ?? false,
      isActive: (json['IsActive'] as bool?) ?? false,
      subDistrictName: json['SubDistrictName'] as String?,
      districtName: json['DistrictName'] as String?,
      provinceName: json['ProvinceName'] as String?,
      countryName: json['CountryName'] as String?,
      postCode: json['PostCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'CompanyAddressID': companyAddressID,
    'CompanyID': companyID,
    'Address': address,
    'SubDistrictID': subDistrictID,
    'DistrictID': districtID,
    'ProvinceID': provinceID,
    'CountryID': countryID,
    'Latitude': latitude,
    'Longitude': longitude,
    'IsPrimary': isPrimary,
    'IsActive': isActive,
    'SubDistrictName': subDistrictName,
    'DistrictName': districtName,
    'ProvinceName': provinceName,
    'CountryName': countryName,
    'PostCode': postCode,
  };

  static List<CompanyAddress> listFromJson(List<dynamic> jsonList) => jsonList.map((e) => CompanyAddress.fromJson(e as Map<String, dynamic>)).toList();

  CompanyAddress copyWith({
    String? companyAddressID,
    String? companyID,
    String? address,
    int? subDistrictID,
    int? districtID,
    int? provinceID,
    int? countryID,
    Object? latitude = _noValue,
    Object? longitude = _noValue,
    bool? isPrimary,
    bool? isActive,
    String? createdBy,
    DateTime? createdDate,
    String? modifiedBy,
    DateTime? modifiedDate,
    String? subDistrictName,
    String? districtName,
    String? provinceName,
    String? countryName,
    String? postCode,
  }) {
    return CompanyAddress(
      companyAddressID: companyAddressID ?? this.companyAddressID,
      companyID: companyID ?? this.companyID,
      address: address ?? this.address,
      subDistrictID: subDistrictID ?? this.subDistrictID,
      districtID: districtID ?? this.districtID,
      provinceID: provinceID ?? this.provinceID,
      countryID: countryID ?? this.countryID,
      latitude: latitude == _noValue ? this.latitude : latitude as double?,
      longitude: longitude == _noValue ? this.longitude : longitude as double?,
      isPrimary: isPrimary ?? this.isPrimary,
      isActive: isActive ?? this.isActive,
      subDistrictName: subDistrictName ?? this.subDistrictName,
      districtName: districtName ?? this.districtName,
      provinceName: provinceName ?? this.provinceName,
      countryName: countryName ?? this.countryName,
      postCode: postCode ?? this.postCode,
    );
  }

  static const _noValue = Object();
}
