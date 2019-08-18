// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'api/api.dart';
import 'package:intl/intl.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'components/input_date_dropdown.dart';
import 'package:provider/provider.dart';
import 'app.dart';

List <String> employeeSt= ['','Василенко', 'Эклема', 'Лещинский', 'Царалунга', 'Бойко'];
List <String> status = ['','Наряд выдан', 'Взят в работу', 'Остановлен', 'Выполнен'];
List <String> statusKeys = ['','4', '2', '3', '1'];

class DataTableDemo extends StatefulWidget {
  static const String routeName = '/material/data-table';
  Future<List<dynamic>> orders = Api.fetchOrdersAll({'AE' : {'>': DateFormat('dd.MM.yy').format(DateTime.now().add(Duration(days: -1)))}});
  Map <String, dynamic> filter = {};
  Map<String, dynamic> stateStatus = {};
  List<DateTime> _date = [new DateTime.now().add(Duration(days: 1)), new DateTime.now().add(Duration(days: 7))];

  @override
  _DataTableDemoState createState() => _DataTableDemoState();
}

class _DataTableDemoState extends State<DataTableDemo> {
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _sortColumnIndex;
  bool _sortAscending = true;
  DessertDataSource _dessertsDataSource;
  List<Order> _orders = [];
  dynamic order;
  InputDateDropdown _inputDateDropdown;
  List <Widget> _buildActions = [];
  String _title = '';
  var dateFormat = new DateFormat('dd.MM.yy');

  final key = new GlobalKey<ScaffoldState>();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void _sort<T>(Comparable<T> getField(Order d), int columnIndex, bool ascending) {
    _dessertsDataSource._sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  void _handleDataSourceChanged() {
    if (_dessertsDataSource.selectedRowCount == 0) {
      _buildActions.clear();
      //_buildActions.add(_getButtonRangeDate());
    }

    if (_buildActions.length == 0 && _dessertsDataSource.selectedRowCount > 0) {
      _buildActions.add(_getDropDownState('Исполнитель', 'employeeSt', employeeSt));
      _buildActions.add(_getDropDownState('Статус', 'statusSt', status));
      //_buildActions.add(_getDropDownState());
      _buildActions.add(_dropDownDate(null));

      _buildActions.add(_getButtonApply());

    }
  }

  void _selectDateRange() async {
    final List<DateTime> pickedRange = await DateRagePicker.showDatePicker(
        context: context,
        initialFirstDate: widget._date[0],
        initialLastDate: widget._date[1],
        firstDate: new DateTime(2015),
        lastDate: new DateTime(2020)
    );
    if (pickedRange != null && pickedRange.length == 2) {

      setState(() {
        widget._date = pickedRange;
        _title = dateFormat.format(pickedRange[0])+'-'+dateFormat.format(pickedRange[1]);
        widget.orders = Api.fetchOrdersAll({'AE':{'>=':dateFormat.format(widget._date[0]), '<=':dateFormat.format(widget._date[1])}});
      });
    }
    print(widget.filter);
  }

  Widget _getButtonApply() {

    return Consumer<IsLoading>(
      builder: (context, loader, child) {
        return AbsorbPointer(
            absorbing: loader.value,
            child: FlatButton(
              onPressed: () {
                return  _saveMultiSelect();
              },
              child: Text('Применить'),

            )
        );
      },
    );
  }

  bool _validateData() {

    if (widget.stateStatus.length == 0) {
      return false;
    }

    if (widget.stateStatus['employeeSt'] == null) {
      return false;
    }
    if (widget.stateStatus['statusSt'] == null) {
      return false;
    }
    return true;
  }

  void _saveMultiSelect() {

    if (_validateData()) {
      int index = status.indexOf(widget.stateStatus['statusSt']);
      String date = _inputDateDropdown.getDate();
      if ( widget.stateStatus['statusSt'] == '') {
        date = '';
      }
      Map<String, dynamic> result = {
        'fields': {
          'AZ'  : widget.stateStatus['employeeSt'],
          'BA'  : statusKeys[index],
          'BB'  : date,
        },
        'ids' : _dessertsDataSource.getSelected()
      };
      Provider.of<IsLoading>(context, listen: false).setState(true);
      print(widget.stateStatus.length);
      print(widget.stateStatus);
      print(_dessertsDataSource.getSelected());
      print(_inputDateDropdown.getDate());
      Api.updateAll(result).then((value){
        if (value == true) {
          key.currentState.showSnackBar(new SnackBar(
              backgroundColor: Colors.green,
              content: new Text("Изменения сохранены!"),
          ));
          Provider.of<IsLoading>(context, listen: false).setState(false);
          _dessertsDataSource.unSelectedAll();
          setState(() {
            widget.orders = Api.fetchOrdersAll({'AE':{'>=':dateFormat.format(widget._date[0]), '<=':dateFormat.format(widget._date[1])}});
          });

        } else {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("Ошибка"),
                content: Text("Данные не сохранены!"),
              )
          );
        }
        Provider.of<IsLoading>(context, listen: false).setState(false);
        return value;
      });

    } else {
      _showError();
    }
  }

  void _showError() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Проверьте данные"),
          content: new Text("Выберите ФИО, Статус, Дату"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Закрыть"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _getDropDownState(title, stateName, employeeSt) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             new DropdownButton<String>(
              value: widget.stateStatus[stateName],
              items: employeeSt.map<DropdownMenuItem<String>>((String value) {
                var i = employeeSt.indexOf(value);
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String newValue) {
                setState(() {
                  widget.stateStatus[stateName] = newValue;
                });
              },
            )
        ]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar: AppBar(
        title: Text('Распределение заказов' + _title),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            semanticLabel: 'arrow_back',
          ),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed("/home");
          },
        ),
        actions: <Widget>[
          //MaterialDemoDocumentationButton(DataTableDemo.routeName),
          IconButton(
            icon: Icon(
              Icons.tune,
              semanticLabel: 'filter',
            ),
            onPressed: _selectDateRange,
          ),
        ],
        bottom: PreferredSize(
            preferredSize: Size(double.infinity, 4.0),
            child: SizedBox(
                height: 4.0,
                child: Consumer<IsLoading>(
                  builder: (context, loader, child) => ProgressBar(loader.value),
                ),//ProgressBar(widget.isLoading)
            )
        ),
      ),
      body: Scrollbar(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: <Widget>[
            _builderFuture()

          ],
        )
      ),

    );
  }

  Widget _builderFuture()  {
    return FutureBuilder<List<dynamic>>(
      future: widget.orders,
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.hasData) {
          Order order;
          _orders = [];
          for (Map<String, dynamic> item in snapshot.data) {
            order = Order(item['A'], item['AE'], item['I'], (item['AZ'])??'', item['BA']??'', item['BB']??'');
            _orders.add(order);
          }
          return _buildTable(_orders);
        }
        return Column(children: <Widget>[ Center( child:CircularProgressIndicator()) ]);
      },
    );

  }

  Widget _getButtonRangeDate() {
    return   IconButton(
      icon: Icon(
        Icons.tune,
        semanticLabel: 'filter',
      ),
      onPressed: () {
        _selectDateRange();
      },
    );
  }

  Widget _buildTable(_orders) {
    _dessertsDataSource = new DessertDataSource(_orders);
    _dessertsDataSource.addListener(_handleDataSourceChanged);
    //_handleDataSourceChanged();
    return PaginatedDataTable(
      header: const Text('Заказы'),
      actions: _buildActions,
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

  Widget _dropDownDate(valueDate) {

    _inputDateDropdown = InputDateDropdown(
        labelText: 'Дата производства:',
        valueText: valueDate,
        //valueStyle: valueStyle,
        onPressed: () {
          //_inputDateDropdown.setDate('13.08.19');
        }
    );
    return new Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        new Row(
          //flex: 4,
          children: [_inputDateDropdown],
        ),
      ],
    );
  }

}

