import 'package:e_demand/app/generalImports.dart';

class ProviderRepository {
  //
  /// This method is used to fetch Provider List
  Future<Map<String, dynamic>> fetchProviderList(
      {required final bool isAuthTokenRequired,
      final String? categoryId,
      final String? providerIdOrSlug,
      final String? subCategoryId,
      final String? filter,
      final String? promocode,
      final ProviderDetailsParamType? type}) async {
    try {
      final Map<String, dynamic> parameter = <String, dynamic>{
        Api.latitude: HiveRepository.getLatitude,
        Api.longitude: HiveRepository.getLongitude
      };

      if (categoryId != "" && categoryId != null) {
        parameter[Api.categoryId] = categoryId;
      }
      if (providerIdOrSlug != "" && providerIdOrSlug != null) {
        
        if (type == ProviderDetailsParamType.slug) {
          parameter[Api.slug] = providerIdOrSlug;
        }else{
          parameter[Api.partnerId] = providerIdOrSlug;
        }
      }
      if (subCategoryId != "" && subCategoryId != null) {
        parameter[Api.subCategoryId] = subCategoryId;
      }
      if (filter != "" && filter != null) {
        parameter[Api.filter] = filter;
        // parameter[Api.order] = "desc";
      }
      if (promocode != '' && promocode != null) {
        parameter[Api.promocode] = promocode;
      }
      //
      final providers = await Api.post(
          url: Api.getProviders, parameter: parameter, useAuthToken: false);

      return {
        'totalProviders': providers['total'].toString(),
        'providerList': (providers['data'] as List).map((providerData) {
          return Providers.fromJson(providerData);
        }).toList()
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  //
  /// This method is used to search Provider
  Future<Map<String, dynamic>> searchProvider({
    required final String searchKeyword,
    required final String offset,
    required final String limit,
  }) async {
    try {
      final parameter = <String, dynamic>{
        Api.latitude: HiveRepository.getLatitude,
        Api.longitude: HiveRepository.getLongitude,
        Api.search: searchKeyword,
        Api.limit: limit,
        Api.offset: offset,
        Api.type: "provider",
      };

      final providers = await Api.post(
          url: Api.searchServicesAndProvider,
          parameter: parameter,
          useAuthToken: false);
      //
      return {
        'totalProviders': providers["data"]['total'].toString(),
        'providerList':
            (providers['data']["providers"] as List).map((providerData) {
          return Providers.fromJson(providerData);
        }).toList()
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  //
  /// This method is used to check providers are available at selected latitude longitude
  Future<Map<String, dynamic>> checkProviderAvailability({
    required final String latitude,
    required final String longitude,
    required final String checkingAtCheckOut,
    final String? orderId,
    final String? customJobRequestId,
    final String? bidderId,
    required final bool isAuthTokenRequired,
  }) async {
    try {
      final Map<String, dynamic> parameter = <String, dynamic>{
        Api.latitude: latitude,
        Api.longitude: longitude,
        Api.isCheckoutProcess: checkingAtCheckOut,
        Api.orderId: orderId,
        Api.customJobRequestId: customJobRequestId,
        Api.bidderId: bidderId,
      };
      parameter.removeWhere(
        (key, value) => value == null || value == "null" || value == "",
      );

      final response = await Api.post(
        url: Api.checkProviderAvailability,
        parameter: parameter,
        useAuthToken: isAuthTokenRequired,
      );
      return {
        'error': response['error'],
        'message': response['message'].toString(),
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
