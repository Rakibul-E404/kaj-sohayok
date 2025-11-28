class AppUrl {
  AppUrl._();

  static const String baseUrl = 'https://newsheakh6737.sobhoy.com/api/';
  static const String imageBaseUrl = 'https://newsheakh6737.sobhoy.com';

  static String registerUser = '${baseUrl}v1/auth/register';
  static String registerUserEmailVerify = '${baseUrl}v1/auth/verify-email';
  static String userLogin = '${baseUrl}v1/auth/login';
  static String forgetPassword = '${baseUrl}v1/auth/forgot-password';
  static String resetPassword = '${baseUrl}v1/auth/reset-password';

  ///===> rakiubl added api:
  static String pendingBookings = '${baseUrl}v1/service-bookings/paginate?status=pending';
  static String acceptedBookings = '${baseUrl}v1/service-bookings/paginate?status=accepted';
  static String inProgressBookings = '${baseUrl}v1/service-bookings/paginate?status=inProgress';
  static String cancelledBookings = '${baseUrl}v1/service-bookings/paginate?status=cancelled';
  static String completedBookings = '${baseUrl}v1/service-bookings/paginate?status=completed';
  static String paymentRequests = '${baseUrl}v1/service-bookings/paginate?status=paymentRequest';
  ///===> rakibul api add close

  static String deleteBabyProfile({required String babyId}) {
    return '$baseUrl/api/v1/babies/delete/$babyId';
  }
}
