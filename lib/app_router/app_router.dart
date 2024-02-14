import 'package:chatify/features/chats/logic/cubit/chats_cubit.dart';
import 'package:chatify/features/contacts/logic/cubit/contacts_cubit.dart';
import 'package:chatify/features/contacts/ui/all_contacts_screen.dart';

import '../features/login/logic/authentication_cubit/authentication_cubit.dart';
import '../features/login/ui/login_screen.dart';
import '../features/login/ui/otp_screen.dart';
import '../features/main_screen.dart';
import 'routes.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppRouter {
  Route? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.loginScreen:
        return MaterialPageRoute(
          builder: (context) => BlocProvider<AuthenticationCubit>(
            create: (context) => AuthenticationCubit(),
            child: LoginScreen(),
          ),
        );
      case Routes.homeScreen:
        return MaterialPageRoute(
          builder: (context) => const NavBarPages(),
        );
      case Routes.otpScreen:
        // final phoneNumber = settings.arguments as PhoneNumber;
        final argumentsData = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: AuthenticationCubit(),
            child: BlocProvider<ChatsCubit>(
              create: (context) => ChatsCubit(),
              child: OtpScreen(
                  phoneNumber: argumentsData['phone_number'],
                  verificationId: argumentsData['verification_ID']),
            ),
          ),
        );
      case Routes.contactsScreen:
        return MaterialPageRoute(
          builder: (context) => BlocProvider<ContactsCubit>(
            create: (context) => ContactsCubit(),
            child: const ContactsScreen(),
          ),
        );
      default:
        null;
    }
    return null;
  }
}
