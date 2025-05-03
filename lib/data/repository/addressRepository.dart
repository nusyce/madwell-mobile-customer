// ignore_for_file: file_names

import 'package:madwell/app/generalImports.dart';

class AddressRepository {
  Future<Map<String, dynamic>> addAddress(
      final AddressModel addressDataModel) async {
    try {
      //

      final demo = addressDataModel.toMap();
      //
      demo["lattitude"] = addressDataModel.latitude;
      //

      //
      final response = await Api.post(
          url: Api.addAddress, parameter: demo, useAuthToken: true);
//

      return response;
      //
    } catch (e) {
      //
      throw ApiException(e.toString());
      //
    }
  }

  Future<Map<String, dynamic>> updateDefaultAddress(final String Id) async {
    try {
      final response = await Api.post(
        url: Api.addAddress,
        parameter: {Api.addressId: Id, Api.isDefault: "1"},
        useAuthToken: true,
      );
      return response;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<List<GetAddressModel>> fetchAddress() async {
    try {
      //
      final Map<String, dynamic> response = await Api.post(
        url: Api.getAddress,
        parameter: {Api.limit: 100, Api.offset: 0},
        useAuthToken: true,
      );

      //
      //
      final List<GetAddressModel> mappedResponse =
          (response['data'] as List<dynamic>).map((final entry) {
        final getAddressModel = GetAddressModel.fromJson(entry);

        return getAddressModel;
      }).toList();

      return mappedResponse;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> deleteAddress(final String id) async {
    final Map<String, dynamic> parameter = <String, dynamic>{Api.addressId: id};
    try {
      final Map<String, dynamic> response = await Api.post(
          url: Api.deleteAddress, parameter: parameter, useAuthToken: true);

      return response;
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
