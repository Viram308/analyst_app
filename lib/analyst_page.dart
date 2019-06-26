import 'dart:convert';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'date_time_picker_widget.dart';
import 'complete_kiosk_list_page.dart';
import 'invoice_details_page.dart';
import 'user_details_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  print(body);
  var body1 = jsonEncode(body);
  print(body);

  Map<String, String> userHeader = {'content-type': 'application/json'};
  return await http
      .post(url, body: body1, headers: userHeader)
      .then((http.Response response) {
    final int statusCode = response.statusCode;

    if (statusCode < 200 || statusCode > 400 || json == null) {
      throw new Exception("Error while fetching data");
    }
    Map<String, dynamic> mm = jsonDecode(response.body);
    return mm;
  });
}

class GetKioskList extends StatefulWidget {
  static String tag = 'getApi';

  GetKioskList({Key key}) : super(key: key);

  @override
  createState() => new GetKioskListState();
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
      Post newPost =
          new Post(phone: Constants.USERNAME, password: Constants.PASSWORD);

      Map<String, dynamic> p =
          await createPost(CREATE_POST_URL, newPost.toMap());
      int i = 0;
      List<dynamic> allKioskTags = p['body']['kiosklist'];

      for (var allKioskTag in allKioskTags) {
        i++;
        s.add(allKioskTag['kiosktag']);
      }
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

class GetKioskListState extends State<GetKioskList>
    with WidgetsBindingObserver {
  List<String> _allKiosk = Constants.l;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    print(state);
    print(
        'Helllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllo');
  }

