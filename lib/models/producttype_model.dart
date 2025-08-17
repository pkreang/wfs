class ProductType {
  String? productTypeName;
  String? productTypeDescription;
  bool? isActive;
  String? createdDate;
  String? modifiedDate;
  String? productTypeID;
  String? productCategoryID;
  String? createdBy;
  String? modifiedBy;

  ProductType({
    this.productTypeName,
    this.productTypeDescription,
    this.isActive,
    this.createdDate,
    this.modifiedDate,
    this.productTypeID,
    this.productCategoryID,
    this.createdBy,
    this.modifiedBy,
  });

  ProductType.fromJson(Map<String, dynamic> json) {
    productTypeName = json['ProductTypeName'];
    productTypeDescription = json['ProductTypeDescription'];
    isActive = json['IsActive'];
    createdDate = json['CreatedDate'];
    modifiedDate = json['ModifiedDate'];
    productTypeID = json['ProductTypeID'];
    productCategoryID = json['ProductCategoryID'];
    createdBy = json['CreatedBy'];
    modifiedBy = json['ModifiedBy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ProductTypeName'] = this.productTypeName;
    data['ProductTypeDescription'] = this.productTypeDescription;
    data['IsActive'] = this.isActive;
    data['CreatedDate'] = this.createdDate;
    data['ModifiedDate'] = this.modifiedDate;
    data['ProductTypeID'] = this.productTypeID;
    data['ProductCategoryID'] = this.productCategoryID;
    data['CreatedBy'] = this.createdBy;
    data['ModifiedBy'] = this.modifiedBy;
    return data;
  }
}
