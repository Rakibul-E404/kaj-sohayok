// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:kaz_bd/gen/assets.gen.dart';

// import '../../../../gen/colors.gen.dart';
// import '../presentation/personal_inbox_screen.dart';

// // MessageTile (Each Message Item)
// class MessageTile extends StatelessWidget {
//   final String name;
//   final String lastMessage;
//   final String time;
//   final bool isUnread;

//   const MessageTile({
//     super.key,
//     required this.name,
//     required this.lastMessage,
//     required this.time,
//     required this.isUnread,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       contentPadding: EdgeInsets.zero,
//       leading: CircleAvatar(
//         radius: 30.r,
//         backgroundImage: AssetImage(Assets.images.userImage.path),
//       ),
//       title: Row(
//         children: [
//           Expanded(
//             child: Text(
//               name,
//               style: TextStyle(
//                 color: Colors.black,
//                 fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
//               ),
//             ),
//           ),
//           Text(time, style: TextStyle(fontSize: 12, color: Colors.grey)),
//         ],
//       ),
//       subtitle: Text(
//         lastMessage,
//         style: TextStyle(
//           fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
//           color: isUnread ? AppColors.c778beb : AppColors.ca4b1f2,
//         ),
//         overflow: TextOverflow.ellipsis,
//       ),
//       onTap: () {
//         Get.to(() => PersonalInbox(name: name));
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:kaz_bd/constants/text_font_style.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/gen/colors.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../../chat_inbox/presentation/chat_inbox_screen.dart';

class MessageTile extends StatelessWidget {
  final String userName;
  final String lastMessage;
  final String time;
  final bool isUnread;
  final int totalUnrededMessage;
  const MessageTile({
    super.key,
    required this.userName,
    required this.lastMessage,
    required this.time,
    required this.isUnread,
    required this.totalUnrededMessage,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(() => PersonalInbox(name: userName));
      },
      child: Container(
        child: Row(
          children: [
            ///Section : User Image
            CircleAvatar(
              radius: 30.r,
              backgroundImage: AssetImage(Assets.images.userImage.path),
            ),
            UIHelper.horizontalSpace(12.w),

            ///Section : User Name
            ///Section : Last Message
            ///Section : Last Message Time
            ///Section : Total Unread Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ///Section : Use Name
                  ///Section : Last Message Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 0.57.sw,
                        child: Text(
                          userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextFontStyle.headline16w700c202020StyleSatoshi
                              .copyWith(
                                fontWeight: isUnread ? FontWeight.w700 : null,
                              ),
                        ),
                      ),
                      Spacer(),
                      Text(
                        time,
                        style: TextFontStyle.headline10w400c797c7bStyleSatoshi,
                      ),
                    ],
                  ),
                  UIHelper.verticalSpace(2.h),

                  ///Section : Last Message
                  ///Section : Total Unreaded Message
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ///Section : Last Message
                      SizedBox(
                        width: 0.6.sw,
                        child: Text(
                          lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              TextFontStyle.headline12w400c616161StyleSatoshi,
                        ),
                      ),
                      Spacer(),

                      ///Section : Total Unreaded Message
                      isUnread
                          ? Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 4.h,
                                horizontal: 7.w,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.cf04a4c,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                totalUnrededMessage != 0
                                    ? totalUnrededMessage.toString()
                                    : "",
                                style: TextFontStyle
                                    .headline12w400cFFFFFFStyleSatoshi,
                              ),
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