  @override
  void initState() {
    SharedPreferences sharedPreferences;
    Analyst a = new Analyst();
    int userid;
    String url = '';
    SharedPreferences.getInstance().then((SharedPreferences sp) {
      sharedPreferences = sp;
      userid = sharedPreferences?.getInt('userid');

      url =
          'https://healthatm.in/api/User/getKioskUserTypeMapping?filetype=analyst&userid=' +
              userid.toString();
      print(url);
      a.fetchPost(url).then((ss) {
        print(ss);

        print('i m here');

        print(Constants.KIOSKSTR);
        url =
            'https://healthatm.in/api/BodyVitals/getAllTestCountForDateRangeAndKiosk/?authkey=00:1B:23:SD:44:F5&authsecret=POR3XQNVp2WXVWP&enddate=' +
                Constants.TODATE
                    .add(new Duration(days: 1))
                    .toString()
                    .split(' ')[0] +
                '&kioskstr=' +
                Constants.KIOSKSTR +
                '&startdate=' +
                Constants.FROMDATE.toString().split(' ')[0];
        print(url);
        a.fetchPost(url).then((ss) {
          print(ss);

          setState(() {
            Constants.INVOICE_DETAILS = ss['body']['totaltransaction'];
            Constants.USERLIST = ss['body']['totaluser'];
          });

          print(Constants.INVOICE_DETAILS);
          print(Constants.USERLIST);
        });
      });
    });
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems() {
    List<DropdownMenuItem<String>> items = new List();
    for (String kiosk in _allKiosk) {
      items.add(new DropdownMenuItem(value: kiosk, child: new Text(kiosk)));
    }
    print(_allKiosk);
    return items;
  }

  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final selectKioskButton = new RaisedButton(
      padding: const EdgeInsets.all(8.0),
      textColor: Colors.black,
      color: Colors.blue,
      onPressed: () {
        Navigator.pushReplacementNamed(context, KioskDataTable.tag);
      },
      child: Text("Select Kiosks",
          style: TextStyle(
              fontStyle: FontStyle.normal,
              fontSize: 20.0,
              color: Colors.white)),
    );

    final fromDate = new DateTimePicker(
      labelText: 'From',
      selectedDate: Constants.FROMDATE,
      selectDate: (DateTime date) {
        setState(() {
          _fromDate = date;
          Constants.FROMDATE = _fromDate;
        });
      },
    );

    final toDate = new DateTimePicker(
      labelText: 'To',
      selectedDate: Constants.TODATE,
      selectDate: (DateTime date) {
        setState(() {
          _toDate = date;
          Constants.TODATE = _toDate;
        });
      },
    );

    final space = const SizedBox(height: 58.0);

    final Color cardBackgroundColor = const Color(0xFF337ab7);
    final Color cardDetailColor = const Color(0xFFF5F5F5);
    final invoiceDetailsCard = Card(
      elevation: 5.0,
      color: cardDetailColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: 100,
            color: cardBackgroundColor,
            child: ListTile(
              leading: Icon(
                Icons.assignment,
                color: Colors.white,
                size: 30.0,
              ),
              title: Text('Invoice Details',
                  style: TextStyle(
                      fontStyle: FontStyle.normal,
                      fontSize: 20.0,
                      color: Colors.white)),
              trailing: Text(Constants.INVOICE_DETAILS.toString(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.normal,
                      fontSize: 45.0,
                      color: Colors.white)),
              onTap: () {
                print('Invoice Card tapped');
              },
            ),
          ),
          InkWell(
            splashColor: cardBackgroundColor,
            onTap: () {
              print('LOLOLOLOLLLLLLLLLLLLLLL');
              DateTime endDate = Constants.TODATE;
              String startDateValue =
                  Constants.FROMDATE.toString().split(' ')[0];
              String endDateValue =
                  endDate.add(new Duration(days: 1)).toString().split(' ')[0];
              print(endDateValue);
              print(endDate);
              String kioskidList = Constants.KIOSKSTR;

              Analyst a = new Analyst();
              String url =
                  'https://healthatm.in/api/BodyVitals/getTestDataForDateRangeAndKiosk/?authkey=00:1B:23:SD:44:F5&authsecret=POR3XQNVp2WXVWP&machinestr=transactionlist&enddate=' +
                      endDateValue +
                      '&kioskstr=' +
                      kioskidList +
                      '&startdate=' +
                      startDateValue;

              print(url);

              //Navigator.of(context).pushNamed(GetKioskList.tag);
              a.fetchPost(url).then((ss) {
                List<dynamic> list = ss['body']['transactionlist'];
                print(list);
                Constants.INVOICE_LIST = list;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InvoiceDetailsDataTable(),
                  ),
                );
              });
            },
            child: Container(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: const Text('View Details',
                          style: TextStyle(
                              fontStyle: FontStyle.normal,
                              fontSize: 20.0,
                              color: Colors.blue)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.blue,
                      size: 30.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    final userRegisteredCard = Card(
      elevation: 5.0,
      color: cardDetailColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: 100,
            color: cardBackgroundColor,
            child: ListTile(
              leading: Icon(
                Icons.supervisor_account,
                color: Colors.white,
                size: 30.0,
              ),
              title: Text('User Registered',
                  style: TextStyle(
                      fontStyle: FontStyle.normal,
                      fontSize: 20.0,
                      color: Colors.white)),
              trailing: Text(Constants.USERLIST.toString(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.normal,
                      fontSize: 45.0,
                      color: Colors.white)),
              onTap: () {
                print('User Registered tapped');
              },
            ),
          ),
          InkWell(
            splashColor: cardBackgroundColor,
            onTap: () {
              print('HAHAHAHHAHAHAHHAHAAAAAAAA');
              DateTime endDate = Constants.TODATE;
              String startDateValue =
                  Constants.FROMDATE.toString().split(' ')[0];
              String endDateValue =
                  endDate.add(new Duration(days: 1)).toString().split(' ')[0];
              print(endDateValue);
              print(endDate);
              String kioskIdList = Constants.KIOSKSTR;

              Analyst a = new Analyst();
              String url =
                  'https://healthatm.in/api/BodyVitals/getTestDataForDateRangeAndKiosk/?authkey=00:1B:23:SD:44:F5&authsecret=POR3XQNVp2WXVWP&machinestr=userlist&enddate=' +
                      endDateValue +
                      '&kioskstr=' +
                      kioskIdList +
                      '&startdate=' +
                      startDateValue;

              print(url);

              //Navigator.of(context).pushNamed(GetKioskList.tag);
              a.fetchPost(url).then((ss) {
                List<dynamic> list = ss['body']['userlist'];
                print(list);
                Constants.USER_LIST = list;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserDetailsDataTable(),
                  ),
                );
              });
            },
            child: Container(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: const Text('View Details',
                          style: TextStyle(
                              fontStyle: FontStyle.normal,
                              fontSize: 20.0,
                              color: Colors.blue)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.blue,
                      size: 30.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      body: DropdownButtonHideUnderline(
        child: SafeArea(
          top: true,
          bottom: true,
          right: true,
          left: true,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              fromDate,
              toDate,
              space,
              selectKioskButton,
              space,
              invoiceDetailsCard,
              space,
              userRegisteredCard
            ],
          ),
        ),
      ),
    );
  }
}
