import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:original_taste/controller/ui/general/orders/order_checkout_controller.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_button.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_flex.dart';
import 'package:original_taste/helper/widgets/my_flex_item.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/helper/widgets/my_text_style.dart';
import 'package:original_taste/views/layout/layout.dart';

class OrderCheckoutScreen extends StatefulWidget {
  const OrderCheckoutScreen({super.key});

  @override
  State<OrderCheckoutScreen> createState() => _OrderCheckoutScreenState();
}

class _OrderCheckoutScreenState extends State<OrderCheckoutScreen> with UIMixin {
  late OrderCheckoutController controller;

  @override
  void initState() {
    controller = Get.put(OrderCheckoutController());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      tag: 'order_checkout_controller',
      builder: (controller) {
        return Layout(
          screenName: "ORDER CHECKOUT",
          child: MyFlex(
            children: [
              MyFlexItem(
                sizes: 'lg-8',
                child: MyCard(
                  shadow: MyShadow(elevation: .7, position: MyShadowPosition.bottom),
                  paddingAll: 24,
                  borderRadiusAll: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [personalDetails(), MySpacing.height(12), shippingDetails(), MySpacing.height(12), paymentMethod()],
                  ),
                ),
              ),
              MyFlexItem(
                sizes: 'lg-4',
                child: Column(
                  children: [
                    promoCode(),
                    MySpacing.height(12),
                    orderSummary(),
                    MySpacing.height(20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        MyContainer(
                          color: contentTheme.danger,
                          borderRadiusAll: 12,
                          paddingAll: 12,
                          child: MyText.bodyMedium("Back to cart", color: contentTheme.onDanger),
                        ),
                        MySpacing.width(12),
                        MyContainer(
                          color: contentTheme.success,
                          paddingAll: 12,
                          borderRadiusAll: 12,
                          child: MyText.bodyMedium("Checkout Order", color: contentTheme.onSuccess),
                        ),
                      ],
                    ),
                    MySpacing.height(20),
                    MyContainer(
                      borderRadiusAll: 12,
                      paddingAll: 20,
                      color: contentTheme.dark,
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyContainer(
                                paddingAll: 4,
                                height: 44,
                                width: 44,
                                borderRadiusAll: 12,
                                color: contentTheme.secondary.withValues(alpha: 0.1),
                                child: SvgPicture.asset('assets/svg/box.svg'),
                              ),
                              MySpacing.width(12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyText.bodyMedium("Streaming box shipping information", color: contentTheme.onDark),
                                    MySpacing.height(2),
                                    MyText.bodyMedium(
                                      "Below your selected items, enter your zip code to calculate the shipping charge. We like to make shipping simple and affordable!",
                                      color: contentTheme.onDark.withValues(alpha: 0.4),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          MySpacing.height(12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyContainer(
                                paddingAll: 4,
                                height: 44,
                                width: 44,
                                borderRadiusAll: 12,
                                color: contentTheme.secondary.withValues(alpha: 0.1),
                                child: SvgPicture.asset(
                                  'assets/svg/wallet_money_bold.svg',
                                  colorFilter: ColorFilter.mode(contentTheme.success, BlendMode.srcIn),
                                ),
                              ),
                              MySpacing.width(12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyText.bodyMedium("30 Day money back guarantee", color: contentTheme.onDark),
                                    MySpacing.height(2),
                                    MyText.bodyMedium(
                                      "Money Return In 30 day In Your Bank Account",
                                      color: contentTheme.onDark.withValues(alpha: 0.4),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget personalDetails() {
    return Form(
      key: controller.formKey,
      child: MyFlex(
        children: [
          MyFlexItem(
            sizes: 'lg-2',
            child: MyText.titleMedium(
              "Personal Details",
              style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontWeight: FontWeight.w600),
            ),
          ),
          MyFlexItem(
            sizes: 'lg-10',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: customTextField("First Name", "First Name", controller.firstNameController)),
                    MySpacing.width(16),
                    Expanded(child: customTextField("Last Name", "Last Name", controller.lastNameController)),
                  ],
                ),
                MySpacing.height(12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(child: customTextField("Your email", "Email", controller.emailController)),
                    MySpacing.width(16),
                    Expanded(child: customTextField("Phone Number", "Number", controller.phoneController)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget shippingDetails() {
    return MyFlex(
      children: [
        MyFlexItem(
          sizes: 'lg-2',
          child: MyText.titleMedium(
            "Shipping Details",
            style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontWeight: FontWeight.w600),
          ),
        ),
        MyFlexItem(
          sizes: 'lg-10',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText.titleMedium(
                "Shipping Address:",
                style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontWeight: FontWeight.w600),
              ),
              MySpacing.height(12),
              customTextField("Full Address", "Enter address", controller.addressController, maxLines: 3),
              MySpacing.height(12),
              MyFlex(
                contentPadding: false,
                children: [
                  MyFlexItem(
                    sizes: 'lg-4',
                      child: Expanded(child: customTextField("Zip-Code", "zip-code", controller.zipController))),
                  MyFlexItem(
                    sizes: 'lg-4',

                    child: Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText.bodyMedium("City", fontWeight: 600),
                          MySpacing.height(12),
                          DropdownButtonFormField<String>(
                            value: controller.selectedCity,
                            items:
                                controller.cities.map((city) {
                                  return DropdownMenuItem(value: city, child: Text(city));
                                }).toList(),
                            dropdownColor: contentTheme.disabled,
                            onChanged: (val) => setState(() => controller.selectedCity = val),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: contentTheme.secondary),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: contentTheme.secondary),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: contentTheme.secondary),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: contentTheme.secondary),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: contentTheme.secondary),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: contentTheme.secondary),
                              ),
                              contentPadding: MySpacing.all(16),
                              isDense: true,
                              hintText: "City",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  MyFlexItem(
                    sizes: 'lg-4',

                    child: Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText.bodyMedium("Country", fontWeight: 600),
                          MySpacing.height(12),
                          DropdownButtonFormField<String>(
                            value: controller.selectedCountry,
                            items:
                                controller.countries.map((country) {
                                  return DropdownMenuItem(value: country, child: Text(country));
                                }).toList(),
                            dropdownColor: contentTheme.disabled,
                            onChanged: (val) => setState(() => controller.selectedCountry = val),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: contentTheme.secondary),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: contentTheme.secondary),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: contentTheme.secondary),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: contentTheme.secondary),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: contentTheme.secondary),
                              ),
                              disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: contentTheme.secondary),
                              ),
                              contentPadding: MySpacing.all(16),
                              isDense: true,
                              hintText: "Country",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              MySpacing.height(12),
              MyButton.text(
                splashColor: contentTheme.primary.withValues(alpha: 0.2),
                padding: MySpacing.x(12),
                onPressed: () {},
                child: MyText.bodyMedium("+ Add New Billing Address", color: contentTheme.primary),
              ),
              MySpacing.height(12),
              MyText.bodyMedium("Shipping Method:", fontWeight: 600),
              MySpacing.height(12),
              Wrap(
                runSpacing: 16,
                spacing: 16,
                children:
                    controller.shippingMethods.map((method) {
                      return MyContainer.bordered(
                        borderRadiusAll: 12,
                        onTap: () => setState(() => controller.selectedShippingMethod = method.title),
                        width: MediaQuery.of(context).size.width / 4.4 - 55,
                        padding: const EdgeInsets.all(12),
                        border: controller.selectedShippingMethod == method.title ? Border.all(color: contentTheme.primary, width: 2) : null,
                        child: Row(
                          children: [
                            if (method.image != null)
                              MyContainer(
                                height: 50,
                                width: 50,
                                paddingAll: 4,
                                color: contentTheme.secondary.withValues(alpha: 0.2),
                                child: Image.asset(method.image!, fit: BoxFit.contain),
                              )
                            else
                              const Icon(Icons.local_shipping, size: 36, color: Colors.amber),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [MyText.titleMedium(method.title), MyText.bodyMedium("Delivery - ${method.deliveryTime}")],
                              ),
                            ),
                            Column(
                              children: [
                                MyText.bodyMedium(method.price),
                                Radio<String>(
                                  value: method.title,
                                  groupValue: controller.selectedShippingMethod,
                                  onChanged: (value) => setState(() => controller.selectedShippingMethod = value!),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget paymentMethod() {
    return MyFlex(
      children: [
        MyFlexItem(
          sizes: 'lg-2',
          child: MyText.titleMedium(
            "Payment Method",
            style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontWeight: FontWeight.w600),
          ),
        ),
        MyFlexItem(
          sizes: 'lg-10',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyCard(
                paddingAll: 0,
                borderRadiusAll: 12,
                clipBehavior: Clip.antiAlias,
                shadow: MyShadow(elevation: .7, position: MyShadowPosition.bottom),
                child: Column(
                  children: [
                    MyContainer(
                      color: contentTheme.secondary.withValues(alpha: 0.2),
                      paddingAll: 8,
                      child: Row(
                        children: [Expanded(child: MyText.bodyMedium("Paypal")), SvgPicture.asset('assets/card/paypal.svg', height: 44, width: 44)],
                      ),
                    ),
                    Divider(height: 0),
                    Padding(
                      padding: MySpacing.all(20),
                      child: MyText.bodyMedium("Safe Payment Online Credit card needed. PayPal account is not necessary"),
                    ),
                  ],
                ),
              ),
              MySpacing.height(12),
              MyCard(
                paddingAll: 0,
                borderRadiusAll: 12,
                clipBehavior: Clip.antiAlias,
                shadow: MyShadow(elevation: .7, position: MyShadowPosition.bottom),
                child: Column(
                  children: [
                    MyContainer(
                      color: contentTheme.secondary.withValues(alpha: 0.2),
                      paddingAll: 12,
                      child: Row(
                        children: [
                          Expanded(child: MyText.bodyMedium("Credit Card")),
                          SvgPicture.asset('assets/card/mastercard.svg', height: 44, width: 44),
                          MySpacing.width(8),
                          SvgPicture.asset('assets/card/stripe.svg', height: 44, width: 44),
                          MySpacing.width(8),
                          SvgPicture.asset('assets/card/visa.svg', height: 44, width: 44),
                        ],
                      ),
                    ),
                    Divider(height: 0),
                    Padding(
                      padding: MySpacing.all(20),
                      child: MyText.bodyMedium("Safe Money Transfer using your bank account. Visa , Master Card ,Discover , American Express"),
                    ),
                    Divider(height: 0),
                    Padding(
                      padding: MySpacing.all(20),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: controller.cardNumberController,
                            keyboardType: TextInputType.number,
                            maxLength: 16,
                            decoration: InputDecoration(
                              labelText: 'Card Number',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              counterText: '',
                              contentPadding: MySpacing.all(16),
                              isDense: true,
                            ),
                            validator: (value) {
                              if (value == null || value.length != 16) {
                                return 'Enter valid 16-digit card number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: controller.expiryDateController,
                                  keyboardType: TextInputType.datetime,
                                  decoration: InputDecoration(
                                    labelText: 'Expiry Date',
                                    hintText: 'MM/YY',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    contentPadding: MySpacing.all(16),
                                    isDense: true,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Enter expiry date';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: controller.cvvController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 3,
                                  decoration: InputDecoration(
                                    labelText: 'CVV',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    counterText: '',
                                    contentPadding: MySpacing.all(16),
                                    isDense: true,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.length != 3) {
                                      return 'Enter valid CVV';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              children: const [
                                Icon(Icons.verified_user, color: Colors.green),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "We adhere entirely to the data security standards of the payment card industry.",
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget customTextField(String title, String hintText, TextEditingController controller, {int? maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.bodyMedium(title, fontWeight: 600),
        MySpacing.height(12),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: contentTheme.secondary)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: contentTheme.secondary)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: contentTheme.secondary)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: contentTheme.secondary)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: contentTheme.secondary)),
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: contentTheme.secondary)),
            contentPadding: MySpacing.all(16),
            isDense: true,
            hintText: hintText,
          ),
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }

  Widget promoCode() {
    return MyContainer(
      color: contentTheme.primary,
      borderRadiusAll: 12,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyText.titleMedium("Have a promo code?", color: contentTheme.onPrimary),
            MySpacing.height(12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: TextEditingController(text: "CODE123"),
                    style: MyTextStyle.bodyMedium(),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: contentTheme.disabled.withValues(alpha: 0.2),
                      contentPadding: MySpacing.all(16),
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                MySpacing.width(12),
                MyContainer(paddingAll: 12, borderRadiusAll: 12, onTap: () {}, child: MyText.bodyMedium("Apply")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget orderSummary() {
    Widget buildSummaryRow(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Expanded(child: MyText.bodyMedium(label)), MyText.bodyMedium(value)],
        ),
      );
    }

    return MyCard(
      paddingAll: 0,
      borderRadiusAll: 12,
      shadow: MyShadow(elevation: .7, position: MyShadowPosition.bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.all(20),
            child: MyText.titleMedium(
              "Personal Details",
              style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontWeight: FontWeight.w600),
            ),
          ),
          Divider(height: 0),
          Padding(
            padding: MySpacing.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListView.separated(
                  itemCount: controller.products.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final product = controller.products[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyContainer(
                          height: 48,
                          width: 48,
                          paddingAll: 0,
                          borderRadiusAll: 12,
                          color: contentTheme.secondary.withValues(alpha: 0.1),
                          child: Image.asset(product['image'].toString()),
                        ),
                        MySpacing.width(20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText.bodyMedium(product['name'].toString()),
                              MySpacing.height(12),
                              MyText.labelMedium('Size : ${product['size']}'),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            MyText.bodyMedium('\$${product['price']}.00'),
                            MySpacing.height(12),
                            MyText.bodyMedium('0.${product['quantity']}'),
                          ],
                        ),
                      ],
                    );
                  },
                  separatorBuilder: (context, index) {
                    return MySpacing.height(20);
                  },
                ),
                MySpacing.height(12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildSummaryRow("Sub Total :", "\$777.00"),
                    Divider(),
                    buildSummaryRow("Discount :", "-\$60.00"),
                    Divider(),
                    buildSummaryRow("Delivery Charge :", "\$00.00"),
                    Divider(),
                    buildSummaryRow("Estimated Tax (15.5%) :", "\$20.00"),
                  ],
                ),
                MySpacing.height(20),
                buildSummaryRow("Total Amount", "\$737.00"),
                MySpacing.height(20),
                MyContainer(
                  color: contentTheme.warning.withValues(alpha: 0.3),
                  paddingAll: 8,
                  borderRadiusAll: 12,
                  child: Row(
                    children: [
                      MyContainer.none(
                        color: contentTheme.warning,
                        paddingAll: 4,
                        height: 36,
                        width: 36,
                        borderRadiusAll: 12,
                        child: SvgPicture.asset(
                          'assets/svg/kick_scooter_broken.svg',
                          colorFilter: ColorFilter.mode(contentTheme.light, BlendMode.srcIn),
                          height: 16,
                        ),
                      ),
                      MySpacing.width(12),
                      MyText.bodyMedium("Estimated Delivery by 25 April, 2024"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
