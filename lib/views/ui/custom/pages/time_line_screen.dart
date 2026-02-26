import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:original_taste/controller/ui/custom/pages/time_line_controller.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/helper/widgets/responsive.dart';
import 'package:original_taste/views/layout/layout.dart';
import 'package:timelines_plus/timelines_plus.dart';

class TimeLineScreen extends StatefulWidget {
  const TimeLineScreen({super.key});

  @override
  State<TimeLineScreen> createState() => _TimeLineScreenState();
}

class _TimeLineScreenState extends State<TimeLineScreen>with UIMixin{
  TimeLineController controller = Get.put(TimeLineController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      tag: 'time_line_controller',
      builder: (controller) {
        return Layout(
          screenName: "TIMELINE",
          child: Padding(
            padding: MySpacing.x(flexSpacing),
            child: Column(
              children: [
                Timeline.tileBuilder(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  shrinkWrap: true,
                  builder: TimelineTileBuilder.fromStyle(
                    itemCount: controller.timeLineData.length,
                    contentsAlign: ContentsAlign.alternating,
                    connectorStyle: ConnectorStyle.dashedLine,
                    endConnectorStyle: ConnectorStyle.dashedLine,
                    contentsBuilder: (context, index) {
                      var timeLine = controller.timeLineData[index];
                      return MyCard(
                        marginAll: 20,
                        shadow: MyShadow(elevation: 0.2),
                        paddingAll: 24,
                        child: Column(
                          crossAxisAlignment: index % 2 == 0 ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                          children: [
                            MyText.titleMedium(timeLine['title'], fontWeight: 600, overflow: TextOverflow.ellipsis),
                            MySpacing.height(12),
                            MyText.bodyMedium(timeLine['description'],
                                fontWeight: 600, xMuted: true, textAlign: index % 2 == 0 ? TextAlign.start : TextAlign.end),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Divider(),
                Timeline.tileBuilder(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  shrinkWrap: true,
                  builder: TimelineTileBuilder.fromStyle(
                    itemCount: controller.timeLineData.length,
                    contentsAlign: ContentsAlign.alternating,
                    connectorStyle: ConnectorStyle.dashedLine,
                    endConnectorStyle: ConnectorStyle.dashedLine,
                    addSemanticIndexes: true,
                    addAutomaticKeepAlives: true,
                    addRepaintBoundaries: true,

                    contentsBuilder: (context, index) {
                      var timeLine = controller.timeLineData[index];
                      return MyCard(
                        marginAll: 20,
                        shadow: MyShadow(elevation: 0.2),
                        paddingAll: 24,
                        child: Column(
                          crossAxisAlignment:  CrossAxisAlignment.start,
                          children: [
                            MyText.titleMedium(timeLine['title'], fontWeight: 600, overflow: TextOverflow.ellipsis),
                            MySpacing.height(12),
                            MyText.bodyMedium(timeLine['description'],
                                fontWeight: 600, xMuted: true,),
                          ],
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
