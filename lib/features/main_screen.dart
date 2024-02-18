import 'calls/calls_screen.dart';
import 'chats/chats_screen.dart';
import 'login/logic/authentication_cubit/authentication_cubit.dart';
import 'profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavBarPages extends StatefulWidget {
  const NavBarPages({super.key});

  @override
  State<NavBarPages> createState() => _NavBarPagesState();
}

class _NavBarPagesState extends State<NavBarPages> {
  final List<Widget> pages = [
    BlocProvider<AuthenticationCubit>(
      create: (context) => AuthenticationCubit(),
      child: const ChatsScreen(),
    ),
    const CallsScreen(),
    const ProfileScreen()
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
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.messenger_sharp),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.groups),
              label: 'Groups',
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
