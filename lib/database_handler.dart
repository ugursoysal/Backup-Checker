import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DatabaseHandler {
  Future<List<String>> readCompanyList() async {
    try {
      List<String> companyList;
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/backupcheckerdb.txt');
      if (!(await file.exists())) {
        await file.create();
      }
      String text = await file.readAsString();
      companyList = text.split(',').toList();
      companyList.sort();
      for (int i = 0; i < companyList.length; i++) {
        if (companyList[i].length < 2) {
          companyList.removeAt(i);
        }
      }
      return companyList;
    } catch (e) {
      print("Couldn't read file: " + e.toString());
      return null;
    }
  }

  Future<String> readFile(String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/' + filename);
      if (!(await file.exists())) {
        await file.create();
        return "";
      }
      String text = await file.readAsString();
      return text;
    } catch (e) {
      print("Couldn't read file");
      return "";
    }
  }

  writeFile(String filename, String text) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/' + filename);
    if (!(await file.exists())) {
      await file.create();
    }
    await file.writeAsString(text);
  }

  Future<bool> fileExists(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}' + filename);
    return (!(await file.exists()) != null);
  }

  Future<List<String>> addCompany(String name) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/backupcheckerdb.txt');
    if (!(await file.exists())) {
      await file.create();
    }
    List<String> companies = List<String>();
    await readCompanyList()
        .then((value) => (value != null) ? companies = value.toList() : null);
    if (companies != null) {
      companies.add(name);
      await file.writeAsString(companies.join(','));
    }
    return companies;
  }

  Future<List<String>> deleteCompany(String name) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/backupcheckerdb.txt');
    if (!(await file.exists())) {
      await file.create();
    }
    List<String> companies = List<String>();
    await readCompanyList()
        .then((value) => (value != null) ? companies = value.toList() : null);
    if (companies != null && companies.length > 0) {
      companies.remove(name);
      await file.writeAsString(companies.join(','));
    }
    return companies;
  }
}
