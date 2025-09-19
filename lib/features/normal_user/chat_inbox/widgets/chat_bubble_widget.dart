import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../../../../gen/colors.gen.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isSentByMe;
  final String time;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isSentByMe,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 16.h,
          horizontal: UIHelper.kDefaulutPadding(),
        ),
        child: Column(
          crossAxisAlignment: isSentByMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 0.75.sw),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
                decoration: BoxDecoration(
                  borderRadius: isSentByMe
                      ? BorderRadiusGeometry.directional(
                          topStart: Radius.circular(10.r),
                          bottomStart: Radius.circular(10.r),
                          bottomEnd: Radius.circular(10.r),
                        )
                      : BorderRadiusGeometry.directional(
                          topEnd: Radius.circular(10.r),
                          bottomStart: Radius.circular(10.r),
                          bottomEnd: Radius.circular(10.r),
                        ),
                  color: isSentByMe ? AppColors.c778beb : AppColors.cd5dbf9,
                ),
                child: Text(
                  message,
                  style: TextFontStyle.headline12w700c000e08StyleSatoshi,
                  softWrap: true,
                ),
              ),
            ),
            UIHelper.verticalSpace(8.h),

            ///Section : Message send/receive time widget
            Text(time, style: TextFontStyle.headline10w700c797c7bStyleSatoshi),
          ],
        ),
      ),
    );
  }
}
