import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/text_font_style.dart';
import '../helpers/ui_helpers.dart';
import '../gen/assets.gen.dart';
import '../custom_widgets/custom_shimmer_effect.dart';

class RatingsShowingWidget extends StatelessWidget {
  final String userImage;
  final String userName;
  final double givenRatings;
  final String timeFrame;
  final String comment;
  const RatingsShowingWidget({
    super.key,
    required this.userImage,
    required this.userName,
    required this.givenRatings,
    required this.timeFrame,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ///Section : User Image
        ///Section : User Name
        ///Section : User given Rating
        ///Section : Ratings
        ///Section : Time Frame
        Row(
          children: [
            ///Section : User Image
            SizedBox(
              width: 40.w,
              height: 40.h,
              child: CachedNetworkImage(
                imageUrl: userImage,
                fit: BoxFit.cover,
                imageBuilder: (context, imageProvider) => CircleAvatar(
                  radius: 20,
                  backgroundImage: imageProvider,
                ),
                placeholder: (context, url) => CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(Icons.person, color: Colors.grey),
                ),
                errorWidget: (context, url, error) => CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(Icons.person, color: Colors.grey),
                ),
              ),
            ),
            UIHelper.horizontalSpace(12.w),

            ///Section : User Name
            ///Section : User given Rating
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ///Section : User Name
                SizedBox(
                  width: 0.5.sw,
                  child: Text(
                    userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextFontStyle.headline16w500c000000StyleSatoshi,
                  ),
                ),
                UIHelper.verticalSpace(3.h),

                ///Section : Ratings
                RatingBarIndicator(
                  rating: givenRatings,
                  itemCount: 5,
                  itemSize: 16.sp,
                  unratedColor: Colors.grey.shade300,
                  itemBuilder: (context, _) =>
                      const Icon(Icons.star_rate_rounded, color: Colors.amber),
                ),
              ],
            ),
            Spacer(),

            ///Section : Time Frame
            Text(
              timeFrame,
              style: TextFontStyle.headline12w500c5c5c5cStyleSatoshi,
            ),
          ],
        ),
        UIHelper.verticalSpace(12.h),

        Text(
          comment,
          textAlign: TextAlign.start,
          style: TextFontStyle.headline12w400c5c5c5cStyleSatoshi,
        ),
      ],
    );
  }
}
