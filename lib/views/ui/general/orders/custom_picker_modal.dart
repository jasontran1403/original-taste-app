import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:original_taste/helper/services/seller_services.dart';
import 'package:original_taste/helper/theme/app_theme.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/helper/widgets/my_text_style.dart';

import '../../../../controller/seller/order_cart_controller.dart';

class CustomerPickerModal extends StatefulWidget {
  final OrderCartController controller;
  const CustomerPickerModal({super.key, required this.controller});

  static Future<void> show(BuildContext context, OrderCartController ctrl) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomerPickerModal(controller: ctrl),
    );
  }

  @override
  State<CustomerPickerModal> createState() => _CustomerPickerModalState();
}

class _CustomerPickerModalState extends State<CustomerPickerModal> with UIMixin {
  final phoneCtrl    = TextEditingController();
  final nameCtrl     = TextEditingController();
  final emailCtrl    = TextEditingController();
  final addressCtrl  = TextEditingController();
  final discountCtrl = TextEditingController(text: '0');
  final notesCtrl    = TextEditingController();

  CustomerModel? foundCustomer;
  bool isSearching = false;
  bool isSaving    = false;
  String? searchError;
  bool _showForm   = false;

  late OutlineInputBorder _border;
  late OutlineInputBorder _borderFocus;

  bool get _isRetail    => widget.controller.orderMode == OrderMode.retail;
  bool get _isWholesale => !_isRetail;
  bool get _isExistingCustomer => foundCustomer != null;

  @override
  void initState() {
    super.initState();
    final e = widget.controller.selectedCustomer;

    if (_isRetail) {
      // Chế độ lẻ: tên cố định 'Khách lẻ', không thể đổi
      nameCtrl.text    = 'Khách lẻ';
      phoneCtrl.text   = e?.phone ?? '';
      emailCtrl.text   = e?.email ?? '';
      addressCtrl.text = e?.address ?? '';
      notesCtrl.text   = '';
    } else {
      // Chế độ sỉ: restore state nếu đã có selectedCustomer
      if (e != null) {
        phoneCtrl.text    = e.phone;
        nameCtrl.text     = e.name;
        emailCtrl.text    = e.email;
        addressCtrl.text  = e.address;
        discountCtrl.text = e.discountRate.toString();
        _showForm         = true;
        if (e.id != null) {
          foundCustomer = CustomerModel(
            id:           e.id!,
            phone:        e.phone,
            name:         e.name,
            email:        e.email.isEmpty ? null : e.email,
            discountRate: e.discountRate,
            isActive:     true,
            addresses:    e.address.isEmpty ? [] : [
              CustomerAddressModel(address: e.address, isDefault: true),
            ],
          );
        }
      }
    }
  }

