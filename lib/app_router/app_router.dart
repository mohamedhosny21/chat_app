import 'package:chatify/features/contacts/logic/contacts_cubit/cubit/contacts_cubit.dart';
import 'package:chatify/features/contacts/ui/contacts_screen.dart';
import 'package:chatify/features/user_chat/user_chat_screen.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

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
        final argumentsData = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (context) => BlocProvider<AuthenticationCubit>.value(
            value: AuthenticationCubit(),
            child: OtpScreen(
                phoneNumber: argumentsData['phone_number'],
                verificationId: argumentsData['verification_ID']),
          ),
        );
      case Routes.contactsScreen:
        return MaterialPageRoute(
          builder: (context) => BlocProvider<ContactsCubit>(
            create: (context) => ContactsCubit(),
            child: const ContactsScreen(),
          ),
        );
      case Routes.userChatScreen:
        final contact = settings.arguments as Contact;
        return MaterialPageRoute(
          builder: (context) => UserChatScreen(contact: contact),
        );
      default:
        null;
    }
    return null;
  }
}
