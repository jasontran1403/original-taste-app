import 'package:flutter/material.dart';
import 'package:original_taste/controller/my_controller.dart';
import 'package:original_taste/images.dart';

class OrderCheckoutController extends MyController {
  final formKey = GlobalKey<FormState>();
  int expandedIndex = 1;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController zipController = TextEditingController();
  final TextEditingController paypalEmailController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  String? selectedCity;
  String? selectedCountry;
  String selectedShippingMethod = 'Our Courier Services';

  final List<String> cities = [
    'London',
    'Manchester',
    'Liverpool',
    'Paris',
    'Lyon',
    'Marseille',
    'New York',
    'Michigan',
    'Madrid',
    'Toronto',
    'Vancouver',
  ];

  final List<String> countries = [
    'United Kingdom',
    'France',
    'Netherlands',
    'U.S.A',
    'Denmark',
    'Canada',
    'Australia',
    'India',
    'Germany',
    'Spain',
    'United Arab Emirates',
  ];

  final List<ShippingMethod> shippingMethods = [
    ShippingMethod('DHL Fast Services', 'Today', '\$10.00', Images.dhl),
    ShippingMethod('FedEx Services', 'Today', '\$10.00', Images.fedex),
    ShippingMethod('UPS Services', 'Tomorrow', '\$8.00', Images.ups),
    ShippingMethod('Our Courier Services', '25 Apr 2024', '\$0.00', null),
  ];
  final products = [
    {"image": "assets/product/p-1.png", "name": "Men Black Slim Fit T-shirt", "size": "M", "price": 83.00, "quantity": 1},
    {"image": "assets/product/p-5.png", "name": "Dark Green Cargo Pant", "size": "M", "price": 334.00, "quantity": 3},
    {"image": "assets/product/p-8.png", "name": "Men Dark Brown Wallet", "size": "S", "price": 137.00, "quantity": 1},
    {"image": "assets/product/p-10.png", "name": "Kid's Yellow T-shirt", "size": "S", "price": 223.00, "quantity": 2},
  ];
}

class ShippingMethod {
  final String title;
  final String deliveryTime;
  final String price;
  final String? image;

  ShippingMethod(this.title, this.deliveryTime, this.price, this.image);
}
