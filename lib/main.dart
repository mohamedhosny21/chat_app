import 'app_router/app_router.dart';
import 'app_router/routes.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

late String initialRoute;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (FirebaseAuth.instance.currentUser == null) {
    initialRoute = Routes.loginScreen;
  } else {
    initialRoute = Routes.homeScreen;
  }
  runApp(ChatApp(
    appRouter: AppRouter(),
  ));
}

class ChatApp extends StatelessWidget {
  final AppRouter appRouter;
  const ChatApp({super.key, required this.appRouter});

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
      ),
    );
  }
}
