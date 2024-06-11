import 'package:chatify/core/dependency_injection/dependency_injection.dart';
import 'package:chatify/features/login/logic/cubit/authentication_cubit.dart';

import 'core/app_router/app_router.dart';
import 'firebase_options.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await FirebaseAppCheck.instance
  //     .activate(androidProvider: AndroidProvider.debug);
  setupGetIt();
  final initialRoute = await getIt<AuthenticationCubit>().getInitialRoute();

  runApp(ChatApp(
    initialRoute: initialRoute,
    appRouter: AppRouter(),
  ));
}

class ChatApp extends StatelessWidget {
  final String initialRoute;
  final AppRouter appRouter;
  const ChatApp(
      {super.key, required this.appRouter, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        child: MaterialApp(
          title: 'Chatify',
          initialRoute: initialRoute,
          onGenerateRoute: appRouter.onGenerateRoute,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              textTheme: GoogleFonts.montserratTextTheme(),
              scaffoldBackgroundColor: Colors.white),
        ));
  }
}
