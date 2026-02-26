import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:original_taste/controller/ui/components/forms/form_editor_controller.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/views/layout/layout.dart';

class FormEditorScreen extends StatefulWidget {
  const FormEditorScreen({super.key});

  @override
  State<FormEditorScreen> createState() => _FormEditorScreenState();
}

class _FormEditorScreenState extends State<FormEditorScreen> with UIMixin {
  FormEditorController controller = Get.put(FormEditorController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      tag: 'editor_controller',
      builder: (controller) {
        return Layout(
          screenName: "FORM EDITOR",
          child: MyCard(
            borderRadiusAll: 12,
            shadow: MyShadow(elevation: .5, position: MyShadowPosition.bottom),
            paddingAll: 20,
            child: Column(
              children: [
                QuillSimpleToolbar(controller: controller.quillController, config: QuillSimpleToolbarConfig()),
                SizedBox(
                  height: 300,
                  child: QuillEditor.basic(
                    controller: controller.quillController,
                    config: QuillEditorConfig(showCursor: true, expands: false),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
