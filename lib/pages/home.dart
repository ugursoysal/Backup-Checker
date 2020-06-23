import 'package:backupchecker/models/authsettings.dart';
import 'package:backupchecker/pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:backupchecker/models/checker.dart';
import 'package:backupchecker/database_handler.dart';
import 'package:backupchecker/googleapi_helpers.dart';
import 'package:flutter/services.dart';
import 'backups.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  AuthSettings globalSettings;
  final addController = TextEditingController();

  @override
  void dispose() {
    addController.dispose();
    super.dispose();
  }

  String textAdd;
  List<String> companyList = List<String>();

  @override
  void initState() {
    super.initState();
    //DatabaseHandler().save("companya,companyb,companyc");
    readCompanyAsync();
    globalSettings = new AuthSettings();
    globalSettings.refresh();
  }
  readCompanyAsync() async {
    await DatabaseHandler().readCompanyList().then((value) =>
    {
      if (value != null && value.length > 0){
        setState(() {
          companyList = value;
          companyList.sort();
        })
      }
      else
          if (value != null && value.length > 0){
            setState(() {
              companyList = new List<String>();
              companyList.sort();
            })
          }
    });
  }

  Widget createCompanyRow(String companyName) {
    if (companyName.length > 2)
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(companyName,
              style: TextStyle(fontSize: 16.0, color: Colors.white)),
          FlatButton(
            onPressed: () => DatabaseHandler()
                .deleteCompany(companyName)
                .then((value) => setState(() {
                      companyList = value;
                      if(value != null)
                        companyList.sort();
                    })),
            child: Icon(
              Icons.delete_forever,
              color: Colors.amberAccent[200],
            ),
          )
        ],
      );
    return Row();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Backup Checker'),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.grey[850],
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (context) => new Settings()));
            },
          )
        ],
      ),
      backgroundColor: Colors.grey[900],
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await globalSettings.refresh();
          if(globalSettings.clientSecret.length < 5
          || globalSettings.clientID.length < 5
          || globalSettings.refreshToken.length < 10) {
            showDialog(
                context: context,
                child: new AlertDialog(
                  title: new Text("Need configuration"),
                  content: new Text(
                      "Please set the configuration before checking for the backups."),
                  actions: <Widget>[
                FlatButton(
                child: Text("OK"),
              onPressed: () { Navigator.pop(context); },
                ),
                  ],
                ));
          }else{
            showDialog(
              context: context,
                child: new AlertDialog(
                title: new Text("Please wait"),
                content: new Text("We're checking the backups for you..."),
              )
            );
            List<Checker> checkerList = new List<Checker>();
            if (companyList.length > 0)
              checkerList = await GoogleApiHelpers(globalSettings)
                  .checkBackups(companyList);
            await Navigator.push(
              context,
              MaterialPageRoute(
              builder: (context) => new Backups(checkerList)));
            Navigator.of(context).popUntil((r) => r.isFirst);
          }
        },
        child: Text('Check', style: TextStyle(color: Colors.grey[850])),
        backgroundColor: Colors.amberAccent[200],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(25.0, 38.0, 25.0, 0.0),
          child: Column(
            children: <Widget>[
              Theme(
                data: new ThemeData(
                  hintColor: Colors.amberAccent[200],
                  primaryColor: Colors.amberAccent[200],
                ),
                child: new TextFormField(
                  controller: addController,
                  inputFormatters: [
                    new LengthLimitingTextInputFormatter(25),
                  ],
                  decoration: InputDecoration(
                    hoverColor: Colors.amberAccent[200],
                    focusColor: Colors.amberAccent[200],
                    labelText: "Plan/Task Name",
                    hintText: "Enter the plan/task name to be added",
                    hintStyle: TextStyle(color: Colors.white12),
                    labelStyle: TextStyle(color: Colors.amberAccent[200]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  validator: (val) {
                    if (val.length == 0) {
                      return "Plan/Task Name can't be empty";
                    } else if (val.length > 25) {
                      return "Plan/Task Name can't be more than 25 characters";
                    } else {
                      return null;
                    }
                  },
                  keyboardType: TextInputType.text,
                  style: TextStyle(
                    fontFamily: "Poppins",
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              FlatButton(
                child: Icon(
                  Icons.add,
                  color: Colors.amberAccent[200],
                ),
                color: Colors.grey[800].withOpacity(0.05),
                onPressed: () => {
                  if (addController.text.length > 25 ||
                      addController.text.length < 2)
                    {addController.text = ""}
                  else
                    {
                      DatabaseHandler()
                          .addCompany(addController.text)
                          .then((value) => setState(() {
                                addController.text = "";
                                companyList = value.toList();
                                companyList.sort();
                              }))
                    }
                },
              ),
              Divider(
                height: 60.0,
                color: Colors.grey[500],
              ),
              Container(
                  child: Column(
                children: (companyList.length > 0)
                    ? companyList.map((e) => createCompanyRow(e)).toList()
                    : [],
              )),
            ],
          ),
        ),
      ),
    );
  }
}
