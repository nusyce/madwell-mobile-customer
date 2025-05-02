import 'package:madwell/app/generalImports.dart';
import 'package:flutter/material.dart';

class LocalAwesomeNotification {
  static AwesomeNotifications notification = AwesomeNotifications();

//****** */
  static String notificationChannel = "basic_channel";
  static String chatNotificationChannel = "chat_notification";

  static Future<void> init(final BuildContext context) async {
    await requestPermission();
    await NotificationService.init(context);

    notification.initialize(
      null,
      [
        NotificationChannel(
          playSound: true,
          channelKey: notificationChannel,
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel',
          importance: NotificationImportance.High,
          ledColor: Colors.white,
        ),
        NotificationChannel(
            channelKey: chatNotificationChannel,
            channelName: "Chat notifications",
            channelDescription: "Notification related to chat",
            vibrationPattern: highVibrationPattern,
            importance: NotificationImportance.High)
      ],
      channelGroups: [],
    );
    await setupAwesomeNotificationListeners();
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
    ReceivedAction event,
  ) async {
    if (Platform.isAndroid) {
      final data = event.payload;
      if (data?["type"] == "chat") {
        //get off the route if already on it
        if (Routes.currentRoute == chatMessages) {
          UiUtils.rootNavigatorKey.currentState?.pop();
        }
        try {
          await UiUtils.rootNavigatorKey.currentState?.pushNamed(chatMessages,
              arguments: {
                "chatUser": ChatUser.fromNotificationData(data ?? {})
              });
        } catch (_) {}
        //
      } else if (data?["type"] == "category") {
        if (data?["parent_id"] == "0") {
          await UiUtils.rootNavigatorKey.currentState?.pushNamed(
            subCategoryRoute,
            arguments: {
              'subCategoryId': '',
              'categoryId': data?["category_id"],
              'appBarTitle': data?["category_name"],
              'type': CategoryType.category
            },
          );
        } else {
          await UiUtils.rootNavigatorKey.currentState?.pushNamed(
            subCategoryRoute,
            arguments: {
              'subCategoryId': data?["category_id"],
              'categoryId': '',
              'appBarTitle': data?["category_name"],
              'type': CategoryType.subcategory
            },
          );
        }
      } else if (data?["type"] == "provider") {
        await UiUtils.rootNavigatorKey.currentState?.pushNamed(
          providerRoute,
          arguments: {'providerId': data?["provider_id"]},
        );
      } else if (data?["type"] == "order") {
        //navigate to booking tab
        //bottomNavigationBarGlobalKey.currentState?.selectedIndexOfBottomNavigationBar.value = 1;
      } else if (data?["type"] == "url") {
        final url = data!["url"].toString();
        try {
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url),
                mode: LaunchMode.externalApplication);
          } else {
            throw 'Could not launch $url';
          }
        } catch (e) {
          throw 'Something went wrong';
        }
      }
    }
  }

  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Your code goes here
  }

  @pragma('vm:entry-point')
  static Future<void> setupAwesomeNotificationListeners() async {
    // Only after at least the action method is set, the notification events are delivered
    notification.setListeners(
        onActionReceivedMethod: LocalAwesomeNotification.onActionReceivedMethod,
        onNotificationCreatedMethod:
            LocalAwesomeNotification.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:
            LocalAwesomeNotification.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:
            LocalAwesomeNotification.onDismissActionReceivedMethod);
  }

  Future<void> createNotification({
    required final RemoteMessage notificationData,
    required final bool isLocked,
  }) async {
    try {
      await notification
          .createNotification(
            content: NotificationContent(
              id: Random().nextInt(5000),
              title: notificationData.data["title"] ?? "",
              locked: isLocked,
              payload: Map.from(notificationData.data),
              autoDismissible: true,
              body: notificationData.data["body"] ?? "",
              color: const Color.fromARGB(255, 79, 54, 244),
              wakeUpScreen: true,
              channelKey: notificationChannel,
              notificationLayout: NotificationLayout.BigText,
            ),
          )
          .then((final bool value) {})
          .onError((final error, stackTrace) {});
    } catch (_) {
      //
    }
  }

  Future<void> createImageNotification({
    required final RemoteMessage notificationData,
    required final bool isLocked,
  }) async {
    try {
      await notification
          .createNotification(
            content: NotificationContent(
              id: Random().nextInt(5000),
              title: notificationData.data["title"] ?? "",
              locked: isLocked,
              payload: Map.from(notificationData.data),
              autoDismissible: true,
              body: notificationData.data["body"] ?? "",
              color: const Color.fromARGB(255, 79, 54, 244),
              wakeUpScreen: true,
              channelKey: notificationChannel,
              largeIcon: notificationData.data["image"] ?? "",
              bigPicture: notificationData.data["image"] ?? "",
              notificationLayout: NotificationLayout.BigPicture,
            ),
          )
          .then((final value) {})
          .onError((final error, final stackTrace) {});
    } catch (_) {
      //
    }
  }

  static Future<void> requestPermission() async {
    final NotificationSettings notificationSettings =
        await FirebaseMessaging.instance.getNotificationSettings();

    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.notDetermined) {
      await notification.requestPermissionToSendNotifications(
        channelKey: notificationChannel,
        permissions: [
          NotificationPermission.Alert,
          NotificationPermission.Sound,
          NotificationPermission.Badge,
          NotificationPermission.Vibration,
          NotificationPermission.Light
        ],
      );

      if (notificationSettings.authorizationStatus ==
              AuthorizationStatus.authorized ||
          notificationSettings.authorizationStatus ==
              AuthorizationStatus.provisional) {}
    } else if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.denied) {
      return;
    }
  }
}
