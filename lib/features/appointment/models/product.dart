class Product {
  final String productId;
  final String productName;

  Product({required this.productId, required this.productName});

  factory Product.fromJson(Map<String, dynamic> json) => Product(productId: json["ProductID"], productName: json["ProductName"] ?? '');

  Map<String, dynamic> toJson() => {"ProductID": productId, "ProductName": productName};

  static List<Product> listFromJson(List<dynamic> jsonList) => jsonList.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();

  static List<String> listFromJsonString(List<dynamic> jsonList) => jsonList.map((e) => e as String).toList();
}
