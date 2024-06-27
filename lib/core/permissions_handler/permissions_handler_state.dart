part of 'permissions_handler_cubit.dart';

sealed class PermissionsHandlerState {}

final class PermissionsHandlerInitial extends PermissionsHandlerState {}

class ContactsPermissionAcceptedState extends PermissionsHandlerState {}

class ContactsPermissionDeniedState extends PermissionsHandlerState {
  final String errorMsg;

  ContactsPermissionDeniedState({required this.errorMsg});
}

class NotificationPermissionAcceptedState extends PermissionsHandlerState {}

class NotificationPermissionDeniedState extends PermissionsHandlerState {
  final String errorMsg;

  NotificationPermissionDeniedState({required this.errorMsg});
}
