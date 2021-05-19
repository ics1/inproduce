// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'orders.dart';
import 'dart:io';
import 'package:decimal/decimal.dart';
import 'auth/auth.dart';
import 'api/api.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;

class Todo {
  final String title = '1';
  final String description = '2';

  //Todo(this.title, this.description);
}

class HomePage extends StatefulWidget {
  Map <String, String> dropdownValue = {};
  static DateTime now = new DateTime.now();
  DateFormat dateFormat = new DateFormat('dd.MM.yy');
  List <dynamic> range = [[0,6], [-1,5], [-2,4], [-3,3], [-4,2], [-5,7], [0,7]];
  int weekday = now.weekday;


  List<DateTime> _date = [new DateTime.now().add(Duration(days: 1)), new DateTime.now().add(Duration(days: 7))];


  Future<List<dynamic>> post;// = Future(null);//Api.fetchPost(null);
  List<String> employees = [];
  List<String> statuses = [];

  List<dynamic> departments;

  Map <String, dynamic> filter = {};
  Decimal coefSumTotal = Decimal.parse('0.0');
  Decimal coefPlSumTotal = Decimal.parse('0.0');

  dynamic params;

  HomePage({Key key,  this.params}) : super(key: key);

  @override

  _HomePageState createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {
  // TODO: Add a variable for Category (104)
  int userType;
  String userFio;
  BuildContext _ctx;
  String columnDate = 'AE';//BB
  String columnStatus = 'W';//BA
  String columnFio = 'Z';

  List <String> employee = [];//['Все','Социгашев', 'Байталенко', 'Литвин', 'Андреев', 'Буковский', 'Пикущак', 'Кузьменко', 'Ракицкий','Коцюк','Салыга',
    //'Завальнюк', 'Скрипник','Ткачук', 'Чеховский','Долгиер','Гаврилашенко','Резерв'];
  //List <String> employeeSt= ['Все','Василенко', 'Эклема', 'Лещинский', 'Царалунга', 'Бойко', 'Отрышко', 'Жарков', 'Ракицкий'];

  @override
  _HomePageState() {
    print('init home _HomePageState');

  }
  didUpdateWidget(obj) {
    super.didUpdateWidget(obj);
    print('HOME PAGE didUpdateWidget ==============');
    setStartFilter();
  }
  @override
  void initState() {
    super.initState();
    print('initstate home=');


    setStartFilter();


  }
  setStartFilter() {
    setState(() {
      widget._date = [new DateTime.now().add(Duration(days: widget.range[widget.weekday-1][0])), new DateTime.now().add(Duration(days: widget.range[widget.weekday-1][1]))];
    });

    getEmployees('1').then((value){

      if (value == null) {
        setEmployees('1').then((valueSet) {
          widget.employees = valueSet;
          setStatuses().then((valueSetSt) {
            widget.statuses = valueSetSt;
            getUserType().then((value) => setType(value));
          });

        });

      } else {
        widget.employees = value;
        getStatuses().then((valueSetSt) {
          widget.statuses = valueSetSt;
        });
        getUserType().then((value) => setType(value));
      }
    });



    //getUserType().then((value) => setType(value));
  }

//  setEmployeeList() {
//    //employee = getEmployees();
//    //employee = erg;
//    employee.add('Все');
//    getEmployees().then((erg) {
//      //employee = erg;
//    });
//  }

  setType(value) {
    userType = value;


    if (userType == null) {
      Navigator.of(_ctx).pushReplacementNamed("/login");
    }
    if ([10,0,80,90].contains(userType)) {
      setState(() {
        widget.filter[columnDate] = {'>=':widget.dateFormat.format(widget._date[0]), '<=':widget.dateFormat.format(widget._date[1])};
        widget.post = Api.fetchOrdersAll(widget.filter);
      });
    } else {
      if ([40].contains(userType)) {
        Navigator.of(_ctx).pushReplacementNamed("/orders-stolyarka");
        return null;
//        columnDate = 'BB';
//        columnStatus = 'BA';
//        columnFio = 'AZ';
      }
      if ([50,51,60].contains(userType)) {
        Navigator.of(_ctx).pushReplacementNamed("/orders-all");
        return null;
      }
      if ([70].contains(userType)) {
        Navigator.of(_ctx).pushReplacementNamed("/orders-paralon");
        return null;
      }
      setState(() {
        widget.filter[columnDate] = {'>=':widget.dateFormat.format(widget._date[0]), '<=':widget.dateFormat.format(widget._date[1])};
      });
      getUserFio().then((erg) => setFilterFio(erg));
    }
    return userType;
  }

  setFilterFio(value) {
    setState(() {
      widget.filter[columnFio] = value;
      widget.post = Api.fetchOrdersAll(widget.filter);
    });
  }

  Future <List<dynamic>> isSetFilter() async {
    var filterPref = await getFilterPref();
    if (filterPref != null) {
      return Api.fetchOrdersAll(filterPref);
    } else {
      return Api.fetchOrdersAll(widget.filter);
    }
  }




  //List<String> employee= ['все', 'социгашев', 'байталенко', 'литвин', 'андреев', 'буковский', 'пикущак'];




  _buildDropDown(int userType, List<String> list, stateName) {

    if (userType == 10 || userType == 0) {
      return DropdownButton<String>(
        value: (widget.dropdownValue[stateName] != null) ? widget.dropdownValue[stateName] :  '0',
        onChanged: (String newValue) {
          setState(() {
            if(list[int.parse(newValue)] == '') {
              widget.filter.remove(columnFio);
            } else {
              widget.filter[columnFio] = list[int.parse(newValue)];
            }
            widget.post = Api.fetchOrdersAll(widget.filter);
            widget.dropdownValue[stateName] = newValue;
          });
        },
        items: list.map<DropdownMenuItem<String>>((String value) {
          var i = list.indexOf(value);
          return DropdownMenuItem<String>(
            value: i.toString(),
            child: Text(value),
          );
        }).toList(),
      );
    } else { // Just Divider with zero Height xD
      return Divider(color: Colors.white, height: 0.0);
    }
  }

  _buildDropDownFuture(int userType, Future<List<dynamic>> lists, stateName, departmentId ) {
    if (userType == 10 || userType == 0) {
      return FutureBuilder<List<dynamic>>(
        future: lists,
        builder: (context, snapshot) {

          if (snapshot.hasData) {
            List<String> list = [];
            list.add('Все');
            snapshot.data.forEach((row) {
              if (departmentId == row['department_id']) {
                list.add(row['name']);
              }
            });
            employee = list;
            return DropdownButton<String>(
              value: (widget.dropdownValue[stateName] != null) ? widget.dropdownValue[stateName] :  '0',
              onChanged: (String newValue) {
                setState(() {
                  if(list[int.parse(newValue)] == 'Все') {
                    widget.filter.remove(columnFio);
                  } else {
                    widget.filter[columnFio] = list[int.parse(newValue)];
                  }
                  widget.post = Api.fetchOrdersAll(widget.filter);
                  widget.dropdownValue[stateName] = newValue;
                });
              },
              items: list.map<DropdownMenuItem<String>>((String value) {
                var i = list.indexOf(value);
                return DropdownMenuItem<String>(
                  value: i.toString(),
                  child: Text(value),
                );
              }).toList(),
            );;

          }
          // By default, show a loading spinner.
          return Center();//Center( child:CircularProgressIndicator());
        },
      );
    } else { // Just Divider with zero Height xD
      return Divider(color: Colors.white, height: 0.0);
    }

  }

  DateTime picked = new DateTime.now();

  Future<bool> _onBackPressed() async {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Выйти из приложения?'),
        content: new Text(''),
        actions: <Widget>[
          new GestureDetector(
            child: FlatButton(
              child: Text('Нет'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
          ),
          new GestureDetector(
            child: FlatButton(
              child: Text('Да'),
              onPressed: () {
                pops();
                //exit(0);
              },
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  static Future<void> pops()  async {
     await SystemChannels.platform.invokeMethod<void>('SystemNavigator.pop');

  }

  _navigateOrders(BuildContext context, item) async {
    Map<String, dynamic> filterOrders = {};
    if (widget.filter != null) filterOrders = widget.filter;
    filterOrders[columnDate] = item['headerValue'];
    //filterOrders[columnDate] = widget._date;
    final result = await Navigator.push(
      _ctx,
      MaterialPageRoute(builder: (context) => OrdersPage(params: {'filter': filterOrders, 'dateValue' : item['headerValue'], 'range' : widget._date} )),
    );

    if (result != null) {
      result['params']['filter'].remove(columnDate);
      setState(() {
        widget.filter = result['params']['filter'];
        widget._date = result['params']['range'];
        widget.filter[columnDate] = {'>=':widget.dateFormat.format(widget._date[0]), '<=':widget.dateFormat.format(widget._date[1])};
        widget.post = Api.fetchOrdersAll(widget.filter);

      });

    }
  }

  Widget build(BuildContext context) {
    _ctx = context;
    dynamic sum =0;
    // TODO: Return an AsymmetricView (104)
    // TODO: Pass Category variable to AsymmetricView (104)

    final ThemeData theme = Theme.of(context);
    final NumberFormat formatter = NumberFormat.simpleCurrency(
        locale: Localizations.localeOf(context).toString());

    Widget _buildRow(item, index) {

      String dayWeek = DateFormat('MEd','ru').format(DateFormat('dd.MM.yy').parse(item['headerValue']));
      return ListTile(

          trailing: Text(item['coefMoneySum'].toStringAsFixed(1) +'    '+item['coefShvSum'].toStringAsFixed(1) +'    '+item['coefTimeSum'].toStringAsFixed(1) +'    '+item['coefPlSum'].toStringAsFixed(1) +'    '+item['coefSum'].toStringAsFixed(1) ),
          title: Text(dayWeek, style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black)),
          enabled: true,
          onTap: () {
            setFilterPref(widget.filter);
            _navigateOrders(_ctx, item);
          }
        //isThreeLine: false,

      );
    }


    Widget _buildList(item) {
      return ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(8.0),
          shrinkWrap: true,
          itemCount: item.length,
          itemBuilder: (BuildContext context, int index) {

            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    //padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 2.0),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 1.0, color: Color(0xFFFFDFDFDF)),
                      ),
                    ),
                    child: _buildRow(item[index], index),
                  ),

                ]
            );
          }
      );
    }
    dynamic coefSumTotal1 = 0;

    return new WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,

          title: Text('Greensofa'),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.refresh,
                semanticLabel: 'refresh',
              ),
              onPressed: () {
                setState(() {
                  widget.post = Api.fetchOrdersAll(widget.filter);
                });
              },
            ),
            IconButton(
              icon: Icon(
                Icons.tune,
                semanticLabel: 'filter',
              ),
              onPressed: () async {
                if ([80, 90].contains(userType)) {
                  return;
                }
                //_selectDate();
                final List<DateTime> picked = await DateRagePicker.showDatePicker(
                    context: context,
                    initialFirstDate: widget._date[0],
                    initialLastDate: widget._date[1],
                    firstDate: new DateTime(2015),
                    lastDate: new DateTime(2030)
                );
                if (picked != null && picked.length == 2) {
                  setState(() {
                    widget._date = picked;
                    widget.filter[columnDate] = {'>=':widget.dateFormat.format(picked[0]), '<=':widget.dateFormat.format(picked[1])};
                    widget.post = Api.fetchOrdersAll(widget.filter);
                  });
                }

              },
            ),
          ],
        ),

        body: SingleChildScrollView(
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                    children: [
                      Expanded(
                        child: Container(
                          //padding: new EdgeInsets.only(left: 0.0, bottom: 0, top: 10.0),
                            margin: new EdgeInsets.only(left: 15.0, bottom: 0, top: 10.0, right: 15.0),

                            child: _buildDropDown(userType, widget.employees, 'employeeState')
                        ),
                      ),

                    ]
                ),

                FutureBuilder<List<dynamic>>(
                  future: widget.post,
                  builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                    if (snapshot.hasData) {
                      dynamic totalArray = _getArray(snapshot.data);
                      return Container(
                          child: _buildList(totalArray['listExpand'])//_buildPanel(listExpand),
                      );
                    } else if (snapshot.connectionState != ConnectionState.waiting) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                          return Column(children: [
                            Text("Нет соединения с интернетом!"),
                            FlatButton(
                              color: Colors.blue,
                              textColor: Colors.white,
                              disabledColor: Colors.grey,
                              disabledTextColor: Colors.black,
                              padding: EdgeInsets.all(8.0),
                              splashColor: Colors.blueAccent,
                              onPressed: () {
                                setStartFilter();
                              },
                              child: Text(
                                "Обновить",
                              ),
                            )
                          ]);
                          //return Text('Press button to start.');
                        case ConnectionState.active:
                        case ConnectionState.waiting:
                          return Text('Awaiting result...');
                        case ConnectionState.done:
                          if (snapshot.hasError)
                            return Text('Error: ${snapshot.error}');
                      }

                    }
                    return Center( child:CircularProgressIndicator());
                  },
                ),
              ]
          ),
        ),
        drawer: Drawer(
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the drawer if there isn't enough vertical
          // space to fit everything.
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: new Image.asset(
                  'assets/logo-green.png',
                  fit: BoxFit.fitWidth,
                  width: 210.0,
                  height: 40.0,
                  //fit: BoxFit.cover,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              _getMenuDrawer(),
              ListTile(
                title: Text('Выход'),
                onTap: () {
                  logout();
                  Navigator.of(_ctx).pushReplacementNamed("/login");
                },
              ),
            ],
          ),
        ),

        bottomNavigationBar: BottomAppBar(
          child: Container(
            height: 50.0,
            padding: new EdgeInsets.only(left: 25.0, bottom: 5.0, top: 5.0, right: 25.0),
            child: _getTotal(),
          ),
        ),
        resizeToAvoidBottomInset: false,
      ),
    );

  }

  Widget _getMenuDrawer() {
    if (userType == 10 || userType == 0) {
      return Column( children: <Widget>[
        ListTile(
            title: Text('Обивка план'),
            onTap: () {
              Navigator.of(_ctx).pushReplacementNamed("/orders-upholstery-plan");
            }
        ),
        ListTile(
            title: Text('Швейка'),
            onTap: () {
              Navigator.of(_ctx).pushReplacementNamed("/orders-all");
            }
        ),
        ListTile(
            title: Text('Швейка план'),
            onTap: () {
              Navigator.of(_ctx).pushReplacementNamed("/orders-sewing-plan");
            }
        ),
        ListTile(
            title: Text('Паралонка'),
            onTap: () {
              Navigator.of(_ctx).pushReplacementNamed("/orders-paralon");
            }
        ),
        ListTile(
            title: Text('Столярка New'),
            onTap: () {
              Navigator.of(_ctx).pushReplacementNamed("/orders-stolyarka");
            }
        ),
        ListTile(
          title: Text('Столярка'),
          onTap: () {
            Navigator.of(_ctx).pushReplacementNamed("/orders-table");
          },
        ),
        ListTile(
            title: Text('Столярка план'),
            onTap: () {
              Navigator.of(_ctx).pushReplacementNamed("/orders-carpenter-plan");
            }
        ),
        ListTile(
          title: Text('Распил'),
          onTap: () {
            Navigator.of(_ctx).pushReplacementNamed("/orders-sawcut");
          },
        ),
        ListTile(
            title: Text('Посещения'),
            onTap: () {
              Navigator.of(_ctx).pushReplacementNamed("/visits");
            }
        ),
        ListTile(
            title: Text('Комментарии'),
            onTap: () {
              Navigator.of(_ctx).pushReplacementNamed("/comments");
            }
        ),

      ]);
    } else {
      return Center();
    }
  }

  Widget  _getTotal() {

    return FutureBuilder<List<dynamic>>(
      future: widget.post,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          dynamic totalArray = _getArray(snapshot.data);
          String pribil = '';
          if (userType == 0) {
            pribil = totalArray['pribil'].toStringAsFixed(1);
          }
          return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Итого: '+pribil),
                Text(totalArray['coefMoneySum'].toStringAsFixed(1)+'   '+totalArray['coefShvSum'].toStringAsFixed(1)+'   '+totalArray['coefTimeSum'].toStringAsFixed(1)+'   '+totalArray['coefPlSum'].toStringAsFixed(1)+'   '+totalArray['coefSum'].toStringAsFixed(1)),
              ]
          );

        }
        // By default, show a loading spinner.
        return Center();//Center( child:CircularProgressIndicator());
      },
    );
  }

  dynamic _getArray(data) {
    List listExpand = [];

    int index = 0;
    Decimal AB, AC, AG, AJ, AE;
    Decimal coefSumTotal = Decimal.parse('0');
    Decimal coefPlSumTotal = Decimal.parse('0');
    Decimal coefTimeSumTotal = Decimal.parse('0');
    Decimal coefShvSumTotal = Decimal.parse('0');
    Decimal coefMoneySumTotal = Decimal.parse('0');



    dynamic item;
    Map <String, dynamic> dataDate = {};
    String currentDate;
    //print(widget.filter);
    for (var i = 0; i < data.length; i++) {
      //print(data[i]['AE']);
      item = data[i];
      currentDate = item[columnDate];
      if (currentDate == null || currentDate=='') {
        continue;
      }
      //new
      if (dataDate[currentDate] == null) {
        dataDate[currentDate] = {
          'coefSum' : Decimal.parse('0'),
          'coefPlSum' : Decimal.parse('0'),
          'coefTimeSum' : Decimal.parse('0'),
          'coefShvSum' : Decimal.parse('0'),
          'coefMoneySum' : Decimal.parse('0'),
          'headerValue' : currentDate
        };
      }

      if (item['AB'] == '' || item['AB'] == null) {
        item['AB'] = '0,0';
      }
      if (item['AA'] == '' || item['AA'] == null) {
        item['AA'] = '0,0';
      }
      if (item['AG'] == '' || item['AG'] == null) {
        item['AG'] = '0,0';
      }
      if (item['AJ'] == '' || item['AJ'] == null) {
        item['AJ'] = '0,0';
      }
      if (item['AO'] == '' || item['AO'] == null) {
        item['AO'] = '0,0';
      }

      AB = Decimal.parse(item['AB'].replaceAll(',','.'));
      AC = Decimal.parse(item['AA'].replaceAll(',','.'));
      AG = Decimal.parse(item['AG'].replaceAll(',','.'));
      AJ = Decimal.parse(item['AJ'].replaceAll(',','.'));
      AE = Decimal.parse(item['AO'].replaceAll(',','.'));


      dataDate[currentDate]['coefSum'] += (item[columnStatus] == '1') ? Decimal.parse(AC.toStringAsFixed(2)) : Decimal.parse('0');
      dataDate[currentDate]['coefPlSum'] += Decimal.parse(AC.toStringAsFixed(2));
      dataDate[currentDate]['coefTimeSum'] += Decimal.parse(AG.toStringAsFixed(2));
      dataDate[currentDate]['coefShvSum'] += Decimal.parse(AJ.toStringAsFixed(2));
      dataDate[currentDate]['coefMoneySum'] += Decimal.parse(AE.toStringAsFixed(2));

      //print(currentDate);
      //print(item[columnStatus]);
      //print(dataDate[currentDate]['coefSum'] );
      coefSumTotal = coefSumTotal + Decimal.parse(AB.toStringAsFixed(2));
      coefPlSumTotal = coefPlSumTotal + Decimal.parse(AC.toStringAsFixed(2));
      coefTimeSumTotal = coefTimeSumTotal + Decimal.parse(AG.toStringAsFixed(2));
      coefShvSumTotal = coefShvSumTotal + Decimal.parse(AJ.toStringAsFixed(2));
      coefMoneySumTotal = coefMoneySumTotal + Decimal.parse(AE.toStringAsFixed(2));


      index++;
    }

    widget.coefSumTotal = coefSumTotal;
    widget.coefPlSumTotal = coefPlSumTotal;
    int sandays = 0;
    String weekday;
    dataDate.forEach((i, value) {
      listExpand.add(value);

      weekday = DateFormat('EEEE','ru').format(DateFormat('dd.MM.yy').parse(value['headerValue']));

      if (weekday == 'суббота' && weekday != 'воскресенье') {
        sandays++;
      }

    });

    Decimal Pribil = Decimal.parse('0');
    //DateFormat('dd.MM.yy').parse(listExpand[0]['headerValue']);
    if (listExpand.length > 0) {
      List arrayDate = listExpand[0]['headerValue'].split('.');
      int daysWork = daysWorkInMonth(
          int.parse(arrayDate[1]), int.parse(arrayDate[2]));
      //daysWork = daysWork + sandays;


      Decimal Oborot = coefMoneySumTotal * Decimal.parse('7860'); //2090760

      Decimal Sebestoimost = Oborot * Decimal.parse('0.53'); //1108102

      Decimal Zarplata = Oborot * Decimal.parse('27') / Decimal.parse('100'); //564300

      Decimal ZatratiDen = Decimal.parse('400000') /
          Decimal.parse(daysWork.toString());

      Decimal ZatratiPeriod = ZatratiDen *
          Decimal.parse(listExpand.length.toString());
      Decimal DividentiDen = Decimal.parse('150000') /
          Decimal.parse(daysWork.toString());
      Decimal DividentiPeriod = DividentiDen *
          Decimal.parse(listExpand.length.toString());

      Pribil = Sebestoimost - Zarplata - ZatratiPeriod -
          DividentiPeriod; //1108102-564300-400000-150000=
    }


    listExpand.sort((a, b) => DateFormat('dd.MM.yy').parse(a['headerValue']).compareTo(DateFormat('dd.MM.yy').parse(b['headerValue'])));
    return {'listExpand': listExpand, 'coefMoneySum': coefMoneySumTotal, 'coefShvSum': coefShvSumTotal, 'coefSum': coefSumTotal, 'coefPlSum': coefPlSumTotal, 'coefTimeSum': coefTimeSumTotal,'pribil' : Pribil};
  }
}



