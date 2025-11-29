class AppUrl {
  AppUrl._();

  static const String baseUrl = 'https://newsheakh6737.sobhoy.com/api/';

  static String registerUser = '${baseUrl}v1/auth/register';
  static String registerUserEmailVerify = '${baseUrl}v1/auth/verify-email';
  static String userLogin = '${baseUrl}v1/auth/login';
  static String forgetPassword = '${baseUrl}v1/auth/forgot-password';
  static String resetPassword = '${baseUrl}v1/auth/reset-password';
  static String getNormalUserHomeData = '${baseUrl}v1/users/home-page';
  static String getNormalUserAllCategory =
      '${baseUrl}v1/service-categories/paginate?page=1&limit=2000';

  static String getSpecificServiceByCategory({
    required String categoryId,
    required String pageId,
    String? serviceName,
  }) {
    String url =
        '${baseUrl}v1/service-providers/paginate?page=$pageId&serviceCategoryId=$categoryId';
    if (serviceName != null && serviceName.isNotEmpty) {
      url += '&serviceName=$serviceName';
    }
    return url;
  }

  static String deleteBabyProfile({required String babyId}) {
    return '$baseUrl/api/v1/babies/delete/$babyId';
  }

  static String getSpecificServiceDetails({required String svpId}) {
    return '${baseUrl}v1/service-providers/$svpId';
  }
}
