import 'package:chatify/chatify_app.dart';
import 'package:chatify/core/dependency_injection/dependency_injection.dart';
import 'package:chatify/features/login/logic/cubit/authentication_cubit.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/app_router/app_router.dart';
import 'firebase_options.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await setupGetIt();
  final initialRoute = await getIt<AuthenticationCubit>().getInitialRoute();

  runApp(ChatifyApp(
    initialRoute: initialRoute,
    appRouter: AppRouter(),
  ));
}
