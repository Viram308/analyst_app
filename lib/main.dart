import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'analyst_page.dart';
import 'complete_kiosk_list_page.dart';
import 'invoice_details_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  createState() => new MyAppState();
}

class MyAppState extends State<MyApp> {
  Widget check = LoginPage();
  final routes = <String, WidgetBuilder>{
    LoginPage.tag: (context) => LoginPage(),
    GetKioskList.tag: (context) => GetKioskList(),
    KioskDataTable.tag: (context) => KioskDataTable(),
  };
  SharedPreferences sharedPreferences;

  bool _testValue;

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((SharedPreferences sp) {
      sharedPreferences = sp;
      _testValue = sharedPreferences.getBool('Logged_In');
      // will be null if never previously saved
      if (_testValue == null) {
        _testValue = false;
        check=LoginPage();
        persist(_testValue); // set an initial value
      }
      else if(_testValue){
        check=GetKioskList();
      }
      setState(() {});
    });
  }

  void persist(bool value) {
    setState(() {
      _testValue = value;
    });
    sharedPreferences?.setBool('Logged_In', value);
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        fontFamily: 'Nunito',
      ),
      home: check,
      routes: routes,
    );
  }
}
