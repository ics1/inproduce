// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'api/api.dart';
import 'package:intl/intl.dart';
//import '../../gallery/demo.dart';

class Order {
  Order(this.id, this.dateInproduce, this.name, this.fio, this.status, this.dateIzg);
  final String id;
  final String dateInproduce;
  final String name;
  final String fio;
  final String status;
  final String dateIzg;




  bool selected = false;
}



class DataTableDemo extends StatefulWidget {
  static const String routeName = '/material/data-table';
  Future<List<dynamic>> orders = Api.fetchOrdersAll({'AE' : {'>': DateFormat('dd.MM.yy').format(DateTime.now().add(Duration(days: -1)))}});
  Map <String, dynamic> filter;

  @override
  _DataTableDemoState createState() => _DataTableDemoState();
}

class _DataTableDemoState extends State<DataTableDemo> {
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _sortColumnIndex;
  bool _sortAscending = true;
  DessertDataSource _dessertsDataSource;// = DessertDataSource();
  dynamic order;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //widget.orders = Api.fetchOrdersAll({'AE' : {'>': DateFormat('dd.MM.yy').format(DateTime.now().add(Duration(days: -1)))}});
  }
  void _sort<T>(Comparable<T> getField(Order d), int columnIndex, bool ascending) {
    _dessertsDataSource._sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Распределение заказов'),
        actions: <Widget>[
          //MaterialDemoDocumentationButton(DataTableDemo.routeName),
        ],
      ),
      body: Scrollbar(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: <Widget>[
            _builderFuture()

          ],
        ),
      ),
    );
  }
  Widget _builderFuture()  {
    return FutureBuilder<List<dynamic>>(
      future: widget.orders,
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        print('snapshot.hasData=');
        print(snapshot.hasData);

        if (snapshot.hasData) {
          Order order;
          List<Order> _orders = [];
          print('1=');
          print(snapshot.data);
          for (Map<String, dynamic> item in snapshot.data) {
            order = Order(item['A'], item['AE'], item['I'], (item['AZ'])??'', item['BA']??'', item['BB']??'');
            _orders.add(order);
          }
          return _buildTable(_orders);
        }
        return Center( child:CircularProgressIndicator());
      },
    );
  }
  Widget _buildTable(_orders) {
    _dessertsDataSource = new DessertDataSource(_orders);
    return PaginatedDataTable(
      header: const Text('Заказы'),
      rowsPerPage: _rowsPerPage,
      onRowsPerPageChanged: (int value) { setState(() { _rowsPerPage = value; }); },
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      //onSelectAll: _dessertsDataSource._selectAll,
      columns: <DataColumn>[
        DataColumn(
          label: const Text('№'),
          onSort: (int columnIndex, bool ascending) => _sort<String>((Order d) => d.id, columnIndex, ascending),
        ),
        DataColumn(
          label: const Text('Дата'),
          onSort: (int columnIndex, bool ascending) => _sort<String>((Order d) => d.dateInproduce, columnIndex, ascending),
        ),
        DataColumn(
          label: const Text('Наименование'),
          tooltip: 'The total amount of food energy in the given serving size.',
          numeric: false,
          onSort: (int columnIndex, bool ascending) => _sort<String>((Order d) => d.name, columnIndex, ascending),
        ),
        DataColumn(
          label: const Text('Столярка ФИО'),
          tooltip: 'The total amount of food energy in the given serving size.',
          numeric: false,
          onSort: (int columnIndex, bool ascending) => _sort<String>((Order d) => d.fio, columnIndex, ascending),
        ),
        DataColumn(
          label: const Text('Статус'),
          tooltip: 'The total amount of food energy in the given serving size.',
          numeric: false,
          onSort: (int columnIndex, bool ascending) => _sort<String>((Order d) => d.status, columnIndex, ascending),
        ),
        DataColumn(
          label: const Text('Дата изг.'),
          tooltip: 'The total amount of food energy in the given serving size.',
          numeric: false,
          onSort: (int columnIndex, bool ascending) => _sort<String>((Order d) => d.dateIzg, columnIndex, ascending),
        ),
      ],
      source: _dessertsDataSource,
    );
  }
}

class DessertDataSource extends DataTableSource {
  //Future<List<dynamic>> data;
  //DessertDataSource(this.data);
  List<Order> _desserts; /*<Order>[
    Order('8543','12.08.19','New'),
    Order('8544','12.08.19','New2'),

  ];*/
  DessertDataSource(List<Order> data)  {
    print('2=');
    this._desserts = data;
  }


  void _sort<T>(Comparable<T> getField(Order d), bool ascending) {
    _desserts.sort((Order a, Order b) {
      if (!ascending) {
        final Order c = a;
        a = b;
        b = c;
      }
      final Comparable<T> aValue = getField(a);
      final Comparable<T> bValue = getField(b);
      return Comparable.compare(aValue, bValue);
    });
    notifyListeners();
  }

  int _selectedCount = 0;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= _desserts.length)
      return null;
    final Order dessert = _desserts[index];
    return DataRow.byIndex(
      index: index,
      selected: dessert.selected,
      onSelectChanged: (bool value) {
        if (dessert.selected != value) {
          _selectedCount += value ? 1 : -1;
          assert(_selectedCount >= 0);
          dessert.selected = value;
          notifyListeners();
        }
      },

      cells: <DataCell>[
        DataCell(Text('${dessert.id}')),
        DataCell(Text('${dessert.dateInproduce}')),
        DataCell(Text('${dessert.name}')),
        DataCell(Text('${dessert.fio}')),
        DataCell(Text('${dessert.status}')),
        DataCell(Text('${dessert.dateIzg}')),


      ],
    );
  }


  @override
  int get rowCount => _desserts.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;

  void _selectAll(bool checked) {
    for (Order dessert in _desserts)
      dessert.selected = checked;
    _selectedCount = checked ? _desserts.length : 0;
    notifyListeners();
  }
}
