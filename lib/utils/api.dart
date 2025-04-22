import 'package:dio/dio.dart';

import "../app/generalImports.dart";

class ApiException implements Exception {
  ApiException(this.errorMessage);

  String errorMessage;

  @override
  String toString() => errorMessage;
}

class Api {
  //headers
  static Map<String, dynamic> headers() {
    final String jwtToken = HiveRepository.getUserToken;
    if (kDebugMode) {
      print("token is $jwtToken");
    }
    return {"Authorization": "Bearer $jwtToken"};
  }

  ///API list
  static String getServices = "${baseUrl}get_services";
  static String getSubCategories = "${baseUrl}get_sub_categories";
  static String getReview = "${baseUrl}get_ratings";
  static String getCategories = "${baseUrl}get_categories";
  static String getNotifications = "${baseUrl}get_notifications";
  static String getSections = "${baseUrl}get_sections";
  static String getProviders = "${baseUrl}get_providers";
  static String getHomeScreenData = "${baseUrl}get_home_screen_data";
  static String getCart = "${baseUrl}get_cart";
  static String getAddress = "${baseUrl}get_address";
  static String addAddress = "${baseUrl}add_address";
  static String deleteAddress = "${baseUrl}delete_address";
  static String bookMark = "${baseUrl}book_mark";
  static String updateUser = "${baseUrl}update_user";
  static String updateFCM = "${baseUrl}update_fcm";
  static String manageCart = "${baseUrl}manage_cart";
  static String manageNotification = "${baseUrl}manage_notification";
  static String manageUser = "${baseUrl}manage_user";
  static String getUserDetails = "${baseUrl}get_user_info";
  static String removeFromCart = "${baseUrl}remove_from_cart";
  static String getAvailableSlots = "${baseUrl}get_available_slots";
  static String placeOrder = "${baseUrl}place_order";
  static String getPromocode = "${baseUrl}get_promo_codes";
  static String validatePromocode = "${baseUrl}validate_promo_code";
  static String getSystemSettings = "${baseUrl}get_settings";
  static String getFAQs = "${baseUrl}get_faqs";
  static String createRazorpayOrder = "${baseUrl}razorpay_create_order";
  static String getOrderBooking = "${baseUrl}get_orders";
  static String addTransaction = "${baseUrl}add_transaction";
  static String addRating = "${baseUrl}add_rating";
  static String verifyUser = "${baseUrl}verify_user";
  static String verifyOTP = "${baseUrl}verify_otp";
  static String changeBookingStatus = "${baseUrl}update_order_status";
  static String validateCustomTime = "${baseUrl}check_available_slot";
  static String getTransactions = "${baseUrl}get_transactions";
  static String deleteUserAccount = "${baseUrl}delete_user_account";
  static String checkProviderAvailability =
      "${baseUrl}provider_check_availability";
  static String downloadInvoice = "${baseUrl}invoice-download";
  static String searchServicesAndProvider =
      "${baseUrl}search_services_providers";
  static String sendQuery = "${baseUrl}contact_us_api";
  static String resendOTP = "${baseUrl}resend_otp";
  static String getAllCategories = "${baseUrl}get_all_categories";

  //my request APIs
  static String makeCustomJobRequest = "${baseUrl}make_custom_job_request";
  static String myCustomJobRequests = "${baseUrl}fetch_my_custom_job_requests";
  static String customJobBidders = "${baseUrl}fetch_custom_job_bidders";
  static String cancelCustomJobRequest = "${baseUrl}cancle_custom_job_request";
  //chat related APIs
  static const String sendChatMessage = "${baseUrl}send_chat_message";
  static const String getChatMessages = "${baseUrl}get_chat_history";
  static const String getChatUsers = "${baseUrl}get_chat_providers_list";

  ///API parameter
  static const String limit = "limit";
  static const String name = "name";
  static const String longitude = "longitude";
  static const String latitude = "latitude";
  static const String mobile = "mobile";
  static const String countryCode = "country_code";
  static const String phone = "phone";
  static const String otp = "otp";
  static const String countryCodeName = "countryCodeName";
  static const String notificationId = "notification_id";
  static const String uid = "uid";
  static const String offset = "offset";
  static const String pincode = "pincode";
  static const String state = "state";
  static const String loginType = "loginType";

