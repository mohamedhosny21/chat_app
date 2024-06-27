part of 'authentication_cubit.dart';

sealed class AuthenticationState {}

final class AuthenticationInitial extends AuthenticationState {}

class LoginLoadingState extends AuthenticationState {}

class PhoneNumberSubmittedState extends AuthenticationState {
  final String verificationId;

  PhoneNumberSubmittedState({required this.verificationId});
}

class LoginSuccessState extends AuthenticationState {
  final String successMsg;

  LoginSuccessState({required this.successMsg});
}

class LoginFailedState extends AuthenticationState {
  final String errorMsg;

  LoginFailedState({required this.errorMsg});
}

class AuthenticationUserState extends AuthenticationState {}

class UnAuthenticationUserState extends AuthenticationState {}

class UserCreationState extends AuthenticationState {}
