class Product {
  String? productID;
  String? productName;
  String? productDescription;
  String? productSKU;
  double? unitPrice;
  String? productTypeID;
  bool? isActive;
  String? createdDate;
  String? modifiedDate;
  String? createdBy;
  String? modifiedBy;

  Product({
    this.productID,
    this.productName,
    this.productDescription,
    this.productSKU,
    this.unitPrice,
    this.productTypeID,
    this.isActive,
    this.createdDate,
    this.modifiedDate,
    this.createdBy,
    this.modifiedBy,
  });

  Product.fromJson(Map<String, dynamic> json) {
    if (json.length == 5) {
      json = json["Product"];
    }
    productID = json['ProductID'];
    productName = json['ProductName'];
    productDescription = json['ProductDescription'];
    productSKU = json['ProductSKU'];
    unitPrice = json['UnitPrice'];
    productTypeID = json['ProductTypeID'];
    isActive = json['IsActive'];
    createdDate = json['CreatedDate'];
    modifiedDate = json['ModifiedDate'];
    createdBy = json['CreatedBy'];
    modifiedBy = json['ModifiedBy'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ProductID'] = this.productID;
    data['ProductName'] = this.productName;
    data['ProductDescription'] = this.productDescription;
    data['ProductSKU'] = this.productSKU;
    data['UnitPrice'] = this.unitPrice;
    data['ProductTypeID'] = this.productTypeID;
    data['IsActive'] = this.isActive;
    data['CreatedDate'] = this.createdDate;
    data['ModifiedDate'] = this.modifiedDate;
    data['CreatedBy'] = this.createdBy;
    data['ModifiedBy'] = this.modifiedBy;
    return data;
  }
}
