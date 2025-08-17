class Country {
  String? countryName;
  bool? isActive;
  int? countryID;

  Country({this.countryName, this.isActive, this.countryID});

  Country.fromJson(Map<String, dynamic> json) {
    countryName = json['CountryName'];
    isActive = json['IsActive'];
    countryID = json['CountryID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CountryName'] = this.countryName;
    data['IsActive'] = this.isActive;
    data['CountryID'] = this.countryID;
    return data;
  }
}
