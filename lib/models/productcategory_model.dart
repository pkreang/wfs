class ProductCategory {
  String? productCategoryID;
  bool? isActive;
  String? createdDate;
  String? modifiedDate;
  String? createdBy;
  String? productCategoryName;
  String? productCategoryDescription;
  String? modifiedBy;

  ProductCategory({
    this.productCategoryID,
    this.isActive,
    this.createdDate,
    this.modifiedDate,
    this.createdBy,
    this.productCategoryName,
    this.productCategoryDescription,
    this.modifiedBy,
  });

  ProductCategory.fromJson(Map<String, dynamic> json) {
    productCategoryID = json['ProductCategoryID'];
    isActive = json['IsActive'];
    createdDate = json['CreatedDate'];
    modifiedDate = json['ModifiedDate'];
    createdBy = json['CreatedBy'];
    productCategoryName = json['ProductCategoryName'];
    productCategoryDescription = json['ProductCategoryDescription'];
    modifiedBy = json['ModifiedBy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ProductCategoryID'] = this.productCategoryID;
    data['IsActive'] = this.isActive;
    data['CreatedDate'] = this.createdDate;
    data['ModifiedDate'] = this.modifiedDate;
    data['CreatedBy'] = this.createdBy;
    data['ProductCategoryName'] = this.productCategoryName;
    data['ProductCategoryDescription'] = this.productCategoryDescription;
    data['ModifiedBy'] = this.modifiedBy;
    return data;
  }
}