  @override
  void dispose() {
    phoneCtrl.dispose();
    nameCtrl.dispose();
    emailCtrl.dispose();
    addressCtrl.dispose();
    discountCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: contentTheme.secondary.withValues(alpha: 0.4)),
    );
    _borderFocus = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: contentTheme.primary, width: 1.5),
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(children: [
          // Handle bar
          Container(
            margin: MySpacing.xy(0, 12),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: contentTheme.secondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: MySpacing.xy(20, 0),
            child: Row(children: [
              // Badge chế độ
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (_isRetail ? Colors.orange : contentTheme.primary)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: (_isRetail ? Colors.orange : contentTheme.primary)
                        .withOpacity(0.4),
                  ),
                ),
                child: Text(
                  _isRetail ? 'Khách lẻ' : 'Khách sỉ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _isRetail ? Colors.orange : contentTheme.primary,
                  ),
                ),
              ),
              MySpacing.width(10),
              Expanded(
                child: MyText.titleMedium(
                  _isRetail ? 'Thông tin khách lẻ' : 'Thông tin khách sỉ',
                  style: TextStyle(
                    fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (widget.controller.selectedCustomer != null)
                TextButton(
                  onPressed: () {
                    widget.controller.clearCustomer();
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    padding: MySpacing.xy(8, 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: MyText.bodySmall('Xóa KH', color: contentTheme.danger),
                ),
              MySpacing.width(4),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: contentTheme.secondary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 18, color: contentTheme.secondary),
                ),
              ),
            ]),
          ),
          const Divider(height: 16),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollCtrl,
              padding: MySpacing.all(20),
              child: _isRetail ? _buildRetailBody() : _buildWholesaleBody(),
            ),
          ),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // CHẾ ĐỘ LẺ — nhập trực tiếp, không search
  // ══════════════════════════════════════════════════════════════
  Widget _buildRetailBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info banner
        Container(
          padding: MySpacing.xy(12, 10),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.orange.withOpacity(0.2)),
          ),
          child: Row(children: [
            Icon(Icons.info_outline, size: 15, color: Colors.orange.shade700),
            MySpacing.width(8),
            Expanded(
              child: MyText.bodySmall(
                'SĐT, email và địa chỉ là bắt buộc. Ghi chú là tuỳ chọn.',
                color: Colors.orange.shade700,
              ),
            ),
          ]),
        ),
        MySpacing.height(20),

        // Tên — cố định "Khách lẻ", không thể sửa
        _field('Tên khách hàng', TextFormField(
          controller: nameCtrl,
          readOnly: true,
          style: MyTextStyle.bodyMedium(color: contentTheme.secondary),
          decoration: _deco('Khách lẻ').copyWith(
            filled: true,
            fillColor: contentTheme.secondary.withValues(alpha: 0.06),
          ),
        )),
        MySpacing.height(12),

        // SĐT — bắt buộc
        _fieldWithBadge(
          'Số điện thoại',
          required: true,
          child: TextFormField(
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: MyTextStyle.bodyMedium(),
            decoration: _deco('Nhập SĐT...'),
          ),
        ),
        MySpacing.height(12),

        // Email — BẮT BUỘC
        _fieldWithBadge(
          'Email',
          required: true,
          child: TextFormField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: MyTextStyle.bodyMedium(),
            decoration: _deco('Nhập email...'),
          ),
        ),
        MySpacing.height(12),

        // Địa chỉ — BẮT BUỘC
        _fieldWithBadge(
          'Địa chỉ',
          required: true,
          child: TextFormField(
            controller: addressCtrl,
            style: MyTextStyle.bodyMedium(),
            decoration: _deco('Nhập địa chỉ...'),
            maxLines: 2,
          ),
        ),
        MySpacing.height(12),

        // Ghi chú — tuỳ chọn
        _field('Ghi chú', TextFormField(
          controller: notesCtrl,
          style: MyTextStyle.bodyMedium(),
          decoration: _deco('Ghi chú đơn hàng (tuỳ chọn)'),
          maxLines: 2,
        )),
        MySpacing.height(24),

        _btn(
          label: 'Xác nhận',
          icon: Icons.check_circle_outline,
          onTap: isSaving ? null : _applyRetail,
          color: Colors.orange.shade700,
        ),
        MySpacing.height(20),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // CHẾ ĐỘ SỈ — search SĐT, tạo mới nếu chưa có (giữ nguyên logic cũ)
  // ══════════════════════════════════════════════════════════════
  Widget _buildWholesaleBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── SĐT search ─────────────────────────────────────
        MyText.bodyMedium('Số điện thoại *'),
        MySpacing.height(8),
        Row(children: [
          Expanded(
            child: TextFormField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              readOnly: _isExistingCustomer,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: MyTextStyle.bodyMedium(
                color: _isExistingCustomer ? contentTheme.secondary : null,
              ),
              decoration: _deco('Nhập SĐT để tìm KH...').copyWith(
                filled: _isExistingCustomer,
                fillColor: _isExistingCustomer
                    ? contentTheme.secondary.withValues(alpha: 0.06) : null,
              ),
              onFieldSubmitted: _isExistingCustomer ? null : (_) => _searchByPhone(),
            ),
          ),
          MySpacing.width(10),
          if (!_isExistingCustomer)
            GestureDetector(
              onTap: isSearching ? null : _searchByPhone,
              child: Container(
                padding: MySpacing.all(13),
                decoration: BoxDecoration(
                  color: isSearching
                      ? contentTheme.secondary.withValues(alpha: 0.3)
                      : contentTheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: isSearching
                    ? SizedBox(
                    height: 18, width: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: contentTheme.onPrimary))
                    : Icon(Icons.search, color: contentTheme.onPrimary, size: 20),
              ),
            ),
        ]),

        // Card KH tìm được
        if (foundCustomer != null) ...[
          MySpacing.height(12),
          _buildFoundCard(),
        ],

        // Không tìm thấy → gợi ý tạo mới
        if (searchError != null && !_showForm) ...[
          MySpacing.height(10),
          Container(
            padding: MySpacing.xy(12, 10),
            decoration: BoxDecoration(
              color: contentTheme.warning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: contentTheme.warning.withValues(alpha: 0.3)),
            ),
            child: Row(children: [
              Icon(Icons.info_outline, size: 16, color: contentTheme.warning),
              MySpacing.width(8),
              Expanded(
                child: MyText.bodySmall(
                  'Không tìm thấy — bạn có muốn tạo mới?',
                  color: contentTheme.warning,
                ),
              ),
              MySpacing.width(8),
              GestureDetector(
                onTap: () => setState(() => _showForm = true),
                child: Container(
                  padding: MySpacing.xy(10, 6),
                  decoration: BoxDecoration(
                    color: contentTheme.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.person_add_outlined,
                        size: 13, color: contentTheme.onPrimary),
                    MySpacing.width(4),
                    MyText.labelSmall('Tạo mới',
                        color: contentTheme.onPrimary, fontWeight: 700),
                  ]),
                ),
              ),
            ]),
          ),
        ],

        // Form chi tiết
        if (_showForm) ...[
          MySpacing.height(20),
          Row(children: [
            Expanded(child: Divider(
                color: contentTheme.secondary.withValues(alpha: 0.2))),
            Padding(
              padding: MySpacing.xy(12, 0),
              child: MyText.bodySmall(
                _isExistingCustomer ? 'Thông tin' : 'Khách hàng mới',
                color: contentTheme.primary, fontWeight: 600,
              ),
            ),
            Expanded(child: Divider(
                color: contentTheme.secondary.withValues(alpha: 0.2))),
          ]),
          MySpacing.height(16),

          _field('Tên khách hàng *', TextFormField(
            controller: nameCtrl,
            style: MyTextStyle.bodyMedium(),
            decoration: _deco('Nhập tên...'),
          )),
          MySpacing.height(12),

          _field('Email', TextFormField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: MyTextStyle.bodyMedium(),
            decoration: _deco('Nhập email (tuỳ chọn)...'),
          )),
          MySpacing.height(12),

          _field('Địa chỉ', TextFormField(
            controller: addressCtrl,
            style: MyTextStyle.bodyMedium(),
            decoration: _deco('Nhập địa chỉ (tuỳ chọn)...'),
            maxLines: 2,
          )),
          MySpacing.height(12),

          _field('Chiết khấu (%)', TextFormField(
            controller: discountCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: MyTextStyle.bodyMedium(),
            decoration: _deco('0 – 100').copyWith(
              suffixText: '%',
              suffixStyle: MyTextStyle.bodyMedium(color: contentTheme.secondary),
            ),
          )),
          MySpacing.height(24),

          if (_isExistingCustomer)
            Row(children: [
              Expanded(child: _btnOutlined(
                  label: 'Dùng', onTap: isSaving ? null : _applyLocal)),
              MySpacing.width(10),
              Expanded(
                flex: 2,
                child: _btn(
                  label: isSaving ? 'Đang lưu...' : 'Cập nhật',
                  icon: isSaving ? null : Icons.check_circle_outline,
                  onTap: isSaving ? null : _updateAndApply,
                  color: contentTheme.primary,
                  loading: isSaving,
                ),
              ),
            ])
          else
            Row(children: [
              Expanded(child: _btnOutlined(
                  label: 'Dùng tạm', onTap: isSaving ? null : _applyLocal)),
              MySpacing.width(10),
              Expanded(
                flex: 2,
                child: _btn(
                  label: isSaving ? 'Đang lưu...' : 'Lưu & dùng',
                  icon: isSaving ? null : Icons.save_outlined,
                  onTap: isSaving ? null : _saveAndUse,
                  color: contentTheme.primary,
                  loading: isSaving,
                ),
              ),
            ]),
        ],

        // Placeholder
        if (!_showForm && foundCustomer == null && searchError == null)
          Padding(
            padding: MySpacing.xy(0, 40),
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.person_search_outlined,
                    size: 52,
                    color: contentTheme.secondary.withValues(alpha: 0.2)),
                MySpacing.height(10),
                MyText.bodyMedium('Nhập SĐT để tìm khách hàng sỉ', muted: true),
                MySpacing.height(4),
                MyText.bodySmall('Nhấn 🔍 hoặc Enter sau khi nhập', muted: true),
              ]),
            ),
          ),

        MySpacing.height(20),
      ],
    );
  }

  // ── Apply retail (không gọi API) ───────────────────────────────
  void _applyRetail() {
    final email   = emailCtrl.text.trim();
    final address = addressCtrl.text.trim();

    final phone = phoneCtrl.text.trim();
    if (phone.isEmpty) {
      Get.snackbar('Thiếu thông tin', 'Vui lòng nhập số điện thoại',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    if (email.isEmpty) {
      Get.snackbar('Thiếu thông tin', 'Vui lòng nhập email',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    if (address.isEmpty) {
      Get.snackbar('Thiếu thông tin', 'Vui lòng nhập địa chỉ',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    // Gán notes vào controller nếu có
    final notes = notesCtrl.text.trim();
    if (notes.isNotEmpty) {
      widget.controller.orderNotes = notes;
    }

    _applyCustomer(
      id:       null,
      name:     'Khách lẻ',
      phone:    phone,
      email:    email,
      address:  address,
      discount: 0,
    );
  }

  // ── Card KH sỉ tìm được ────────────────────────────────────────
  Widget _buildFoundCard() {
    final c = foundCustomer!;
    return GestureDetector(
      onTap: () => setState(() {
        foundCustomer     = null;
        _showForm         = false;
        searchError       = null;
        phoneCtrl.text    = '';
        nameCtrl.text     = '';
        emailCtrl.text    = '';
        addressCtrl.text  = '';
        discountCtrl.text = '0';
      }),
      child: Container(
        padding: MySpacing.all(14),
        decoration: BoxDecoration(
          color: contentTheme.success.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: contentTheme.success.withValues(alpha: 0.35)),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: contentTheme.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_outline,
                size: 18, color: contentTheme.success),
          ),
          MySpacing.width(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.check_circle, size: 13, color: contentTheme.success),
                  MySpacing.width(4),
                  MyText.bodySmall('Đã có trong hệ thống',
                      color: contentTheme.success, fontWeight: 600),
                ]),
                MySpacing.height(3),
                MyText.bodyMedium(c.name ?? '', fontWeight: 700),
                MyText.bodySmall(c.phone, muted: true),
                if (c.discountRate > 0)
                  Container(
                    margin: MySpacing.top(3),
                    padding: MySpacing.xy(6, 2),
                    decoration: BoxDecoration(
                      color: contentTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: MyText.labelSmall('CK: ${c.discountRate}%',
                        color: contentTheme.primary, fontWeight: 600),
                  ),
              ],
            ),
          ),
          Column(children: [
            Icon(Icons.close, size: 15,
                color: contentTheme.secondary.withValues(alpha: 0.4)),
            MySpacing.height(2),
            MyText.labelSmall('Bỏ chọn',
                color: contentTheme.secondary.withValues(alpha: 0.4),
                fontSize: 10),
          ]),
        ]),
      ),
    );
  }

  // ── Search SĐT (sỉ) ───────────────────────────────────────────
  Future<void> _searchByPhone() async {
    final phone = phoneCtrl.text.trim();
    if (phone.isEmpty) return;

    setState(() {
      isSearching       = true;
      searchError       = null;
      foundCustomer     = null;
      _showForm         = false;
      nameCtrl.text     = '';
      emailCtrl.text    = '';
      addressCtrl.text  = '';
      discountCtrl.text = '0';
    });

    final result = await SellerService.getCustomerByPhone(phone);

    setState(() {
      isSearching = false;
      if (result.isSuccess && result.data != null) {
        foundCustomer         = result.data!;
        _showForm             = true;
        nameCtrl.text         = foundCustomer!.name ?? '';
        emailCtrl.text        = foundCustomer!.email ?? '';
        addressCtrl.text      = foundCustomer!.addresses.isNotEmpty
            ? foundCustomer!.addresses.first.address : '';
        discountCtrl.text     = foundCustomer!.discountRate.toString();
      } else {
        searchError = 'Không tìm thấy';
      }
    });
  }

  // ── Apply local (sỉ) ──────────────────────────────────────────
  void _applyLocal() {
    if (!_validateWholesale()) return;
    _applyCustomer(
      id:       foundCustomer?.id,
      name:     nameCtrl.text.trim(),
      phone:    phoneCtrl.text.trim(),
      email:    emailCtrl.text.trim(),
      address:  addressCtrl.text.trim(),
      discount: (int.tryParse(discountCtrl.text.trim()) ?? 0).clamp(0, 100),
    );
  }

  // ── Tạo KH mới (sỉ) ──────────────────────────────────────────
  Future<void> _saveAndUse() async {
    if (!_validateWholesale()) return;
    setState(() => isSaving = true);

    final result = await SellerService.createCustomer(
      phone:        phoneCtrl.text.trim(),
      name:         nameCtrl.text.trim(),
      email:        emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
      discountRate: (int.tryParse(discountCtrl.text.trim()) ?? 0).clamp(0, 100),
      addresses:    addressCtrl.text.trim().isEmpty ? null : [
        {'address': addressCtrl.text.trim(), 'isDefault': true}
      ],
    );

    setState(() => isSaving = false);

    if (result.isSuccess && result.data != null) {
      final saved = result.data!;
      _applyCustomer(
        id:       saved.id,
        name:     saved.name ?? '',
        phone:    saved.phone,
        email:    saved.email ?? '',
        address:  saved.addresses.isNotEmpty
            ? saved.addresses.first.address : '',
        discount: saved.discountRate,
      );
      Get.snackbar('✅ Đã lưu',
          'Khách hàng "${saved.name ?? saved.phone}" đã được tạo',
          backgroundColor: Colors.green.shade600, colorText: Colors.white,
          duration: const Duration(seconds: 2));
    } else {
      Get.snackbar('Lỗi', result.message ?? 'Không thể tạo khách hàng',
          backgroundColor: Colors.red.shade600, colorText: Colors.white);
    }
  }

  // ── Update KH (sỉ) ───────────────────────────────────────────
  Future<void> _updateAndApply() async {
    if (!_validateWholesale()) return;

    final newName     = nameCtrl.text.trim();
    final newEmail    = emailCtrl.text.trim();
    final newAddress  = addressCtrl.text.trim();
    final newDiscount =
    (int.tryParse(discountCtrl.text.trim()) ?? 0).clamp(0, 100);

    final oldName     = foundCustomer!.name ?? '';
    final oldEmail    = foundCustomer!.email ?? '';
    final oldAddress  = foundCustomer!.addresses.isNotEmpty
        ? foundCustomer!.addresses.first.address : '';
    final oldDiscount = foundCustomer!.discountRate;

    final hasChanged = newName != oldName || newEmail != oldEmail ||
        newAddress != oldAddress || newDiscount != oldDiscount;

    if (hasChanged) {
      setState(() => isSaving = true);

      final result = await SellerService.updateCustomer(
        id:           foundCustomer!.id,
        phone:        foundCustomer!.phone,
        name:         newName,
        email:        newEmail.isEmpty ? null : newEmail,
        discountRate: newDiscount,
        addresses:    newAddress.isEmpty ? null : [
          {'address': newAddress, 'isDefault': true}
        ],
      );

      setState(() => isSaving = false);

      if (!result.isSuccess) {
        Get.snackbar('Lỗi', result.message ?? 'Không thể cập nhật khách hàng',
            backgroundColor: Colors.red.shade600, colorText: Colors.white);
        return;
      }
      Get.snackbar('✅ Đã cập nhật', 'Thông tin khách hàng đã được lưu',
          backgroundColor: Colors.green.shade600, colorText: Colors.white,
          duration: const Duration(seconds: 2));
    }

    _applyCustomer(
      id:       foundCustomer!.id,
      name:     newName,
      phone:    foundCustomer!.phone,
      email:    newEmail,
      address:  newAddress,
      discount: newDiscount,
    );
  }

  // ── Apply vào controller + đóng ──────────────────────────────
  void _applyCustomer({
    int? id,
    required String name,
    required String phone,
    required String email,
    required String address,
    required int discount,
  }) {
    widget.controller.setCustomer(SelectedCustomer(
      id:           id,
      name:         name,
      phone:        phone,
      email:        email,
      address:      address,
      discountRate: discount,
    ));
    if (mounted) Navigator.pop(context);
  }

  bool _validateWholesale() {
    if (phoneCtrl.text.trim().isEmpty) {
      Get.snackbar('Thiếu thông tin', 'Vui lòng nhập số điện thoại',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return false;
    }
    if (nameCtrl.text.trim().isEmpty) {
      Get.snackbar('Thiếu thông tin', 'Vui lòng nhập tên khách hàng',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return false;
    }
    return true;
  }

  // ── UI helpers ────────────────────────────────────────────────
  Widget _btn({
    required String label,
    IconData? icon,
    required VoidCallback? onTap,
    required Color color,
    bool loading = false,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: MySpacing.xy(0, 13),
          decoration: BoxDecoration(
            color: onTap == null ? color.withValues(alpha: 0.4) : color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: loading
                ? SizedBox(
                height: 18, width: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: contentTheme.onPrimary))
                : Row(mainAxisSize: MainAxisSize.min, children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: contentTheme.onPrimary),
                MySpacing.width(6),
              ],
              MyText.bodyMedium(label,
                  fontWeight: 700, color: contentTheme.onPrimary),
            ]),
          ),
        ),
      );

  Widget _btnOutlined({required String label, required VoidCallback? onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: MySpacing.xy(0, 13),
          decoration: BoxDecoration(
            border: Border.all(
                color: contentTheme.secondary.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: MyText.bodyMedium(label,
                fontWeight: 600, color: contentTheme.secondary),
          ),
        ),
      );

  Widget _field(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [MyText.bodyMedium(label), MySpacing.height(8), child],
  );

  /// Label có badge "bắt buộc" màu cam
  Widget _fieldWithBadge(String label,
      {required bool required, required Widget child}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            MyText.bodyMedium(label),
            if (required) ...[
              MySpacing.width(6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('bắt buộc',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade700)),
              ),
            ],
          ]),
          MySpacing.height(8),
          child,
        ],
      );

  InputDecoration _deco(String hint) => InputDecoration(
    border: _border,
    focusedBorder: _borderFocus,
    enabledBorder: _border,
    errorBorder: _border,
    focusedErrorBorder: _borderFocus,
    contentPadding: MySpacing.all(13),
    isDense: true,
    isCollapsed: true,
    hintText: hint,
    hintStyle: MyTextStyle.bodyMedium(muted: true),
  );
}