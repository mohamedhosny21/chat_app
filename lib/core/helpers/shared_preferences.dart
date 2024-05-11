import 'package:shared_preferences/shared_preferences.dart';

class AppSharedPreferences {
  // static void savePhoneNumber(String phoneNumber) async {
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   sharedPreferences.setString('Phone_Number', phoneNumber);
  // }

  // static Future<String> getSavedPhoneNumber() async {
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   return sharedPreferences.getString('Phone_Number') ?? '';
  // }

  // static void saveLoggedUserId(String loggedUserId) async {
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //   sharedPreferences.setString('loggedUserId', loggedUserId);
  // }

  static Future<String> getSavedLoggedUserId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('loggedUserId') ?? '';
  }
}
