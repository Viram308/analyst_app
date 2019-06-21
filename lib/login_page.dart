import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Constants.dart';
import 'apiCall.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

TextEditingController usernameController = new TextEditingController();
TextEditingController passwordController = new TextEditingController();

class Post {
  final String phone;
  final String password;

  Post({this.phone, this.password});

  factory Post.fromJson(Map<String, dynamic> json) {
    print('hhhhhhh');
    return Post(
      phone: json['phone'],
      password: json['password'],
    );
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["phone"] = phone;
    map["password"] = password;

    return map;
  }
}

Future<Map<String, dynamic>> createPost(String url, Map body) async {
  var body1 = jsonEncode(body);
  print(body1);
  print(url);
  Map<String, String> userHeader = {'content-type': 'application/json'};
  return await http
      .post(url, body: body1, headers: userHeader)
      .then((http.Response response) {
    final int statusCode = response.statusCode;
    Constants.TOKEN =
        response.headers['set-cookie'].split(';')[3].split('=')[2];
    if (statusCode < 200 || statusCode > 400 || json == null) {
      throw new Exception("Error while fetching data");
    }
    Map<String, dynamic> mm = jsonDecode(response.body);
    return mm;
  });
}

class Analyst {
  static List<String> s = [];
  static String loginAnalyst = 'loginanalyst';
  String kioskList = '';

  // ignore: non_constant_identifier_names
  String CREATE_POST_URL = Constants.SERVER_ADDRESS +
      '/' +
      Constants.PLATFORM +
      '/' +
      loginAnalyst +
      '/';

  Future<List<String>> callPostApi(int id) async {
    if (id == 0) {
      print(CREATE_POST_URL);
      Post newPost =
          new Post(phone: Constants.USERNAME, password: Constants.PASSWORD);

      Map<String, dynamic> p =
          await createPost(CREATE_POST_URL, newPost.toMap());
      int i = 0;
      String ss = '';
      List<dynamic> decoded = p['body']['kiosklist'];

      for (var colour in decoded) {
        i++;
        ss = ss + colour['kioskid'].toString() + ",";
        s.add(colour['kiosktag']);

        // prints 1-0001
//        print(decoded[colour]['name']);  // prints red
//        print(decoded[colour]['hex']);   // prints FF0000
      }
      s.add(ss.substring(0, ss.length - 1));
      print(i);
    }

    return s;
  }

  String basicAuthenticationHeader(String username, String password) {
    return 'Basic ' + base64Encode(utf8.encode('$username:$password'));
  }

  Future<Map<String, dynamic>> fetchPost(String url) async {
    String username = Constants.USERNAME;
    String password = Constants.PASSWORD;
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    print(Constants.TOKEN);
    final token = Constants.TOKEN;
    http.Response response =
        await http.get(url, headers: {'content-type': 'application/json'});

    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      return jsonDecode(response.body);
    } else {
      print(response.statusCode);
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post');
    }
  }
}

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  static List<String> list = [];

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((SharedPreferences sp) {
      sharedPreferences = sp;

      // will be null if never previously saved

      setState(() {});
    });
  }

  void persist(bool value) {
    sharedPreferences?.setBool('Logged_In', value);
  }

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: Image.asset('assets/logo.png'),
      ),
    );

    final email = TextFormField(
      controller: usernameController,
      keyboardType: TextInputType.text,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'Phone Number',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final password = TextFormField(
      controller: passwordController,
      autofocus: false,
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Password',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () {
          if (usernameController.text == Constants.USERNAME &&
              passwordController.text == Constants.PASSWORD) {
            Analyst a = new Analyst();
            a.callPostApi(0).then((s) {
//            persist(true);

              DateTime endDate = new DateTime.now();
              String startDateValue =
                  new DateTime.now().toString().split(' ')[0];
              String endDateValue =
                  endDate.add(new Duration(days: 1)).toString().split(' ')[0];
              print(endDateValue);
              print(endDate);
              String kioskidList = s.last;
              print(s.last);
              s.removeLast();
              Constants.l = s;
              print(Constants.l);
              String url =
                  'https://healthatm.in/api/BodyVitals/getAllTestCountForDateRangeAndKiosk/?authkey=00:1B:23:SD:44:F5&authsecret=POR3XQNVp2WXVWP&enddate=' +
                      endDateValue +
                      '&kioskstr=' +
                      kioskidList +
                      '&startdate=' +
                      startDateValue;

              print(url);

              //Navigator.of(context).pushNamed(GetKioskList.tag);
              a.fetchPost(url).then((ss) {
                // persist(true);
                print(s);
                Constants.l = s;
                print(ss);
                Constants.INVOICE_DETAILS = ss['body']['totaltransaction'];
                Constants.USERLIST = ss['body']['totaluser'];
                print(Constants.INVOICE_DETAILS);
                print(Constants.USERLIST);
                Navigator.of(context).pushNamed(GetKioskList.tag);
              });
            });
          } else {
            Fluttertoast.showToast(
              msg: "Wrong Credentials",
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIos: 1,
              backgroundColor: Colors.lightBlue,
            );
          }
        },
        padding: EdgeInsets.all(12),
        color: Colors.lightBlue,
        child: Text('Log In', style: TextStyle(color: Colors.white)),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            logo,
            SizedBox(height: 48.0),
            email,
            SizedBox(height: 8.0),
            password,
            SizedBox(height: 24.0),
            loginButton
          ],
        ),
      ),
    );
  }
}
