import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:chatify/core/app_router/navigator_observer.dart';
import 'package:chatify/core/app_router/routes.dart';
import 'package:chatify/core/helpers/constants/app_constants.dart';
import 'package:chatify/core/notifications_manager/data/models/notification_payload_model.dart';
import 'package:chatify/core/notifications_manager/data/notifications_webservices.dart';
import 'package:chatify/features/contacts/data/contact_model.dart';
import 'package:chatify/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class NotificationsRepository {
  String enteredChatRoomId = '';
  final NotificationsWebservices notificationsWebservices;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationsRepository({required this.notificationsWebservices});

  Future<String?> getCurrentDeviceToken() async {
    final currentDeviceToken = await _firebaseMessaging.getToken();
    debugPrint('currentDeviceToken: $currentDeviceToken');
    return currentDeviceToken;
  }

  Future<List<String>> _getReceiverDeviceTokens(String receiverId) async {
    return FirebaseFirestore.instance
        .collection("FCM_Tokens")
        .where('userId', isEqualTo: receiverId)
        .get()
        .then((userSnapshot) {
      List<String> deviceTokens = [];
      if (userSnapshot.docs.isNotEmpty) {
        for (var doc in userSnapshot.docs) {
          deviceTokens.add(doc.data()["token"]);
        }
      }
      return deviceTokens;
    });
  }

  Future<void> saveCurrentDeviceTokenToDatabase() async {
    final deviceToken = await getCurrentDeviceToken();
    final currentUser = _firebaseAuth.currentUser;
    await _firestore.collection("FCM_Tokens").doc(deviceToken).set({
      'token': deviceToken,
      'createdAt': FieldValue.serverTimestamp(),
      'userId': currentUser!.uid
    });
  }

  Future<void> pushNotification(
      {required NotificationPayload notificationPayloadModel,
      required String receiverId}) async {
    final deviceTokens = await _getReceiverDeviceTokens(receiverId);
    debugPrint('deviceTokens: $deviceTokens');
    for (String deviceToken in deviceTokens) {
      try {
        await notificationsWebservices.pushNotification(
            deviceToken: deviceToken,
            notificationPayloadModel: notificationPayloadModel);
      } catch (error) {
        debugPrint('repo error : $error');
        await deleteDeviceTokenFromDatabase(deviceToken);
      }
    }
  }

  Future<String> _getContactNameByPhoneNumber(String senderPhoneNumber) async {
    final deviceContacts =
        await FlutterContacts.getContacts(withProperties: true);
    final contact = deviceContacts.firstWhere(
      (contact) => contact.phones.any(
          (phoneNumber) => phoneNumber.normalizedNumber == senderPhoneNumber),
      orElse: () => Contact(
        displayName: senderPhoneNumber,
      ),
    );
    return contact.displayName;
  }

  void setChatRoomId(String chatId) {
    enteredChatRoomId = chatId;
  }

  bool _isSameChatRoomId(String remoteChatRoomId) {
    return remoteChatRoomId == enteredChatRoomId;
  }

  void subscribeForegroundNotificationListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final senderName =
          await _getContactNameByPhoneNumber(message.data['senderPhoneNumber']);
      final currentRoute = AppNavigatorObserver.currentRoute;
      debugPrint('display : $senderName');
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data.entries}');
      if (message.notification != null) {
        debugPrint(
            'Message also contained a notification: ${message.notification}');

        if (currentRoute == Routes.chatRoomScreen) {
          final bool sameChatRoomId =
              _isSameChatRoomId(message.data['chatRoomId']);
          if (!sameChatRoomId) {
            await showNotification(
                title: senderName,
                body: message.notification!.body!,
                message: message);
            await updateMessagesStatusToDelivered(
                chatRoomId: message.data['chatRoomId']);
          }
        } else {
          await showNotification(
              title: senderName,
              body: message.notification!.body!,
              message: message);
          await updateMessagesStatusToDelivered(
              chatRoomId: message.data['chatRoomId']);
        }
      }
    });
  }

  Future<void> updateMessagesStatusToDelivered(
      {required String chatRoomId}) async {
    final sentMessagesQuerySnapshot = await _firestore
        .collection("Chat_Rooms")
        .doc(chatRoomId)
        .collection("Messages")
        .where('status', isEqualTo: 'sent')
        .get();
    for (var doc in sentMessagesQuerySnapshot.docs) {
      await _firestore
          .collection("Chat_Rooms")
          .doc(chatRoomId)
          .collection("Messages")
          .doc(doc.id)
          .update({'status': 'delivered'}).then((_) => debugPrint(
              '${sentMessagesQuerySnapshot.size} docs status updated to delivered'));
      await _updateOngoingChatLastMessageStatusToDelivered(
          chatRoomId: chatRoomId);
    }
  }

  Future<void> _updateOngoingChatLastMessageStatusToDelivered(
      {required String chatRoomId}) async {
    final User? currentUser = _firebaseAuth.currentUser;
    final String peerUserId =
        chatRoomId.replaceAll(currentUser!.uid, '').replaceAll('_', '');

    await _firestore
        .collection("OngoingChats")
        .doc(peerUserId)
        .collection("Conversations")
        .doc(chatRoomId)
        .update({'lastMessageStatus': 'delivered'});
  }

  Future<void> deleteDeviceTokenFromDatabase(String token) async {
    try {
      await _firestore.collection("FCM_Tokens").doc(token).delete();
      debugPrint('Deleted Token: $token');
    } catch (error) {
      throw Exception('Error deleting token: $error');
    }
  }

  Future<void> setupInteractiveMessage() async {
    final RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('initialMessage: ${initialMessage.data}');
      _handleMessage(initialMessage);
    }
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(
    RemoteMessage message,
  ) async {
    final senderName =
        await _getContactNameByPhoneNumber(message.data['senderPhoneNumber']);
    final currentRoute = AppNavigatorObserver.currentRoute;
    if (currentRoute != Routes.chatRoomScreen) {
      navigatorKey.currentState!.pushNamed(Routes.chatRoomScreen,
          arguments: ContactModel(
            id: message.data['senderId'],
            name: senderName,
            phoneNumber: message.data['senderPhoneNumber'],
            profilePicture: message.data['senderProfilePicture'],
          ));
    } else {
      navigatorKey.currentState!.pushReplacementNamed(Routes.chatRoomScreen,
          arguments: ContactModel(
            id: message.data['senderId'],
            name: senderName,
            phoneNumber: message.data['senderPhoneNumber'],
            profilePicture: message.data['senderProfilePicture'],
          ));
    }
  }

  //Local Notifications
  Future<void> initLocalNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("@mipmap/ic_launcher");
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);
    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) =>
          _onSelectForegroundNotification(details.payload),
    );

    /// need this for ios foregournd notification
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );
  }

  void _onSelectForegroundNotification(String? payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
      final messageData = jsonDecode(payload) as Map<String, dynamic>;

      final String senderName = await _getContactNameByPhoneNumber(
          messageData['data']['senderPhoneNumber']);
      final currentRoute = AppNavigatorObserver.currentRoute;
      if (currentRoute != Routes.chatRoomScreen) {
        navigatorKey.currentState!.pushNamed(Routes.chatRoomScreen,
            arguments: ContactModel(
              id: messageData['data']['senderId'],
              name: senderName,
              phoneNumber: messageData['data']['senderPhoneNumber'],
              profilePicture: messageData['data']['senderProfilePicture'],
            ));
      } else {
        final bool isSameChatRoomId =
            _isSameChatRoomId(messageData['data']['chatRoomId']);
        if (!isSameChatRoomId) {
          navigatorKey.currentState!.pushReplacementNamed(Routes.chatRoomScreen,
              arguments: ContactModel(
                id: messageData['data']['senderId'],
                name: senderName,
                phoneNumber: messageData['data']['senderPhoneNumber'],
                profilePicture: messageData['data']['senderProfilePicture'],
              ));
        }
      }
    }
  }

  Future<String> getSenderProfilePicture() async {
    final currentUserId = _firebaseAuth.currentUser!.uid;
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await _firestore.collection('Users').doc(currentUserId).get();
    final String? profilePicture = documentSnapshot.data()?['photo'];
    if (profilePicture != null) {
      return profilePicture;
    } else {
      final String profilePicture = await _uploadAndfetchSenderProfilePic();
      await _updateSenderProfilePic(profilePicture: profilePicture);
      return profilePicture;
    }
  }

  Future<void> _updateSenderProfilePic({required String profilePicture}) async {
    final currentUserId = _firebaseAuth.currentUser!.uid;
    await _firestore
        .collection('Users')
        .doc(currentUserId)
        .update({'photo': profilePicture});
  }

  Future<Uint8List> _downloadAndSaveSenderProfilePic({
    required String senderProfilePicUrl,
  }) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/UserPhoto.png';
    final File file = File(filePath);
    final http.Response response =
        await http.get(Uri.parse(senderProfilePicUrl));
    if (response.statusCode == 200) {
      await file.writeAsBytes(
        response.bodyBytes,
      );
    } else {
      throw Exception('Failed to download sender profile pic');
    }

    return file.readAsBytes();
  }

  Future<String> _uploadAndfetchSenderProfilePic() async {
    debugPrint('Upload and fetch sender profile pic');
    final currentUserId = _firebaseAuth.currentUser!.uid;
    final Reference reference = _storage
        .ref()
        .child('UsersProfilePics')
        .child(currentUserId)
        .child('defaultUserPhoto.png');
    final uploadTask = await _uploadSenderProfilePic(reference);
    return await _fetchSenderProfilePic(uploadTask);
  }

  Future<TaskSnapshot> _uploadSenderProfilePic(Reference reference) async {
    // Read the file from assets
    final ByteData bytes = await rootBundle.load(AppConstants.defaultUserPhoto);
    return await reference.putData(
      bytes.buffer.asUint8List(),
    );
  }

  Future<String> _fetchSenderProfilePic(TaskSnapshot uploadTask) async {
    return await uploadTask.ref.getDownloadURL();
  }

  Future<Uint8List> _getDefaultUserPhoto() async {
    double imageWidth = 300.0;
    double imageHeight = 200.0;
    // Create a large icon with specified width and height
    final ByteData bytes = await rootBundle.load(AppConstants.defaultUserPhoto);
    final codec = await instantiateImageCodec(bytes.buffer.asUint8List(),
        targetWidth: imageWidth.toInt(), targetHeight: imageHeight.toInt());
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final largeIcon = await image.toByteData(format: ImageByteFormat.png);
    return largeIcon!.buffer.asUint8List();
  }

  Future<NotificationDetails> _configureNotificationDetails(
      {required String? senderProfilePicUrl}) async {
    const String channelId = 'message_notification';
    const String channelName = 'Chat Message Notifications';
    const String channelDescription =
        'Receive alerts when new messages arrive.';
    Uint8List senderProfilePicBytes;
    if (senderProfilePicUrl != null) {
      senderProfilePicBytes = await _downloadAndSaveSenderProfilePic(
          senderProfilePicUrl: senderProfilePicUrl);
    } else {
      senderProfilePicBytes = await _getDefaultUserPhoto();
    }

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      visibility: NotificationVisibility.public,
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      largeIcon: ByteArrayAndroidBitmap(senderProfilePicBytes),
    );

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    return notificationDetails;
  }

  Future<void> showNotification({
    required String title,
    required String body,
    required RemoteMessage message,
  }) async {
    final senderProfilePicUrl = message.data['senderProfilePicture'];
    final notificationDetails = await _configureNotificationDetails(
        senderProfilePicUrl: senderProfilePicUrl);
    final int notificationId = Random().nextInt(1000000);
    await _flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      notificationDetails,
      payload: jsonEncode(message.toMap()),
    );
  }
}
