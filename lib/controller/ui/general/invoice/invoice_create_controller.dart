import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:original_taste/controller/my_controller.dart';

class InvoiceCreateController extends MyController {
  final picker = ImagePicker();
  File? logo;
  Future<void> pickLogo() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      logo = File(picked.path);
      update();
    }
  }

  final senderName = TextEditingController();
  final senderAddress = TextEditingController();
  final senderPhone = TextEditingController();
  final invoiceNo = TextEditingController(text: "#INV-0758267/90");
  final issueDate = TextEditingController();
  final dueDate = TextEditingController();
  final amount = TextEditingController();
  String status = "Paid";

  final buyerName = TextEditingController();
  final buyerAddress = TextEditingController();
  final buyerPhone = TextEditingController();
  final buyerEmail = TextEditingController();

  final issuerName = TextEditingController();
  final issuerAddress = TextEditingController();
  final issuerPhone = TextEditingController();
  final issuerEmail = TextEditingController();

  // Product fields
  final productName = TextEditingController();
  final productSize = TextEditingController();
  final productPrice = TextEditingController();
  final productTax = TextEditingController();
  final productQty = TextEditingController(text: "1");
  double get productTotal {
    final p = double.tryParse(productPrice.text) ?? 0;
    final t = double.tryParse(productTax.text) ?? 0;
    final q = double.tryParse(productQty.text) ?? 0;
    return (p + t) * q;
  }

  final subTotal = TextEditingController();
  final discount = TextEditingController();
  final estimatedTax = TextEditingController();
  final grandTotal = TextEditingController();

  void recalculateTotals() {
    final st = productTotal;
    final disc = double.tryParse(discount.text) ?? 0;
    final estTax = double.tryParse(estimatedTax.text) ?? 0;
    final grand = st - disc + estTax;
    subTotal.text = st.toStringAsFixed(2);
    grandTotal.text = grand.toStringAsFixed(2);
  }

  @override
  void onInit() {
    discount.addListener(recalculateTotals);
    estimatedTax.addListener(recalculateTotals);
    productPrice.addListener(recalculateTotals);
    productTax.addListener(recalculateTotals);
    productQty.addListener(recalculateTotals);
    super.onInit();
  }

  @override
  void dispose() {
    discount.dispose();
    estimatedTax.dispose();
    productPrice.dispose();
    productTax.dispose();
    productQty.dispose();
    super.dispose();
  }
}
