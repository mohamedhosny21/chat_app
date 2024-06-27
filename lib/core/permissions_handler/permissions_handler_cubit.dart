import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

part 'permissions_handler_state.dart';

class PermissionsHandlerCubit extends Cubit<PermissionsHandlerState> {
  PermissionsHandlerCubit() : super(PermissionsHandlerInitial());
  Future<void> requestContactsPermission() async {
    final requestPermission = await FlutterContacts.requestPermission();
    if (requestPermission) {
      emit(ContactsPermissionAcceptedState());
    } else {
      emit(ContactsPermissionDeniedState(errorMsg: 'Permission Denied !'));
    }
  }

  Future<void> requestNotificationsPermission() async {
    final requestPermission =
        await FirebaseMessaging.instance.requestPermission();
    if (requestPermission.authorizationStatus ==
        AuthorizationStatus.authorized) {
      emit(NotificationPermissionAcceptedState());
    } else {
      emit(NotificationPermissionDeniedState(errorMsg: 'Permission Denied !'));
    }
  }
}
