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
      latitude: json['Latitude'],
      longitude: json['Longitude'],
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
    'CountryID': countryID ?? 1,
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

  Map<String, dynamic> toJsonUpdate() => {
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
    "CreatedBy": null,
    "ModifiedBy": null,
  };

  // [
  //   {
  //     "Address": "123 ABC Rd.",
  //     "ProvinceID": 1,
  //     "DistrictID": 13,
  //     "Latitude": null,
  //     "IsPrimary": true,
  //     "CreatedBy": null,
  //     "ModifiedBy": null,
  //     "CountryID": 1,
  //     "SubDistrictID": 2583,
  //     "Longitude": null,
  //     "IsActive": true,
  //   },
  // ],

  static List<CompanyAddress> listFromJson(List<dynamic> jsonList) => jsonList.map((e) => CompanyAddress.fromJson(e as Map<String, dynamic>)).toList();

  // Address copyWith({
  //   Object? latitude = _noValue,
  //   Object? longitude = _noValue,
  //   Object? address = _noValue,
  //   Object? subDistrictID = _noValue,
  //   Object? subDistrictName = _noValue,
  //   Object? districtID = _noValue,
  //   Object? districtName = _noValue,
  //   Object? provinceID = _noValue,
  //   Object? provinceName = _noValue,
  //   Object? postCode = _noValue,
  //   Object? countryID = _noValue,
  //   Object? countryName = _noValue,
  // }) {
  //   return Address(
  //     latitude: latitude == _noValue ? this.latitude : latitude as double?,
  //     longitude: longitude == _noValue ? this.longitude : longitude as double?,
  //     address: address == _noValue ? this.address : address as String?,
  //     subDistrictID: subDistrictID == _noValue ? this.subDistrictID : subDistrictID as int?,
  //     subDistrictName: subDistrictName == _noValue ? this.subDistrictName : subDistrictName as String?,
  //     districtID: districtID == _noValue ? this.districtID : districtID as int?,
  //     districtName: districtName == _noValue ? this.districtName : districtName as String?,
  //     provinceID: provinceID == _noValue ? this.provinceID : provinceID as int?,
  //     provinceName: provinceName == _noValue ? this.provinceName : provinceName as String?,
  //     postCode: postCode == _noValue ? this.postCode : postCode as String?,
  //     countryID: countryID == _noValue ? this.countryID : countryID as int?,
  //     countryName: countryName == _noValue ? this.countryName : countryName as String?,
  //   );
  // }

  // static const _noValue = Object();

  CompanyAddress copyWith({
    Object? companyAddressID = _noValue,
    Object? companyID = _noValue,
    Object? address = _noValue,
    Object? subDistrictID = _noValue,
    Object? districtID = _noValue,
    Object? provinceID = _noValue,
    Object? countryID = _noValue,
    Object? latitude = _noValue,
    Object? longitude = _noValue,
    Object? isPrimary = _noValue,
    Object? isActive = _noValue,
    Object? subDistrictName = _noValue,
    Object? districtName = _noValue,
    Object? provinceName = _noValue,
    Object? countryName = _noValue,
    Object? postCode = _noValue,
  }) {
    return CompanyAddress(
      companyAddressID: companyAddressID == _noValue ? this.companyAddressID : companyAddressID as String?,
      companyID: companyID == _noValue ? this.companyID : companyID as String?,
      address: address == _noValue ? this.address : address as String?,
      subDistrictID: subDistrictID == _noValue ? this.subDistrictID : subDistrictID as int?,
      districtID: districtID == _noValue ? this.districtID : districtID as int?,
      provinceID: provinceID == _noValue ? this.provinceID : provinceID as int?,
      countryID: countryID == _noValue ? this.countryID : countryID as int?,
      latitude: latitude == _noValue ? this.latitude : latitude as double?,
      longitude: longitude == _noValue ? this.longitude : longitude as double?,
      isPrimary: isPrimary == _noValue ? this.isPrimary : isPrimary as bool,
      isActive: isActive == _noValue ? this.isActive : isActive as bool,
      subDistrictName: subDistrictName == _noValue ? this.subDistrictName : subDistrictName as String?,
      districtName: districtName == _noValue ? this.districtName : districtName as String?,
      provinceName: provinceName == _noValue ? this.provinceName : provinceName as String?,
      countryName: countryName == _noValue ? this.countryName : countryName as String?,
      postCode: postCode == _noValue ? this.postCode : postCode as String?,
    );
  }

  static const _noValue = Object();
}

extension AddressFormatter on CompanyAddress {
  String get fullAddress {
    final parts = [address, subDistrictName, districtName, provinceName, postCode, countryName].where((e) => (e ?? '').isNotEmpty).join(' ');
    return parts;
  }
}
