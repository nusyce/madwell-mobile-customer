import 'package:e_demand/app/generalImports.dart';

class ChatNotificationsUtils {
  static int? currentChattingUserHashCode;

  static late StreamController<ChatNotificationData>
      notificationStreamController;

  static Future<void> initialize() async {
    //remove old data when initializing to remove terminated state data
    ChatNotificationsRepository().setBackgroundChatNotificationData(data: []);
    notificationStreamController = StreamController.broadcast();
  }

  static void dispose() {
    notificationStreamController.close();
  }

  //foreground chat notification handler
  static void addChatStreamAndShowNotification(
      {required RemoteMessage message}) {
    final chatNotification =
        ChatNotificationData.fromRemoteMessage(remoteMessage: message);
    notificationStreamController.add(chatNotification);
    if (currentChattingUserHashCode != chatNotification.fromUser.hashCode &&
        Platform.isAndroid &&
        chatNotification.fromUser.senderType != "0") {
      createChatNotification(chatData: chatNotification, message: message);
    } else if (currentChattingUserHashCode !=
            chatNotification.fromUser.senderType.hashCode &&
        Platform.isAndroid &&
        chatNotification.fromUser.senderType == "0") {
      createChatNotification(chatData: chatNotification, message: message);
    }
  }

  static void addChatStreamValue({required ChatNotificationData chatData}) {
    notificationStreamController.add(chatData);
  }

  static Future<void> createChatNotification(
      {required ChatNotificationData chatData,
      required RemoteMessage message}) async {
    String title = "";
    String body = "";
    if (message.notification != null) {
      title = message.notification?.title ?? "";
      body = message.notification?.body ?? "";
    } else {
      title = message.data["title"] ?? "";
      body = message.data["body"] ?? "";
    }

    LocalAwesomeNotification.notification.createNotification(
      content: NotificationContent(
          id: Random().nextInt(5000),
          groupKey: chatData.fromUser.hashCode.toString(),
          autoDismissible: true,
          title: chatData.fromUser.bookingId == "0"
              ? "New Message"
              : "Booking Id: ${chatData.fromUser.bookingId}",
          body: body,
          locked: false,
          wakeUpScreen: true,
          largeIcon: chatData.fromUser.profile,
          payload: Map.from(message.data),
          channelKey: "chat_notification",
          summary: title,
          notificationLayout: NotificationLayout.Messaging,
          category: NotificationCategory.Message),
    );
  }
}
