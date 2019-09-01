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

List <String> employeeSt= ['','Плукчи', 'Социгашева', 'Овчарская', 'Агарунова', 'Логинов'];
List <String> status = ['','Наряд срочный', 'Наряд выдан', 'Взят в работу', 'Остановлен', 'Выполнен'];
List <String> statusKr = ['','Крой'];

List <String> statusKeys = ['','5', '4', '2', '3', '1'];

class TableSveika extends StatefulWidget {
  static const String routeName = '/material/data-table';


  Map<String, dynamic> stateStatus = {};
  List<DateTime> _date = [new DateTime.now().add(Duration(days: 1)), new DateTime.now().add(Duration(days: 7))];

  @override
  _TableSveikaState createState() => _TableSveikaState();
}

class _TableSveikaState extends State<TableSveika> {
  Map <String, dynamic> filter = {'AE' : {'>': DateFormat('dd.MM.yy').format(DateTime.now().add(Duration(days: -1)))}};
  Future<List<dynamic>> orders = Api.fetchOrdersAll({'AE' : {'>': DateFormat('dd.MM.yy').format(DateTime.now().add(Duration(days: -1)))}});
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int _sortColumnIndex;
  bool _sortAscending = true;
  DessertDataSource _dessertsDataSource;
  List<Order> _orders = [];
  dynamic order;
  InputDateDropdown _inputDateDropdown;
  InputDateDropdown _inputDateDropdownFilter;

  List <Widget> _buildActions = [];
  String _title = '';
  var dateFormat = new DateFormat('dd.MM.yy');

