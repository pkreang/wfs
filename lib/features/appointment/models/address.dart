class Address {
  final double? latitude;
  final double? longitude;
  final String address;
  final int subDistrictId;
  final String subDistrictName;
  final int districtId;
  final String districtName;
  final int provinceId;
  final String provinceName;
  final String postCode;
  final int countryId;
  final String countryName;

  Address({
    this.latitude,
    this.longitude,
    required this.address,
    required this.subDistrictId,
    required this.subDistrictName,
    required this.districtId,
    required this.districtName,
    required this.provinceId,
    required this.provinceName,
    required this.postCode,
    required this.countryId,
    required this.countryName,
  });


  

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    latitude: json["Latitude"],
    longitude: json["Longitude"],
    address: json["Address"],
    subDistrictId: json["SubDistrictID"],
    subDistrictName: json["SubDistrictName"] ?? '',
    districtId: json["DistrictID"],
    districtName: json["DistrictName"] ?? '',
    provinceId: json["ProvinceID"],
    provinceName: json["ProvinceName"] ?? '',
    postCode: json["PostCode"] ?? '',
    countryId: json["CountryID"],
    countryName: json["CountryName"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "Latitude": latitude,
    "Longitude": longitude,
    "Address": address,
    "SubDistrictName": subDistrictName,
    "DistrictName": districtName,
    "ProvinceName": provinceName,
    "PostCode": postCode,
    "CountryName": countryName,
  };

  Address copyWith({
    double? latitude,
    double? longitude,
    String? address,
    int? subDistrictId,
    String? subDistrictName,
    int? districtId,
    String? districtName,
    int? provinceId,
    String? provinceName,
    String? postCode,
    int? countryId,
    String? countryName,
  }) {
    return Address(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      subDistrictId: subDistrictId ?? this.subDistrictId,
      subDistrictName: subDistrictName ?? this.subDistrictName,
      districtId: districtId ?? this.districtId,
      districtName: districtName ?? this.districtName,
      provinceId: provinceId ?? this.provinceId,
      provinceName: provinceName ?? this.provinceName,
      postCode: postCode ?? this.postCode,
      countryId: countryId ?? this.countryId,
      countryName: countryName ?? this.countryName,
    );
  }
}

extension AddressFormatter on Address {
  String get fullAddress {
    final parts = [address, subDistrictName, districtName, provinceName, postCode, countryName].where((e) => e.isNotEmpty).join(' ');
    return parts;
  }
}
