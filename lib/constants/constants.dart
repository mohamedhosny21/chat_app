import 'package:cloud_firestore/cloud_firestore.dart';

class AppConstants {
  static const String defaultUserPhoto = 'assets/images/default_user.png';
  static final database = FirebaseFirestore.instance;
}