Future<void> logout() async{
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.remove("auth_token");
  pref.remove("is_login");
  pref.remove("fio");
  pref.remove("type");
  pref.remove("filter");
  pref.remove("employees_1");
  pref.remove("statuses");
}



getUserType() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  int getUserType = await preferences.getInt("type");
  return getUserType;
}

getUserFio() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  String getUserFio = await preferences.getString("fio");
  return getUserFio;
}

getFilterPref() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  String getFilter = await preferences.getString("filter");
  return getFilter;
}

Future<void> setFilterPref(dynamic filter) async{
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setString("filter", filter.toString());
  //pref.remove('employees');
}

Future<List<String>> setEmployees(departmentId) async{
  List<dynamic> futureEmployees;
  SharedPreferences pref = await SharedPreferences.getInstance();

  List<String> employees = pref.getStringList("employees_"+departmentId);
  Map<String,List<String>> employeesMap = {};

  if (employees == null) {

    futureEmployees = await Api.fetch('accounting/employees', {'status':'1'}, 'name');
    List<String> words;
    futureEmployees.forEach((row) {
      if (!employeesMap.containsKey(row['department_id'].toString())) {
        employeesMap[row['department_id'].toString()] = [];
        employeesMap[row['department_id'].toString()].add('');
      }
      words = row['name'].split(' ');
      employeesMap[row['department_id'].toString()].add(words[0]);
      //employees.add(row['name']);
    });

    employeesMap.forEach((key, row ) {
      pref.setStringList("employees_"+key, row);
    });

  }
  return employeesMap[departmentId];
}

