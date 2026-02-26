import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:original_taste/controller/ui/general/invoice/invoice_details_controller.dart';
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

class InvoiceDetailsScreen extends StatefulWidget {
  const InvoiceDetailsScreen({super.key});

  @override
  State<InvoiceDetailsScreen> createState() => _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends State<InvoiceDetailsScreen> with UIMixin {
  InvoiceDetailsController controller = Get.put(InvoiceDetailsController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (controller) {
        return Layout(
          screenName: "INVOICE DETAILS",
          child: Center(
            child: MyFlex(
              children: [
                MyFlexItem(
                  sizes: 'md-7',
                  child: MyCard(
                    borderRadiusAll: 12,
                    shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
                    child: Column(
                      children: [
                        buildHeaderSection(),
                        MySpacing.height(24),
                        buildIssueSection(),
                        MySpacing.height(32),
                        buildProductTable(),
                        MySpacing.height(24),
                        buildSummarySection(),
                        MySpacing.height(24),
                        buildNoticeSection(),
                        MySpacing.height(16),
                        buildActionButtons(),
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

  Widget buildHeaderSection() {
    return MyContainer(
      borderRadiusAll: 12,
      color: contentTheme.info.withValues(alpha: 0.2),
      paddingAll: 20,
      child: MyFlex(
        wrapAlignment: WrapAlignment.spaceBetween,
        runAlignment: WrapAlignment.spaceBetween,
        children: [
          MyFlexItem(
            sizes: 'lg-6',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(Images.darkLogo, height: 24),
                MySpacing.height(12),
                MyText.titleLarge("Larkon Admin"),
                MySpacing.height(20),
                MyText.bodyMedium("1729 Bangor St,\nHoulton, ME, 04730\nUnited States"),
                MySpacing.height(8),
                MyText.bodyMedium("Phone: +1(142)-532-9109"),
              ],
            ),
          ),
          MyFlexItem(
            sizes: 'lg-6',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MyText.bodyMedium('Invoice:', fontWeight: 700),
                    MySpacing.width(16),
                    Flexible(child: MyText.bodyMedium('#INV-0758267/90', fontWeight: 700,maxLines: 1,)),
                  ],
                ),
                MySpacing.height(14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [MyText.bodyMedium('Issue Date:'), MySpacing.width(16), Flexible(child: MyText.bodyMedium('23 April 2024',maxLines: 1,))],
                ),
                MySpacing.height(14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [MyText.bodyMedium('Due Date:'), MySpacing.width(16), Flexible(child: MyText.bodyMedium('26 April 2024',maxLines: 1,))],
                ),
                MySpacing.height(14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [MyText.bodyMedium('Amount:'), MySpacing.width(16), MyText.bodyMedium('\$737.00')],
                ),
                MySpacing.height(14),
                MyContainer(
                  color: contentTheme.success,
                  padding: MySpacing.xy(12, 8),
                  child: MyText.bodyMedium("Paid", color: contentTheme.onSuccess),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildIssueSection() {
    return MyFlex(
      children: [
        MyFlexItem(
          sizes: 'lg-6',
          child: buildIssueCard(
            'Issue From',
            'Larkon Admin.INC',
            '2437 Romano Street\nCambridge, MA 02141',
            'Phone: +(31)781-417-2004',
            'Email: JulianeKuhn@jourrapide.com',
          ),
        ),
        MyFlexItem(
          sizes: 'lg-6',
          child: buildIssueCard(
            'Issue For',
            'Gaston Lapierre',
            '1344 Hershell Hollow Road\nWA 98168, USA',
            'Phone: +(123) 732-760-5760',
            'Email: hello@dundermuffilin.com',
          ),
        ),
      ],
    );
  }

  Widget buildIssueCard(String title, String name, String address, String phone, String email) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.bodyLarge(title, fontWeight: 700),
        MySpacing.height(8),
        MyText.bodyMedium(name),
        MySpacing.height(8),
        MyText.bodyMedium(address),
        MySpacing.height(8),
        MyText.bodyMedium(phone, style: const TextStyle(decoration: TextDecoration.underline)),
        MySpacing.height(8),
        MyText.bodyMedium(email, style: TextStyle(decoration: TextDecoration.underline)),
      ],
    );
  }

  Widget buildProductTable() {
    final items = [
      {'name': 'Men Black Slim Fit T‑shirt', 'size': 'M', 'qty': 1, 'price': 80.0, 'tax': 3.0},
      {'name': 'Dark Green Cargo Pant', 'size': 'M', 'qty': 3, 'price': 110.0, 'tax': 4.0},
      {'name': 'Men Dark Brown Wallet', 'size': 'S', 'qty': 1, 'price': 132.0, 'tax': 5.0},
      {'name': 'Kid\'s Yellow T‑shirt', 'size': 'S', 'qty': 2, 'price': 110.0, 'tax': 5.0},
    ];

    return Table(
      columnWidths: const {0: FlexColumnWidth(4), 1: FlexColumnWidth(1), 2: FlexColumnWidth(2), 3: FlexColumnWidth(2), 4: FlexColumnWidth(2)},
      border: TableBorder(horizontalInside: BorderSide(color: Colors.grey.shade300)),
      children: [
        TableRow(
          children: [
            tableHeader('Product Name'),
            tableHeader('Qty'),
            tableHeader('Price'),
            tableHeader('Tax'),
            tableHeader('Total', alignRight: true),
          ],
        ),
        ...items.map((item) {
          final int qty = item['qty'] as int;
          final double price = item['price'] as double;
          final double tax = item['tax'] as double;
          final double total = qty * price + tax;

          return TableRow(
            children: [
              Padding(padding: MySpacing.symmetric(vertical: 8), child: MyText.bodyMedium('${item['name']} (Size: ${item['size']})')),
              Padding(padding: MySpacing.symmetric(vertical: 8), child: MyText.bodyMedium('$qty')),
              Padding(padding: MySpacing.symmetric(vertical: 8), child: MyText.bodyMedium('\$${price.toStringAsFixed(2)}')),
              Padding(padding: MySpacing.symmetric(vertical: 8), child: MyText.bodyMedium('\$${tax.toStringAsFixed(2)}')),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(padding: MySpacing.symmetric(vertical: 8), child: MyText.bodyMedium('\$${total.toStringAsFixed(2)}')),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget tableHeader(String text, {bool alignRight = false}) {
    return Padding(
      padding: MySpacing.symmetric(vertical: 8),
      child: Align(alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft, child: MyText.titleMedium(text, fontWeight: 700)),
    );
  }

  Widget buildSummarySection() {
    const subTotal = 777.0;
    const discount = 60.0;
    const estimatedTax = 20.0;
    const grandTotal = 737.0;

    Widget row(String label, String value, {bool isBold = false}) {
      return Padding(
        padding: MySpacing.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [MyText.bodyMedium(label, fontWeight: isBold ? 700 : null), MyText.bodyMedium(value, fontWeight: isBold ? 700 : null)],
        ),
      );
    }

    return Column(
      children: [
        row('Sub Total:', '\$${subTotal.toStringAsFixed(2)}'),
        row('Discount:', '-\$${discount.toStringAsFixed(2)}'),
        row('Estimated Tax (15.5%):', '\$${estimatedTax.toStringAsFixed(2)}'),
        Divider(height: 20),
        row('Grand Amount:', '\$${grandTotal.toStringAsFixed(2)}', isBold: true),
      ],
    );
  }

  Widget buildNoticeSection() {
    return MyContainer(
      borderRadiusAll: 12,
      color: contentTheme.danger.withValues(alpha: 0.2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info, color: contentTheme.danger),
          MySpacing.width(8),
          Expanded(
            child: MyText.bodyMedium(
              'All accounts are to be paid within 7 days from receipt of invoice. '
              'To be paid by cheque or credit card or direct payment online. '
              'If account is not paid within 7 days the credits details supplied '
              'as confirmation of work undertaken will be charged the agreed quoted fee noted above.',
              color: contentTheme.danger,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        MyContainer(
          onTap: () => {},
          color: contentTheme.info,
          borderRadiusAll: 12,
          paddingAll: 12,
          width: 100,
          child: Center(child: MyText.bodyMedium("Print", color: contentTheme.onPrimary)),
        ),

        MySpacing.width(16),
        MyContainer.bordered(
          onTap: () => {},
          borderRadiusAll: 12,
          borderColor: contentTheme.primary,
          width: 100,
          paddingAll: 12,
          child: Center(child: MyText.bodyMedium("Submit", color: contentTheme.primary)),
        ),
      ],
    );
  }
}
