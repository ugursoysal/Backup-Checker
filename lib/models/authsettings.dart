import 'package:backupchecker/database_handler.dart';

class AuthSettings {
  String clientID, clientSecret, refreshToken;
  String body;
  final String url = "https://oauth2.googleapis.com/token";
  final String gmailUrl =
      "https://www.googleapis.com/gmail/v1/users/me/messages?q=successfully ";
  final String gmailMessagesEndpoint =
      "https://www.googleapis.com/gmail/v1/users/me/messages/";
  final String newerThan = " newer_than:2d";
  final String grantType = "refresh_token";

  AuthSettings() {
    DatabaseHandler db = DatabaseHandler();
    db.readFile("cli_id").then((value) => clientID = value);
    db.readFile("cli_sec").then((value) => clientSecret = value);
    db.readFile("ref_tok").then((value) => refreshToken = value);
  }

  Future<void> refresh() async {
    DatabaseHandler db = DatabaseHandler();
    await db.readFile("cli_id").then((value) => clientID = value);
    await db.readFile("cli_sec").then((value) => clientSecret = value);
    await db.readFile("ref_tok").then((value) => refreshToken = value).then(
        (value) => body = Uri.encodeFull(
            "client_secret=${clientSecret}&grant_type=${grantType}&refresh_token=${refreshToken}&client_id=${clientID}"));
  }
}
