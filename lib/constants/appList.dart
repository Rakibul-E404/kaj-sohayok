import 'package:flutter/material.dart';
import 'package:kaz_bd/features/normal_user/provider_profile_details/model/profile_tile_model.dart';
import 'package:kaz_bd/features/service_provider/svp_job_details/model/user_info_model.dart';
import 'package:kaz_bd/gen/assets.gen.dart';

import '../features/normal_user/chat_inbox/model/chat_message_model.dart';
import '../features/normal_user/home/models/category_mode.dart';
import '../features/normal_user/chat_list/model/message_model.dart';
import '../features/normal_user/chat_list/presentation/chat_list_screen.dart';
import '../features/common_screens/notification/model/notification_model.dart';
import '../features/normal_user/user_profile/models/settings_options_model.dart';
import '../features/normal_user/work_completed_details/model/additional_cost_model.dart';
import '../features/service_provider/svp_home/model/svp_card_model.dart';

class AppList {
  static final List<String> genderList = ["Male", "Female", "Other"];

  static List<NotificationModel> notificationList = [
    NotificationModel(title: "Your Password Updated Successfully!", time: 10),
    NotificationModel(title: "Your Password Updated Successfully!", time: 10),
    NotificationModel(title: "Your Password Updated Successfully!", time: 10),
    NotificationModel(title: "Your Password Updated Successfully!", time: 10),
    NotificationModel(title: "Your Password Updated Successfully!", time: 10),
    NotificationModel(title: "Your Password Updated Successfully!", time: 10),
    NotificationModel(title: "Your Password Updated Successfully!", time: 10),
    NotificationModel(title: "Your Password Updated Successfully!", time: 10),
    NotificationModel(title: "Your Password Updated Successfully!", time: 10),
    NotificationModel(title: "Your Password Updated Successfully!", time: 10),
    NotificationModel(title: "Your Password Updated Successfully!", time: 10),
    NotificationModel(title: "Your Password Updated Successfully!", time: 10),
    NotificationModel(title: "Your Password Updated Successfully!", time: 10),
  ];

  // Pages of categories
  static final List<List<CategoryModel>> categories = [
    [
      CategoryModel(
        categoryIcon: Icons.cleaning_services,
        categoryName: 'Cleaning',
      ),
      CategoryModel(categoryIcon: Icons.ac_unit, categoryName: 'AC Repair'),
      CategoryModel(categoryIcon: Icons.plumbing, categoryName: 'Plumbing'),
      CategoryModel(
        categoryIcon: Icons.electric_car,
        categoryName: 'Electrical',
      ),
      CategoryModel(categoryIcon: Icons.brush, categoryName: 'Painting'),
      CategoryModel(categoryIcon: Icons.settings, categoryName: 'Repairing'),
    ],
    [
      CategoryModel(
        categoryIcon: Icons.local_car_wash,
        categoryName: 'Car Wash',
      ),
      CategoryModel(categoryIcon: Icons.grass, categoryName: 'Gardening'),
      CategoryModel(
        categoryIcon: Icons.local_laundry_service,
        categoryName: 'Laundry',
      ),
      CategoryModel(
        categoryIcon: Icons.delivery_dining,
        categoryName: 'Delivery',
      ),
      CategoryModel(categoryIcon: Icons.restaurant, categoryName: 'Cooking'),
      CategoryModel(categoryIcon: Icons.security, categoryName: 'Security'),
    ],
    [
      CategoryModel(categoryIcon: Icons.fitness_center, categoryName: 'Gym'),
      CategoryModel(categoryIcon: Icons.self_improvement, categoryName: 'Yoga'),
      CategoryModel(categoryIcon: Icons.music_note, categoryName: 'Dance'),
      CategoryModel(categoryIcon: Icons.pool, categoryName: 'Swimming'),
      CategoryModel(
        categoryIcon: Icons.camera_alt,
        categoryName: 'Photography',
      ),
      CategoryModel(categoryIcon: Icons.school, categoryName: 'Tutoring'),
    ],
  ];

