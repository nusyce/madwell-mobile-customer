// ignore_for_file: file_names

import 'package:madwell/app/generalImports.dart';

class GooglePlaceRepository {
  Future<PlacesModel> searchLocationsFromPlaceAPI(
    final String text,
  ) async {
    try {
      final Map<String, dynamic> queryParameters = <String, dynamic>{
        Api.input: text
      };

      final Map<String, dynamic> placesData = await Api.get(
          url: Api.placeAPI,
          useAuthToken: false,
          queryParameters: queryParameters);

      return PlacesModel.fromJson(placesData['data']);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future getPlaceDetailsFromPlaceId(final String placeId) async {
    try {
      final Map<String, dynamic> queryParameters = <String, dynamic>{
        Api.placeid: placeId
      };
      final Map<String, dynamic> response = await Api.get(
        url: Api.placeApiDetails,
        queryParameters: queryParameters,
        useAuthToken: false,
      );
      return response['data']['result']['geometry']['location'];
    } catch (e) {
      rethrow;
    }
  }
}
