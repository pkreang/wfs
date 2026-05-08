class TerritoryModel {
  final String? salesTerritoryID;
  final String? salesRegionID;
  final String salesTerritoryName;
  final String salesTerritoryDescription;
  final String? createdBy;
  final String? modifiedBy;
  final bool isActive;

  const TerritoryModel({
    this.salesTerritoryID,
    this.salesRegionID,
    this.salesTerritoryName = '',
    this.salesTerritoryDescription = '',
    this.createdBy,
    this.modifiedBy,
    this.isActive = true,
  });

  factory TerritoryModel.fromJson(Map<String, dynamic> json) {
    return TerritoryModel(
      salesTerritoryID: json['SalesTerritoryID']?.toString(),
      salesRegionID: json['SalesRegionID']?.toString(),
      salesTerritoryName: json['SalesTerritoryName']?.toString() ?? '',
      salesTerritoryDescription: json['SalesTerritoryDescription']?.toString() ?? '',
      createdBy: json['CreatedBy']?.toString(),
      modifiedBy: json['ModifiedBy']?.toString(),
      isActive: json['IsActive'] as bool? ?? true,
    );
  }

  static List<TerritoryModel> listFromJson(List<dynamic> jsonList) => jsonList.map((e) => TerritoryModel.fromJson(e as Map<String, dynamic>)).toList();

  Map<String, dynamic> toJson() {
    return {
      'SalesTerritoryID': salesTerritoryID,
      'SalesRegionID': salesRegionID,
      'SalesTerritoryName': salesTerritoryName,
      'SalesTerritoryDescription': salesTerritoryDescription,
      'CreatedBy': createdBy,
      'ModifiedBy': modifiedBy,
      'IsActive': isActive,
    };
  }

  Map<String, dynamic> toJsonCreate(String userID) {
    return {
      if ((salesRegionID ?? '').isNotEmpty) 'SalesRegionID': salesRegionID,
      'SalesTerritoryName': salesTerritoryName,
      'SalesTerritoryDescription': salesTerritoryDescription,
      'CreatedBy': userID,
      'ModifiedBy': userID,
      'IsActive': isActive,
    };
  }

  Map<String, dynamic> toJsonUpdate(String userID) {
    return {
      if ((salesTerritoryID ?? '').isNotEmpty) 'SalesTerritoryID': salesTerritoryID,
      if ((salesRegionID ?? '').isNotEmpty) 'SalesRegionID': salesRegionID,
      'SalesTerritoryName': salesTerritoryName,
      'SalesTerritoryDescription': salesTerritoryDescription,
      'CreatedBy': createdBy ?? userID,
      'ModifiedBy': userID,
      'IsActive': isActive,
    };
  }

  TerritoryModel copyWith({
    String? salesTerritoryID,
    String? salesRegionID,
    String? salesTerritoryName,
    String? salesTerritoryDescription,
    String? createdBy,
    String? modifiedBy,
    bool? isActive,
  }) {
    return TerritoryModel(
      salesTerritoryID: salesTerritoryID ?? this.salesTerritoryID,
      salesRegionID: salesRegionID ?? this.salesRegionID,
      salesTerritoryName: salesTerritoryName ?? this.salesTerritoryName,
      salesTerritoryDescription: salesTerritoryDescription ?? this.salesTerritoryDescription,
      createdBy: createdBy ?? this.createdBy,
      modifiedBy: modifiedBy ?? this.modifiedBy,
      isActive: isActive ?? this.isActive,
    );
  }
}
