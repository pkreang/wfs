class CompanyAddress {
  String? address;
  int? provinceID;
  int? districtID;
  int? countryID;
  int? subDistrictID;
  int? latitude;
  bool? isPrimary;
  String? createdBy;
  String? modifiedBy;
  int? longitude;
  bool? isActive;
  String? provinceName;
  String? districtName;
  String? countryName;
  String? subDistrictName;
  String? postCode;

  CompanyAddress({
    this.address,
    this.provinceID,
    this.districtID,
    this.latitude,
    this.isPrimary,
    this.createdBy,
    this.modifiedBy,
    this.countryID,
    this.subDistrictID,
    this.longitude,
    this.isActive,
    this.provinceName,
    this.districtName,
    this.countryName,
    this.subDistrictName,
    this.postCode,
  });

  CompanyAddress.fromJson(Map<String, dynamic> json) {
    address = json['Address'];
    provinceID = json['ProvinceID'];
    districtID = json['DistrictID'];
    latitude = json['Latitude'];
    isPrimary = json['IsPrimary'];
    createdBy = json['CreatedBy'];
    modifiedBy = json['ModifiedBy'];
    countryID = json['CountryID'];
    subDistrictID = json['SubDistrictID'];
    longitude = json['Longitude'];
    isActive = json['IsActive'];

    provinceName = json['ProvinceName'];
    districtName = json['DistrictName'];
    countryName = json['CountryName'];
    subDistrictName = json['SubDistrictName'];
    postCode = json['PostCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Address'] = this.address;
    data['ProvinceID'] = this.provinceID;
    data['DistrictID'] = this.districtID;
    data['Latitude'] = this.latitude;
    data['IsPrimary'] = this.isPrimary;
    data['CreatedBy'] = this.createdBy;
    data['ModifiedBy'] = this.modifiedBy;
    data['CountryID'] = this.countryID;
    data['SubDistrictID'] = this.subDistrictID;
    data['Longitude'] = this.longitude;
    data['IsActive'] = this.isActive;

    data['ProvinceName'] = this.provinceName;
    data['DistrictName'] = this.districtName;
    data['CountryName'] = this.countryName;
    data['SubDistrictName'] = this.subDistrictName;
    data['PostCode'] = this.postCode;
    return data;
  }
}