  static List<CategoryModel> allCategoryList = [
    CategoryModel(
      categoryIcon: Icons.cleaning_services,
      categoryName: 'Cleaning',
    ),
    CategoryModel(categoryIcon: Icons.ac_unit, categoryName: 'AC Repair'),
    CategoryModel(categoryIcon: Icons.plumbing, categoryName: 'Plumbing'),
    CategoryModel(categoryIcon: Icons.electric_car, categoryName: 'Electrical'),
    CategoryModel(categoryIcon: Icons.local_car_wash, categoryName: 'Car Wash'),
    CategoryModel(categoryIcon: Icons.grass, categoryName: 'Gardening'),
    CategoryModel(
      categoryIcon: Icons.local_laundry_service,
      categoryName: 'Laundry',
    ),
    CategoryModel(
      categoryIcon: Icons.delivery_dining,
      categoryName: 'Delivery',
    ),
    CategoryModel(categoryIcon: Icons.restaurant, categoryName: 'Cooking'),
    CategoryModel(categoryIcon: Icons.security, categoryName: 'Security'),
    CategoryModel(categoryIcon: Icons.fitness_center, categoryName: 'Gym'),
    CategoryModel(categoryIcon: Icons.self_improvement, categoryName: 'Yoga'),
    CategoryModel(categoryIcon: Icons.music_note, categoryName: 'Dance'),
    CategoryModel(categoryIcon: Icons.pool, categoryName: 'Swimming'),
    CategoryModel(categoryIcon: Icons.camera_alt, categoryName: 'Photography'),
    CategoryModel(categoryIcon: Icons.school, categoryName: 'Tutoring'),
    CategoryModel(categoryIcon: Icons.restaurant, categoryName: 'Cooking'),
    CategoryModel(categoryIcon: Icons.security, categoryName: 'Security'),
    CategoryModel(categoryIcon: Icons.fitness_center, categoryName: 'Gym'),
    CategoryModel(categoryIcon: Icons.self_improvement, categoryName: 'Yoga'),
    CategoryModel(categoryIcon: Icons.music_note, categoryName: 'Dance'),
    CategoryModel(categoryIcon: Icons.pool, categoryName: 'Swimming'),
    CategoryModel(categoryIcon: Icons.camera_alt, categoryName: 'Photography'),
    CategoryModel(categoryIcon: Icons.school, categoryName: 'Tutoring'),
  ];

  static List imageList = [
    Assets.images.serviceImage.path,
    Assets.images.heroBannerImage.path,
    Assets.images.userImage.path,
    Assets.images.specificServiceImage.path,
    Assets.images.heroBannerImage.path,
    Assets.images.userImage.path,
  ];

  static List<ProfileTileModel> profileTileList = [
    ProfileTileModel(title: "Occupation", data: "AC-Repair"),
    ProfileTileModel(title: "Years of Experience", data: "4 Years"),
    ProfileTileModel(title: "Name", data: "Ripon Mia"),
    ProfileTileModel(title: "Phone Number", data: "1233333333"),
    ProfileTileModel(title: "Location", data: "Rangpur Bangladesh"),
    ProfileTileModel(title: "Date of Birth", data: "11-11-2025"),
    ProfileTileModel(title: "Gender", data: "Male"),
  ];

  static List<SettingsOptionsModel> settingsOptionsList = [
    SettingsOptionsModel(
      icon: Assets.icons.keyIcon,
      optionName: "Change Password",
    ),
    SettingsOptionsModel(
      icon: Assets.icons.privacyPolicyIcon,
      optionName: "Privacy policy",
    ),
    SettingsOptionsModel(
      icon: Assets.icons.termsConditionsIcon,
      optionName: "Terms & conditions",
    ),
    SettingsOptionsModel(
      icon: Assets.icons.aboutUsIcon,
      optionName: "About us",
    ),
    SettingsOptionsModel(icon: Assets.icons.helpIcon, optionName: "Contact Us"),
    SettingsOptionsModel(icon: Assets.icons.logOutIcon, optionName: "Logout"),
  ];

  static List<ProfileTileModel> userProfileList = [
    ProfileTileModel(title: "Name", data: "Chowdhury Md. Imtiazul Islam"),
    ProfileTileModel(title: "Email", data: "Support@gmail.com"),
    ProfileTileModel(title: "Phone number", data: "1233333333"),
    ProfileTileModel(title: "Address", data: "Rangpur Bangladesh"),
    ProfileTileModel(title: "Date of Birth", data: "11-11-1999"),
    ProfileTileModel(title: "Gender", data: "Male"),
  ];

