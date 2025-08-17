class Subdistrict {
  String? postCode;
  int? subDistrictID;
  String? subDistrictName;
  int? districtID;
  bool? isActive;

  Subdistrict({
    this.postCode,
    this.subDistrictID,
    this.subDistrictName,
    this.districtID,
    this.isActive,
  });

  Subdistrict.fromJson(Map<String, dynamic> json) {
    postCode = json['PostCode'];
    subDistrictID = json['SubDistrictID'];
    subDistrictName = json['SubDistrictName'];
    districtID = json['DistrictID'];
    isActive = json['IsActive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['PostCode'] = this.postCode;
    data['SubDistrictID'] = this.subDistrictID;
    data['SubDistrictName'] = this.subDistrictName;
    data['DistrictID'] = this.districtID;
    data['IsActive'] = this.isActive;
    return data;
  }
}
