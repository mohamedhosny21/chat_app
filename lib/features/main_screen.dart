import '../core/dependency_injection/dependency_injection.dart';
import 'home/chats/logic/cubit/chat_cubit.dart';
import 'home/stories/logic/cubit/stories_cubit.dart';
import 'profile/logic/cubit/profile_cubit.dart';

import 'calls/calls_screen.dart';
import 'home/home_screen.dart';
import 'login/logic/cubit/authentication_cubit.dart';
import 'profile/ui/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavBarPages extends StatefulWidget {
  const NavBarPages({super.key});

  @override
  State<NavBarPages> createState() => _NavBarPagesState();
}

class _NavBarPagesState extends State<NavBarPages> {
  final List<Widget> pages = [
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationCubit>(
          create: (context) => getIt<AuthenticationCubit>(),
        ),
        BlocProvider<ChatCubit>(
          create: (context) => getIt<ChatCubit>(),
        ),
        BlocProvider<StoriesCubit>(
          create: (context) => getIt<StoriesCubit>(),
        ),
      ],
      child: const HomeScreen(),
    ),
    const CallsScreen(),
    BlocProvider<ProfileCubit>.value(
      value: getIt<ProfileCubit>(),
      child: const ProfileScreen(),
    )
  ];
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: index,
          onTap: (newIndex) {
            setState(() {
              index = newIndex;
            });
          },
          selectedItemColor: Colors.black,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.messenger_sharp),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.call),
              label: 'Calls',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile')
          ]),
    );
  }
}
