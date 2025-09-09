import 'package:flutter/material.dart';

import '../features/normal_user/home/models/category_mode.dart';

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
}
