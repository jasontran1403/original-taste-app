import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:original_taste/controller/ui/general/orders/order_cart_controller.dart';
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
import 'package:original_taste/models/order_cart_model.dart';
import 'package:original_taste/views/layout/layout.dart';

class OrderCartScreen extends StatefulWidget {
  const OrderCartScreen({super.key});

  @override
  State<OrderCartScreen> createState() => _OrderCartScreenState();
}

class _OrderCartScreenState extends State<OrderCartScreen> with UIMixin {
  final OrderCartController controller = Get.put(OrderCartController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderCartController>(
      init: controller,
      builder: (controller) {
        return Layout(
          screenName: "ORDER CART",
          child: MyFlex(
            children: [
              MyFlexItem(
                sizes: 'lg-9',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyContainer(
                      color: contentTheme.primary,
                      borderRadiusAll: 12,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          MyText.bodyMedium("There are ${controller.orderCartModel.length} products in your cart", color: contentTheme.onPrimary),
                          MyButton.text(onPressed: controller.clearCart, child: MyText.bodyMedium("Clear Cart", color: contentTheme.onPrimary)),
                        ],
                      ),
                    ),
                    MySpacing.height(12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: controller.orderCartModel.length,
                      itemBuilder: (context, index) {
                        OrderCartModel order = controller.orderCartModel[index];
                        return MyCard(
                          paddingAll: 0,
                           shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
                          borderRadiusAll: 12,
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              Padding(
                                padding: MySpacing.all(20),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyContainer(height: 80, width: 80, child: Image.asset(order.image, fit: BoxFit.contain)),
                                    MySpacing.width(20),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          MyText.titleMedium(order.name),
                                          MySpacing.height(8),
                                          Row(
                                            children: [
                                              MyText.bodyMedium("Color: "),
                                              MyText.bodyMedium(order.color),
                                              MySpacing.width(20),
                                              MyText.bodyMedium("Size: "),
                                              MyText.bodyMedium(order.size),
                                            ],
                                          ),
                                          MySpacing.height(12),
                                          Row(
                                            children: [
                                              MyContainer.bordered(
                                                borderRadiusAll: 8,
                                                paddingAll: 8,
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    MyContainer(
                                                      onTap: () => controller.decrementQuantity(order),
                                                      paddingAll: 4,
                                                      color: contentTheme.secondary.withAlpha(50),
                                                      child: Icon(Icons.remove, size: 12),
                                                    ),
                                                    MySpacing.width(12),
                                                    MyText.bodyMedium(order.quantity.toString()),
                                                    MySpacing.width(12),
                                                    MyContainer(
                                                      onTap: () => controller.incrementQuantity(order),
                                                      paddingAll: 4,
                                                      color: contentTheme.secondary.withAlpha(50),
                                                      child: Icon(Icons.add, size: 12),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        MyText.bodyMedium("Item Price"),
                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            MyText.bodyMedium("\$${order.itemPrice.toStringAsFixed(2)}"),
                                            MyText.bodyMedium(" / \$${order.tax.toStringAsFixed(2)} Tax", color: contentTheme.secondary),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              MyContainer(
                                color: contentTheme.secondary.withValues(alpha: 0.04),
                                clipBehavior: Clip.antiAlias,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () {},
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete_outline, size: 18),
                                              MySpacing.width(4),
                                              Text("Remove", style: TextStyle(fontSize: 14)),
                                            ],
                                          ),
                                        ),
                                        MySpacing.width(16),
                                        InkWell(
                                          onTap: () {},
                                          child: Row(
                                            children: [
                                              Icon(Icons.favorite_border, size: 18),
                                              MySpacing.width(4),
                                              MyText.bodyMedium("Add Wishlist"),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    MyText.bodyMedium("Total: \$${order.total.toStringAsFixed(2)}"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => MySpacing.height(12),
                    ),
                  ],
                ),
              ),
              MyFlexItem(
                sizes: 'lg-3',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyContainer(
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
                    ),
                    MySpacing.height(12),
                    MyCard(
                       shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
                      borderRadiusAll: 12,
                      paddingAll: 0,
                      child: Builder(
                        builder: (_) {
                          double subTotal = controller.orderCartModel.fold(0.0, (sum, item) => sum + (item.itemPrice * item.quantity));
                          double tax = controller.orderCartModel.fold(0.0, (sum, item) => sum + (item.tax * item.quantity));
                          double discount = 60.0;
                          double delivery = 0.0;
                          double total = subTotal + tax + delivery - discount;

                          return Column(
                            children: [
                              Padding(
                                padding: MySpacing.all(20),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: MyText.titleMedium(
                                        "Order Summary",
                                        style: TextStyle(fontFamily: GoogleFonts.hankenGrotesk().fontFamily, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(height: 0),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    buildRow(Icons.receipt_long, "Sub Total", "\$${subTotal.toStringAsFixed(2)}"),
                                    buildRow(Icons.local_offer_outlined, "Discount", "-\$${discount.toStringAsFixed(2)}"),
                                    buildRow(Icons.delivery_dining, "Delivery Charge", "\$${delivery.toStringAsFixed(2)}"),
                                    buildRow(Icons.calculate_outlined, "Estimated Tax", "\$${tax.toStringAsFixed(2)}"),
                                  ],
                                ),
                              ),
                              Divider(height: 1, thickness: 1),
                              MyContainer(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [MyText.bodyMedium("Total Amount"), MyText.bodyMedium("\$${total.toStringAsFixed(2)}")],
                                ),
                              ),
                              Divider(),
                              MyContainer(
                                color: contentTheme.warning.withValues(alpha: 0.3),
                                marginAll: 12,
                                paddingAll: 12,
                                borderRadiusAll: 12,
                                child: Row(
                                  children: [
                                    CircleAvatar(backgroundColor: Colors.orange, radius: 20, child: Icon(Icons.delivery_dining, color: Colors.white)),
                                    MySpacing.width(12),
                                    Expanded(child: MyText.bodyMedium("Estimated Delivery by 25 April, 2024")),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    MySpacing.height(20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        MyContainer(
                          color: contentTheme.primary,
                          paddingAll: 12,
                          borderRadiusAll: 12,
                          child: MyText.bodyMedium("Continue Shopping", color: contentTheme.onPrimary),
                        ),
                        MySpacing.width(12),
                        MyContainer(
                          color: contentTheme.success,
                          paddingAll: 12,
                          borderRadiusAll: 12,
                          child: MyText.bodyMedium("Buy Now", color: contentTheme.onSuccess),
                        ),
                      ],
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

  Widget buildRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Expanded(child: MyText.bodyMedium(label)),
          MyText.bodyMedium(value),
        ],
      ),
    );
  }
}
