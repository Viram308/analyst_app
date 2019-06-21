import 'dart:convert';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Constants.dart';
import 'package:intl/intl.dart';

class _InputDropdown extends StatelessWidget {
  const _InputDropdown({
    Key key,
    this.child,
    this.labelText,
    this.valueText,
    this.valueStyle,
    this.onPressed,
  }) : super(key: key);

  final String labelText;
  final String valueText;
  final TextStyle valueStyle;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
        ),
        baseStyle: valueStyle,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(valueText, style: valueStyle),
            Icon(
              Icons.arrow_drop_down,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey.shade700
                  : Colors.white70,
            ),
          ],
        ),
      ),
    );
  }
}

class _DateTimePicker extends StatelessWidget {
  const _DateTimePicker({
    Key key,
    this.labelText,
    this.selectedDate,
    this.selectDate,
  }) : super(key: key);

  final String labelText;
  final DateTime selectedDate;
  final ValueChanged<DateTime> selectDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) selectDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle valueStyle = Theme.of(context).textTheme.title;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          flex: 4,
          child: _InputDropdown(
            labelText: labelText,
            valueText: DateFormat.yMMMd().format(selectedDate),
            valueStyle: valueStyle,
            onPressed: () {
              _selectDate(context);
            },
          ),
        ),
        const SizedBox(width: 12.0),
      ],
    );
  }
}

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
//  HttpClient httpClient = new HttpClient();
//  // ignore: close_sinks
//  HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
//  request.headers.set('content-type', 'application/json');
//
//  request.add(utf8.encode(json.encode(body)));
//  HttpClientResponse response = await request.close();

//  print(response.statusCode);
//  print(response.body);
//  Future<String> reply = response.transform(utf8.decoder).join();
//  print(reply.toString());

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
      List<dynamic> decoded = p['body']['kiosklist'];

      for (var colour in decoded) {
        i++;
        s.add(colour['kiosktag']);

        // prints 1-0001
//        print(decoded[colour]['name']);  // prints red
//        print(decoded[colour]['hex']);   // prints FF0000
      }
      print(i);
    }

    return s;
  }
}

class GetKioskListState extends State<GetKioskList> {
  List<DropdownMenuItem<String>> _dropDownMenuItems;
  List<String> _allKiosk = Constants.l;

  String _currentKiosk;

  @override
  void initState() {
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

  void changedDropDownItem(String selectedKiosk) {
    print("Selected Kiosk $selectedKiosk");
    setState(() {
      _currentKiosk = selectedKiosk;
    });
  }

  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();

  String _getFromDate = '';
  String _getToDate = '';

  @override
  Widget build(BuildContext context) {
    final goButton = new RaisedButton(
      padding: const EdgeInsets.all(8.0),
      textColor: Colors.black,
      color: Colors.blue,
      onPressed: null,
      child: Text("GO"),
    );

    final fromDate = new _DateTimePicker(
      labelText: 'From',
      selectedDate: _fromDate,
      selectDate: (DateTime date) {
        setState(() {
          _fromDate = date;
          _getFromDate = date.toString();
        });
      },
    );

    final toDate = new _DateTimePicker(
      labelText: 'To',
      selectedDate: _toDate,
      selectDate: (DateTime date) {
        setState(() {
          _toDate = date;
          _getToDate = date.toString();
        });
      },
    );

//    final space = const SizedBox(height: 58.0);

    final kioskList = new InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Select Kiosk',
        hintText: 'Choose a Kiosk',
        contentPadding: EdgeInsets.zero,
      ),
      isEmpty: _currentKiosk == null,
      child: DropdownButton<String>(
        value: _currentKiosk,
        onChanged: changedDropDownItem,
        items: getDropDownMenuItems(),
      ),
    );

//    return Scaffold(
//      body: DropdownButtonHideUnderline(
//        child: SafeArea(
//          top: true,
//          bottom: true,
//          child: ListView(
//            padding: const EdgeInsets.all(16.0),
//            children: <Widget>[fromDate, toDate, space],
//          ),
//        ),
//      ),
//    );
//    Analyst ab = new Analyst();
//    return new Scaffold(
//      body: new Column(
//        mainAxisAlignment: MainAxisAlignment.center,
//        children: <Widget>[
//          fromDate,
//          toDate,
//          space,
//          new FutureBuilder(
//              future: ab.callPostApi(0),
//              builder:
//                  (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
//                if (snapshot.connectionState == ConnectionState.done) {
//                  _allKiosk = snapshot.data;
//                  print(_allKiosk);
//                  return Scaffold(
//                    body: DropdownButtonHideUnderline(
//                      child: SafeArea(
//                        top: true,
//                        bottom: true,
//                        child: ListView(
//                          padding: const EdgeInsets.all(16.0),
//                          children: <Widget>[
//                            fromDate,
//                            toDate,
//                            space,
//
//                            goButton
//                          ],
//                        ),
//                      ),
//                    ),
//                  );
//                } else {
//                  return Center(child: CircularProgressIndicator());
//                }
//              }),
//        ],
//      ),
//    );

    return Scaffold(
      body: DropdownButtonHideUnderline(
        child: SafeArea(
          top: true,
          bottom: true,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[fromDate, toDate, kioskList, goButton],
          ),
        ),
      ),
    );
  }
}
