import 'package:chatify/core/config/app_config.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'chatify_app.dart';
import 'core/dependency_injection/dependency_injection.dart';
import 'core/notifications_manager/data/notifications_repository.dart';
import 'features/login/logic/cubit/authentication_cubit.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/app_router/app_router.dart';
import 'firebase_options.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('wow : ${message.data}');

  await Firebase.initializeApp();
  if (!getIt.isRegistered<NotificationsRepository>()) {
    debugPrint('get it not registered');
    await setupGetIt();
    debugPrint('now it is registered');
  }

  await getIt<NotificationsRepository>()
      .updateMessagesStatusToDelivered(chatRoomId: message.data['chatRoomId']);
  debugPrint("Handling a background message: ${message.messageId}");
}

void main() async {
  await ScreenUtil.ensureScreenSize();

  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await setupGetIt();
  final initialRoute = await getIt<AuthenticationCubit>().getInitialRoute();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await getIt<NotificationsRepository>().initLocalNotification();
  await getIt<NotificationsRepository>().setupInteractiveMessage();
  getIt<NotificationsRepository>().subscribeForegroundNotificationListener();

  runApp(ChatifyApp(
    initialRoute: initialRoute,
    appRouter: AppRouter(),
    navigatorKey: AppConfig.navigatorKey,
  ));
}
