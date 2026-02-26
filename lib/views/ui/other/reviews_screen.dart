import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:original_taste/controller/ui/other/reviews_controller.dart';
import 'package:original_taste/helper/utils/mixins/ui_mixins.dart';
import 'package:original_taste/helper/utils/my_shadow.dart';
import 'package:original_taste/helper/widgets/my_card.dart';
import 'package:original_taste/helper/widgets/my_container.dart';
import 'package:original_taste/helper/widgets/my_spacing.dart';
import 'package:original_taste/helper/widgets/my_star_rating.dart';
import 'package:original_taste/helper/widgets/my_text.dart';
import 'package:original_taste/images.dart';
import 'package:original_taste/views/layout/layout.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> with UIMixin{
  ReviewsController controller = Get.put(ReviewsController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (controller) {
        return Layout(screenName: "REVIEWS LIST",
        child: GridView.builder(
          itemCount: controller.reviews.length,
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 500,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 300,
          ),
          itemBuilder: (context, index) {
            final review = controller.reviews[index];
            return MyCard(
              shadow: MyShadow(elevation: .7, position: MyShadowPosition.bottom),
              paddingAll: 0,
              borderRadiusAll: 12,
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: MySpacing.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText.titleMedium('Reviewed in ${review['country']} on ${review['date']}', fontWeight: 700),
                        MySpacing.height(12),
                        MyText.bodyMedium("${review['review']}"),
                        MySpacing.height(12),
                        Row(
                          children: [
                            MyStarRating(rating: review['rating'],size: 20,),
                        MySpacing.width(12),
                        MyText.bodyMedium("${review['label']}"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      MyContainer(
                        borderRadiusAll: 0,
                        color: contentTheme.primary,
                        width: double.infinity,
                        clipBehavior: Clip.antiAlias,
                        padding: const EdgeInsets.only(top: 40, bottom: 16,left: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:  [
                            MyText.titleMedium(review['name'],color: contentTheme.onPrimary,),
                            MySpacing.height(6),
                            MyText.bodyMedium('${review['company']} / ${review['role']}',color: contentTheme.onPrimary,),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 16,
                        top: -30,
                        child: MyContainer.rounded(
                          paddingAll: 0,
                          height: 58,
                          width: 58,
                          child: Image.asset(Images.userAvatars[index % Images.userAvatars.length]),
                        ),
                      ),
                      Positioned(
                        right: 24,
                        top: -30,
                        child: Image.asset(
                          "assets/double.png",
                          height: 72,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        ),
        );
      },);
  }
}
