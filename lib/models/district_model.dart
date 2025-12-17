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
    final id = json['DistrictID'] ?? json['districtID'] ?? json['DistrictId'];
    districtID = id is String ? int.tryParse(id) : id;
    districtName = json['DistrictName'];
    final pId = json['ProvinceID'] ?? json['provinceID'] ?? json['ProvinceId'];
    provinceID = pId is String ? int.tryParse(pId) : pId;
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
