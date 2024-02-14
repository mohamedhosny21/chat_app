import 'package:chatify/constants/strings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'chats_state.dart';

class ChatsCubit extends Cubit<ChatsState> {
  final database = FirebaseFirestore.instance;
  ChatsCubit() : super(ChatsInitial());
  Future<bool> isUserCreated({required String phoneNumber}) async {
    final existingUserQuery = await database
        .collection("Users")
        .where("phone_number", isEqualTo: phoneNumber)
        .get();
    return existingUserQuery.docs.isNotEmpty;
  }

  //create new user
  void createNewUser({required String phoneNumber}) async {
    final isUserExists = await isUserCreated(phoneNumber: phoneNumber);
    // Add a new document with a generated ID
    if (!isUserExists) {
      final user = <String, dynamic>{
        "phone_number": phoneNumber,
        "photo": AppConstants.defaultUserPhoto
      };
      database.collection("Users").add(user).then(
          (doc) => debugPrint('DocumentSnapshot added with ID: ${doc.id}'));
    }
  }
}
