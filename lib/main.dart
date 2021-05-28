import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_eg/contact_model.dart';
import 'package:hive_eg/contact_page.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final path = await pathProvider.getApplicationDocumentsDirectory();
  print(path);

  Hive.init(path.path);

  Hive.registerAdapter(ContactsAdapter());
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Hive.openBox('contacts'),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text(snapshot.hasError.toString());
          } else {
            return ContactPage();
          }
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    // To close all opened Hive Boxes
    //  Hive.close();

    // To just close a Particular box
    Hive.box('contacts').close();
    super.dispose();
  }
}
