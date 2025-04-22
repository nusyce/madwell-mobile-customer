import 'package:e_demand/app/generalImports.dart';

class SystemRepository {
  //
  Future<Map<String, dynamic>> getFAndQ(
      {required Map<String, dynamic> parameter}) async {
    try {
      final response = await Api.post(
        url: Api.getFAQs,
        parameter: parameter,
        useAuthToken: false,
      );

      return {
        "fAndQData": (response['data'] as List)
            .map((final e) => Faqs.fromJson(Map.from(e)))
            .toList(),
        "totalFaqs": int.parse((response['total'] ?? "0").toString())
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> getUserPaymentDetails(
      {required final Map<String, dynamic> parameter}) async {
    try {
      //
      final response = await Api.post(
          url: Api.getTransactions, parameter: parameter, useAuthToken: true);

      return {
        "paymentDetails": (response['data'] as List)
            .map((final e) => Payment.fromJson(Map.from(e)))
            .toList(),
        "total": response['total'] == null
            ? 0
            : int.parse(response['total'].toString())
      };
    } catch (e) {
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> sendQueryToAdmin(
      {required final Map<String, dynamic> parameter}) async {
    try {
      //
      final response = await Api.post(
          url: Api.sendQuery, parameter: parameter, useAuthToken: true);

      return {"message": response["message"], "error": response['error']};
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
