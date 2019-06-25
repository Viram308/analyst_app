import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'Constants.dart';
class InvoiceDetails {
  InvoiceDetails(
    this.invoiceDate,
    this.receiptId,
    this.userName,
    this.checkupString,
    this.amount,
    this.paidStatus,
    this.kioskTag,
  );

  final String invoiceDate;
  final int receiptId;
  final String userName;
  final String checkupString;
  final int amount;
  final String paidStatus;
  final String kioskTag;

//  bool selected = false;
}

class InvoiceDetailsDataSource extends DataTableSource {

static List<dynamic> _listOfInvoice;
//  InvoiceDetailsDataSource(List<dynamic> l) {
//    print(';ll;l;ll;'+l.toString());
//    _listOfInvoice = l;
//print('LPLPLP'+_listOfInvoice.toString());
//
//  }


  static List<InvoiceDetails> getInvoiceDetailsList() {
    List<InvoiceDetails> _invoiceDetailsList = [];
    print('klklkl'+_listOfInvoice.toString());
    for (var eachKiosk in Constants.INVOICE_LIST) {
      String datetime=eachKiosk['datetime'];
      int receiptId=eachKiosk['receiptid'];
       String userName=eachKiosk['username'];
       String checkupString=eachKiosk['checkupstr'];
       int amount=eachKiosk['billamount'];
       String paidStatus=eachKiosk['paymentdone'].toString();
       String kioskTag=eachKiosk['kiosktag'];

      _invoiceDetailsList.add(InvoiceDetails(datetime,receiptId,userName,checkupString,amount,paidStatus,kioskTag));
    }
    return _invoiceDetailsList;
  }
List<InvoiceDetails> _invoiceDetails =getInvoiceDetailsList();
  int _selectedCount = 0;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= _invoiceDetails.length) return null;
    final InvoiceDetails invoice = _invoiceDetails[index];
    return DataRow.byIndex(
      index: index,
      cells: <DataCell>[
        DataCell(Text('${invoice.invoiceDate}')),
        DataCell(Text('${invoice.receiptId}')),
        DataCell(Text('${invoice.userName}')),
        DataCell(Text('${invoice.checkupString}')),
        DataCell(Text('${invoice.amount}')),
        DataCell(Text('${invoice.paidStatus}')),
        DataCell(Text('${invoice.kioskTag}')),
      ],
    );
  }

  @override
  int get rowCount => _invoiceDetails.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}

class InvoiceDetailsDataTable extends StatefulWidget {
  static const String tag = 'invoice-details';




  @override
  _InvoiceDetailsDataTableState createState() =>
      _InvoiceDetailsDataTableState();
}

class _InvoiceDetailsDataTableState extends State<InvoiceDetailsDataTable> {
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _sortColumnIndex;
  bool _sortAscending = true;
  static List<dynamic> listOfInvoice;

//  _InvoiceDetailsDataTableState(List<dynamic> l) {
//    print('kkkkkkkk'+l.toString());
//    listOfInvoice = l;
//    print('kkkkkllll'+listOfInvoice.toString());
//  }

  InvoiceDetailsDataSource _invoiceDetailsDataSource =new InvoiceDetailsDataSource();
  

  @override
  Widget build(BuildContext context) {
//    print(widget.invoiceDetailsList);
    return Scaffold(
      body: Scrollbar(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: <Widget>[
            PaginatedDataTable(
              header: const Text('Invoice Details'),
              rowsPerPage: _rowsPerPage,
              onRowsPerPageChanged: (int value) {
                setState(() {
                  _rowsPerPage = value;
                });
              },
              sortColumnIndex: _sortColumnIndex,
              sortAscending: _sortAscending,
              columns: <DataColumn>[
                DataColumn(
                  label: const Text('Date'),
                ),
                DataColumn(
                  label: const Text('Receipt ID'),
                  numeric: true,
                ),
                DataColumn(
                  label: const Text('User Name'),
                ),
                DataColumn(
                  label: const Text('Checkup String'),
                ),
                DataColumn(
                  label: const Text('Amount'),
                  numeric: true,
                ),
                DataColumn(
                  label: const Text('Paid?'),
                ),
                DataColumn(
                  label: const Text('Kiosk'),
                ),
              ],
              source: _invoiceDetailsDataSource,
            ),
          ],
        ),
      ),
    );
  }
}
