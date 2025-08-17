class District {
  bool? isActive;
  int? districtID;
  String? districtName;
  int? provinceID;

  District({
    this.isActive,
    this.districtID,
    this.districtName,
    this.provinceID,
  });

  District.fromJson(Map<String, dynamic> json) {
    isActive = json['IsActive'];
    districtID = json['DistrictID'];
    districtName = json['DistrictName'];
    provinceID = json['ProvinceID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['IsActive'] = this.isActive;
    data['DistrictID'] = this.districtID;
    data['DistrictName'] = this.districtName;
    data['ProvinceID'] = this.provinceID;
    return data;
  }
}
