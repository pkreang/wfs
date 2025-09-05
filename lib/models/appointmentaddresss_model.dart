class AppointmentAddresss {
  String? address;
  int? countryID;
  int? provinceID;
  int? districtID;
  int? subDistrictID;
  int? latitude;
  int? longitude;
  bool? isPrimary;
  bool? isActive;

  String? subDistrictName;
  String? districtName;
  String? provinceName;
  String? countryName;
  String? postCode;
  AppointmentAddresss({
    this.address,
    this.countryID,
    this.provinceID,
    this.districtID,
    this.subDistrictID,
    this.latitude,
    this.longitude,
    this.isPrimary,
    this.isActive,
    this.subDistrictName,
    this.districtName,
    this.provinceName,
    this.countryName,
    this.postCode,
  });

  AppointmentAddresss.fromJson(Map<String, dynamic> json) {
    address = json['Address'];
    countryID = json['CountryID'];
    provinceID = json['ProvinceID'];
    districtID = json['DistrictID'];
    subDistrictID = json['SubDistrictID'];
    latitude = json['Latitude'];
    longitude = json['Longitude'];
    isPrimary = json['IsPrimary'];
    isActive = json['IsActive'];

    subDistrictName = json['SubDistrictName'];
    districtName = json['DistrictName'];
    provinceName = json['ProvinceName'];
    countryName = json['CountryName'];
    postCode = json['PostCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Address'] = this.address;
    data['CountryID'] = this.countryID;
    data['ProvinceID'] = this.provinceID;
    data['DistrictID'] = this.districtID;
    data['SubDistrictID'] = this.subDistrictID;
    data['Latitude'] = this.latitude;
    data['Longitude'] = this.longitude;
    data['IsPrimary'] = this.isPrimary;
    data['IsActive'] = this.isActive;

    data['SubDistrictName'] = this.subDistrictName;
    data['DistrictName'] = this.districtName;
    data['ProvinceName'] = this.provinceName;
    data['CountryName'] = this.countryName;
    data['PostCode'] = this.postCode;
    return data;
  }
}
