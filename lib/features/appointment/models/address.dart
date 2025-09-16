class Address {
  final double? latitude;
  final double? longitude;
  final String? address;
  final int? subDistrictID;
  final String? subDistrictName;
  final int? districtID;
  final String? districtName;
  final int? provinceID;
  final String? provinceName;
  final String? postCode;
  final int? countryID;
  final String? countryName;

  Address({
    this.latitude,
    this.longitude,
    this.address,
    this.subDistrictID,
    this.subDistrictName,
    this.districtID,
    this.districtName,
    this.provinceID,
    this.provinceName,
    this.postCode,
    this.countryID,
    this.countryName,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    latitude: json["Latitude"],
    longitude: json["Longitude"],
    address: json["Address"] ?? '',
    subDistrictID: json["SubDistrictID"],
    subDistrictName: json["SubDistrictName"] ?? '',
    districtID: json["DistrictID"],
    districtName: json["DistrictName"] ?? '',
    provinceID: json["ProvinceID"],
    provinceName: json["ProvinceName"] ?? '',
    postCode: json["PostCode"] ?? '',
    countryID: json["CountryID"],
    countryName: json["CountryName"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "Latitude": latitude,
    "Longitude": longitude,
    "Address": address,
    "SubDistrictID": subDistrictID,
    "SubDistrictName": subDistrictName,
    "DistrictID": districtID,
    "DistrictName": districtName,
    "ProvinceID": provinceID,
    "ProvinceName": provinceName,
    "PostCode": postCode,
    "CountryID": countryID,
    "CountryName": countryName,
  };

  Address copyWith({
    Object? latitude = _noValue,
    Object? longitude = _noValue,
    Object? address = _noValue,
    Object? subDistrictID = _noValue,
    Object? subDistrictName = _noValue,
    Object? districtID = _noValue,
    Object? districtName = _noValue,
    Object? provinceID = _noValue,
    Object? provinceName = _noValue,
    Object? postCode = _noValue,
    Object? countryID = _noValue,
    Object? countryName = _noValue,
  }) {
    return Address(
      latitude: latitude == _noValue ? this.latitude : latitude as double?,
      longitude: longitude == _noValue ? this.longitude : longitude as double?,
      address: address == _noValue ? this.address : address as String?,
      subDistrictID: subDistrictID == _noValue ? this.subDistrictID : subDistrictID as int?,
      subDistrictName: subDistrictName == _noValue ? this.subDistrictName : subDistrictName as String?,
      districtID: districtID == _noValue ? this.districtID : districtID as int?,
      districtName: districtName == _noValue ? this.districtName : districtName as String?,
      provinceID: provinceID == _noValue ? this.provinceID : provinceID as int?,
      provinceName: provinceName == _noValue ? this.provinceName : provinceName as String?,
      postCode: postCode == _noValue ? this.postCode : postCode as String?,
      countryID: countryID == _noValue ? this.countryID : countryID as int?,
      countryName: countryName == _noValue ? this.countryName : countryName as String?,
    );
  }

  static const _noValue = Object();
}

extension AddressFormatter on Address {
  String get fullAddress {
    final parts = [address, subDistrictName, districtName, provinceName, postCode, countryName].where((e) => (e ?? '').isNotEmpty).join(' ');
    return parts;
  }
}
