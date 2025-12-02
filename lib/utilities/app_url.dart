class AppUrl {
  AppUrl._();

  static const String baseUrl = 'https://newsheakh6737.sobhoy.com/api/';
  static const String imageBaseUrl = 'https://newsheakh6737.sobhoy.com';

  static String registerUser = '${baseUrl}v1/auth/register';
  static String registerUserEmailVerify = '${baseUrl}v1/auth/verify-email';
  static String userLogin = '${baseUrl}v1/auth/login';
  static String forgetPassword = '${baseUrl}v1/auth/forgot-password';
  static String resetPassword = '${baseUrl}v1/auth/reset-password';
  static String changePassword = '${baseUrl}v1/auth/change-password';
  // ==========> User Profile ==========>
  static String fetchProfile = '${baseUrl}v1/users/profile-info';
  static String updateUserProfileInfo = '${baseUrl}v1/users/profile-info';
  static String updateUserProfilePicture = '${baseUrl}v1/users/profile-picture';
  // ==========> User Settings ==========>
  static String userPrivacyPolicy = '${baseUrl}v1/settings?type=privacyPolicy';
  static String userTermsAndConditions = '${baseUrl}v1/settings?type=termsAndConditions';
  static String userAboutUs = '${baseUrl}v1/settings?type=aboutUs';
  static String userContactUs = '${baseUrl}v1/settings?type=contactUs';
  // ==========> Service Form ==========>
  static String serviceFormCategories = '${baseUrl}v1/service-categories/';
  static String serviceProviderFormSubmit = '${baseUrl}v1/service-providers';

<<<<<<< HEAD
  // ==========> Service Document Fetch ==========>

  static String getProviderDocumentDetails =
      '${baseUrl}v1/service-providers/details-with-nid?page=1&limit=2000';
=======
  ///===> rakiubl added api:
  static String pendingBookings = '${baseUrl}v1/service-bookings/paginate?status=pending';
  static String acceptedBookings = '${baseUrl}v1/service-bookings/paginate?status=accepted';
  static String inProgressBookings = '${baseUrl}v1/service-bookings/paginate?status=inProgress';
  static String cancelledBookings = '${baseUrl}v1/service-bookings/paginate?status=cancelled';
  static String completedBookings = '${baseUrl}v1/service-bookings/paginate?status=completed';
  static String paymentRequests = '${baseUrl}v1/service-bookings/paginate?status=paymentRequest';
  ///===> rakibul api add close
>>>>>>> c6e475534a98b790bbdfcb6991192fe23bfaa5e8

  static String getNormalUserHomeData = '${baseUrl}v1/users/home-page';
  static String getNormalUserAllCategory =
      '${baseUrl}v1/service-categories/paginate?page=1&limit=2000';

  static String getSpecificServiceByCategory({
    required String categoryId,
    required String pageId,
    String? serviceName,
  }) {
    String url = '${baseUrl}v1/service-providers/paginate?page=$pageId&serviceCategoryId=$categoryId';
    if (serviceName != null && serviceName.isNotEmpty) {
      url += '&serviceName=$serviceName';
    }
    return url;
  }

  static String deleteBabyProfile({required String babyId}) {
    return '$baseUrl/api/v1/babies/delete/$babyId';
  }
}
