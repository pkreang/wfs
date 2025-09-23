// class Company {
//   final String companyID;
//   final String companyName;

//   Company({required this.companyID, required this.companyName});

//   factory Company.fromJson(Map<String, dynamic> json) {
//     return Company(companyID: json['CompanyID'] as String, companyName: json['CompanyName'] as String);
//   }

//   Map<String, dynamic> toJson() {
//     return {'CompanyID': companyID, 'CompanyName': companyName};
//   }

//   static List<Company> listFromJson(List<dynamic> jsonList) => jsonList.map((e) => Company.fromJson(e as Map<String, dynamic>)).toList();
// }