  final key = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _filter.addListener(() {

      if (_filter.text.length > 3) {
        print(_filter.text.indexOf(','));
        if (_filter.text.indexOf(',') > 0) {
          List ids = _filter.text.split(",");
          setState(() {
            filter = {"A": {'in': ids}};
            orders = Api.fetchOrdersAll(filter);
          });
        } else {
          setState(() {
            filter = {"A": _filter.text};
            orders = Api.fetchOrdersAll(filter);
          });
        }
      } else {
        setState(() {
          filter = _getBaseFilter();
          orders = Api.fetchOrdersAll(filter);
        });
      }

    });
  }
  _getBaseFilter() {
    return {'AE':{'>=':dateFormat.format(widget._date[0]), '<=':dateFormat.format(widget._date[1])}};
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
      _buildActions.add(_getDropDownState('Крой', 'statusKr', statusKr));
      //_buildActions.add(_getDropDownState());
      _buildActions.add(_dropDownDate(DateFormat('dd.MM.yy').format(DateTime.now())));

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
        _appBarTitle = Text('Распределение заказов' + ' ' + _title);
        filter = {'AE':{'>=':dateFormat.format(widget._date[0]), '<=':dateFormat.format(widget._date[1])}};
        orders = Api.fetchOrdersAll(filter);
      });
    }
    //print(widget.filter);
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
      String date = _inputDateDropdown.valueText;
      if ( widget.stateStatus['statusSt'] == '') {
        date = '';
      }

      Map<String, dynamic> result = {
        'fields': {
          'BO'  : widget.stateStatus['employeeSt'],
          'BP'  : statusKeys[index],
          'BQ'  : date,
          'BR'  : '',
          'BS'  : '',
          'BT'  : '',
          'BU'  : '',
          'BV'  : '',
          'BW'  : '',
          'BX'  : ''
        },
        'ids' : _dessertsDataSource.getSelected()
      };
      int indexKr = statusKr.indexOf(widget.stateStatus['statusKr']);
      print('2=');
      print(indexKr);
      if (indexKr == 1) {
        result['fields']['BV'] = widget.stateStatus['employeeSt'];
        result['fields']['BW'] = indexKr;
        result['fields']['BX'] = date;
      }


      Provider.of<IsLoading>(context, listen: false).setState(true);
      print(widget.stateStatus.length);
      print(widget.stateStatus);
      print(_dessertsDataSource.getSelected());
      print(_inputDateDropdown.valueText);
      Api.updateAll(result).then((value){
        if (value == true) {
          key.currentState.showSnackBar(new SnackBar(
            backgroundColor: Colors.green,
            content: new Text("Изменения сохранены!"),
          ));
          Provider.of<IsLoading>(context, listen: false).setState(false);
          _dessertsDataSource.unSelectedAll();
          setState(() {
            orders = Api.fetchOrdersAll(filter);
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
                    child: Text(value, style: TextStyle(fontSize:14)),
                  );
                }).toList(),
                onChanged: (String newValue) {
                  setState(() {
                    widget.stateStatus[stateName] = newValue;
                  });

                  _changeFilter(stateName);

                },
              )
            ]);
      },
    );
  }

  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = Text('Распределение заказов');

  final TextEditingController _filter = new TextEditingController();

  List filteredNames = new List();
  List names = new List(); // names we get from API

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar: AppBar(
        title: _appBarTitle,
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
          _getButtonSearch(),
          _getButtonRangeDate()
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
      future: orders,
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.hasData) {
          Order order;
          _orders = [];
          for (Map<String, dynamic> item in snapshot.data) {
            order = Order(item['A'], item['AE'], item['I'], (item['BO'])??'', item['BP']??'',  item['BQ']??'', item['BR']??'', item['BS']??'',
              item['BV']??'',item['BW']??'',item['BX']??'',);

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

  Widget _getButtonSearch() {
    return IconButton(
      icon: _searchIcon,
      onPressed: () {
        print('1=');
        setState(() {
          if (this._searchIcon.icon == Icons.search) {
            _dessertsDataSource.unSelectedAll();
            this._searchIcon = new Icon(Icons.close);
            this._appBarTitle = new TextField(
              controller: _filter,
              autofocus: true,
              decoration: new InputDecoration(
                  prefixIcon: new Icon(Icons.search),
                  hintText: 'Поиск...'
              ),
            );
          } else {
            this._searchIcon = new Icon(Icons.search);
            this._appBarTitle = Text('Распределение заказов' + ' '+_title);
            filteredNames = names;
            _dessertsDataSource.unSelectedAll();
            _filter.clear();
          }
        });
      },
    );
  }

  Widget _buildTable(_orders) {
    _dessertsDataSource = new DessertDataSource(_orders);
    _dessertsDataSource.addListener(_handleDataSourceChanged);
    if (_filter.text.indexOf(',') > 0) {
      _dessertsDataSource.selectedAll();
    }
    //_handleDataSourceChanged();
    return PaginatedDataTable(
      header: const Text('Заказы'),
      actions: _buildActions,
      rowsPerPage: _rowsPerPage,
      onRowsPerPageChanged: (int value) { setState(() { _rowsPerPage = value; }); },
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _sortAscending,
      headingRowHeight: 62,
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
          label: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Исполнитель'),
                _getDropDownState('ФИО', 'employeeStFilter', employeeSt),
              ]
          ),
          tooltip: 'The total amount of food energy in the given serving size.',
          numeric: false,
          onSort: (int columnIndex, bool ascending) => _sort<String>((Order d) => d.fio, columnIndex, ascending),
        ),
        DataColumn(
          label: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Статус'),
                _getDropDownState('Статус', 'statusStFilter', status),
              ]
          ),
          tooltip: 'The total amount of food energy in the given serving size.',
          numeric: false,
          onSort: (int columnIndex, bool ascending) => _sort<String>((Order d) => d.status, columnIndex, ascending),
        ),
        DataColumn(
          label: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Крой'),
              ]
          ),
          tooltip: 'The total amount of food energy in the given serving size.',
          numeric: false,
          onSort: (int columnIndex, bool ascending) => _sort<String>((Order d) => d.status, columnIndex, ascending),
        ),
        DataColumn(
          label: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Дата (изг.)'),
                _getDropDownDate('', 'dateIzgFilter'),
              ]
          ),
          tooltip: 'The total amount of food energy in the given serving size.',
          numeric: false,
          onSort: (int columnIndex, bool ascending) => _sort<String>((Order d) => d.dateIzg, columnIndex, ascending),
        ),
      ],
      source: _dessertsDataSource,
    );
  }

  void _changeFilter(stateName) {
    if (stateName == 'statusStFilter') {
      print(widget.stateStatus[stateName]);
      if (widget.stateStatus[stateName] == '') {
        setState(() {
          if (filter['BP']!=null) {
            filter.remove('BP');
          }
          if (filter.length == 0) {
            filter = _getBaseFilter();
          }
          orders = Api.fetchOrdersAll(filter);
        });
      } else {
        int index = status.indexOf(widget.stateStatus[stateName]);
        setState(() {
          filter['BP'] = statusKeys[index];
          orders = Api.fetchOrdersAll(filter);
        });
      }
    }
    if (stateName == 'employeeStFilter') {
      if (widget.stateStatus[stateName] == '') {
        setState(() {
          if (filter['BO']!=null) {
            filter.remove('BO');
          }
          if (filter.length == 0) {
            filter = {};
            filter = _getBaseFilter();
          }
          orders = Api.fetchOrdersAll(filter);
        });
      } else {

        setState(() {
          print(widget.stateStatus[stateName]);
          print(filter);
          filter['BO'] = widget.stateStatus[stateName];

          orders = Api.fetchOrdersAll(filter);
        });
      }
    }
  }

  void _changeFilterDate(stateName) {
    if (stateName == 'dateIzgFilter') {
      if (widget.stateStatus[stateName] == '') {
        setState(() {
          if (filter['BS'] != null) {
            filter.remove('BS');
          }
          if (filter.length == 0) {
            filter = _getBaseFilter();
          }
          orders = Api.fetchOrdersAll(filter);
        });
      } else {
        setState(() {
          if (filter['AE'] != null) {
            filter.remove('AE');
          }
          if (filter.length == 0) {
            filter = {};
          }
          filter['BS'] = widget.stateStatus[stateName];
          orders = Api.fetchOrdersAll(filter);
        });
      }
    }
  }

  Widget _dropDownDate(valueDate) {

    _inputDateDropdown = InputDateDropdown(
        labelText: 'Дата производства:',
        valueText: valueDate,
        //valueStyle: valueStyle,
        onPressed: () {
          _changeFilterDate(_inputDateDropdown.getDate());
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

  Widget _getDropDownDate(valueDate, stateName) {

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        _inputDateDropdownFilter = new InputDateDropdown(
            labelText: 'Дата производства:',
            valueText: widget.stateStatus[stateName] ?? valueDate,
            //valueStyle: valueStyle,
            onPressed: () {
              setState(() {
                widget.stateStatus[stateName] = _inputDateDropdownFilter.valueText;
              });
              _changeFilterDate(stateName);
            }
        );
        return Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              new Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  new Row(
                    //flex: 4,
                    children: [
                      _inputDateDropdownFilter,

                    ],
                  ),
                ],
              )
            ]);
      },
    );
  }

}



//Map<String, dynamic> stateStatus = {};

Widget _getExtDropDownState(value, stateName, employeeSt, callback) {
  return StatefulBuilder(
    builder: (BuildContext context, StateSetter setState) {
      return Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            new DropdownButton<String>(
              //value: stateStatus[stateName]??value,
              items: employeeSt.map<DropdownMenuItem<String>>((String value) {
                var i = employeeSt.indexOf(value);
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String newValue) {
                setState(() {
                  //stateStatus[stateName] = newValue;
                });
                if (callback != null) callback(stateName);
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
        DataCell(Text('${dessert.statusKr}')),

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
        _selectedCount--;
      }
    }
    notifyListeners();
  }

  selectedAll() {
    for (Order item in _desserts) {
      item.selected = true;
      _selectedCount ++;
    }
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
  Order(this.id, this.dateInproduce, this.name, this.fio, this.status, this.dateIzg, this.statusVt, this.statusOt, this.fioKr, this.statusKr, this.dateIzgKr);
  final String id;
  final String dateInproduce;
  final String name;
  final String fio;
  final String status;
  final String dateIzg;
  final String statusVt;
  final String statusOt;
  final String fioKr;
  final String statusKr;
  final String dateIzgKr;

  bool selected = false;
}