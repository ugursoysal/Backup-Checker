import 'dart:convert';
import 'dart:io';
import 'package:backupchecker/models/authsettings.dart';
import 'package:backupchecker/models/checker.dart';
import 'package:http/http.dart' as http;

class GoogleApiHelpers {
  String accessToken;
  AuthSettings globalSettings;

  GoogleApiHelpers(this.globalSettings);

  Future<String> getAccessToken() async {
    String token;
    await http.post(
      globalSettings.url,
      body: globalSettings.body,
      headers: {
        HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded",
      },
    ).then((http.Response response) {
      if (response.statusCode == 200)
        token = json.decode(response.body)['access_token'];
    }).catchError((err) => token = "error: " + err.toString());
    return token;
  }

  checkBackup(String bearerToken, String element) async {
    try {
      var dateTimeYesterday = new DateTime.now().subtract(Duration(days: 1));
      dateTimeYesterday = new DateTime(dateTimeYesterday.year,
          dateTimeYesterday.month, dateTimeYesterday.day, 16, 59, 0, 0, 0);
      //print(dateTimeYesterday.toString());
      var response = await http.get(
        globalSettings.gmailUrl + element + globalSettings.newerThan,
        headers: {
          HttpHeaders.authorizationHeader: bearerToken,
          HttpHeaders.contentLengthHeader: "0",
        },
      );
      if (response.statusCode == 200) {
        String resultSizeEstimate;
        var jsonObject = json.decode(response.body);
        resultSizeEstimate = jsonObject['resultSizeEstimate'].toString();
        if (resultSizeEstimate != "0") {
          for (var message in jsonObject['messages']) {
            var messageID = message['id'].toString();
            var res2 = await http.get(
              globalSettings.gmailMessagesEndpoint + messageID,
              headers: {
                HttpHeaders.authorizationHeader: bearerToken,
                HttpHeaders.contentLengthHeader: "0",
              },
            );
            var messageResultObject = json.decode(res2.body);
            int messageDateUnixTimestamp =
                int.parse(messageResultObject['internalDate'].toString());
            var date = new DateTime.fromMillisecondsSinceEpoch(
                messageDateUnixTimestamp);
            //print(date.toString());
            if (date.isAfter(dateTimeYesterday)) return true;
          }
          return false;
        } else
          return false;
      } else
        return false;
    } catch (on) {
      return false;
    }
  }

  Future<List<Checker>> checkBackups(List<String> companiesList) async {
    String accessToken;
    await GoogleApiHelpers(globalSettings).getAccessToken().then((token) {
      accessToken = token;
    }).catchError((err) => {accessToken = "error"});
    if (accessToken == "error") return null;
    String bearerToken = "Bearer " + accessToken;
    List<Checker> checkList = new List<Checker>();
    for (var element in companiesList) {
      if (await checkBackup(bearerToken, element))
        checkList.add(new Checker(companyName: element, successful: true));
      else
        checkList.add(new Checker(companyName: element, successful: false));
    }
    return checkList;
  }
}
