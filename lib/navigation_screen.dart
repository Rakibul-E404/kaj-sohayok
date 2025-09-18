// // ignore_for_file: deprecated_member_use

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:kaz_bd/features/auth/forgot_password/presentation/forgot_password_screen.dart';
// import 'package:kaz_bd/features/auth/sign_in/presentation/sign_in_screen.dart';
// import 'package:kaz_bd/features/auth/verify_otp/verify_otp_screen.dart';
// import 'package:kaz_bd/features/welcome/choose_role/presentation/choose_role_screen.dart';
// import 'package:kaz_bd/gen/assets.gen.dart';
// import 'package:kaz_bd/helpers/ui_helpers.dart';

// import '../../../gen/colors.gen.dart';

// class NavigationScreen extends StatefulWidget {
//   const NavigationScreen({super.key});

//   @override
//   State<NavigationScreen> createState() => _NavigationScreenState();
// }

// class _NavigationScreenState extends State<NavigationScreen> {
//   int _selectedIndex = 0;
//   late PageController _pageController;

//   final List<Widget> _pages = [
//     ChooseRoleScreen(),
//     ForgotPasswordScreen(),
//     VerifyOtpScreen(),
//     SignInScreen(),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _pageController = PageController(initialPage: _selectedIndex);
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//       _pageController.animateToPage(
//         index,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.ease,
//       );
//     });
//   }

//   void _onPageChanged(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.scaffoldBackgroundColor,
//       body: SafeArea(
//         child: PageView(
//           controller: _pageController,
//           onPageChanged: _onPageChanged,
//           children: _pages,
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       floatingActionButton: Padding(
//         padding: EdgeInsets.symmetric(horizontal: UIHelper.kDefaulutPadding()),
//         child: Container(
//           alignment: Alignment.center,
//           height: 80.h,
//           width: 1.sw,
//           padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
//           decoration: BoxDecoration(
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.1), // rgba(0, 0, 0, 0.10)
//                 blurRadius: 25,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//             color: AppColors.cf1f3fd,
//             border: Border.all(color: AppColors.c778beb),
//             borderRadius: BorderRadius.circular(50.r),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               GestureDetector(
//                 onTap: () {
//                   _onItemTapped(0);
//                 },
//                 child: NavItem(
//                   icon: Assets.icons.homeIcon,
//                   selectedIndex: _selectedIndex,
//                   currentIndex: 0,
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   _onItemTapped(1);
//                 },
//                 child: NavItem(
//                   icon: Assets.icons.bookingsIcon,
//                   selectedIndex: _selectedIndex,
//                   currentIndex: 1,
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   _onItemTapped(2);
//                 },
//                 child: NavItem(
//                   icon: Assets.icons.chatIcon,
//                   selectedIndex: _selectedIndex,
//                   currentIndex: 2,
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   _onItemTapped(3);
//                 },
//                 child: NavItem(
//                   icon: Assets.icons.profileIcon,
//                   selectedIndex: _selectedIndex,
//                   currentIndex: 3,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class NavItem extends StatelessWidget {
//   final String icon;
//   final int currentIndex;
//   final int selectedIndex;
//   const NavItem({
//     super.key,
//     required this.icon,
//     required this.currentIndex,
//     required this.selectedIndex,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(12.sp),
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: selectedIndex == currentIndex
//             ? AppColors.c778beb
//             : Colors.transparent,
//       ),
//       child: SvgPicture.asset(
//         icon,
//         height: 24.h,
//         width: 24.w,
//         color: selectedIndex == currentIndex
//             ? AppColors.cFFFFFF
//             : AppColors.c616161,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kaz_bd/features/normal_user/bookings/presentation/bookings_screen.dart';
import 'package:kaz_bd/features/normal_user/home/presentation/home_screen.dart';
import 'package:kaz_bd/features/normal_user/messages/message_list.dart';
import 'package:kaz_bd/features/normal_user/user_profile/presentation/user_profile_screen.dart';
import 'package:kaz_bd/gen/assets.gen.dart';
import 'package:kaz_bd/helpers/ui_helpers.dart';

