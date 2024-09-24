import 'dart:io';

import 'package:camera/camera.dart';

import '../../features/home/stories/ui/screens/camera_view_screen.dart';
import '../dependency_injection/dependency_injection.dart';
import '../permissions_handler/permissions_handler_cubit.dart';
import '../../features/home/chats/ui/screens/video_message_screen.dart';
import '../../features/contacts/data/contact_model.dart';
import '../../features/contacts/logic/cubit/contacts_cubit.dart';
import '../../features/contacts/ui/contacts_screen.dart';
import '../../features/home/chats/logic/cubit/chat_cubit.dart';
import '../../features/home/chats/ui/screens/chat_room_screen.dart';
import '../../features/home/stories/data/model/story_model.dart';
import '../../features/home/stories/ui/screens/video_story_preview_screen.dart';
import 'package:file_picker/file_picker.dart';
import '../../features/home/stories/logic/cubit/stories_cubit.dart';
import '../../features/home/stories/ui/screens/image_story_preview_screen.dart';
import '../../features/home/stories/ui/screens/story_view_screen.dart';
import '../../features/home/stories/ui/screens/text_story_preview_screen.dart';
import '../../features/home/chats/ui/screens/image_message_screen.dart';
import '../../features/login/logic/cubit/authentication_cubit.dart';
import '../../features/login/ui/login_screen.dart';
import '../../features/login/ui/otp_screen.dart';
import '../../features/main_screen.dart';
import 'routes.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppRouter {
  Route? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.loginScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => BlocProvider<AuthenticationCubit>(
            create: (context) => getIt<AuthenticationCubit>(),
            child: LoginScreen(),
          ),
        );
      case Routes.homeScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const NavBarPages(),
        );
      case Routes.otpScreen:
        final argumentsData = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => MultiBlocProvider(
            providers: [
              BlocProvider<AuthenticationCubit>.value(
                value: getIt<AuthenticationCubit>(),
              ),
              BlocProvider<PermissionsHandlerCubit>(
                create: (context) => PermissionsHandlerCubit(),
              ),
            ],
            child: OtpScreen(
                phoneNumber: argumentsData['phone_number'],
                verificationId: argumentsData['verification_ID']),
          ),
        );
      case Routes.contactsScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => BlocProvider<ContactsCubit>(
            create: (context) => getIt<ContactsCubit>(),
            child: const ContactsScreen(),
          ),
        );
      case Routes.chatRoomScreen:
        final contact = settings.arguments as ContactModel;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => BlocProvider<ChatCubit>.value(
              value: getIt<ChatCubit>(),
              child: ChatRoomScreen(
                contact: contact,
              )),
        );
      case Routes.videoMessageScreen:
        final argumentData = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => VideoMessageScreen(
            isSentByMe: argumentData['isSentByMe'],
            videoMessage: argumentData['videoMessage'],
            contact: argumentData['contact'],
          ),
        );
      case Routes.imageMessageScreen:
        final argumentData = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
            settings: settings,
            builder: (context) => ImageMessageScreen(
                  contact: argumentData['contact'],
                  isSentByMe: argumentData['isSentByMe'],
                  imageMessage: argumentData['imageMessage'],
                ));
      case Routes.textStoryPreviewScreen:
        final storiesCubit = settings.arguments as StoriesCubit;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => BlocProvider<StoriesCubit>.value(
            value: storiesCubit,
            child: const TextStoryPreviewScreen(),
          ),
        );
      case Routes.imageStoryPreviewScreen:
        final argumentData = settings.arguments as Map<String, dynamic>;
        final storiesCubit = argumentData['storiesCubit'];
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => BlocProvider<StoriesCubit>.value(
            value: storiesCubit,
            child: ImageStoryPreviewScreen(
              imageName: argumentData['imageName'],
              imageType: argumentData['imageType'],
              imagePath: argumentData['imagePath'],
            ),
          ),
        );
      case Routes.videoStoryPreviewScreen:
        final argumentData = settings.arguments as Map<String, dynamic>;
        final storiesCubit = argumentData['storiesCubit'];
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => BlocProvider<StoriesCubit>.value(
            value: storiesCubit,
            child: VideoStoryPreviewScreen(
              videoName: argumentData['videoName'],
              videoType: argumentData['videoType'],
              videoPath: argumentData['videoPath'],
            ),
          ),
        );
      case Routes.storyViewScreen:
        final stories = settings.arguments as List<StoryModel>;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => StoryViewScreen(
            stories: stories,
          ),
        );
      case Routes.cameraViewScreen:
        final argumentData = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => BlocProvider<StoriesCubit>.value(
            value: argumentData['storiesCubit'],
            child: CameraViewScreen(
              cameras: argumentData['cameras'],
            ),
          ),
        );
      default:
        null;
    }
    return null;
  }
}