  static final List<MessageModel> messages = [
    MessageModel(
      name: 'Rocky Parker',
      lastMessage: 'Your okay fine.',
      time: '08:36 am',
      isUnread: true,
      totalUnrededMessage: 5,
    ),
    MessageModel(
      name: 'Jobless Community Jobless Community',
      lastMessage: 'Your okay fine.',
      time: '08:36 am',
      isUnread: false,
      totalUnrededMessage: 0,
    ),
    MessageModel(
      name: 'IT Job',
      lastMessage: 'Your okay fine.',
      time: '08:36 am',
      isUnread: false,
      totalUnrededMessage: 0,
    ),
    MessageModel(
      name: 'Abir Parker',
      lastMessage: 'Your okay fine.',
      time: '08:36 am',
      isUnread: true,
      totalUnrededMessage: 7,
    ),
    MessageModel(
      name: 'IT Job',
      lastMessage: 'Your okay fine.',
      time: '08:36 am',
      isUnread: false,
      totalUnrededMessage: 0,
    ),
    MessageModel(
      name: 'Imtiaz Chowdhury',
      lastMessage: 'Your okay fine.',
      time: '08:36 am',
      isUnread: true,
      totalUnrededMessage: 7,
    ),
    MessageModel(
      name: 'Abir Parker',
      lastMessage: 'Your okay fine.',
      time: '08:36 am',
      isUnread: true,
      totalUnrededMessage: 7,
    ),
    MessageModel(
      name: 'IT Job',
      lastMessage: 'Your okay fine.',
      time: '08:36 am',
      isUnread: false,
      totalUnrededMessage: 0,
    ),
    MessageModel(
      name: 'Imtiaz Chowdhury',
      lastMessage: 'Your okay fine.',
      time: '08:36 am',
      isUnread: true,
      totalUnrededMessage: 7,
    ),
  ];

  static final List<ChatMessageModel> chatInboxMessageList = [
    ChatMessageModel(message: "Hyyy!!!", isSentByMe: true, time: "3:00 pm"),
    ChatMessageModel(
      message: "When are we meeting? It's been so long!",
      isSentByMe: false,
      time: "3:01 pm",
    ),
    ChatMessageModel(
      message: "Hyyyy.... georg.",
      isSentByMe: true,
      time: "3:02 pm",
    ),
    ChatMessageModel(
      message: "Next week for sure.",
      isSentByMe: false,
      time: "3:02 pm",
    ),
  ];

  static List<SvpCardModel> svpJobsTypeList = [
    SvpCardModel(title: "Job Request", totalJobs: 12),
    SvpCardModel(title: "Accepted Booking", totalJobs: 01),
    SvpCardModel(title: "In Progress", totalJobs: 12),
    SvpCardModel(title: "Work completed", totalJobs: 16),
  ];

  static List<UserInfoModel> userInfoList = [
    UserInfoModel(fieldName: "Name", data: "Swapon Mia"),
    UserInfoModel(fieldName: "Location", data: "Rangpur Bangladesh"),
    UserInfoModel(fieldName: "Date of Birth", data: "11-11-2025"),
    UserInfoModel(fieldName: "Gender", data: "Male"),
  ];

  static final List<AdditionalCostModel> additionalCosts = [
    AdditionalCostModel(title: "Delivery Charge", price: 50.0),
    AdditionalCostModel(title: "Installation Fee", price: 120.0),
    AdditionalCostModel(title: "Service Tax", price: 30.0),
    AdditionalCostModel(title: "Maintenance Fee", price: 75.0),
    AdditionalCostModel(title: "Warranty Extension", price: 200.0),
    AdditionalCostModel(title: "Packaging Cost", price: 25.0),
    AdditionalCostModel(title: "Express Shipping", price: 150.0),
    AdditionalCostModel(title: "Extra Parts", price: 300.0),
    AdditionalCostModel(title: "Cleaning Service", price: 80.0),
    AdditionalCostModel(title: "Miscellaneous", price: 40.0),
  ];
}
