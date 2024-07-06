import 'package:chatify/core/dependency_injection/dependency_injection.dart';
import 'package:chatify/core/notifications_manager/data/notifications_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/app_router/routes.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  final _firestore = FirebaseFirestore.instance;

  final GlobalKey<FormState> phoneAuthFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> pinFormKey = GlobalKey<FormState>();
  AuthenticationCubit() : super(AuthenticationInitial());

  Future<void> loginWithPhoneNumber(String phoneNumber) async {
    emit(LoginLoadingState());

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        //time taken to recieve sms message
        timeout: const Duration(seconds: 15),

        //Automatic handling of the SMS code on Android devices
        verificationCompleted: _onVerificationCompleted,
        //Handle failure events such as invalid phone numbers or whether the SMS quota has been exceeded.
        verificationFailed: _onVerificationFailed,

        // Save the verification ID and show a UI to enter the code
        // Handle when a code has been sent to the device from Firebase, used to prompt users to enter the code.
        codeSent: _onCodeSent,
        //Handle a timeout of when automatic SMS code handling fails.
        codeAutoRetrievalTimeout: _onCodeAutoRetrievalTimeout);
  }

  void _onVerificationCompleted(PhoneAuthCredential credential) async {
    debugPrint('Auto Verification Completed');

    await _signIn(credential);
  }

  void _onVerificationFailed(FirebaseAuthException error) {
    debugPrint(error.toString());
    emit(LoginFailedState(errorMsg: 'The number isn\'t valid'));
  }

  void _onCodeSent(String verificationId, int? resendToken) async {
    emit(PhoneNumberSubmittedState(verificationId: verificationId));
  }

  void _onCodeAutoRetrievalTimeout(String verificationId) {
    debugPrint('codeAutoRetrievalTimeout !');
  }

  Future<void> _signIn(PhoneAuthCredential credential) async {
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      emit(LoginSuccessState(successMsg: 'Verification Completed'));
      await getIt<NotificationsRepository>().saveCurrentDeviceTokenToDatabase();
    } catch (error) {
      emit(LoginFailedState(errorMsg: 'Incorrect OTP code'));
      throw Exception(error);
    }
  }

  Future<void> signOut() async {
    final currentDeviceToken =
        await getIt<NotificationsRepository>().getCurrentDeviceToken();
    await getIt<NotificationsRepository>()
        .deleteDeviceTokenFromDatabase(currentDeviceToken!);
    await FirebaseAuth.instance.signOut();
  }

  //function called when code is submitted and entered manually by user
  Future<void> submitPhoneOtp(String smsCode, String verificationId) async {
    emit(LoginLoadingState());
    PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);
    debugPrint('verificationId : $verificationId');
    await _signIn(phoneAuthCredential);
  }

  void createNewUser({required String phoneNumber}) async {
    final bool isUserExists = await _checkUserExists();
    if (!isUserExists) {
      final newUser = <String, dynamic>{
        "phone_number": phoneNumber,
        "photo": null,
      };
      final currentUser = FirebaseAuth.instance.currentUser;
      debugPrint(currentUser?.uid);
      await _firestore.collection("Users").doc(currentUser!.uid).set(newUser);
      await getIt<NotificationsRepository>().saveCurrentDeviceTokenToDatabase();

      emit(UserCreationState());
    }
  }

  Future<bool> _checkUserExists() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    final existingUserQuery =
        await _firestore.collection("Users").doc(currentUser?.uid).get();
    return existingUserQuery.exists;
  }

  Future<String> getInitialRoute() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    String initialRoute = Routes.loginScreen;

    if (currentUser != null) {
      bool userExists = await _checkUserExists();
      if (!userExists) {
        await FirebaseAuth.instance.signOut();
      } else {
        initialRoute = Routes.homeScreen;
        await getIt<NotificationsRepository>()
            .saveCurrentDeviceTokenToDatabase();
      }
    }
    return initialRoute;
  }
}
