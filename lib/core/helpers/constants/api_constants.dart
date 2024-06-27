import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class ApiConstants {
  static Map<String, String> serviceAccountJson = {
    "type": "service_account",
    "project_id": dotenv.env['PROJECT_ID']!,
    "private_key_id": dotenv.env['PRIVATE_KEY_ID']!,
    "private_key": dotenv.env['PRIVATE_KEY']!,
    "client_email": dotenv.env['CLIENT_EMAIL']!,
    "client_id": dotenv.env['CLIENT_ID']!,
    "auth_uri": dotenv.env['AUTH_URI']!,
    "token_uri": dotenv.env['TOKEN_URI']!,
    "auth_provider_x509_cert_url": dotenv.env['AUTH_PROVIDER_X509_CERT_URL']!,
    "client_x509_cert_url": dotenv.env['CLIENT_X509_CERT_URL']!,
    "universe_domain": dotenv.env['UNIVERSE_DOMAIN']!
  };

  //To authorize access to FCM, request the scope
  static const List<String> scopes = [
    "https://www.googleapis.com/auth/firebase.messaging"
  ];
  static const firebaseCloudMessageEndPoint =
      "https://fcm.googleapis.com/v1/projects/flutter-maps-d6a2e/messages:send";
}
