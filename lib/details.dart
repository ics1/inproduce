import 'package:flutter/material.dart';
import 'api/api.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';


class DetailsPage extends StatefulWidget {
  final dynamic params;

  bool changed = false;
  String dropdownValue;
  String dropdownObFio, dropdownStFio;
  Map<String, dynamic> stateStatus = {};
  String paralonCargiFio,
      paralonCargiStatus,
      obivkaCargiFio,
      obivkaCargiStatus,
      paralonIzgFio,
      paralonIzgStatus,
      obivkaIzgiFio,
      obivkaIzgStatus;
  DateTime _dateInproduce = DateTime.now();
  //Stream <bool> isLoading;
  Future<bool> isLoading;

  DetailsPage({Key key, @required this.params}) : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();

}

class Item {
  Item({
    this.expandedValue,
    this.headerValue,
    this.isExpanded = false,
  });

  String expandedValue;
  String headerValue;
  bool isExpanded;
}

class _DetailsPageState extends State<DetailsPage> {
  int index = 0;
  BuildContext _ctx;
  List <String> status = ['','Наряд выдан', 'Взят в работу', 'Остановлен', 'Выполнен'];
  List <String> statusKeys = ['','4', '2', '3', '1'];
  List <String> employeeOb= ['','Социгашев', 'Байталенко', 'Литвин', 'Андреев', 'Буковский', 'Пикущак', 'Иксаров', 'Кузьменко', 'Ракицкий'];
  List <String> employeeSt= ['','Василенко', 'Эклема', 'Лещинский', 'Царалунга', 'Бойко'];
  List <String> employeeSv= ['','Плукчи', 'Социгашева', 'Агарукова', 'Овчарская', 'Логинов'];
  DateFormat dateFormat;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  final key = new GlobalKey<ScaffoldState>();
  List<bool> _data = [true, false, false, false];
  Widget _buildPanel(product) {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _data[index] = !isExpanded;
        });
      },
      children: [

        ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text('Описание'),
            );
          },
          body: _buildDescription(product),
          isExpanded: _data[0],
        ),
        ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text('Паралонка'),
            );
          },
          body: _buildParalon(product),
          isExpanded: _data[1],
        ),
        /*ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text('Обивка'),
            );
          },
          body: _buildObivka(product),
          isExpanded: _data[2],
        ),*/
        ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text('Столярка'),
            );
          },
          body: _buildStolarka(product),
          isExpanded: _data[2],
        ),
        ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text('Швейка'),
            );
          },
          body: _buildShveika(product),
          isExpanded: _data[3],
        ),
      ],

    );
  }

  Widget _buildShveika(product) {
    print('1=');
    print((widget.stateStatus['shveikaVtyagkaStatus']!=null) ? widget.stateStatus['shveikaVtyagkaStatus'] : (product['BQ']=='1' ? true : false));
    return  Container(
        padding: new EdgeInsets.only(left: 10.0, bottom: 10.0, top: 10.0, right: 10.0),
        child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Пошив", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), softWrap: true),
              _dropDownEmployee(product['id'], "Исполнитель: ", 'shveikaPoshivFio', product['BO'], 'BO', employeeSv),
              _dropDownStatus(product['id'], "Статус: ", 'shveikaPoshivStatus', product['BP'], 'BP', ['BS','BT','BU'] ),

              Center(
                child:
                  CheckboxListTile(
                    title: const Text('Втяжка'),
                    value: (widget.stateStatus['shveikaVtyagkaStatus']!=null) ? widget.stateStatus['shveikaVtyagkaStatus'] : (product['BQ']=='1' ? true : false),
                    onChanged: (bool value) {
                      String valueStatus = (value) ? '1' : '0';
                      changeStatus(product['id'], {'BQ' : valueStatus }).then((value) {
                        if (value) {
                          setState(() {
                            widget.stateStatus['shveikaVtyagkaStatus'] = value;
                            widget.changed = true;
                          });
                        }
                      });
                    },
                  ),


              ),
              Center(
                child:
                CheckboxListTile(
                  title: const Text('Отстрочка'),
                  value: (widget.stateStatus['shveikaOtstrochaStatus']!=null) ? widget.stateStatus['shveikaOtstrochaStatus'] : (product['BR']=='1' ? true : false),
                  onChanged: (bool value) {
                    String valueStatus = (value) ? '1' : '0';
                    changeStatus(product['id'], {'BR' : valueStatus }).then((value) {
                      if (value) {
                        setState(() {
                          widget.stateStatus['shveikaOtstrochaStatus'] = value;
                          widget.changed = true;
                        });
                      }
                    });
                  },
                  //secondary: const Icon(Icons.hourglass_empty),
                ),
              ),
              Text("Крой", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), softWrap: true),
              _dropDownEmployee(product['id'], "Исполнитель: ", 'shveikaKroiFio', product['BV'], 'BV', employeeSv),
              _dropDownStatus(product['id'], "Статус: ", 'shveikaKroiStatus', product['BW'], 'BW', ['BX','BY','BZ'] ),
            ]
        )
    );
  }

  Widget _buildStolarka(product) {
    return  Container(
        padding: new EdgeInsets.only(left: 10.0, bottom: 10.0, top: 10.0, right: 10.0),
        child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Царги", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), softWrap: true),
              _dropDownEmployee(product['id'], "Исполнитель: ", 'stolarkaIzgFio', product['BE'], 'BE', employeeSt),
              _dropDownStatus(product['id'], "Статус: ", 'stolarkaIzgStatus', product['BF'], 'BF', ['BG','BH','BI'] ),
              Text("Изголовье", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), softWrap: true),
              _dropDownEmployee(product['id'], "Исполнитель: ", 'stolarkaCargiFio', product['AZ'], 'AZ', employeeSt),
              _dropDownStatus(product['id'], "Статус: ", 'stolarkaCargiStatus', product['BA'], 'BA', ['BB','BC','BD'] ),
            ]
        )
    );
  }

  Widget _buildObivka(product) {
    return  Container(
        padding: new EdgeInsets.only(left: 10.0, bottom: 10.0, top: 10.0, right: 10.0),
        child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Изголовье", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), softWrap: true),
              _dropDownEmployee(product['id'], "Исполнитель: ", 'obivkaIzgiFio', product['Z'], 'Z', employeeOb),
              _dropDownStatus(product['id'], "Статус: ", 'obivkaIzgStatus', product['W'], 'W', ['AH','AI','AJ'] ),
              Text("Царги", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), softWrap: true),
              _dropDownEmployee(product['id'], "Исполнитель: ", 'obivkaCargiFio', product['AK'], 'AK', employeeOb),
              _dropDownStatus(product['id'], "Статус: ", 'obivkaCargiStatus', product['AL'], 'AL', ['AM','AN','AO'] ),
            ]
        )
    );
  }

  Widget _buildParalon(product) {
    return  Container(
        padding: new EdgeInsets.only(left: 10.0, bottom: 10.0, top: 10.0, right: 10.0),
        child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Царги", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), softWrap: true),
              _dropDownEmployee(product['id'], "Исполнитель: ", 'paralonCargiFio', product['AU'], 'AU', employeeOb),
              _dropDownStatus(product['id'], "Статус: ", 'paralonCargiStatus', product['AV'], 'AV', ['AW','AX','AY']),
              Text("Изголовье", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), softWrap: true),
              _dropDownEmployee(product['id'], "Исполнитель: ", 'paralonIzgFio', product['AP'], 'AP', employeeOb),
              _dropDownStatus(product['id'], "Статус: ", 'paralonIzgStatus', product['AQ'], 'AQ', ['AR','AS','AT'] ),
            ]
        )
    );
  }

  Widget _buildDescription(product) {
    return Container(
        padding: new EdgeInsets.only(left: 10.0, bottom: 0.0, top: 0.0, right: 10.0),
        child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            //mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
                Row(
                    children:[
                      Flexible(
                        child: Container(
                            padding: new EdgeInsets.only(left: 0.0, bottom: 0.0, top: 0.0, right: 0.0),
                            child: Text(product['I'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),)
                        ),
                      ),
                    ]
                ),
                Container(
                    padding: new EdgeInsets.only(left: 10.0, bottom: 0.0, top: 0.0, right: 10.0),
                    child: _dropDownDate(widget.params['AE']),
                ),

                _rowParam("Дата: ", product['D']),
                //_rowParam("Дата производства: ", product['AE']),

                _rowParam("Толщина спинки: ", ''),
                _rowParam("Тип: ", product['E']),
                _rowParam("Материал: ", product['L']),
                _rowParam("Ножки: ", product['N']),
                _rowParam("Пуговицы: ", product['O']),
                _rowParam("Отстрочка: ", product['P']),
                _rowParam("Пружина: ", product['Q']),
                _rowParam("Механизм: ", product['R']),
                _rowParam("Номер клиента: ", product['S']),
                Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:[
                      Container(
                        padding: new EdgeInsets.only(left: 10.0, bottom: 5.0, top: 5.0, right: 10.0),
                        child: Text("Описание: ", style: TextStyle(color: Colors.black)),
                      ),
                    ]
                ),
                Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:[
                      Flexible(
                        child: Container(
                          padding: new EdgeInsets.only(left: 10.0, bottom: 5.0, top: 5.0, right: 10.0),
                          child: Text(product['T'].toString(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), softWrap: true),
                        ),
                      ),
                    ]
                ),
                _buildObivka(product)
            ]
        )
    );
  }

  Widget build(BuildContext context) {
    _ctx = context;
    Map <String, dynamic> product = widget.params;
    //dynamic currentFilter = widget.params['filter'];
    return Scaffold(
      key: key,

      appBar: AppBar(
        title: Text(product['A']),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            semanticLabel: 'arrow_back',
          ),
          onPressed: () {
            Navigator.pop(_ctx, { 'params' : product , 'changed': widget.changed});
            /*Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OrdersPage(params: product)),
            );*/
          },
        ),
        bottom: PreferredSize(
            preferredSize: Size(double.infinity, 4.0),
            child: SizedBox(
                height: 4.0,
                child: ProgressBar(widget.isLoading)
            )
        ),
      ),
      body: SingleChildScrollView(
        //margin: new EdgeInsets.only(left: 5.0, bottom: 10.0, top: 10.0, right: 5.0),
        child: Container(
            //padding: new EdgeInsets.only(left: 10.0, bottom: 10.0, top: 10.0, right: 10.0),
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              //mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPanel(product),
              ],
            ),
        ),
      ),
    );
  }


  Widget _rowParam(title, value) {
    return Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:[
          Container(
            padding: new EdgeInsets.only(left: 10.0, bottom: 5.0, top: 5.0, right: 10.0),
            child: Text(title, style: TextStyle(color: Colors.black)),
          ),
          Container(
            padding: new EdgeInsets.only(left: 10.0, bottom: 5.0, top: 5.0, right: 10.0),
            child:  Text(value.toString(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          ),
        ]
    );
  }

  Widget _dropDownEmployee(productId, title, stateName, productValue, column, List<String> listEmployee) {

    return Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:[
          Container(
              padding: new EdgeInsets.only(left: 10.0, bottom: 5.0, top: 5.0, right: 10.0),
              child: Text(title, style: TextStyle(color: Colors.black))
          ),
          Container(
            padding: new EdgeInsets.only(left: 10.0, bottom: 5.0, top: 0, right: 10.0),
            child: DropdownButton<String>(
              value: (widget.stateStatus[stateName] != null) ? widget.stateStatus[stateName] : productValue,
              onChanged: (String newValue) {
                _changeData(productId, stateName, column, newValue);
              },
              items: listEmployee.map<DropdownMenuItem<String>>((String value) {
                var i = listEmployee.indexOf(value);
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ]
    );
  }

  Widget _dropDownStatus(productId, title, stateName, productStatusValue, column, timeColumns ) {
    return Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:[
          Container(
            padding: new EdgeInsets.only(left: 10.0, bottom: 5.0, top: 5.0, right: 10.0),
            child: Column( children: [
              Text(title, style: TextStyle(color: Colors.black)),
            ])
          ),
          Container(
            padding: new EdgeInsets.only(left: 10.0, bottom: 5.0, top: 0, right: 10.0),
            child: DropdownButton<String>(
              value: (widget.stateStatus[stateName] != null) ? widget.stateStatus[stateName] : productStatusValue,
              onChanged: (String newValue) {
                _changeData(productId, stateName, column, newValue);
                var now = new DateTime.now();
                var date = new DateFormat('dd-MM-yyyy hh:mm');
                changeStatusTime(productId, newValue, timeColumns, date.format(now));
                /*changeStatus(productId, {column : newValue}).then((value) {
                  print('1=');
                  print(value);
                  if (value == true) {
                    setState(() {
                      widget.stateStatus[stateName] = newValue;
                      widget.changed = true;
                    });
                    var now = new DateTime.now();
                    var date = new DateFormat('dd-MM-yyyy hh:mm');
                    changeStatusTime(productId, newValue, timeColumns, date.format(now));
                    key.currentState.showSnackBar(new SnackBar(
                      content: new Text("Изменения сохранены!"),
                    ));
                  } else {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Ошибка"),
                          content: Text("Данные не сохранены!"),
                        )
                    );
                  }
                });*/

              },
              items: status.map<DropdownMenuItem<String>>((String value) {
                var i = status.indexOf(value);
                return DropdownMenuItem<String>(
                  value: statusKeys[i],
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ]
    );
  }

  Widget _dropDownDate(valueDate) {
    final TextStyle valueStyle = Theme.of(context).textTheme.body1;

    return new Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        new Expanded(
          flex: 4,
          child: new _InputDateDropdown(
            labelText: 'Дата производства:',
            valueText: valueDate,
            valueStyle: valueStyle,
            onPressed: () {
              _selectDate(context, valueDate);
            },
          ),
        ),
      ],
    );

  }

  Future <bool> changeStatus(dynamic recordId, Map <String, String> value) async {
    bool result;
    await Api.updateOrderStatus(recordId, value).then( (value) {
      result = value;
      print('2=');
      print(result);
    });
    return result;

  }

  bool changeStatusTime(dynamic recordId, dynamic statusValue, List<String> column, value) {
    int i = statusKeys.indexOf(statusValue);
    Map <String, String> result = {};

    if (status[i] == 'Взят в работу' ) {
      result[column[1]] = value;
    }
    if (status[i] == 'Выполнен' ) {
      result[column[0]] = value;
    }
    print(recordId);
    print(result);
    if (result != null) {
      Api.updateOrderStatus(recordId, result);
      return true;
    }
    return false;
  }

  DateTime picked = new DateTime.now();
  Future<Null> _selectDate(context, dateValue) async {
    DateTime dateFormat = new DateFormat('dd.MM.yy').parse(dateValue).add(Duration(milliseconds: DateTime(1970 + 2000).millisecondsSinceEpoch+24*60*60*100));
    picked = await showDatePicker(
        context: context,
        //locale:  Locale('ru', 'RU'),
        initialDate: dateFormat,
        firstDate: new DateTime(1918),
        lastDate: new DateTime(2030)
    );

    if (picked != null) {

      setState(() {
        widget.params['AE'] = new DateFormat('dd.MM.yy').format(picked);
      });
      _changeData(widget.params['id'], 'dateInproduce', 'AE', widget.params['AE']);
    }
  }

  _changeData(productId, stateName, column, newValue) {
      setState(() {
        widget.isLoading = Future(() {
          return true;
        });
      });


      changeStatus(productId, {column : newValue}).then((value) {
        if (value == true) {
          setState(() {
            widget.stateStatus[stateName] = newValue;
            widget.changed = true;
          });
          key.currentState.showSnackBar(new SnackBar(
            backgroundColor: Colors.green,
            content: new Text("Изменения сохранены!"),
          ));
        } else {
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Colors.red,
                title: Text("Ошибка"),
                content: Text("Данные не сохранены!"),
              )
          );
        }
        setState(() {
          widget.isLoading = Future(() {
            return false;
          });
        });
        return value;
      });



  }

}


class ProgressBar extends StatelessWidget {
  final Future<bool> _isLoading;
  ProgressBar(this._isLoading);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _isLoading,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data) {
            return LinearProgressIndicator();
          }
          else {
            return Container();
          }
        }
    );
  }
}

class _InputDateDropdown extends StatelessWidget {
  const _InputDateDropdown(
      {Key key,
        this.child,
        this.labelText,
        this.valueText,
        this.valueStyle,
        this.onPressed})
      : super(key: key);

  final String labelText;
  final String valueText;
  final TextStyle valueStyle;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return new InkWell(
      onTap: onPressed,
      child: new InputDecorator(
        decoration: new InputDecoration(
          labelText: labelText,
        ),
        baseStyle: valueStyle,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Text(valueText, style: valueStyle),
            new Icon(Icons.arrow_drop_down,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.grey.shade700
                    : Colors.white70),
          ],
        ),
      ),
    );
  }
}