import '../../../gen/colors.gen.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late PageController _pageController;
  late AnimationController _backgroundAnimationController;
  late Animation<double> _backgroundAnimation;

  final List<Widget> _pages = [
    HomeScreen(),
    BookingsScreen(),
    MessageScreen(),
    UserProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);

    // Initialize background animation controller
    _backgroundAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _backgroundAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    });

    // Trigger background animation
    _backgroundAnimationController.forward().then((_) {
      _backgroundAnimationController.reset();
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: _pages,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(horizontal: UIHelper.kDefaulutPadding()),
        child: Container(
          alignment: Alignment.center,
          height: 80.h,
          width: 1.sw,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 25,
                offset: const Offset(0, 4),
              ),
            ],
            color: AppColors.cf1f3fd,
            border: Border.all(color: AppColors.c778beb),
            borderRadius: BorderRadius.circular(50.r),
          ),
          child: AnimatedNavigationBar(
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
            backgroundAnimation: _backgroundAnimation,
          ),
        ),
      ),
    );
  }
}

class AnimatedNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final Animation<double> backgroundAnimation;

  const AnimatedNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.backgroundAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Animated Background
        AnimatedBuilder(
          animation: backgroundAnimation,
          builder: (context, child) {
            return AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _calculateBackgroundPosition(context),
              top: 0,
              bottom: 0,
              child: Container(
                width: 48.w, // Size of the circular background
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.c778beb,
                ),
              ),
            );
          },
        ),
        // Navigation Items
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => onItemTapped(0),
              child: NavItem(
                icon: Assets.icons.homeIcon,
                selectedIndex: selectedIndex,
                currentIndex: 0,
              ),
            ),
            GestureDetector(
              onTap: () => onItemTapped(1),
              child: NavItem(
                icon: Assets.icons.bookingsIcon,
                selectedIndex: selectedIndex,
                currentIndex: 1,
              ),
            ),
            GestureDetector(
              onTap: () => onItemTapped(2),
              child: NavItem(
                icon: Assets.icons.chatIcon,
                selectedIndex: selectedIndex,
                currentIndex: 2,
              ),
            ),
            GestureDetector(
              onTap: () => onItemTapped(3),
              child: NavItem(
                icon: Assets.icons.profileIcon,
                selectedIndex: selectedIndex,
                currentIndex: 3,
              ),
            ),
          ],
        ),
      ],
    );
  }

  double _calculateBackgroundPosition(BuildContext context) {
    // Get the container width (total screen width minus horizontal padding)
    final double containerWidth = 1.sw - (UIHelper.kDefaulutPadding() * 2);

    // Account for the container's internal padding
    final double availableWidth =
        containerWidth - 40.w; // 20.w padding on each side

    // Calculate the width each item occupies
    final double itemWidth = availableWidth / 4;

    // Calculate the center position for the selected item
    final double itemCenterX = (selectedIndex * itemWidth) + (itemWidth / 2);

    // Subtract half the background width to center it (no need to add left padding)
    final double backgroundWidth = 48.w;

    return itemCenterX - (backgroundWidth / 2);
  }
}

class NavItem extends StatefulWidget {
  final String icon;
  final int currentIndex;
  final int selectedIndex;

  const NavItem({
    super.key,
    required this.icon,
    required this.currentIndex,
    required this.selectedIndex,
  });

  @override
  State<NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<NavItem> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(NavItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.selectedIndex == widget.currentIndex &&
        oldWidget.selectedIndex != widget.currentIndex) {
      // Item became selected - animate scale up
      _scaleController.forward();
    } else if (widget.selectedIndex != widget.currentIndex &&
        oldWidget.selectedIndex == widget.currentIndex) {
      // Item became unselected - animate scale down
      _scaleController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.selectedIndex == widget.currentIndex
              ? _scaleAnimation.value
              : 1.0,
          child: Container(
            padding: EdgeInsets.all(12.sp),
            child: SvgPicture.asset(
              widget.icon,
              height: 24.h,
              width: 24.w,
              color: widget.selectedIndex == widget.currentIndex
                  ? AppColors.cFFFFFF
                  : AppColors.c616161,
            ),
          ),
        );
      },
    );
  }
}
