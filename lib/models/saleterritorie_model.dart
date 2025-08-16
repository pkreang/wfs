class SaleTerritorie {
  String? salesRegionID;
  String? salesTerritoryID;
  String? createdBy;
  String? createdDate;
  String? modifiedDate;
  String? salesTerritoryName;
  String? salesTerritoryDescription;
  bool? isActive;
  String? modifiedBy;

  SaleTerritorie({
    this.salesRegionID,
    this.salesTerritoryID,
    this.createdBy,
    this.createdDate,
    this.modifiedDate,
    this.salesTerritoryName,
    this.salesTerritoryDescription,
    this.isActive,
    this.modifiedBy,
  });

  SaleTerritorie.fromJson(Map<String, dynamic> json) {
    salesRegionID = json['SalesRegionID'];
    salesTerritoryID = json['SalesTerritoryID'];
    createdBy = json['CreatedBy'];
    createdDate = json['CreatedDate'];
    modifiedDate = json['ModifiedDate'];
    salesTerritoryName = json['SalesTerritoryName'];
    salesTerritoryDescription = json['SalesTerritoryDescription'];
    isActive = json['IsActive'];
    modifiedBy = json['ModifiedBy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SalesRegionID'] = this.salesRegionID;
    data['SalesTerritoryID'] = this.salesTerritoryID;
    data['CreatedBy'] = this.createdBy;
    data['CreatedDate'] = this.createdDate;
    data['ModifiedDate'] = this.modifiedDate;
    data['SalesTerritoryName'] = this.salesTerritoryName;
    data['SalesTerritoryDescription'] = this.salesTerritoryDescription;
    data['IsActive'] = this.isActive;
    data['ModifiedBy'] = this.modifiedBy;
    return data;
  }
}
