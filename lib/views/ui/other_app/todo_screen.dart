import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:original_taste/controller/ui/other_app/todo_controller.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/helper/widgets/my_text_style.dart';
import 'package:original_taste/images.dart';
import 'package:original_taste/models/todo_model.dart';
import 'package:original_taste/views/layout/layout.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> with UIMixin {
  final TodoController controller = Get.put(TodoController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TodoController>(
      init: controller,
      builder: (controller) {
        return Layout(
          screenName: "TODO",
          child: MyCard(
             shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
            borderRadiusAll: 12,
            paddingAll: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 300,
                      child: customField(hintText: "Search Task...", prefixIcon: Icon(Icons.search, color: contentTheme.secondary)),
                    ),
                    const Spacer(),
                    MyContainer(
                      onTap: () => showDialogForm(),
                      color: contentTheme.primary,
                      paddingAll: 12,
                      borderRadiusAll: 12,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: contentTheme.onPrimary, size: 18),
                          MySpacing.width(12),
                          MyText.bodyMedium("Create Task", color: contentTheme.onPrimary),
                        ],
                      ),
                    ),
                  ],
                ).paddingAll(20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStatePropertyAll(contentTheme.secondary.withAlpha(5)),
                    dataRowMaxHeight: 60,
                    columnSpacing: 80,
                    showBottomBorder: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    columns: [
                      DataColumn(label: MyText.labelLarge('Task Name', fontWeight: 700)),
                      DataColumn(label: MyText.labelLarge('Created Date', fontWeight: 700)),
                      DataColumn(label: MyText.labelLarge('Due Date', fontWeight: 700)),
                      DataColumn(label: MyText.labelLarge('Assigned', fontWeight: 700)),
                      DataColumn(label: MyText.labelLarge('Status', fontWeight: 700)),
                      DataColumn(label: MyText.labelLarge('Priority', fontWeight: 700)),
                      DataColumn(label: MyText.labelLarge('Action', fontWeight: 700)),
                    ],
                    rows: List.generate(controller.todo.length, (index) {
                      final data = controller.todo[index];
                      return DataRow(
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                Theme(
                                  data: ThemeData(),
                                  child: Checkbox(
                                    value: data.checked,
                                    activeColor: contentTheme.primary,
                                    visualDensity: VisualDensity.compact,
                                    onChanged: (_) => controller.toggleTaskComplete(data),
                                  ),
                                ),
                                MySpacing.width(12),
                                MyText.bodyMedium(
                                  data.taskName,
                                  fontWeight: 600,
                                  decoration: data.checked ? TextDecoration.lineThrough : TextDecoration.none,
                                ),
                              ],
                            ),
                          ),
                          DataCell(MyText.bodyMedium(data.createdDate, fontWeight: 600)),
                          DataCell(MyText.bodyMedium(data.dueDate, fontWeight: 600)),
                          DataCell(
                            Row(
                              children: [
                                MyContainer.rounded(paddingAll: 0, height: 24, width: 24, child: Image.asset(data.avatar)),
                                MySpacing.width(12),
                                MyText.bodyMedium(data.name, fontWeight: 600),
                              ],
                            ),
                          ),
                          DataCell(
                            MyContainer(
                              color: statusColor(data.status).withAlpha(80),
                              paddingAll: 4,
                              child: MyText.labelMedium(data.status, color: statusColor(data.status), fontWeight: 600),
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                MyContainer.rounded(paddingAll: 6, color: priorityColor(data.priority)),
                                MySpacing.width(12),
                                MyText.bodyMedium(data.priority, fontWeight: 600, color: priorityColor(data.priority)),
                              ],
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                MyContainer(
                                  color: contentTheme.primary.withAlpha(20),
                                  padding: MySpacing.xy(12, 8),
                                  borderRadiusAll: 8,
                                  onTap: () => showDialogForm(editing: data),
                                  child: SvgPicture.asset('assets/svg/pen_2.svg', height: 16, width: 16),
                                ),
                                MySpacing.width(12),
                                MyContainer(
                                  color: contentTheme.danger.withAlpha(20),
                                  padding: MySpacing.xy(12, 8),
                                  borderRadiusAll: 8,
                                  onTap: () => controller.deleteTodo(data),
                                  child: SvgPicture.asset(
                                    'assets/svg/trash_bin_2.svg',
                                    height: 16,
                                    width: 16,
                                    colorFilter: ColorFilter.mode(contentTheme.danger, BlendMode.srcIn),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showDialogForm({TodoModel? editing}) {
    final isEdit = editing != null;
    final taskCtrl = TextEditingController(text: editing?.taskName);
    final dueCtrl = TextEditingController(text: editing?.dueDate);
    final nameCtrl = TextEditingController(text: editing?.name);
    final statusCtrl = TextEditingController(text: editing?.status);
    final priorityCtrl = TextEditingController(text: editing?.priority);

    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SizedBox(
              width: 500,
              height: 420,
              child: Padding(
                padding: MySpacing.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText.titleLarge(isEdit ? 'Edit Task' : 'Create Task', fontWeight: 700, letterSpacing: 1),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            customField(hintText: "Task", controller: taskCtrl, title: "Task"),
                            MySpacing.height(12),
                            customField(hintText: "Due Date", controller: dueCtrl, title: "Due Date"),
                            MySpacing.height(12),
                            customField(hintText: "Assigned To", controller: nameCtrl, title: "Assigned To"),
                            MySpacing.height(12),
                            customField(hintText: "Status", controller: statusCtrl, title: "Status"),
                            MySpacing.height(12),
                            customField(hintText: "Priority", controller: priorityCtrl, title: "Priority"),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        MyContainer(onTap: () => Navigator.pop(context), child: MyText.labelMedium("Cancel")),
                        const SizedBox(width: 12),
                        MyContainer(
                          onTap: () {
                            if (taskCtrl.text.trim().isEmpty ||
                                dueCtrl.text.trim().isEmpty ||
                                nameCtrl.text.trim().isEmpty ||
                                statusCtrl.text.trim().isEmpty ||
                                priorityCtrl.text.trim().isEmpty) {
                              return;
                            }

                            if (isEdit) {
                              final updated = TodoModel(
                                editing.id,
                                statusCtrl.text,
                                taskCtrl.text,
                                editing.createdDate,
                                editing.createdTime,
                                dueCtrl.text,
                                nameCtrl.text,
                                editing.avatar,
                                priorityCtrl.text,
                                editing.checked,
                              );
                              controller.updateTodo(updated);
                            } else {
                              controller.addTodo(
                                taskName: taskCtrl.text,
                                dueDate: dueCtrl.text,
                                name: nameCtrl.text,
                                status: statusCtrl.text,
                                priority: priorityCtrl.text,
                                avatar: Images.userAvatars[1],
                              );
                            }
                            Navigator.pop(context);
                          },
                          color: contentTheme.primary,
                          paddingAll: 12,
                          borderRadiusAll: 12,
                          child: MyText.bodyMedium(isEdit ? 'Update' : 'Add', color: contentTheme.onPrimary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Color priorityColor(String p) => {'High': Colors.red, 'Medium': Colors.amber, 'Low': Colors.green}[p] ?? Colors.grey;

  Color statusColor(String s) =>
      {'In-progress': Colors.orange, 'Pending': Colors.blue, 'Completed': Colors.green, 'New': Colors.cyan}[s] ?? Colors.grey;

  OutlineInputBorder border() => OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: contentTheme.secondary));

  Widget customField({String? hintText, Widget? prefixIcon, TextEditingController? controller, String? title}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) MyText.bodyMedium(title),
        if (title != null) MySpacing.height(4),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            border: border(),
            focusedErrorBorder: border(),
            focusedBorder: border(),
            errorBorder: border(),
            enabledBorder: border(),
            disabledBorder: border(),
            contentPadding: MySpacing.all(12),
            isDense: true,
            isCollapsed: true,
            hintStyle: MyTextStyle.bodyMedium(),
            prefixIcon: prefixIcon,
            hintText: hintText,
          ),
        ),
      ],
    );
  }
}
