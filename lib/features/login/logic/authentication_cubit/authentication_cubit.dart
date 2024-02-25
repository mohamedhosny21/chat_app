import 'package:chatify/widgets/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../constants/constants.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
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
    await getloggedUserId();
  } // Create new user

  void createNewUser({required String phoneNumber}) async {
    final userExists = await checkUserExists(phoneNumber);

    if (!userExists) {
      final user = <String, dynamic>{
        "phone_number": phoneNumber,
        "photo": AppConstants.defaultUserPhoto
      };
      AppConstants.database.collection("Users").add(user).then(
          (doc) => debugPrint('DocumentSnapshot added with ID: ${doc.id}'));
      emit(USerCreationState());
    }
  }

  // Check if user exists by phone number
  Future<bool> checkUserExists(String phoneNumber) async {
    final existingUserQuery = await AppConstants.database
        .collection("Users")
        .where("phone_number", isEqualTo: phoneNumber)
        .get();
    return existingUserQuery.docs.isNotEmpty;
  }

  Future<String> getloggedUserId() async {
    final String loggedPhoneNumber =
        await AppSharedPreferences.getSavedPhoneNumber();
    final documentsQuery = await AppConstants.database
        .collection("Users")
        .where("phone_number", isEqualTo: loggedPhoneNumber)
        .get();
    final String loggedUserId = documentsQuery.docs.first.id;
    AppSharedPreferences.saveLoggedUserId(loggedUserId);
    debugPrint('logged User Id : $loggedUserId');

    return loggedUserId;
  }
}
