import 'package:backupchecker/database_handler.dart';
import 'package:backupchecker/models/authsettings.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  AuthSettings globalSettings;

  Settings() {
    globalSettings = AuthSettings();
  }

  static const TextStyle settingsTextStyle = TextStyle(
      fontSize: 18, fontWeight: FontWeight.normal, color: Colors.amberAccent);
  static const TextStyle settingsTextFieldStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Colors.white,
      fontStyle: FontStyle.italic);
  static const TextStyle warningTextStyle = TextStyle(
      fontSize: 14, fontWeight: FontWeight.w100, color: Colors.redAccent);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final clientIDController = TextEditingController();

  final clientSecretController = TextEditingController();

  final refreshTokenController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    clientIDController.dispose();
    clientSecretController.dispose();
    refreshTokenController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.globalSettings = new AuthSettings();
    widget.globalSettings.refresh().then((value) => {
          clientIDController.text = widget.globalSettings.clientID,
          clientSecretController.text = widget.globalSettings.clientSecret,
          refreshTokenController.text = widget.globalSettings.refreshToken,
        });
  }

  @override
  Widget build(BuildContext context) {
    clientIDController.text = widget.globalSettings.clientID;
    clientSecretController.text = widget.globalSettings.clientSecret;
    refreshTokenController.text = widget.globalSettings.refreshToken;
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.grey[850],
      ),
      backgroundColor: Colors.grey[900],
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(25.0, 38.0, 25.0, 0.0),
          child: Column(
            children: <Widget>[
              Row(children: <Widget>[
                Text('Client ID:', style: Settings.settingsTextStyle)
              ]),
              TextField(
                controller: clientIDController,
                onChanged: (value) =>
                    {DatabaseHandler().writeFile("cli_id", value)},
                style: Settings.settingsTextFieldStyle,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '(enter your client ID)',
                  hintStyle: Settings.settingsTextFieldStyle,
                ),
              ),
              Row(children: <Widget>[
                Text('Client Secret:', style: Settings.settingsTextStyle)
              ]),
              TextField(
                controller: clientSecretController,
                onChanged: (value) =>
                    {DatabaseHandler().writeFile("cli_sec", value)},
                style: Settings.settingsTextFieldStyle,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '(enter your client secret)',
                  hintStyle: Settings.settingsTextFieldStyle,
                ),
              ),
              Row(children: <Widget>[
                Text('Refresh Token:', style: Settings.settingsTextStyle)
              ]),
              TextField(
                controller: refreshTokenController,
                onChanged: (value) =>
                    {DatabaseHandler().writeFile("ref_tok", value)},
                style: Settings.settingsTextFieldStyle,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '(enter your refresh token)',
                  hintStyle: Settings.settingsTextFieldStyle,
                ),
              ),
              Row(children: <Widget>[
                Text('Do NOT share these information.',
                    style: Settings.warningTextStyle)
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
