import 'package:madwell/app/generalImports.dart';

class ServiceRepository {
  //
  ///This method is used to fetch available services form database
  Future<Map<String, dynamic>> getServices({
    required final String offset,
    required final String limit,
    required final bool isAuthTokenRequired,
    required final ProviderDetailsParamType type,
    /* String? search,*/ required final String providerIdOrSlug,
  }) async {
    try {
      final Map<String, dynamic> parameter = <String, dynamic>{
        Api.latitude: HiveRepository.getLatitude,
        Api.longitude: HiveRepository.getLongitude,
        if (type == ProviderDetailsParamType.slug)
          Api.providerSlug: providerIdOrSlug
        else
          Api.partnerId: providerIdOrSlug,
        Api.limit: limit,
        Api.offset: offset
      };

      final response = await Api.post(
        parameter: parameter,
        url: Api.getServices,
        useAuthToken: isAuthTokenRequired,
      );

      if (response.isEmpty) {
        return {"services": [], "totalServices": 0};
      }
      return {
        "services": (response['data'] as List)
            .map((final e) => Services.fromJson(Map.from(e)))
            .toList(),
        "totalServices": response['total']
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  //
  ///This method is used to search services
  Future<Map<String, dynamic>> searchServicesWithProviders({
    required final String offset,
    required final String limit,
    required final bool isAuthTokenRequired,
    required String searchText,
  }) async {
    try {
      final Map<String, dynamic> parameter = <String, dynamic>{
        Api.latitude: HiveRepository.getLatitude,
        Api.longitude: HiveRepository.getLongitude,
        Api.search: searchText,
        Api.type: "service",
        Api.limit: limit,
        Api.offset: offset
      };

      final response = await Api.post(
        parameter: parameter,
        url: Api.searchServicesAndProvider,
        useAuthToken: isAuthTokenRequired,
      );

      if (response.isEmpty) {
        return {"providersWithServices": [], "totalProvidersWithServices": 0};
      }
      return {
        "providersWithServices":
            (response['data']["Services"] as List).map((final e) {
          final Providers provider =
              Providers.fromJson(Map.from(e["provider"]));
          return provider;
        }).toList(),
        "totalProvidersWithServices": response["data"]['total']
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
