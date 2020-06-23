import 'package:flutter/material.dart';
import 'package:backupchecker/models/checker.dart';

class Backups extends StatefulWidget {
  final List<Checker> checkerList;

  Backups(this.checkerList);

  @override
  _BackupsState createState() => _BackupsState(checkerList);
}

class _BackupsState extends State<Backups> {
  int _selectedIndex = 0;
  List<Checker> checkerList;

  _BackupsState(this.checkerList);

  @override
  void initState() {
    super.initState();
    if (checkerList == null ||
        (checkerList.length == 1 && checkerList[0].companyName.length < 2))
      checkerList = List<Checker>(0);
    _widgetOptions = createCompanyList(checkerList);
  }

  static const TextStyle successfulStyle =
      TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green);
  static const TextStyle failedStyle = TextStyle(
      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent);
  List<Widget> _widgetOptions;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> createCompanyList(List<Checker> checkList) {
    List<Checker> successCheckList =
        checkList.where((e) => e.successful == true).toList();
    List<Checker> failedCheckList =
        checkList.where((e) => e.successful == false).toList();
    List<Widget> successfulList = successCheckList.map((e) {
      return Row(
          children: <Widget>[Text(e.companyName, style: successfulStyle)]);
    }).toList();
    List<Widget> failedList = failedCheckList.map((e) {
      return Row(children: <Widget>[Text(e.companyName, style: failedStyle)]);
    }).toList();
    return <Widget>[
      Container(
        child: Column(
          children: successfulList,
        ),
      ),
      Container(
        child: Column(
          children: failedList,
        ),
      ),
    ];
  }

  Widget companyCheckWidget() {
    if (checkerList == null)
      return Text(
          "Couldn't access the Gmail account. Please check the credentials.",
          style: TextStyle(color: Colors.white));
    if (checkerList.length == 0) {
      return Text(
          "No company record has been found in the application. Please add one before checking the status.",
          style: TextStyle(color: Colors.white));
    }
    _widgetOptions = createCompanyList(checkerList);
    return _widgetOptions.elementAt(_selectedIndex); // successful page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Check Results'),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.grey[850],
      ),
      backgroundColor: Colors.grey[900],
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(25.0, 38.0, 25.0, 0.0),
          child: companyCheckWidget(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.done_outline),
            title: Text('Successful'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.highlight_off),
            title: Text('Failed'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amberAccent[200],
        onTap: _onItemTapped,
      ),
    );
  }
}
