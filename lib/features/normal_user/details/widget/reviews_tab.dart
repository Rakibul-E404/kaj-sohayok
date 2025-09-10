import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/features/normal_user/details/widget/rating_card_widget.dart';
import 'package:kaz_bd/features/normal_user/details/widget/ratings_showing_widget.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import '../../../../helpers/ui_helpers.dart';

class ReviewsTab extends StatelessWidget {
  const ReviewsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const PageStorageKey('reviews'),
      padding: EdgeInsets.all(UIHelper.kDefaulutPadding()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///Section : Top Review
          RatingCard(
            overallRating: 4.0,
            totalReviews: 52,
            starDistribution: {
              5: 0.85, // 85% of reviews are 5 star
              4: 0.50, // 50% of reviews are 4 star
              3: 0.25, // 25% of reviews are 3 star
              2: 0.10, // 10% of reviews are 2 star
              1: 0.05, // 5% of reviews are 1 star
            },
          ),
          UIHelper.verticalSpace(16.h),

          ///Section : Comments
          ListView.separated(
            itemCount: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => UIHelper.verticalSpace(16.h),
            itemBuilder: (context, index) {
              return RatingsShowingWidget(
                userImage: Assets.images.userImage.path,
                userName: "Chowdhury Md. Imtiazul Islam",
                givenRatings: 4,
                timeFrame: "2 Weeks ago",
                comment:
                    "Lorem ipsum dolor sit amet consectetur. Dolor volutpat "
                    "tellus nunc nulla enim sit. Nunc ut pellentesque aliquet et. "
                    " Nunc mattis molestie elit malesuada.",
              );
            },
          ),
        ],
      ),
    );
  }
}
