import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'apiCall.dart';
import 'Constants.dart';
import 'login_page.dart';

class Kiosk {
  Kiosk(this.name);

  final String name;

  bool selected = true;
}

class KioskDataSource extends DataTableSource {
  int _selectedCount = getKioskList().length;

  static List<Kiosk> getKioskList() {
    List<Kiosk> _kiosks = [];
    for (String eachKiosk in Constants.l) {
      _kiosks.add(Kiosk(eachKiosk));
    }
    return _kiosks;
  }

  static List<Kiosk> _kiosks = getKioskList();

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= _kiosks.length) return null;
    final Kiosk kiosk = _kiosks[index];
    return DataRow.byIndex(
      index: index,
      selected: kiosk.selected,
      onSelectChanged: (bool value) {
        if (kiosk.selected != value) {
          _selectedCount += value ? 1 : -1;
//          assert(_selectedCount >= 0);
          kiosk.selected = value;
          notifyListeners();
        }
      },
      cells: <DataCell>[
        DataCell(Text('${kiosk.name}')),
      ],
    );
  }

  @override
  int get rowCount => _kiosks.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;

  void _selectAll(bool checked) {
    for (Kiosk selectEachKiosk in _kiosks) selectEachKiosk.selected = checked;
    _selectedCount = checked ? _kiosks.length : 0;
    notifyListeners();
  }
}

class KioskDataTable extends StatefulWidget {
  static String tag = 'new-approach';

  @override
  _KioskDataTableState createState() => _KioskDataTableState();
}

class _KioskDataTableState extends State<KioskDataTable> {
  final KioskDataSource _kiosksDataSource = KioskDataSource();
  List<int> kioskStr = [];

  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int i = 0;

  @override
  Widget build(BuildContext context) {
    final resultButton = new RaisedButton(
      padding: const EdgeInsets.all(8.0),
      textColor: Colors.black,
      color: Colors.blue,
      onPressed: () {
        Constants.KIOSKSTR = '';
        for (var kioskTagtoStr in KioskDataSource.getKioskList()) {
          if (KioskDataSource._kiosks[i++].selected) {
            print(kioskTagtoStr.name +
                'jjjdkjdkjsdjksdjsjd' +
                LoginPage.mapping[kioskTagtoStr.name].toString());
            Constants.KIOSKSTR = Constants.KIOSKSTR +
                LoginPage.mapping[kioskTagtoStr.name].toString() +
                ',';
          }
        }
        Constants.KIOSKSTR =
            Constants.KIOSKSTR.substring(0, Constants.KIOSKSTR.length - 1);
        print(Constants.KIOSKSTR);
        Navigator.pushReplacementNamed(context, GetKioskList.tag);
      },
      child: Text("Show Result"),
    );

    return Scaffold(
      body: Scrollbar(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: <Widget>[
            PaginatedDataTable(
              header: const Text('Kiosk List'),
              rowsPerPage: _rowsPerPage,
              onRowsPerPageChanged: (int value) {
                setState(() {
                  _rowsPerPage = value;
                });
              },
              onSelectAll: _kiosksDataSource._selectAll,
              columns: <DataColumn>[
                DataColumn(
                  label: const Text('Select All'),
                ),
              ],
              source: _kiosksDataSource,
            ),
            resultButton,
          ],
        ),
      ),
    );
  }
}
