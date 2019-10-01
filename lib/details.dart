import 'package:flutter/material.dart';
import 'api/api.dart';
import 'package:intl/intl.dart';
//import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  List <String> employeeOb= ['','Социгашев', 'Байталенко', 'Литвин', 'Андреев', 'Буковский', 'Пикущак', 'Иксаров', 'Кузьменко', 'Ракицкий','Коцюк','Салыга','Лобенко', 'Резерв'];
  List <String> employeeSt= ['','Василенко', 'Эклема', 'Лещинский', 'Царалунга', 'Бойко', 'Жарков', 'Ракицкий'];
  List <String> employeeSv= ['','Плукчи', 'Социгашева', 'Агарукова', 'Овчарская', 'Логинов'];
  DateFormat dateFormat;

  int userType;
  String userFio;
  String columnDate = 'AE';//BB
  String columnStatus = 'W';//BA
  String columnFio = 'Z';
  final _descrController = TextEditingController();

  void initState()  {
    // TODO: implement initState
    super.initState();
    getUserType1().then((value) => setType(value));

    _descrController.text = widget.params['AF'];
    print('1=');

  }



  setType(value) {
    userType = value;
    if (userType == null) {
      Navigator.of(_ctx).pushReplacementNamed("/login");
    }

    if (userType == 10 || userType == 0) {

    } else {
      if ([40,80].contains(userType)) {
        columnDate = 'BB';
        columnStatus = 'BA';
        columnFio = 'AZ';
      }
    }

    return userType;
  }

  final key = new GlobalKey<ScaffoldState>();
  List<bool> _data = [true, false, false, false];
  //@override
  Widget build(BuildContext context) {
    getUserType1().then((value) => setType(value));
    print(userType);
    _ctx = context;
    Map <String, dynamic> product = widget.params;
    print(product['user_type']);
    if (userType == null) {
      userType = product['user_type'];
    }
    //_descrController.text = product['AF'];
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
          padding: new EdgeInsets.only(left: 10.0, bottom: 10.0, top: 20.0, right: 10.0),
          child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            //mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _getBody(product),
          ),
        ),
      ),
    );
  }

  bool _value2 = true;
  void _value2Changed(bool value) => setState(() => _value2 = value);

  _getCheckBoxObivka() {
    return new CheckboxListTile(
      value: _value2,
      onChanged: _value2Changed,
      title: new Text('Делал все'),
      controlAffinity: ListTileControlAffinity.leading,
      //subtitle: new Text('Subtitle'),
      //secondary: new Icon(Icons.archive),
      activeColor: Colors.green,
    );
  }

  List<Widget> _getBody(product) {
    List<Widget> per; // _buildDescription(product),
    /*per = [
      _buildDescription(product)
    ];*/
    if (userType == 10 || userType == 0) { //admin
      return <Widget> [
        _buildDescription(product),
        _getStausStolarka(product),
        _getStausShveika(product),
        _buildObivka(product),
        _buildParalon(product),
        _buildUpakovka(product),
        _getDescSave(product),
      ];
    }
    if (userType == 30) { //obivka 30
      return [
        _buildDescription(product),
        _getStausStolarka(product),
        _getStausShveika(product),
        //_getCheckBoxObivka(),
        _buildObivka(product),
        //_buildObivkaSelf(product),
        _buildParalon(product),
        //_getStatusSave(product),
        _getDescSave(product)
      ];
    }
    if (userType == 40) { // stolyarka 40
      return [
        _buildDescription(product),
        _getStausShveika(product),
        _buildStolarka(product),
      ];
    }
    if (userType == 50 || userType == 51) { // shveika 50
      return [
        _buildDescription(product),
        _getStausStolarka(product),
        _buildShveika(product),
        _buildKroi(product),
      ];
    }
    if (userType == 60 || userType == 61) { // kroi 50
      return [
        _buildDescription(product),
        _getStausStolarka(product),
        _getStausShveika(product),
        _buildKroi(product),
      ];
    }
    if (userType == 70) { // paralonka 70
      return [
        _buildDescription(product),
        _getStausStolarka(product),
        _getStausShveika(product),
        _getStausObivka(product),
        _buildParalon(product),
      ];
    }
    if ([80, 90].contains(userType)) { //upakovka 80
      return [
        _buildDescription(product),
        _getStausStolarka(product),
        _getStausShveika(product),
        _getStausObivka(product),
        _buildUpakovka(product),
      ];
    }
    return <Widget> [];
  }
  _getDescSave(product) {
    return Row(
        children:[
          Flexible(
            child:  TextField(
              //obscureText: true,
              controller: _descrController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Описание',
                suffixIcon: IconButton(
                    icon: Icon(Icons.save),
                    onPressed: () {
                      debugPrint(_descrController.text);
                      _changeData(product['id'], 'descrInput', 'AF', _descrController.text);
                    }),
              ),

            ),
          ),
        ]
    );
  }
  _getIconStatus(product, type) {
    String _columnStatus = 'BA';
    String _columnDate = 'BB';

    if (type == 'stolarka') {
      _columnStatus = 'BA';
      _columnDate = 'BB';
    }
    if (type == 'shveika') {
      _columnStatus = 'BP';
      _columnDate = 'BQ';
    }
    if (type == 'obivka') {
      _columnStatus = 'W';
      _columnDate = 'AE';
    }
    Icon iconStatus = Icon(Icons.check_circle_outline, color: Colors.black);
    final ThemeData theme = Theme.of(context);

    if (product[_columnStatus] == '1') {
      iconStatus = Icon(Icons.check_circle_outline, color: Colors.green);
    }
    if (product[_columnStatus] == '2') {
      iconStatus = Icon(Icons.check_circle_outline, color: Colors.yellow);
    }
    if (product[_columnStatus] == '3') {
      iconStatus = Icon(Icons.check_circle_outline, color: Colors.red);
    }
    return IconButton(
        icon: iconStatus,
        tooltip: 'Increase volume by 10'
    );
  }

  _getStausObivka(product) {
    return Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:[
          Container(
            padding: new EdgeInsets.only(left: 10.0, bottom: 0, top: 0, right: 10.0),
            child: Text("Обивка статус: ("+ product['Z'].toString()+") "+ product['W'].toString()+" "+product['AE'].toString()),
          ),
          Container(
            padding: new EdgeInsets.only(left: 10.0, bottom: 0, top: 0, right: 10.0),
            child:  _getIconStatus(product, 'obivka'),
          ),
        ]
    );
  }

  _getStausStolarka(product) {
    return Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:[
          Container(
            padding: new EdgeInsets.only(left: 10.0, bottom: 0, top: 0, right: 10.0),
            child: Text("Столярка статус: ("+ product['BA'].toString()+") "+ product['BB'].toString()+" "+product['AZ'].toString()),
          ),
          Container(
            padding: new EdgeInsets.only(left: 10.0, bottom: 0, top: 0, right: 10.0),
            child:  _getIconStatus(product, 'stolarka'),
          ),
        ]
    );
  }

  _getStausShveika(product) {
    return Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children:[
          Container(
            padding: new EdgeInsets.only(left: 10.0, bottom: 0, top: 0, right: 10.0),
            child: Text("Швейка статус: ("+ product['BP'].toString()+") "+ product['BQ'].toString()+" "+product['BO'].toString()),
          ),
          Container(
            padding: new EdgeInsets.only(left: 10.0, bottom: 0, top: 0, right: 10.0),
            child:  _getIconStatus(product, 'shveika'),
          ),
        ]
    );
  }

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
    return  Container(
        padding: new EdgeInsets.only(left: 10.0, bottom: 10.0, top: 10.0, right: 10.0),
        child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Швейка/Пошив", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), softWrap: true),
              _dropDownEmployee(product['id'], "Исполнитель: ", 'shveikaPoshivFio', product['BO'], 'BO', employeeSv),
              _dropDownStatus(product['id'], "Статус: ", 'shveikaPoshivStatus', product['BP'], 'BP', ['BS','BT','BU'] ),
            ]
        )
    );
  }

  Widget _buildKroi(product) {
    return  Container(
        padding: new EdgeInsets.only(left: 10.0, bottom: 10.0, top: 10.0, right: 10.0),
        child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Швейка/Крой", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), softWrap: true),
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
              /*Text("Царги", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), softWrap: true),
              _dropDownEmployee(product['id'], "Исполнитель: ", 'stolarkaIzgFio', product['BE'], 'BE', employeeSt),
              _dropDownStatus(product['id'], "Статус: ", 'stolarkaIzgStatus', product['BF'], 'BF', ['BG','BH','BI'] ),*/
              Text("Столярка/Изголовье", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), softWrap: true),
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
              Text("Обивка/Изголовье", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), softWrap: true),
              _dropDownEmployee(product['id'], "Исполнитель: ", 'obivkaIzgiFio', product['Z'], 'Z', employeeOb),
              _dropDownStatus(product['id'], "Статус: ", 'obivkaIzgStatus', product['W'], 'W', ['AH','AI','AJ'] ),
              Text("Обивка/Царги", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), softWrap: true),
              _dropDownEmployee(product['id'], "Исполнитель: ", 'obivkaCargiFio', product['AK'], 'AK', employeeOb),
              _dropDownStatus(product['id'], "Статус: ", 'obivkaCargiStatus', product['AL'], 'AL', ['AM','AN','AO'] ),
            ]
        )
    );
  }

  _getStatusSave(product) {
    return Container(
        padding: new EdgeInsets.only(left: 10.0, bottom: 10.0, top: 10.0, right: 10.0),
        child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dropDownStatus(product['id'], "Статус: ", 'obivkaIzgStatus', product['W'], 'W', ['AH','AI','AJ'] ),
              FlatButton(
                color: Colors.blue,
                textColor: Colors.white,
                disabledColor: Colors.grey,
                disabledTextColor: Colors.black,
                padding: EdgeInsets.all(8.0),
                splashColor: Colors.blueAccent,
                onPressed: () {
                  /*...*/
                },
                child: Text(
                  "Сохранить",
                  //style: TextStyle(fontSize: 20.0),
                ),
              )

            ]
        )
    );
  }

  Widget _buildObivkaSelf(product) {
    return  Container(
        padding: new EdgeInsets.only(left: 10.0, bottom: 10.0, top: 10.0, right: 10.0),
        child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Обивка/Изголовье", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), softWrap: true),
              _dropDownEmployeeNoChange(product['id'], "Исполнитель: ", 'obivkaIzgiFio', product['Z'], 'Z', employeeOb),
              //_dropDownStatus(product['id'], "Статус: ", 'obivkaIzgStatus', product['W'], 'W', ['AH','AI','AJ'] ),
              Text("Обивка/Царги", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), softWrap: true),
              _dropDownEmployeeNoChange(product['id'], "Исполнитель: ", 'obivkaCargiFio', product['AK'], 'AK', employeeOb),
              //_dropDownStatus(product['id'], "Статус: ", 'obivkaCargiStatus', product['AL'], 'AL', ['AM','AN','AO'] ),
            ]
        )
    );

  }


  Widget _buildParalonSelf(product) {
    return  Container(
        padding: new EdgeInsets.only(left: 10.0, bottom: 10.0, top: 10.0, right: 10.0),
        child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Паралонка/Царги", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), softWrap: true),
              _dropDownEmployeeNoChange(product['id'], "Исполнитель: ", 'paralonCargiFio', product['AU'], 'AU', employeeOb),
              //_dropDownStatus(product['id'], "Статус: ", 'paralonCargiStatus', product['AV'], 'AV', ['AW','AX','AY']),
              Text("Паралонка/Изголовье", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), softWrap: true),
              _dropDownEmployeeNoChange(product['id'], "Исполнитель: ", 'paralonIzgFio', product['AP'], 'AP', employeeOb),
              //_dropDownStatus(product['id'], "Статус: ", 'paralonIzgStatus', product['AQ'], 'AQ', ['AR','AS','AT'] ),
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
              Text("Паралонка/Царги", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), softWrap: true),
              _dropDownEmployee(product['id'], "Исполнитель: ", 'paralonCargiFio', product['AU'], 'AU', employeeOb),
              _dropDownStatus(product['id'], "Статус: ", 'paralonCargiStatus', product['AV'], 'AV', ['AW','AX','AY']),
              Text("Паралонка/Изголовье", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), softWrap: true),
              _dropDownEmployee(product['id'], "Исполнитель: ", 'paralonIzgFio', product['AP'], 'AP', employeeOb),
              _dropDownStatus(product['id'], "Статус: ", 'paralonIzgStatus', product['AQ'], 'AQ', ['AR','AS','AT'] ),
            ]
        )
    );
  }



  Widget _buildUpakovka(product) {
    return  Container(
        padding: new EdgeInsets.only(left: 10.0, bottom: 10.0, top: 10.0, right: 10.0),
        child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Упаковка", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), softWrap: true),
              //_dropDownEmployee(product['id'], "Исполнитель: ", 'paralonCargiFio', product['AU'], 'AU', employeeOb),
              _dropDownStatus(product['id'], "Статус: ", 'upakovkaStatus', product['CF'], 'CF', ['CG','CH','CI']),

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
                    padding: new EdgeInsets.only(left: 0.0, bottom: 0.0, top: 0.0, right: 0.0),
                    child: _dropDownDate(widget.params['AE']),
                ),

                _rowParam("Дата клиента: ", product['D']),
                //_rowParam("Дата производства: ", product['AE']),

                _rowParam("Толщина спинки: ", ''),
                _rowParam("Тип: ", product['E']),
                _rowParam("Материал: ", product['L']+" "+product['M']),
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

            ]
        )
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

  Widget _dropDownEmployeeNoChange(productId, title, stateName, productValue, column, List<String> listEmployee) {

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
                //_changeData(productId, stateName, column, newValue);
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

  Widget _dropDownStatusNoChange(productId, title, stateName, productStatusValue, column, timeColumns ) {
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
                //_changeData(productId, stateName, column, newValue);
                //var now = new DateTime.now();
                //var date = new DateFormat('dd-MM-yyyy hh:mm');
                //changeStatusTime(productId, newValue, timeColumns, date.format(now));

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
    if (userType != 0) {
      return _rowParam("Дата производства: ", valueDate);
    }
    //final TextStyle valueStyle = Theme.of(context).textTheme.body1;

    return new Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        new Expanded(
          flex: 4,
          child: new _InputDateDropdown(
            labelText: 'Дата производства:',
            valueText: valueDate,
            //valueStyle: valueStyle,
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

getUserType1() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  int getUserType =  await preferences.getInt("type");
  return getUserType;
}

getUserFio() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  String getUserFio = await preferences.getString("fio");
  return getUserFio;
}






