import 'package:chatify/constants/constants.dart';
import 'package:chatify/features/user_chat/data/user_chat_model.dart';
import 'package:chatify/widgets/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'messages_state.dart';

class MessagesCubit extends Cubit<MessagesState> {
  List<Message> messages = [];
  // List<Message> cachedMessages = [];
  MessagesCubit() : super(MessagesInitial());
  Future<String> getChatId(String recieverId) async {
    final String senderId = await AppSharedPreferences.getSavedLoggedUserId();
    print('sender id cubit $senderId');
    final List<String> participentsId = [senderId, recieverId];
    //sort is essential so if the sender and reciever are exchanged with each other then the chatid will be the same id without creating new chat id due to the exchange of their ids
    participentsId.sort();
    print('particepents : $participentsId');

    final String chatId = participentsId.join('_');
    print('chat id : $chatId');

    return chatId;
  }

  void sendMessage(Message message) async {
    final String chatId = await getChatId(message.recieverId);
    AppConstants.database
        .collection("Chats")
        .doc(chatId)
        .collection("Messages")
        .add({
      "id": message.id,
      "senderId": message.senderId,
      "recieverId": message.recieverId,
      "text": message.text,
      "type": message.type,
      "time": message.time
    }).then((doc) {
      emit(MessageSentState());
      getMessages(message.recieverId);
      debugPrint('message id : ${doc.id}');
    }).catchError((error) {
      emit(MessageErrorState());
      throw Exception(error);
    });
  }

  Future<List<Message>> getMessages(String recieverId) async {
    final chatId = await getChatId(recieverId);
    try {
      AppConstants.database
          .collection("Chats")
          .doc(chatId)
          .collection("Messages")
          .orderBy('time',
              descending:
                  true) //descending true bec i make the reverse in listview.builder =true.to make the chat when opened appeared from the end
          .snapshots() //instead of .get()
          .listen((documnetsMessagesQuery) {
        messages = documnetsMessagesQuery.docs.map((doc) {
          final data = doc.data();
          return Message(
              id: data['id'],
              senderId: data['senderId'],
              recieverId: data['recieverId'],
              text: data['text'],
              type: data['type'],
              time: data['time']);
        }).toList();
        for (var element in messages) {
          print(element.text);
        }
        emit(MessagesLoadedState(messages: messages));
      });
    } catch (error) {
      emit(MessageErrorState());
      throw Exception(error);
    }
    return messages;
  }

  void deleteMessages(String recieverId, String messageId) async {
    final chatId = await getChatId(recieverId);
    AppConstants.database
        .collection("Chats")
        .doc(chatId)
        .collection("Messages")
        .where('id', isEqualTo: messageId)
        .get()
        .then((querySnapshots) {
      for (var doc in querySnapshots.docs) {
        doc.reference.delete().then((value) {
          emit(MessageDeletedState());
          return print('deleted msg doc is ${doc.id}');
        });
      }
    });
  }
}
