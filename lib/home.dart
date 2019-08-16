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
  dynamic dropdownValue;
  static DateTime now = new DateTime.now();
  DateFormat dateFormat = new DateFormat('dd.MM.yy');
  List <dynamic> range = [[0,6], [-1,5], [-2,4], [-3,3], [-4,2], [-5,7], [0,7]];
  int weekday = now.weekday;

  List<DateTime> _date = [new DateTime.now().add(Duration(days: 1)), new DateTime.now().add(Duration(days: 7))];
  Future<List<dynamic>> post;// = Future(null);//Api.fetchPost(null);
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


  @override
  _HomePageState() {
    print('init home _HomePageState');

  }
  didUpdateWidget(obj) {
    super.didUpdateWidget(obj);
    print('didUpdateWidget=');
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
      widget.filter['date'] = [widget.dateFormat.format(widget._date[0]),widget.dateFormat.format(widget._date[1])];
    });

    getUserType().then((value) => setType(value));
  }
  setType(value) {
    userType = value;
    if (userType == null) {
      Navigator.of(_ctx).pushReplacementNamed("/login");
    }
    if (userType == 30) {
      getUserFio().then((erg) => setFilterFio(erg));
    } else {
      setState(() {
        widget.post = Api.fetchPost(widget.filter);
      });
    }
    return userType;
  }

  setFilterFio(value) {
    print('userFio=');
    print(value);
    setState(() {
      widget.filter['fio'] = value;
      widget.post = Api.fetchPost(widget.filter);
    });
  }

  Future <List<dynamic>> isSetFilter() async {
    var filterPref = await getFilterPref();
    if (filterPref != null) {
      print('filterPref=');
      print(filterPref);
      return Api.fetchPost(filterPref);
    } else {
      return Api.fetchPost(widget.filter);
    }
    //var list = await Future.wait(getFilterPref());
  }




  //List<String> employee= ['все', 'социгашев', 'байталенко', 'литвин', 'андреев', 'буковский', 'пикущак'];
  List <String> employee= ['Все','Социгашев', 'Байталенко', 'Литвин', 'Андреев', 'Буковский', 'Пикущак', 'Иксаров', 'Кузьменко'];

  _buildDropDown(int userType) {
    if (userType == 10) {
      return DropdownButton<String>(
        value: (widget.dropdownValue != null) ? widget.dropdownValue :  '0',
        onChanged: (String newValue) {
          setState(() {
            widget.filter['fio'] = employee[int.parse(newValue)];
            widget.post = Api.fetchPost(widget.filter);
            widget.dropdownValue = newValue;
          });
        },
        items: employee.map<DropdownMenuItem<String>>((String value) {
          var i = employee.indexOf(value);
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

  DateTime picked = new DateTime.now();


  Future<Null> _selectDate() async {

    picked = await showDatePicker(
        context: context,
        //initialDate: widget._date,
        firstDate: new DateTime(1918),
        //locale: Locale('ru', 'RU'),
        lastDate: new DateTime.now());

    if (picked != null) {
      //print(picked);
      setState(() {
        //widget._date = picked;
       //widget.filter['date'] = '0'+picked.day.toString() + '.0'+ picked.month.toString() +'.'+ '19';
        //widget.post = Api.fetchPost(widget.filter);
        //_birthdayController.text = picked.toString();
      });
    }
  }

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
    filterOrders['date'] = item['headerValue'];
    filterOrders['range'] = widget._date;
    final result = await Navigator.push(
      _ctx,
      MaterialPageRoute(builder: (context) => OrdersPage(params: {'filter': filterOrders})),
    );

    if (result != null) {
      result['params']['filter'].remove('date');
      print(result);
      setState(() {
        widget.filter = result['params']['filter'];
        widget._date = result['params']['filter']['range'];
        widget.filter['date'] = [widget.dateFormat.format(widget._date[0]),widget.dateFormat.format(widget._date[1])];
        widget.post = Api.fetchPost(widget.filter);

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

          trailing: Text(item['coefPlSum'].toStringAsFixed(1) +'        '+item['coefSum'].toStringAsFixed(1) ),
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
            /*IconButton(
            icon: Icon(
              Icons.search,
              semanticLabel: 'search',
            ),
            onPressed: () {
              print('Search button');
            },
          ),*/
            IconButton(
              icon: Icon(
                Icons.tune,
                semanticLabel: 'filter',
              ),
              onPressed: () async {
                //_selectDate();
                final List<DateTime> picked = await DateRagePicker.showDatePicker(
                    context: context,
                    initialFirstDate: widget._date[0],
                    initialLastDate: widget._date[1],
                    firstDate: new DateTime(2015),
                    lastDate: new DateTime(2020)
                );
                if (picked != null && picked.length == 2) {
                  print(picked);
                  setState(() {
                    widget._date = picked;
                    var dateFormat = new DateFormat('dd.MM.yy');
                    print(dateFormat.format(picked[0]));
                    widget.filter['date'] =[dateFormat.format(picked[0]),dateFormat.format(picked[1])];

                    widget.post = Api.fetchPost(widget.filter);
                    //_birthdayController.text = picked.toString();
                  });
                }
                print('Filter button');
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

                            child: _buildDropDown(userType)
                        ),
                      ),

                    ]
                ),

                FutureBuilder<List<dynamic>>(
                  future: widget.post,
                  builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                    print('snapshot.hasData=');
                    print(snapshot.hasData);

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
                                print('refresh filter=');
                                print(widget.filter);
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
    if (userType == 10) {
      return ListTile(
        title: Text('Заказы'),
        onTap: () {
          Navigator.of(_ctx).pushReplacementNamed("/orders-all");
        },
      );
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
          return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Итого'),
                Text(totalArray['coefPlSum'].toStringAsFixed(1)+'           '+totalArray['coefSum'].toStringAsFixed(1))
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
    List namesValue = [];
    String dataValue = '';
    int index = 0;
    Decimal coefSum = Decimal.parse('0');
    Decimal coefPlSum = Decimal.parse('0');

    Decimal AA, G;
    Decimal coefSumTotal = Decimal.parse('0');
    Decimal coefPlSumTotal = Decimal.parse('0');

    dynamic item;
    for (var i = 0; i < data.length; i++) {
      item = data[i];
      if (index == 0) dataValue = item['AE'];
      if (item['V'] == '') {
        item['V'] = '0,0';
      }
      if (item['G'] == '') {
        item['G'] = '0,0';
      }
      if ((index!=0 && dataValue != item['AE']) || index == data.length-1) {
        if (index == data.length-1) {
          AA = Decimal.parse(item['V'].replaceAll(',','.'));
          G = Decimal.parse(item['G'].replaceAll(',','.'));

          coefSum = Decimal.parse(coefSum.toStringAsFixed(2)) + Decimal.parse(AA.toStringAsFixed(2));// double.parse(item['AA']);
          coefPlSum = Decimal.parse(coefPlSum.toStringAsFixed(2)) + Decimal.parse(G.toStringAsFixed(2));// double.parse(item['G']);

          namesValue.add(item);
        }
        listExpand.add({
          'headerValue': dataValue,
          'expandedValue': namesValue,
          'coefSum' : coefSum/Decimal.parse('7860'),
          'coefPlSum' : coefPlSum/Decimal.parse('7860'),

        });
        dataValue = item['AE'];
        coefSumTotal = coefSumTotal + coefSum;
        coefPlSumTotal = coefPlSumTotal + coefPlSum;

        coefSum = Decimal.parse('0');
        coefPlSum = Decimal.parse('0');

        namesValue = [];

      }


      AA = Decimal.parse(item['V'].replaceAll(',','.'));
      coefSum = Decimal.parse(coefSum.toStringAsFixed(2)) + Decimal.parse(AA.toStringAsFixed(2));// double.parse(item['AA']);
      G = Decimal.parse(item['G'].replaceAll(',','.'));
      coefPlSum = Decimal.parse(coefPlSum.toStringAsFixed(2)) + Decimal.parse(G.toStringAsFixed(2));// double.parse(item['AA']);
      namesValue.add(item);
      index++;
    }
    coefSumTotal = coefSumTotal/ Decimal.parse('7860');
    coefPlSumTotal = coefPlSumTotal/ Decimal.parse('7860');

    widget.coefSumTotal = coefSumTotal;
    widget.coefPlSumTotal = coefPlSumTotal;

    return {'listExpand': listExpand, 'coefSum': coefSumTotal, 'coefPlSum': coefPlSumTotal};
  }
}



Future<void> logout() async{
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.remove("auth_token");
  pref.remove("is_login");
  pref.remove("fio");
  pref.remove("type");
  pref.remove("filter");
}



getUserType() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  print('getUserType=');
  int getUserType = await preferences.getInt("type");
  print(getUserType);
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
}