  static const String type = "type";
  static const String id = "id";
  static const String isDefault = "is_default";
  static const String isReadedNotification = "is_readed";
  static const String landmark = "landmark";
  static const String lattitude = "lattitude";
  static const String address = "address";
  static const String addressId = "address_id";
  static const String alternateMobile = "alternate_mobile";
  static const String area = "area";
  static const String categoryId = "category_id";
  static const String providerId = "provider_id";
  static const String filter = "filter";
  static const String sort = "sort";
  static const String order = "order";
  static const String subCategoryId = "sub_category_id";
  static const String cityId = "city_id";
  static const String country = "country";
  static const String deleteNotification = "delete_notification";
  static const String image = "image";
  static const String username = "username";
  static const String email = "email";
  static const String fcmId = "fcm_id";
  static const String platform = "platform";
  static const String partnerId = "partner_id";
  static const String slug = "slug";
  static const String providerSlug = "provider_slug";
  static const String qty = "qty";
  static const String serviceId = "service_id";
  static const String date = "date";
  static const String promocodeId = "promo_code_id";
  static const String totalAmount = "final_total";
  static const String orderId = "order_id";
  static const String customJobRequestId = "custom_job_request_id";
  static const String bidderId = "bidder_id";
  static const String search = "search";
  static const String status = "status";
  static const String rating = "rating";
  static const String comment = "comment";
  static const String time = "time";
  static const String listOfImage = "images[]";
  static const String isCheckoutProcess = "is_checkout_process";
  static const String cartId = "cart_id";
  static const String isAdditionalCharge = "is_additional_charge";
  static const String promocode = 'get_promocode';
  static const String filterType = 'filter_type';
  static const String orderstatus = "order_status";

////////* Place API */////

  static const String input = "input";
  static const String types = "types";
  static const String placeid = "placeid";
  static String placeAPI = "${baseUrl}get_places_for_app";
  static String placeApiDetails = "${baseUrl}get_place_details_for_app";

  ///post method for API calling
  static Future<Map<String, dynamic>> post({
    required final String url,
    required final Map<String, dynamic> parameter,
    required final bool useAuthToken,
    final b,
  }) async {
    try {
      //
      final Dio dio = Dio();
      dio.interceptors.add(CurlLoggerInterceptor());
      final FormData formData =
          FormData.fromMap(parameter, ListFormat.multiCompatible);

      if (kDebugMode) {
        print("API is $url \n pra are $parameter \n ");
      }

      final response = await dio.post(
        url,
        data: formData,
        options: useAuthToken ? Options(headers: headers()) : null,
      );

      /*  if (response.data['error']) {
        throw ApiException(response.data['message']);
      }*/

      if (kDebugMode) {
        print("API is $url \n pra are $parameter \n response is $response");
      }
      return Map.from(response.data);
    } on DioException catch (e) {
      if (kDebugMode) {
        print("error API is $url");

        print("error is ${e.response} ${e.message}");
      }
      if (e.response?.statusCode == 401) {
        throw ApiException("authenticationFailed");
      } else if (e.response?.statusCode == 500) {
        throw ApiException("internalServerError");
      }
      throw ApiException(e.error is SocketException
          ? "noInternetFound"
          : "somethingWentWrong");
    } on ApiException catch (e) {
      throw ApiException(e.errorMessage);
    } catch (e, st) {
      if (kDebugMode) {
        print("api $e ${st.toString()}");
      }
      throw ApiException("somethingWentWrong");
    }
  }

  ///post method for API calling
  static Future<List<int>> downloadAPI({
    required final String url,
    required final Map<String, dynamic> parameter,
    required final bool useAuthToken,
    final bool? isInvoiceAPI,
  }) async {
    try {
      //
      final Dio dio = Dio();
      dio.interceptors.add(CurlLoggerInterceptor());
      final FormData formData =
          FormData.fromMap(parameter, ListFormat.multiCompatible);

      final response = await dio.post(
        url,
        data: formData,
        options: Options(headers: {
          'Accept': 'application/pdf',
        }, responseType: ResponseType.bytes),
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ApiException("authenticationFailed");
      } else if (e.response?.statusCode == 500) {
        throw ApiException("internalServerError");
      } else if (e.response?.statusCode == 503) {
        throw ApiException("internalServerError");
      }
      throw ApiException(e.error is SocketException
          ? "noInternetFound"
          : "somethingWentWrong");
    } on ApiException {
      throw ApiException("somethingWentWrong");
    } catch (e) {
      throw ApiException("somethingWentWrong");
    }
  }

  static Future<Map<String, dynamic>> get({
    required final String url,
    required final bool useAuthToken,
    final Map<String, dynamic>? queryParameters,
  }) async {
    try {
      //
      final Dio dio = Dio();
      dio.interceptors.add(CurlLoggerInterceptor());
      final response = await dio.get(
        url,
        queryParameters: queryParameters,
        options: useAuthToken ? Options(headers: headers()) : null,
      );

      if (response.data['error'] == true) {
        throw ApiException(response.data['code'].toString());
      }

      return Map.from(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ApiException("authenticationFailed");
      } else if (e.response?.statusCode == 500) {
        throw ApiException("internalServerError");
      }
      throw ApiException(e.error is SocketException
          ? "noInternetFound"
          : "somethingWentWrong");
    } on ApiException {
      throw ApiException("somethingWentWrong");
    } catch (e) {
      throw ApiException("somethingWentWrong");
    }
  }
}
