class AppUrl {
  AppUrl._();

  static const String baseUrl = 'https://newsheakh6737.sobhoy.com/api/';
  static const String imageBaseUrl = 'https://newsheakh6737.sobhoy.com';
  static const String socketBaseUrl = "https://newsheakh6737.sobhoy.com";

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

  // ==========> User Payment History ==========>
  static String userPaymentHistory =
      '${baseUrl}v1/service-bookings/paginate?status=completed';

  static String userPaymentHistoryDetails({required String id}) {
    return '${baseUrl}v1/service-bookings/with-costs-summary/$id';
  }

  // ==========> User Settings ==========>
  static String userPrivacyPolicy = '${baseUrl}v1/settings?type=privacyPolicy';
  static String userTermsAndConditions =
      '${baseUrl}v1/settings?type=termsAndConditions';
  static String userAboutUs = '${baseUrl}v1/settings?type=aboutUs';
  static String userContactUs = '${baseUrl}v1/settings?type=contactUs';

  // ==========> Service Form ==========>
  static String serviceFormCategories = '${baseUrl}v1/service-categories/';
  static String serviceProviderFormSubmit = '${baseUrl}v1/service-providers';

  // ==========> Service Wallet ==========>
  static String serviceProviderWithdrawalRequest =
      '${baseUrl}v1/withdrawal-requst/';

  // ==========> Service Document Fetch ==========>

  static String getProviderDocumentDetails =
      '${baseUrl}v1/service-providers/details-with-nid?page=1&limit=2000';
  static String getProviderTransactionDetails =
      '${baseUrl}v1/wallet-transactions/paginate-with-wallet?page=1&limit=2000';

  static String updateProviderDocuments(
      {required String serviceProviderDetailsId}) {
    return '${baseUrl}v1/service-providers/upload-attachments-v2?serviceProviderDetailsId=$serviceProviderDetailsId';
  }

  static String userDocumentDelete({required String id}) {
    return '${baseUrl}v1/attachments/$id';
  }

  // ======= Conversation ==============>

  static String createConversation = '${baseUrl}v1/conversations/';

  ///
  ///
  ///
  ///===> rakiubl added api:::::::::::::::::>
  static String pendingBookings =
      '${baseUrl}v1/service-bookings/paginate?status=pending';
  static String acceptedBookings =
      '${baseUrl}v1/service-bookings/paginate?status=accepted';
  static String inProgressBookings =
      '${baseUrl}v1/service-bookings/paginate?status=inProgress';
  static String cancelledBookings =
      '${baseUrl}v1/service-bookings/paginate?status=cancelled';
  static String completedBookings =
      '${baseUrl}v1/service-bookings/paginate?status=completed';
  static String paymentRequests =
      '${baseUrl}v1/service-bookings/paginate?status=paymentRequest';

  static String jobRequests =
      '${baseUrl}v1/service-bookings/paginate/for-provider?status=pending';
  static String workReview =
      '${baseUrl}v1/reviews/';

  static String workCompletedDetailsApi(String bookingId) {
    return '${baseUrl}v1/service-bookings/with-costs-summary/${bookingId}';
  }

  static String providerAcceptedBookings =
      '${baseUrl}v1/service-bookings/paginate/for-provider?status=accepted';
  static String providerInProgressBookings =
      '${baseUrl}v1/service-bookings/paginate/for-provider?status=inProgress';
  static String providerPaymentRequests =
      '${baseUrl}v1/service-bookings/paginate/for-provider?status=paymentRequest';
  static String providerCancelledBookings =
      '${baseUrl}v1/service-bookings/paginate/for-provider?status=cancelled';
  static String providerCompletedBookings =
      '${baseUrl}v1/service-bookings/paginate/for-provider?status=completed';


  static String providerJobRequestAcceptButton(String bookingId) {
    return '${baseUrl}v1/service-bookings/update-status/$bookingId/status/accept';
  }

  static String providerJobRequestCancelButton(String bookingId) {
    return '${baseUrl}v1/service-bookings/update-status/$bookingId/status/cancel-by-provider';
  }

  static String providerStartWorkButton(String bookingId) {
    return '${baseUrl}v1/service-bookings/update-status/$bookingId/status/inProgress';
  }

  static String providerJobDetailsApi(String bookingId) {
    return '${baseUrl}v1/service-bookings/user-details/$bookingId';
  }

  static String providerWorkSubmitForm(String bookingId) {
    return '${baseUrl}v1/service-bookings/with-costs-summary/$bookingId';
  }

  static String addNewProofFile(String bookingId) {
    return '${baseUrl}v1/service-bookings/update-work-proof/$bookingId';
  }

  static String providerRequestPayment(String bookingId) {
    return '${baseUrl}v1/service-bookings/update-status/$bookingId/status/paymentRequest';
  }

  static const String additionalCost = '${baseUrl}v1/additional-cost';

  ///===> rakibul api add close::::::::::::::::>
  ///
  ///
  ///

  ///
  ///
  ///-------------///Imtiaz Chowdhury Start///------------------
  static String getNormalUserHomeData = '${baseUrl}v1/users/home-page';
  static String getNormalUserAllCategory =
      '${baseUrl}v1/service-categories/paginate?page=1&limit=2000&isDeleted=false&isVisible=true';

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

  static String getNrmUserServiceProviderProfileDetailsInfo({
    required String svpId,
  }) {
    return '${baseUrl}v1/service-providers/profile/$svpId';
  }

  static String getAllPopularProviders = '${baseUrl}v1/users/home-page/popular';
  static String checkProbiderScheduleAvailability =
      '${baseUrl}v1/service-bookings/schedule-check';

  static String bookAService = '${baseUrl}v1/service-bookings';

  static String getServiceDataPreview({required String userId}) {
    return '${baseUrl}v1/service-providers/limited-info/$userId';
  }

  static String getServiceProviderHomeData({required String dataType}) {
    return '${baseUrl}v1/users/home-page/for-provider?type=$dataType';
  }

  ///-------------///Imtiaz Chowdhury End///------------------
}
