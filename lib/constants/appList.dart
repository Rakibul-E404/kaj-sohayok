import 'package:flutter/material.dart';
import 'package:kaz_bd/features/normal_user/provider_profile_details/model/profile_tile_model.dart';
import 'package:kaz_bd/gen/assets.gen.dart';

import '../features/normal_user/home/models/category_mode.dart';
import '../features/normal_user/user_profile/models/settings_options_model.dart';

class AppList {
  static final List<String> genderList = ["Male", "Female", "Other"];

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
}
