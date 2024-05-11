import 'package:shared_preferences/shared_preferences.dart';

class AppSharedPreferences {
  static Future<String> getSavedLoggedUserId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('loggedUserId') ?? '';
  }
}