Map<String, dynamic> stateStatus = {};

Widget _getDropDownState(value, stateName, employeeSt) {
  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      return Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            new DropdownButton<String>(
              value: stateStatus[stateName]??value,
              items: employeeSt.map<DropdownMenuItem<String>>((String value) {
                var i = employeeSt.indexOf(value);
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String newValue) {
                setState(() {
                  stateStatus[stateName] = newValue;
                });
              },
            )
          ]);
    },
  );
}

class ProgressBar extends StatelessWidget {
  final bool _isLoading;
  ProgressBar(this._isLoading);

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return new LinearProgressIndicator();//
    }
    else {
      return Container();
    }
  }
}

class DessertDataSource extends DataTableSource {
  List<Order> _desserts;
  List<String> _selectedIds = [];
  DessertDataSource(List<Order> data)  {
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
    int statusIndex = statusKeys.indexOf(dessert.status);

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
        //DataCell(_getDropDownState(dessert.fio, 'employeeSt'+index.toString(), employeeSt)),
        //DataCell(_getDropDownState(status[statusIndex], 'statusSt'+index.toString(), status)),
        DataCell(Text('${dessert.dateIzg}')),
      ],
    );
  }

  getSelected() {
    _selectedIds.clear();
    for (Order item in _desserts) {
      if (item.selected) {
        _selectedIds.add(item.id);
      }
    }
    return _selectedIds;
  }
  unSelectedAll() {
    for (Order item in _desserts) {
      if (item.selected) {
        item.selected = false;
      }
    }
    _selectedCount = 0;
    notifyListeners();
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