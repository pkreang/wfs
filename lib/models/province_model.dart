class Province {
  bool? isActive;
  String? provinceName;
  int? provinceID;
  int? countryID;

  Province({this.isActive, this.provinceName, this.provinceID, this.countryID});

  Province.fromJson(Map<String, dynamic> json) {
    isActive = json['IsActive'];
    provinceName = json['ProvinceName'];
    provinceID = json['ProvinceID'];
    countryID = json['CountryID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['IsActive'] = this.isActive;
    data['ProvinceName'] = this.provinceName;
    data['ProvinceID'] = this.provinceID;
    data['CountryID'] = this.countryID;
    return data;
  }
}
