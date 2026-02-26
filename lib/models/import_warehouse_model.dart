class ImportWarehouseModel {
  final String id;
  final String importerName;
  final DateTime importTime;
  final List<ImportProductItem> products;
  final bool isSaved;

  ImportWarehouseModel({
    required this.id,
    required this.importerName,
    required this.importTime,
    required this.products,
    this.isSaved = true,
  });

  ImportWarehouseModel copyWith({
    String? id,
    String? importerName,
    DateTime? importTime,
    List<ImportProductItem>? products,
    bool? isSaved,
  }) {
    return ImportWarehouseModel(
      id: id ?? this.id,
      importerName: importerName ?? this.importerName,
      importTime: importTime ?? this.importTime,
      products: products ?? this.products,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  factory ImportWarehouseModel.fromJson(Map<String, dynamic> json) {
    return ImportWarehouseModel(
      id: json['id'],
      importerName: json['importerName'],
      importTime: DateTime.parse(json['importTime']),
      products: (json['products'] as List)
          .map((item) => ImportProductItem.fromJson(item))
          .toList(),
      isSaved: json['isSaved'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'importerName': importerName,
      'importTime': importTime.toIso8601String(),
      'products': products.map((item) => item.toJson()).toList(),
      'isSaved': isSaved,
    };
  }
}

class ImportProductItem {
  final String productName;
  final DateTime manufacturingDate;
  final DateTime expiryDate;
  final String packageWeight;
  final String batchWeight;
  double quantity;

  ImportProductItem({
    required this.productName,
    required this.manufacturingDate,
    required this.expiryDate,
    required this.packageWeight,
    required this.batchWeight,
    this.quantity = 1,
  });

  factory ImportProductItem.fromJson(Map<String, dynamic> json) {
    return ImportProductItem(
      productName: json['productName'],
      manufacturingDate: DateTime.parse(json['manufacturingDate']),
      expiryDate: DateTime.parse(json['expiryDate']),
      packageWeight: json['packageWeight'],
      batchWeight: json['batchWeight'],
      quantity: json['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'manufacturingDate': manufacturingDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'packageWeight': packageWeight,
      'batchWeight': batchWeight,
      'quantity': quantity,
    };
  }

  ImportProductItem copyWith({double? quantity}) {
    return ImportProductItem(
      productName: productName,
      manufacturingDate: manufacturingDate,
      expiryDate: expiryDate,
      packageWeight: packageWeight,
      batchWeight: batchWeight,
      quantity: quantity ?? this.quantity,
    );
  }
}