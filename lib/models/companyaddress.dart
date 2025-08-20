class CompanyAddress {
  String? address;
  int? provinceID;
  int? districtID;
  int? latitude;
  bool? isPrimary;
  String? createdBy;
  String? modifiedBy;
  int? countryID;
  int? subDistrictID;
  int? longitude;
  bool? isActive;

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
    return data;
  }
}
