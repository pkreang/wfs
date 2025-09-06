class Territory {
  final String salesTerritoryID;
  final String salesTerritoryName;

  Territory({required this.salesTerritoryID, required this.salesTerritoryName});

  factory Territory.fromJson(Map<String, dynamic> json) {
    return Territory(salesTerritoryID: json['SalesTerritoryID'] as String, salesTerritoryName: json['SalesTerritoryName'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'SalesTerritoryID': salesTerritoryID, 'SalesTerritoryName': salesTerritoryName};
  }

  static List<Territory> listFromJson(List<dynamic> jsonList) => jsonList.map((e) => Territory.fromJson(e as Map<String, dynamic>)).toList();
}