getEmployees(departmentId) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  //preferences.remove("employees_"+departmentId);
  List<String> employees = preferences.getStringList("employees_"+departmentId);
  return employees;
}

Future<List<String>> setStatuses() async{
  List<dynamic> futureStatuses;
  SharedPreferences pref = await SharedPreferences.getInstance();
  List<String> statuses = pref.getStringList("statuses");
  if (statuses == null) {
    statuses = [];
    futureStatuses = await Api.fetch('accounting/order-work-statuses', [], 'id');

    statuses.add('');
    futureStatuses.forEach((row) {
      statuses.add('');
    });
    futureStatuses.forEach((row) {
      statuses[row['id']] = row['name'];
    });
    pref.setStringList("statuses", statuses);
  }
  return statuses;
}

getStatuses() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  //preferences.remove("statuses");
  List<String> statuses = preferences.getStringList("statuses");
  return statuses;
}

daysInMonth(int monthNum, int year)
{

  List<int> monthLength = new List(12);

  monthLength[0] = 31;
  monthLength[2] = 31;
  monthLength[4] = 31;
  monthLength[6] = 31;
  monthLength[7] = 31;
  monthLength[9] = 31;
  monthLength[11] = 31;
  monthLength[3] = 30;
  monthLength[8] = 30;
  monthLength[5] = 30;
  monthLength[10] = 30;

  if (leapYear(year) == true)
    monthLength[1] = 29;
  else
    monthLength[1] = 28;

  return monthLength[monthNum -1];
}

daysWorkInMonth(int monthNum, int year)
{
  String dayWeek;
  int count = 0;
  int days = daysInMonth(monthNum, year);
  for (var i=0; i<days; i++) {
    dayWeek = DateFormat('EEEE','ru').format(DateFormat('dd.MM.yy').parse((i+1).toString()+'.'+monthNum.toString()+'.'+year.toString()));
    if (dayWeek != 'суббота' && dayWeek != 'воскресенье') {
      count++;
    }
  }
  return count;
}

leapYear(int year)
{
  bool leapYear = false;

  bool leap =  ((year % 100 == 0) && (year % 400 != 0));
  if (leap == true)
    leapYear = false;
  else if (year % 4 == 0)
    leapYear = true;


  return leapYear;
}













