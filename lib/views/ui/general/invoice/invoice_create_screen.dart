import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:original_taste/controller/ui/general/invoice/invoice_create_controller.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_flex.dart';
import 'package:original_taste/helper/widgets/my_flex_item.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/images.dart';
import 'package:original_taste/views/layout/layout.dart';
import 'package:original_taste/views/ui/custom/authentication/widget/custom_text_form_field.dart';

import '../../../../helper/theme/admin_theme.dart';

class InvoiceCreateScreen extends StatefulWidget {
  const InvoiceCreateScreen({super.key});

  @override
  State<InvoiceCreateScreen> createState() => _InvoiceCreateScreenState();
}

class _InvoiceCreateScreenState extends State<InvoiceCreateScreen> with UIMixin {
  InvoiceCreateController controller = Get.put(InvoiceCreateController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (controller) {
        return Layout(
          screenName: "INVOICE CREATE",
          child: Center(
            child: MyFlex(
              children: [
                MyFlexItem(
                  sizes: 'lg-8',
                  child: MyCard(
                     shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
                    borderRadiusAll: 12,
                    paddingAll: 20,
                    child: MyFlex(
                      contentPadding: false,
                      children: [
                        MyFlexItem(
                          sizes: 'lg-6',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyContainer.bordered(
                                borderRadiusAll: 12,
                                borderColor: contentTheme.primary,
                                child: Image.asset(Images.darkLogo, height: 24),
                              ),
                              MySpacing.height(12),
                              CustomTextFormField(labelText: "Sender Name",hintText: "First Name",controller: controller.senderName),
                              MySpacing.height(12),
                              CustomTextFormField(labelText: "Sender Full Address",hintText: "Enter Address",controller: controller.senderAddress, maxLines: 3),
                              MySpacing.height(12),
                              CustomTextFormField(labelText: "Phone Number", hintText: "Number",controller: controller.senderPhone),
                            ],
                          ),
                        ),
                        MyFlexItem(
                          sizes: 'lg-6',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextFormField(labelText: "Invoice Number",hintText:  "#INV-****",controller: controller.invoiceNo),
                              MySpacing.height(12),
                              CustomTextFormField(labelText: "Issue Date",hintText:  "dd-mm-yyyy",controller: controller.issueDate),
                              MySpacing.height(12),
                              CustomTextFormField(labelText: "Due Date",hintText:  "dd-mm-yyyy",controller: controller.dueDate),
                              MySpacing.height(12),
                              CustomTextFormField(labelText: "Amount", hintText: "000",controller: controller.amount),
                              MySpacing.height(12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText.bodyMedium("Status", fontWeight: 600),
                                  MySpacing.height(12),
                                  DropdownButtonFormField<String>(
                                    value: controller.status,
                                    items: ['Paid', 'Cancel', 'Pending'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                    dropdownColor: contentTheme.disabled,
                                    onChanged: (v) => setState(() => controller.status = v!),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AdminTheme.theme.contentTheme.secondary, width: 0.5)),
                                      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AdminTheme.theme.contentTheme.secondary, width: 0.5)),
                                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AdminTheme.theme.contentTheme.secondary, width: 0.5)),
                                      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AdminTheme.theme.contentTheme.secondary, width: 0.5)),
                                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AdminTheme.theme.contentTheme.secondary, width: 0.5)),
                                      disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AdminTheme.theme.contentTheme.secondary, width: 0.5)),
                                      contentPadding: MySpacing.all(16),
                                      isDense: true,
                                      isCollapsed: true,
                                      hintText: "City",
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        MyFlexItem(
                            sizes: 'lg-6',
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText.titleMedium("Issue From:", fontWeight: 600),
                            MySpacing.height(12),
                            CustomTextFormField(hintText: "First Name",controller: controller.buyerName),
                            MySpacing.height(12),
                            CustomTextFormField(hintText: "Enter Address",controller: controller.buyerAddress,maxLines: 3),
                            MySpacing.height(12),
                            CustomTextFormField(hintText: "Number",controller: controller.buyerPhone),
                            MySpacing.height(12),
                            CustomTextFormField(hintText: "Email",controller: controller.buyerEmail),
                          ],
                        )),
                        MyFlexItem(
                            sizes: 'lg-6',
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText.titleMedium("Issue For:", fontWeight: 600),
                            MySpacing.height(12),
                            CustomTextFormField(hintText: "Name",controller: controller.issuerName),
                            MySpacing.height(12),
                            CustomTextFormField(hintText: "Address",controller: controller.issuerAddress,maxLines: 3),
                            MySpacing.height(12),
                            CustomTextFormField(hintText: "Phone",controller: controller.issuerPhone),
                            MySpacing.height(12),
                            CustomTextFormField(hintText: "Email",controller: controller.issuerEmail),
                          ],
                        )),
                        MyFlexItem(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [],
                        ))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget customTextField({String? title, String? hintText, TextEditingController? controller, int? maxLines = 1}) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       if(title != null)
  //       MyText.bodyMedium(title, fontWeight: 600),
  //       if(title != null)
  //       MySpacing.height(12),
  //       TextFormField(
  //         controller: controller,
  //         maxLines: maxLines,
  //         decoration: InputDecoration(
  //           border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: contentTheme.secondary)),
  //           focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: contentTheme.secondary)),
  //           focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: contentTheme.secondary)),
  //           errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: contentTheme.secondary)),
  //           enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: contentTheme.secondary)),
  //           disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: contentTheme.secondary)),
  //           contentPadding: MySpacing.all(16),
  //           isDense: true,
  //           hintText: hintText,
  //         ),
  //         keyboardType: TextInputType.phone,
  //       ),
  //     ],
  //   );
  // }

  Widget data() {
    return MyFlexItem(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Product table
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: const [
                    Expanded(child: Text("Product Name")),
                    SizedBox(width: 80, child: Center(child: Text("Qty"))),
                    SizedBox(width: 100, child: Text("Price")),
                    SizedBox(width: 100, child: Text("Tax")),
                    SizedBox(width: 100, child: Text("Total")),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              /* pick product image */
                            },
                            child: Container(width: 60, height: 60, color: Colors.grey[200], child: Icon(Icons.add_photo_alternate)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              children: [
                                TextField(controller: controller.productName, decoration: const InputDecoration(labelText: 'Name')),
                                TextField(controller: controller.productSize, decoration: const InputDecoration(labelText: 'Size')),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: TextField(controller: controller.productQty, decoration: const InputDecoration(), keyboardType: TextInputType.number),
                    ),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: controller.productPrice,
                        decoration: const InputDecoration(prefixText: "\$"),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: controller.productTax,
                        decoration: const InputDecoration(prefixText: "\$"),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 100, child: Text("\$${controller.productTotal.toStringAsFixed(2)}")),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          controller.productName.clear();
                          controller.productSize.clear();
                          controller.productPrice.clear();
                          controller.productTax.clear();
                          controller.productQty.text = '1';
                          controller.recalculateTotals();
                        });
                      },
                      child: const Text("Clear Product"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(onPressed: () {}, child: const Text("Add More")),
                  ],
                ),
              ],
            ),
            const Divider(height: 32),
            // Summary
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Text("Sub Total:"),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 150,
                      child: TextField(controller: controller.subTotal, decoration: const InputDecoration(prefixText: "\$"), readOnly: true),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text("Discount:"),
                    const SizedBox(width: 16),
                    SizedBox(width: 150, child: TextField(controller: controller.discount, decoration: const InputDecoration(prefixText: "\$"))),
                  ],
                ),
                Row(
                  children: [
                    const Text("Estimated Tax (15.5%):"),
                    const SizedBox(width: 16),
                    SizedBox(width: 150, child: TextField(controller: controller.estimatedTax, decoration: const InputDecoration(prefixText: "\$"))),
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    const Text("Grand Total:"),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 150,
                      child: TextField(controller: controller.grandTotal, decoration: const InputDecoration(prefixText: "\$"), readOnly: true),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "All accounts are to be paid within 7 days from receipt of invoice. To be paid by cheque or credit card or direct payment online. "
              "If account is not paid within 7 days the credits details supplied as confirmation of work undertaken will be charged the agreed quoted fee noted above.",
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
