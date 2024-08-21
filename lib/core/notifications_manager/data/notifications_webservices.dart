import 'dart:convert';

import '../../helpers/constants/api_constants.dart';
import 'models/notification_payload_model.dart';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart';

class NotificationsWebservices {
  Future<String> getServerAccessToken() async {
    final Client authClient = await createAuthenticatedClient();
    final auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(
                ApiConstants.serviceAccountJson),
            ApiConstants.scopes,
            authClient);
    authClient.close();
    return credentials.accessToken.data;
  }

  //Obtains oauth2 credentials and returns an authenticated HTTP client.
  Future<Client> createAuthenticatedClient() async {
    final authClient = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(
            ApiConstants.serviceAccountJson),
        ApiConstants.scopes);
    return authClient;
  }

  Future<void> pushNotification(
      {required String deviceToken,
      required NotificationPayload notificationPayloadModel}) async {
    final serverAccessToken = await getServerAccessToken();
    final Map<String, dynamic> notificationPayload = {
      'message': notificationPayloadModel.toMap(deviceToken),
    };

    final http.Response respone =
        await http.post(Uri.parse(ApiConstants.firebaseCloudMessageEndPoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $serverAccessToken',
            },
            body: json.encode(notificationPayload));
    if (respone.statusCode == 200) {
      debugPrint('notification sent : ${notificationPayload['message']}');
    } else if (respone.statusCode == 404) {
      {
        throw Exception(
            'notification not sent : UNREGISTERED TOKEN ${respone.statusCode}');
      }
    } else {
      debugPrint('notification not sent :  ${respone.statusCode}');
    }
  }
}
