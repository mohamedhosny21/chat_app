import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/app_router/app_router.dart';

class ChatifyApp extends StatelessWidget {
  final String initialRoute;
  final AppRouter appRouter;
  const ChatifyApp(
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
