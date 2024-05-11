import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/app_router/routes.dart';
import '../../../../core/helpers/constants.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  final firestoreDatabase = FirebaseFirestore.instance;
  final currentUser = FirebaseAuth.instance.currentUser;

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
        verificationCompleted: onVerificationCompleted,
        //Handle failure events such as invalid phone numbers or whether the SMS quota has been exceeded.
        verificationFailed: onVerificationFailed,

        // Save the verification ID and show a UI to enter the code
        // Handle when a code has been sent to the device from Firebase, used to prompt users to enter the code.
        codeSent: onCodeSent,
        //Handle a timeout of when automatic SMS code handling fails.
        codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout);
  }

  void onVerificationCompleted(PhoneAuthCredential credential) async {
    debugPrint('Auto Verification Completed');

    await signIn(credential);
  }

  void onVerificationFailed(FirebaseAuthException error) {
    debugPrint(error.toString());
    emit(LoginFailedState(errorMsg: 'The number isn\'t valid'));
  }

  void onCodeSent(String verificationId, int? resendToken) async {
    emit(PhoneNumberSubmittedState(verificationId: verificationId));
  }

  void onCodeAutoRetrievalTimeout(String verificationId) {
    debugPrint('codeAutoRetrievalTimeout !');
  }

  Future<void> signIn(PhoneAuthCredential credential) async {
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      emit(LoginSuccessState(successMsg: 'Verification Completed'));
    } catch (error) {
      emit(LoginFailedState(errorMsg: error.toString()));
      throw Exception(error);
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  //function called when code is submitted and entered manually by user
  Future<void> submitPhoneOtp(String smsCode, String verificationId) async {
    emit(LoginLoadingState());
    PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);
    debugPrint('verificationId : $verificationId');
    await signIn(phoneAuthCredential);
    // await getloggedUserId();
  } // Create new user

  void createNewUser({required String phoneNumber}) async {
    final newUser = <String, dynamic>{
      "phone_number": phoneNumber,
      "photo": AppConstants.defaultUserPhoto
    };
    FirebaseAuth.instance.authStateChanges().listen((currentUser) async {
      debugPrint(currentUser?.uid);
      await firestoreDatabase
          .collection("Users")
          .doc(currentUser!.uid)
          .set(newUser);
      emit(UserCreationState());
    });
  }

  Future<bool> checkUserExists() async {
    final existingUserQuery =
        await firestoreDatabase.collection("Users").doc(currentUser?.uid).get();
    return existingUserQuery.exists;
  }

  Future<String> getInitialRoute() async {
    String initialRoute = Routes.loginScreen;

    if (currentUser != null) {
      bool userExists = await checkUserExists();
      if (!userExists) {
        await FirebaseAuth.instance.signOut();
      } else {
        initialRoute = Routes.homeScreen;
      }
    }
    return initialRoute;
  }
}
