import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

import '../../../app/generalImports.dart';

class ChatRepository {
  String getChatType(String value) {

    final Map<String, String> mapping = {
      'enquiryChats': 'pre_booking',
      'bookingChats': 'booking',
    };

    return mapping[value] ?? 'Unknown'; 
  }

  Future<Map<String, dynamic>> fetchChatUsers(
      {required int offset,
      String? searchString,
      required String filterType,
      required String orderStatus}) async {
    try {
      final response = await Api.post(
        url: Api.getChatUsers,
        useAuthToken: true,
        parameter: {
          "offset": offset.toString(),
          "limit": "25",
          if (filterType != "enquiryChats" && orderStatus != 'all')
            Api.orderstatus: orderStatus,
          Api.filterType: getChatType(filterType),
          if (searchString != null) "search": searchString
        },
      );

      final List<ChatUser> chatUsers = [];

      for (int i = 0; i < response['data'].length; i++) {
        chatUsers.add(ChatUser.fromJson(response['data'][i]));
      }

      return {
        "chatUsers": chatUsers,
        "totalItems": int.tryParse((response['total'] ?? "1").toString()),
        "totalUnreadUsers": 0, //unused response['total_unread_users'] ??
      };
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      throw ApiException(error.toString());
    }
  }

  Future<Map<String, dynamic>> fetchChatMessages({
    required int offset,
    required String bookingId,
    String? providerId,
    required String type,
  }) async {
    try {
      final Map<String, dynamic> parameter = {
        "offset": offset.toString(),
        "limit": "25",
        "booking_id": bookingId,
        "type": type,
        Api.providerId: providerId
      };
      //
      parameter.removeWhere((key, value) =>
          value == "null" ||
          value == null ||
          value == '' ||
          (key == "booking_id" && (value == "0" || value == "-1")));

      //
      final response = await Api.post(
          url: Api.getChatMessages, useAuthToken: true, parameter: parameter);

      final List<ChatMessage> chatMessage = [];

      for (int i = 0; i < response['data'].length; i++) {
        chatMessage.add(ChatMessage.fromJsonAPI(response['data'][i]));
      }

      return {
        "chatMessages": chatMessage,
        "totalItems": int.tryParse((response['total'] ?? "0").toString()),
      };
    } catch (error, st) {
      if (kDebugMode) {
        print(st.toString());
        print(error);
      }
      throw ApiException(error.toString());
    }
  }

  Future<ChatMessage> sendChatMessage({
    required String message,
    List<String> filePaths = const [],
    required String receiverId,

    ///0 : Admin 1: Provider
    required String sendMessageTo,
    String? bookingId,
  }) async {
    try {
      //
      final Map<String, dynamic> parameter = {
        "receiver_id": receiverId,
        "message": message,
        "receiver_type": sendMessageTo,
        "type": sendMessageTo,
        "booking_id": bookingId,
      };
      if (bookingId == "0" ||
          bookingId == "null" ||
          bookingId == null ||
          bookingId == "-1") {
        parameter.remove("booking_id");
      }
      if (receiverId == "-" || sendMessageTo == "0") {
        parameter.remove("receiver_id");
      }
      if (message.isEmpty) {
        parameter.remove("message");
      }
      if (filePaths.isNotEmpty) {
        for (int i = 0; i < filePaths.length; i++) {
          //
          final mimeType = lookupMimeType(filePaths[i]);
          final extension = mimeType!.split("/");
          //
          final imagePart = await MultipartFile.fromFile(
            filePaths[i],
            filename: p.basename(filePaths[i]),
            contentType: MediaType(extension[0], extension[1]),
          );
          parameter["attachment[$i]"] = imagePart;
        }
      }

      final response = await Api.post(
          url: Api.sendChatMessage, parameter: parameter, useAuthToken: true);

      return ChatMessage.fromJsonAPI(response['data']);
    } catch (e) {
      throw ApiException("somethingWentWrong");
    }
  }
}
