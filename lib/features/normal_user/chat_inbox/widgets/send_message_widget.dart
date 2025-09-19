import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../gen/colors.gen.dart';
import '../../../../helpers/ui_helpers.dart';

class SendMessageWidget extends StatelessWidget {
  SendMessageWidget({super.key, required this.controller, this.onTap});

  final TextEditingController controller;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 8.h, bottom: 8.h, right: 8.w, left: 20.w),
      decoration: BoxDecoration(
        color: AppColors.cFFFFFF,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            ///Section : Send Message Section
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: "Write your message",
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12.h,
                    horizontal: 16.w,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: AppColors.ce8e8e8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: AppColors.ce8e8e8),
                  ),
                  filled: true,
                  fillColor: AppColors.cFFFFFF,
                ),
                maxLines: null,
              ),
            ),
            UIHelper.horizontalSpace(8.w),

            ///Section : Send Button
            InkWell(
              onTap: onTap,
              child: Container(
                padding: EdgeInsets.all(8.sp),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.c778beb,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.send, color: AppColors.cFFFFFF, size: 24.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
