import 'package:shared_preferences/shared_preferences.dart';

class AppSharedPreferences {
  static void savePhoneNumberInSharedPrefs(String phoneNumber) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('Phone_Number', phoneNumber);
  }

  static Future<String> getPhoneNumberFromSharedPrefs() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('Phone_Number') ?? '';
  }
}
