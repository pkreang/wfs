class SalesTerritory {
  final String salesTerritoryID;
  final String salesTerritoryName;

  const SalesTerritory({required this.salesTerritoryID, required this.salesTerritoryName});

  factory SalesTerritory.fromJson(Map<String, dynamic> json) {
    return SalesTerritory(salesTerritoryID: json['SalesTerritoryID'] as String, salesTerritoryName: json['SalesTerritoryName'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'SalesTerritoryID': salesTerritoryID, 'SalesTerritoryName': salesTerritoryName};
  }

  SalesTerritory copyWith({String? salesTerritoryID, String? salesTerritoryName}) {
    return SalesTerritory(salesTerritoryID: salesTerritoryID ?? this.salesTerritoryID, salesTerritoryName: salesTerritoryName ?? this.salesTerritoryName);
  }
}
