import '../../data/repository/stories_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/model/story_model.dart';

part 'stories_state.dart';

class StoriesCubit extends Cubit<StoriesState> {
  final StoriesRepository _storiesRepository;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  List<StoryModel>? usersStories;
  final User? currentUser = FirebaseAuth.instance.currentUser;
  StoriesCubit(this._storiesRepository) : super(StoriesInitial());

  void pickFileFromDevice() async {
    final file = await _storiesRepository.pickFileFromDevice();

    if (file != null) {
      emit(StoryPickedState(file: file));
    }
  }

  void addStory({
    required String content,
    required String storyTextColor,
  }) async {
    emit(StoryUploadingState());

    final newAddedStory = await _storiesRepository.addStory(
        content: content, storyType: 'text', storyTextColor: storyTextColor);
    emit(StoryUploadedState(story: newAddedStory));
  }

  void addFileStory(
      {required String filePath,
      required String fileType,
      int? videoDuration,
      required String fileName}) async {
    emit(StoryUploadingState());
    final newAddedStory = await _storiesRepository.addFileStory(
        filePath: filePath,
        fileType: fileType,
        fileName: fileName,
        videoDuration: videoDuration);
    emit(StoryUploadedState(story: newAddedStory));
  }

  void getUsersStories() async {
    final List<Contact> deviceContacts =
        await _storiesRepository.getDeviceContats();
    final List<String> usersId = await _storiesRepository
        .getUsersIdByDevicePhoneNumbers(deviceContacts: deviceContacts);

    // Create a map for quick lookup of contact names by phone number
    final contactMap = {
      for (var contact in deviceContacts)
        for (var phone in contact.phones)
          phone.normalizedNumber: contact.displayName
    };

    // Create a list of streams for each user's StoryItems collection
    final List<Stream<QuerySnapshot>> streams = usersId.map((userId) {
      return _firebaseFirestore
          .collection('Stories')
          .doc(userId)
          .collection('StoryItems')
          .snapshots();
    }).toList();

    // Combine all streams into a single stream
    final combinedStream = Rx.combineLatestList(streams);

    combinedStream.listen((List<QuerySnapshot> snapshots) {
      List<StoryModel> usersStories = [];

      for (var storiesSnapshot in snapshots) {
        if (storiesSnapshot.docs.isNotEmpty) {
          for (var doc in storiesSnapshot.docs) {
            final data = doc.data() as Map<String, dynamic>?;
            if (data != null) {
              final userPhoneNumber = data['userPhoneNumber'];
              // Use the map to quickly find the contact name
              final contactName = contactMap[userPhoneNumber];

              // Create and add StoryModel objects
              usersStories.add(
                StoryModel.fromMap(data, userName: contactName),
              );
            }
          }
        }
      }
      this.usersStories = usersStories;
      // Emit the state with the aggregated stories
      emit(UsersStoriesLoadedState(usersStories: usersStories));
      print(usersStories);
    });
  }
}
