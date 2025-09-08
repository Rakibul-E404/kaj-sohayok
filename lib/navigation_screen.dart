// ignore_for_file: library_private_types_in_public_api

import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kaz_bd/features/auth/forgot_password/presentation/forgot_password_screen.dart';
import 'package:kaz_bd/features/auth/sign_in/presentation/sign_in_screen.dart';
import 'package:kaz_bd/features/auth/sign_up/presentation/sign_up_screen.dart';
import 'package:kaz_bd/features/auth/verify_otp/verify_otp_screen.dart';

class NavigationScreen extends StatefulWidget {
  final Widget? pageNum;
  const NavigationScreen({super.key, this.pageNum});

  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      SignInScreen(),
      SignUpScreen(),
      VerifyOtpScreen(),
      ForgotPasswordScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.cyanAccent,
      extendBody: true,
      body: Center(child: screens.elementAt(currentIndex)),
      bottomNavigationBar: Container(
        height: 66.h,
        decoration: BoxDecoration(color: Colors.purple),
        child: Padding(
          padding: EdgeInsets.all(0.sp),
          child: CustomNavigationBar(
            backgroundColor: Colors.amber,
            iconSize: 28.r,
            selectedColor: Colors.red,
            strokeColor: Colors.red,
            unSelectedColor: Colors.green,
            borderRadius: Radius.zero,
            items: [
              CustomNavigationBarItem(
                icon: Stack(
                  alignment: Alignment.center,
                  children: [
                    currentIndex == 0
                        ? Container(
                            height: 60.h,
                            width: 60.w,
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(6.sp),
                            child: Icon(Icons.person),
                          )
                        : Center(child: Icon(Icons.car_crash)),
                  ],
                ),
                title: Text(
                  "Home",
                  style: TextStyle(
                    color: currentIndex == 0 ? Colors.blue : Colors.pink,
                  ),
                ),
              ),
              CustomNavigationBarItem(
                icon: Stack(
                  alignment: Alignment.center,
                  children: [
                    currentIndex == 1
                        ? Container(
                            height: 50.h,
                            width: 50.w,
                            padding: EdgeInsets.all(4.sp),
                            child: Icon(Icons.follow_the_signs),
                          )
                        : Center(child: Icon(Icons.ac_unit_sharp)),
                  ],
                ),
                title: Text(
                  "Profile",
                  style: TextStyle(
                    color: currentIndex == 1 ? Colors.blue : Colors.pink,
                  ),
                ),
              ),
              CustomNavigationBarItem(
                icon: Stack(
                  alignment: Alignment.center,
                  children: [
                    currentIndex == 2
                        ? Container(
                            height: 50.h,
                            width: 50.w,
                            padding: EdgeInsets.all(4.sp),
                            child: Icon(Icons.follow_the_signs),
                          )
                        : Center(child: Icon(Icons.ac_unit_sharp)),
                  ],
                ),
                title: Text(
                  "Profile",
                  style: TextStyle(
                    color: currentIndex == 2 ? Colors.blue : Colors.pink,
                  ),
                ),
              ),

              CustomNavigationBarItem(
                icon: Stack(
                  alignment: Alignment.center,
                  children: [
                    currentIndex == 3
                        ? Container(
                            height: 50.h,
                            width: 50.w,
                            padding: EdgeInsets.all(4.sp),
                            child: Icon(Icons.follow_the_signs),
                          )
                        : Center(child: Icon(Icons.ac_unit_sharp)),
                  ],
                ),
                title: Text(
                  "Profile",
                  style: TextStyle(
                    color: currentIndex == 3 ? Colors.blue : Colors.pink,
                  ),
                ),
              ),
            ],
            currentIndex: currentIndex,
            onTap: (index) {
              setState(() {
                currentIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
