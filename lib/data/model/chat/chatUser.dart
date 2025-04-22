import 'package:e_demand/app/generalImports.dart';

class ChatUser {
  final String id;
  final String name;
  final String? profile;
  final ChatMessage? lastMessage;
  int unReadChats;

  ///0 : Admin 1: Provider 2: customer
  final String receiverType;
  final String? senderType;
  final String? bookingId;
  final String? bookingStatus;
  final String? providerId;
  final String senderId;

  ChatUser({
    required this.id,
    required this.name,
    required this.receiverType,
    this.senderType,
    required this.senderId,
    this.bookingId,
    this.bookingStatus,
    this.providerId,
    this.profile,
    this.lastMessage,
    required this.unReadChats,
  });

  //getters for the UI
  int get unreadNotificationsCount => unReadChats;

  bool get hasUnreadMessages => unreadNotificationsCount != 0;

  String get userName => name;

  String get avatar => profile ?? "";

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: (json['id'] ?? "0").toString(),
      name: json['name'] ?? json["partner_name"] ?? "",
      profile: json['profile'] ?? json["image"],
      lastMessage: json['last_message'] != null
          ? ChatMessage.fromJsonAPI(json['last_message'])
          : null,
      unReadChats: json['un_read_chats'] ?? 0,
      receiverType: json['receiver_type'] ?? "",
      senderType: json['sender_type'] ?? "",
      bookingId: json["booking_id"] ?? "0",
      bookingStatus: json["order_status"] ?? "",
      providerId: json["partner_id"] ?? "0",
      senderId: json["sender_id"] ?? "0",
    );
  }

  factory ChatUser.fromNotificationData(Map<String, dynamic> json) {
    return ChatUser(
      id: (json['sender_id'] ?? "0").toString(),
      //if admin send the message then name will be customer support
      name: json["sender_type"] == "0"
          ? "customerSupport"
          : json['username'] ?? "",
      profile: json['profile_image'] ?? "",
      lastMessage: null,
      unReadChats: json['un_read_chats'] ?? 0,
      receiverType: json['receiver_type'] ?? "",
      senderType: json['sender_type'] ?? "",
      bookingId: json["booking_id"] ?? json["order_id"] ?? "0",
      bookingStatus: json["booking_status"] ?? json["order_status"] ?? "",
      providerId: json["provider_id"] ?? json["partner_id"] ?? "0",
      senderId: json["receiver_id"] ?? "0",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'partner_name': name,
      'profile': profile,
      'image': profile,
      'last_message': lastMessage?.toMap(),
      'un_read_chats': unReadChats,
      'receiver_type': receiverType,
      'sender_type': senderType,
      "booking_id": bookingId,
      "partner_id": providerId,
      "order_status": bookingStatus,
      "sender_id": senderId,
    };
  }

  ChatUser copyWith({
    String? id,
    String? name,
    ChatMessage? lastMessage,
    int? unReadChats,
    String? receiverType,
    String? senderType,
    String? enquiryId,
    String? bookingId,
    String? bookingStatus,
    String? providerId,
    String? senderId,
    String? profile,
  }) {
    return ChatUser(
      id: id ?? this.id,
      name: name ?? this.name,
      profile: profile ?? this.profile,
      lastMessage: lastMessage ?? this.lastMessage,
      unReadChats: unReadChats ?? this.unReadChats,
      receiverType: receiverType ?? this.receiverType,
      senderType: senderType ?? this.senderType,
      bookingId: bookingId ?? this.bookingId,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      providerId: providerId ?? this.providerId,
      senderId: senderId ?? this.senderId,
    );
  }

  @override
  bool operator ==(covariant ChatUser other) {
    if (bookingId == "0" && other.bookingId == "0") {
      return other.providerId == providerId;
    }
    return other.bookingId == bookingId;
  }

  @override
  int get hashCode {
    if (bookingId == "0" && senderType != "0") {
      return providerId.hashCode;
    }
    if (senderType == "0") {
      return senderType.hashCode;
    }
    return bookingId.hashCode;
  }
}
