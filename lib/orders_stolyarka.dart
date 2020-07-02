import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'details.dart';
import 'api/api.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'components/input_date_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:decimal/decimal.dart';

class OrdersStolyarkaPage extends StatefulWidget {
  dynamic post = null;
  //dynamic filter;
  dynamic dropdownValue;
  OrdersStolyarkaPage({Key key}) : super(key: key);
  @override
  _OrdersStolyarkaPageState createState() => _OrdersStolyarkaPageState();

}

class _OrdersStolyarkaPageState extends State<OrdersStolyarkaPage> {
  List <dynamic> _range = [[0,6], [0,5], [0,4], [0,3], [0,2], [0,7], [0,7]];
  List<DateTime> _date = [new DateTime.now().add(Duration(days: 1)), new DateTime.now().add(Duration(days: 7))];
  static DateTime _now = new DateTime.now();
  int _weekday = _now.weekday;
  DateFormat dateFormat = new DateFormat('dd.MM.yy');
  String columnDate = 'AE';
  String columnFio = 'AZ';
  String _dateRangeText;
  DateTime _dateShvPoshivFilter;
  int userType;
  String userFio;

  BuildContext _ctx;
  Map <String, dynamic> filter = {};
  List _stateSelected = [];
  List<String> listDropDown = <String>['По номеру', 'По клиенту', 'По моделе', 'По дате производства'];
  //List <String> employeeShv= ['','Плукчи', 'Социгашева', 'Овчарская', 'Агарунова', 'Логинов'];
  List <String> employeeShv= ['','Василенко', 'Эклема', 'Лещинский', 'Царалунга', 'Чабан', 'Отрышко', 'Жарков', 'Ракицкий', 'Тютюнник', 'Скрипник'];
  List <String> status = ['','Взят в работу, готовность завтра', 'Наряд выдан', 'Взят в работу, готовность сегодня', 'Остановлен', 'Выполнен'];
  List <String> statusKr = ['','Выполнен', 'Наряд выдан'];
  List <String> statusNastil = ['','Да'];


  List <String> statusKeys = ['','5', '4', '2', '3', '1'];

  FocusNode myFocusNode;
  TextEditingController editingController = TextEditingController();
  final TextEditingController _filter = new TextEditingController();
  Map <String, dynamic> stateValues = {};
  Map<String, dynamic> stateStatus = {};

  InputDateDropdown _inputDateDropdown;

  List names = new List(); // names we get from API
  List filteredNames = new List(); // names filtered by search text
  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = Text('Заказы');

  List<dynamic> listFilter = [];

  final key = new GlobalKey<ScaffoldState>();
  // TODO: Add a variable for Category (104)
  @override
  void initState() {
    super.initState();
    Provider.of<IsLoading>(context, listen: false).setState(false);

    _date = [new DateTime.now().add(Duration(days: _range[_weekday-1][0])), new DateTime.now().add(Duration(days: _range[_weekday-1][1]))];

    _dateRangeText = dateFormat.format(_date[0])+'-'+dateFormat.format(_date[1]);
    _textFieldRangeController.text = _dateRangeText;
    //filter["BP"] = '4';
    getUserType().then((value) => setType(value));

    myFocusNode = FocusNode();
    setState(() {
      widget.dropdownValue = 'По номеру';
    });
    _filter.addListener(() {
      if (_filter.text.length == 0) {
        setState(() {
          //filter["BP"] ='4';
          //filter.remove('BP');
          filter[columnDate] = {'>=': dateFormat.format(_date[0]), '<=': dateFormat.format(_date[1])};
          filter.remove('A');
          if (userType == 40) {
            filter[columnFio] = userFio;
          }
          widget.post = Api.fetchOrdersAll(filter, sort : columnDate);
        });
      }
      if (_filter.text.length > 3) {
        print(_filter.text.indexOf(','));
        if (_filter.text.indexOf(',') > 0) {
          List<String> ids = _filter.text.split(",");
          for (var i=0; i<ids.length; i++) {
            if (ids[i].length == 0) ids.remove(ids[i]);
          }
          setState(() {
            filter = {"A": {'in': ids}};
            if (userType == 40) {
              filter[columnFio] = userFio;
            }
            widget.post = Api.fetchOrdersAll(filter, sort : columnDate);
            for (var i=0; i<ids.length; i++) {
              stateValues[ids[i]] = true ;
            }
            _stateSelected = ids;
          });
        } else {
          print(_filter.text.indexOf('-'));
          if (_filter.text.indexOf('-') > 0) {
            List range = _filter.text.split("-");
            print(range);
            int rangeStart = int.parse(range[0]);
            int rangeStop = int.parse(range[1]);
            List ids = [];

            print(ids);
            setState(() {
              for (var i=rangeStart; i<=rangeStop; i++) {
                ids.add(i.toString());
                stateValues[i.toString()] = true ;
              }
              filter = {"A": {'in': ids}};
              if (userType == 40) {
                filter[columnFio] = userFio;
              }
              widget.post = Api.fetchOrdersAll(filter, sort : columnDate);

              _stateSelected = ids;
            });
          } else {
            setState(() {
              filter = {"A": _filter.text};
              if (userType == 40) {
                filter[columnFio] = userFio;
              }
              widget.post = Api.fetchOrdersAll(filter, sort : columnDate);
            });
          }
        }
      }
    });

    print('initstate ordersAll=');
  }

  setType(value) {
    userType = value;
    print('1=');
    print(userType);
    if (userType == null) {
      Navigator.of(_ctx).pushReplacementNamed("/login");
    }
    if (userType == 40) {
      columnDate = 'AE';
      //columnStatus = 'BW';
      columnFio = 'AZ';
      filter[columnDate] = {'>=': dateFormat.format(_date[0]), '<=': dateFormat.format(_date[1])};
      getUserFio().then((erg) => setFilterFio(erg));
    } else {

      setState(() {
        filter[columnDate] = {'>=': dateFormat.format(_date[0]), '<=': dateFormat.format(_date[1])};
        widget.post = Api.fetchOrdersAll(filter, sort : columnDate);
      });
    }

    return userType;

  }

  setFilterFio(value) {
    userFio = value;
    setState(() {
      filter[columnFio] = value;
      widget.post = Api.fetchOrdersAll(filter, sort : columnDate);
    });
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();
    super.dispose();
  }

  bool _selectedBoxBtnApplyValidateData() {

    if (stateStatus.length == 0) {
      return false;
    }
    /*if (stateStatus['employeeShv'] == null) {
      return false;
    }*/
    /*if (stateStatus['statusShv'] == null) {
      return false;
    }*/
    return true;
  }

  void _setSelectedBoxBtnApplyPress() {

    if (_selectedBoxBtnApplyValidateData()) {
      int index = status.indexOf(stateStatus['statusShv']);
      String date = _inputDateDropdown.valueText;

      Map<String, dynamic> result = {'fields': {}, 'ids':{}};
      print('1=');
      print(stateStatus['statusShv']);
      if (stateStatus['statusShv']  != '') {
        result['fields'] = {
          'AZ': stateStatus['employeeShv'],
          'BA': statusKeys[index],
          'BB': date,
          'BR': '',
          'BS': '',
          'BT': '',
          'BU': ''
        };
      }
      int indexKr = statusKr.indexOf(stateStatus['statusKr']);
      print('2=');
      print(indexKr);
      if (indexKr == 1) {
        result['fields']['BV'] = stateStatus['employeeShv'];
        result['fields']['BW'] = indexKr;
        result['fields']['BX'] = date;
        result['fields']['BY'] = statusNastil.indexOf(stateStatus['statusNastil']);
      }
      result['ids']  = _stateSelected;
      Provider.of<IsLoading>(context, listen: false).setState(true);
      Api.updateAll(result).then((value){
        if (value == true) {
          key.currentState.showSnackBar(new SnackBar(
            //backgroundColor: Colors.green,
            content: new Text("Изменения сохранены!"),
          ));
          Provider.of<IsLoading>(context, listen: false).setState(false);
          //_dessertsDataSource.unSelectedAll();
          setState(() {
            widget.post = Api.fetchOrdersAll(filter);
            stateValues.clear();
            _stateSelected.clear();
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

  void _setFilterDialogBtnApplyPress() {
    int index = status.indexOf(stateStatus['statusShvFilter']);

    if (stateStatus['statusShvFilter'] !='' && stateStatus['statusShvFilter']!=null) {
      filter['BA'] = statusKeys[index];
    } else {
      filter.remove('BA');
    }
    if (stateStatus['emploeeyShvFilter']!='' && stateStatus['emploeeyShvFilter']!=null) {
      filter['AZ'] = stateStatus['emploeeyShvFilter'];
    } else {
      print('remove AZ');
      filter.remove('AZ');
    }


    if (stateStatus['employeeShvFilter']!='' && stateStatus['employeeShvFilter']!=null) {
      filter['AZ'] = stateStatus['employeeShvFilter'];
    } else {
      print('remove AZ');
      filter.remove('AZ');
    }

    if (_dateShvPoshivFilter != null) {
      filter['BB'] = dateFormat.format(_dateShvPoshivFilter);
      filter.remove(columnDate);
    } else {
      print('remove BB');
      filter.remove('BB');
      filter[columnDate] = {'>=': dateFormat.format(_date[0]), '<=': dateFormat.format(_date[1])};
    }

    if (userType == 40) {
      filter[columnFio] = userFio;
    }

    setState(() {
      widget.post = Api.fetchOrdersAll(filter, sort : columnDate);
    });
  }

  void _setFilterDialogIconRangePress() async {
    final List<DateTime> picked = await DateRagePicker.showDatePicker(
        context: context,
        initialFirstDate: _date[0],
        initialLastDate: _date[1],
        firstDate: new DateTime(2015),
        lastDate: new DateTime(2030)
    );
    if (picked != null && picked.length == 2) {
      setState(() {
        _date = picked;
        filter[columnDate] = {'>=':dateFormat.format(picked[0]), '<=':dateFormat.format(picked[1])};
        _dateRangeText = dateFormat.format(_date[0])+'-'+dateFormat.format(_date[1]);
        _textFieldRangeController.text = _dateRangeText;
        //widget.post = Api.fetchOrdersAll(filter);
      });
    }
  }

  void _setFilterDialogIconDatePoshivPress() async {
    picked = await showDatePicker(
        context: context,
        //locale:  Locale('ru', 'RU'),
        initialDate: (_dateShvPoshivFilter) ?? new DateTime.now(),
        firstDate: new DateTime(1918),
        lastDate: new DateTime(2030)
    );

    if (picked != null) {
      setState(() {

        _dateShvPoshivFilter = picked;
        _textFieldController.text = dateFormat.format(_dateShvPoshivFilter);
      });

    }
  }

  void _setFilterDialogIconDateClearPress() async {
    setState(() {
      _dateShvPoshivFilter = null;
      _textFieldController.text = '___.___.___';
    });

  }

  Widget _getGridCardIconStatus(value) {
    if (value == '1') {
      return Icon(Icons.check_box, color: Colors.green, size: 15.0);
    }
    if (value == '2') {
      return Icon(Icons.check_box, color: Colors.yellow, size: 15.0);
    }
    if (value == '3') {
      return Icon(Icons.check_box, color: Colors.red, size: 15.0);
    }
    return  Icon(Icons.check_box_outline_blank, color: Colors.grey, size: 15.0,);
  }

  void _getGridCardNavigateDetails(BuildContext context, product) async {

    product['user_type'] = userType;
    final result = await Navigator.push(
      _ctx,
      MaterialPageRoute(builder: (context) => DetailsPage(params: product)),
    );

    if (result['changed']) {
      setState(() {
        widget.post = Api.fetchOrdersAll(filter);
      });

    }
  }

  Widget _getListOrdersGridCards(dynamic product) {
    //List<Product> products = ProductsRepository.loadProducts(Category.all);

    if (product == null || product.isEmpty) {
      return new ListTile();
    }
    Icon iconStatus = Icon(Icons.check_circle_outline, color: Colors.black);
    final ThemeData theme = Theme.of(context);
    final NumberFormat formatter = NumberFormat.simpleCurrency(
        locale: Localizations.localeOf(context).toString());
    iconStatus = _getGridCardIconStatus(product['W']);

    return ListTile(
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 0,
              child: Container(
                //padding: new EdgeInsets.only(left: 4.0, bottom: 14.0, top: 14.0),
                width: 40,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  //mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(product['A'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),),
                  ],
                ),
              )

          ),

          Expanded(
            flex:1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(product['I'], style: TextStyle(fontSize: 14, color: Colors.black),),
                //Text("клиент: "+product['F'], style: TextStyle(fontSize: 12, color: Colors.blue)),
                //Text("исп./обивка: "+product['Z'].toString()+" ("+product['W'].toString()+') ('+product['AE'].toString()+")", style: TextStyle(fontSize: 12, color: Colors.grey)),
                //Text("исп./столярка: "+product['AZ'].toString()+" ("+product['BA'].toString()+') ('+product['BB'].toString()+")", style: TextStyle(fontSize: 12, color: Colors.grey)),

                Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:[
                      Expanded(flex:3, child:Text("Столярка:", style: TextStyle(fontSize: 12, color: Colors.grey))),
                      Expanded(flex:3,child:Text(product['AZ'].toString(), style: TextStyle(fontSize: 12, color: Colors.grey))),
                      Expanded(flex:2,child:Text(product['BB'].toString(), style: TextStyle(fontSize: 12, color: Colors.grey))),
                      _getGridCardIconStatus(product['BA']),

                    ]),
                Text("материал: "+product['L'].toString()+" "+product['M'].toString(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey)),

                //Text("исп./швейка: "+product['BO'].toString()+" ("+product['BP'].toString()+') ('+product['BQ'].toString()+")", style: TextStyle(fontSize: 12, color: Colors.grey)),
                //Text("исп./крой: "+product['BV'].toString()+" ("+product['BW'].toString()+') ('+product['BX'].toString()+")", style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text("дата клиента: "+product['D'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey)),
                Text("дата производства:: "+product['AE'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey)),
                Text("коэф: "+product['AA'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey)),
                Text("коэф вр/ст: "+product['AG'].toString(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey)),

              ],
            ),
          ),
          Container(
            width: 80,
            child: (![0,10].contains(userType)) ? Text('') : CheckboxListTile(
              //title: const Text('Animate Slowly'),
              value: (stateValues[product['A']]) ?? false,//timeDilation != 1.0,
              onChanged: (bool value) {
                setState(() {
                  stateValues[product['A']] = value;
                  if (stateValues[product['A']]) {
                    _stateSelected.add(product['A']);
                  } else {
                    _stateSelected.remove(product['A']);
                  }

                });
              },
              //secondary: const Icon(Icons.hourglass_empty),
            ),
          )
        ],
      ),
      onTap: () {
        _getGridCardNavigateDetails(_ctx, product);
      },
    );
  }

  dynamic _getArray(data) {
    List listExpand = [];

    int index = 0;
    Decimal AB, AC, CH;
    Decimal coefSumTotal = Decimal.parse('0');
    Decimal coefPlSumTotal = Decimal.parse('0');
    Decimal coefTimeSumTotal = Decimal.parse('0');


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

      //AB = Decimal.parse(item['AB'].replaceAll(',','.'));
      AC = Decimal.parse(item['AA'].replaceAll(',','.'));
      CH = Decimal.parse(item['AG'].replaceAll(',','.'));


      dataDate[currentDate]['coefSum'] +=  Decimal.parse(AC.toStringAsFixed(2));
      //dataDate[currentDate]['coefPlSum'] += Decimal.parse(AC.toStringAsFixed(2));
      dataDate[currentDate]['coefTimeSum'] += Decimal.parse(CH.toStringAsFixed(2));

      //print(currentDate);
      //print(item[columnStatus]);
      //print(dataDate[currentDate]['coefSum'] );
      coefSumTotal = coefSumTotal +  Decimal.parse(AC.toStringAsFixed(2));
      //coefPlSumTotal = coefPlSumTotal + Decimal.parse(AC.toStringAsFixed(2));
      coefTimeSumTotal = coefTimeSumTotal + Decimal.parse(CH.toStringAsFixed(2));


      index++;
    }

    listExpand.sort((a, b) => DateFormat('dd.MM.yy').parse(a['headerValue']).compareTo(DateFormat('dd.MM.yy').parse(b['headerValue'])));
    return {'listExpand': listExpand, 'coefSum': coefSumTotal, 'coefTimeSum': coefTimeSumTotal};
  }

  Widget  _getTotal() {

    return FutureBuilder<List<dynamic>>(
      future: widget.post,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          dynamic totalArray = _getArray(snapshot.data);
          //String pribil = '';
          //if (userType == 0) {
          //  pribil = totalArray['pribil'].toStringAsFixed(1);
          //}
          return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Итого: '),
                Text('ст:'+totalArray['coefTimeSum'].toStringAsFixed(1)+'           '+'           об:'+totalArray['coefSum'].toStringAsFixed(1)),
              ]
          );

        }
        // By default, show a loading spinner.
        return Center();//Center( child:CircularProgressIndicator());
      },
    );
  }

  TextEditingController _textFieldController = new TextEditingController();
  TextEditingController _textFieldRangeController = new TextEditingController();

  Widget _getIconFilterDialog() {
    return AlertDialog(
        title: Text("Фильтр"),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children:[
                    Text('Период:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                  ]
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children:[
                    Container(
                        width: 115,
                        child: TextField(
                          controller: _textFieldRangeController,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
                          decoration: InputDecoration(hintText: "___.___.___"),
                          enabled: false,
                        )
                    ),
                    //Text(_dateRangeText, style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black)),
                    IconButton(
                        iconSize: 22.0,
                        icon: Icon(
                          Icons.calendar_today,
                        ),
                        onPressed: _setFilterDialogIconRangePress
                    ),
                  ]
              ),
              _getDropDownState('Исполнитель', 'employeeShvFilter', employeeShv,[0,10,41]),
              _getDropDownState('Статус столярка:', 'statusShvFilter', status,[0,10,41, 40]),

              //_dropDownDate(DateFormat('dd.MM.yy').format(DateTime.now())),
              _getDropDownDateState(),

              FlatButton(
                color: Colors.blue,
                textColor: Colors.white,
                onPressed: () async {
                  _setFilterDialogBtnApplyPress();
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Применить",
                ),
              ),
            ]
        )
    );
  }

  Widget _getActionsIconSearch() {
    return IconButton(
      icon: _searchIcon,
      onPressed: () {
        setState(() {
          if (this._searchIcon.icon == Icons.search) {
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
            this._appBarTitle = new Text('Заказы');
            filteredNames = names;
            setState(() {
              _filter.clear();
              stateValues.clear();
              _stateSelected.clear();
            });

          }
        });
      },
    );
  }

  Widget _getActionsIconRefresh() {
    return IconButton(
      icon: Icon(
        Icons.refresh,
        semanticLabel: 'refresh',
      ),
      onPressed: () {
        setState(() {
          widget.post = Api.fetchOrdersAll(filter);
        });
      },
    );
  }

  Widget _getActionsIconFilter() {
    return IconButton(
      icon: Icon(
        Icons.tune,
        semanticLabel: 'filter',
      ),
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) => _getIconFilterDialog()
        );
      },
    );
  }

  Iterable<Widget> get _getFilterInfoChip sync* {
    for (Map<String,String> value in listFilter) {
      yield Padding(
        padding: const EdgeInsets.all(4.0),
        child: Chip(
          //avatar: CircleAvatar(child: Text(actor.initials)),
          label: Text(value['value']),
          onDeleted: () {
            if (value['filter'] == "AE") {
              return null;
            }
            if (value['filter'] == "BB") {
              return null;
            }
            setState(() {
              listFilter.removeWhere((entry) {
                print('1=');
                print(entry);
                print(value);
                if (entry['filter'] == value['filter']) {
                  filter.remove(value['filter']);
                  widget.post = Api.fetchOrdersAll(filter);
                }
                return entry['filter'] == value['filter'];
              });

            });
          },
        ),
      );
    }
  }

  Widget _getSelectedBoxFilterInfo() {
    String filterInfo = '';
    listFilter = [];
    filter.forEach((i, value) {
      print(i);
      print(value);
      if (i == columnDate) {
        filterInfo =  DateFormat('dd.mm').format(DateFormat('dd.mm.yy').parse(value['>=']))+'-'+ DateFormat('dd.mm').format(DateFormat('dd.mm.yy').parse(value['<=']));
        listFilter.add({'value' : filterInfo, 'filter' : columnDate});
      }
      if (i == 'BA') {
        int indexStatus = statusKeys.indexOf(value);
        filterInfo = 'Столярка:'+ status[indexStatus];
        listFilter.add({'value' : filterInfo, 'filter' : 'BA'});
      }

      if (i == 'AZ') {
        //int indexStatus = statusKr.indexOf(value);
        filterInfo = 'Исполнитель:'+value;
        listFilter.add({'value' : filterInfo, 'filter' : 'AZ'});
      }
      if (i == 'BB') {
        //int indexStatus = statusKr.indexOf(value);
        filterInfo = value;
        listFilter.add({'value' : filterInfo, 'filter' : 'BB'});
      }

    });

    return Container(
      //padding: const EdgeInsets.only(left: 10.0, bottom: 5.0, top: 5.0, right: 10.0),
        color:Colors.white,
        child: Row(
          //crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            children: _getFilterInfoChip.toList()
        ));
  }

  Widget _getSelectedBoxRow() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Выбрано: '+_stateSelected.length.toString()+' '),

          RaisedButton(
            child: Text('Назначить'),
            //elevation: 8.0,
            onPressed: () async {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                      title: Text("Выберите параметры"),
                      content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            _getDropDownState('Исполнитель', 'employeeShv', employeeShv, [0,10,51,50,60]),
                            _getDropDownState('Статус столярка:', 'statusShv', status, [0,10,51,50]),
                            _dropDownDate(dateFormat.format(DateTime.now())),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children:[

                                  RaisedButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      "Отмена",
                                    ),
                                  ),

                                  RaisedButton(
                                    onPressed: () async {
                                      _setSelectedBoxBtnApplyPress();
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      "Сохранить",
                                    ),
                                  ),
                                ]
                            ),


                          ]
                      )
                  )
              );
            },
          )
        ]
    );
  }

  List<Widget> _getAppBarActions() {
    return <Widget>[
      _getActionsIconSearch(),
      _getActionsIconRefresh(),
      _getActionsIconFilter(),
    ];
  }

  Widget _getAppBarBack() {
    if (userType == 0 || userType==10) {
      return IconButton(
          icon: Icon(
            Icons.arrow_back,
            semanticLabel: 'arrow_back',
          ),
          onPressed: () {
            Navigator.of(_ctx).pushReplacementNamed("/home");
          });
    }
    return null;
  }

  Widget _getAppBarSelectedBox() {
    if (_stateSelected.length == 0) {
      if (![0,10,51].contains(userType)) {
        return PreferredSize(
            preferredSize: Size(double.infinity, 0.0),
            child: Center()
        );
      }
      return PreferredSize(
          preferredSize: Size(double.infinity, 40.0),
          child: _getSelectedBoxFilterInfo()
      );
    } else {
      return PreferredSize(
          preferredSize: Size(double.infinity, 50.0),
          child: Container(
              color: Colors.white,
              padding: const EdgeInsets.only(left: 10.0, bottom: 5.0, top: 5.0, right: 10.0),
              child: _getSelectedBoxRow()
          )
      );
    }
  }

  Widget _getBuildAppBar() {
    return AppBar(
      brightness: Brightness.light,
      title: _appBarTitle,
      leading: _getAppBarBack(),
      actions: _getAppBarActions(),
      bottom:  _getAppBarSelectedBox(),
    );
  }

  Widget _getBuildDrawer() {
    return Drawer(
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
          //_getMenuDrawer(),
          ListTile(
            title: Text('Выход'),
            onTap: () {
              logout();
              Navigator.of(_ctx).pushReplacementNamed("/login");
            },
          ),
        ],
      ),
    );
  }

  Widget _getBuildListOrders() {
    return FutureBuilder<List<dynamic>>(
      future: widget.post,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          String dateGroup;
          return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(0.0),
              shrinkWrap: true,
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {

                if (dateGroup != snapshot.data[index][columnDate]) {
                  dateGroup = snapshot.data[index][columnDate];
                  return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.only(left: 10.0, bottom: 12.0, top: 12.0, right: 10.0),
                          color: Colors.black12,
                          child: Text(snapshot.data[index][columnDate]),
                        ),
                        Container(
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(width: 1.0, color: Color(0xFFFFDFDFDF)),
                              ),
                            ),
                            child: _getListOrdersGridCards(snapshot.data[index])
                        ),
                      ]

                  );
                }
                return Column(
                    children: [
                      Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(width: 1.0, color: Color(0xFFFFDFDFDF)),
                            ),
                          ),
                          child: _getListOrdersGridCards(snapshot.data[index])
                      ),
                    ]
                );
              });
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }


  List<Widget> _buildBody() {
    List<Widget> listWidgets = [];
    Widget scroll = SingleChildScrollView(
      child: Column(
          children: [_getBuildListOrders()]
      ),
    );
    //if (loaderValue) {

    listWidgets.add(scroll);
    listWidgets.add(_getModalLoading());

    //}
    return listWidgets;
  }

  Widget build(BuildContext context) {
    _ctx = context;
    //Provider.of<IsLoading>(context, listen: false).setState(true);
    //bool loader = true;
    return Scaffold(
      key: key,
      appBar: _getBuildAppBar(),
      body: new Stack(
          children: _buildBody()
      ),

      drawer: _getBuildDrawer(),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 50.0,
          padding: new EdgeInsets.only(left: 25.0, bottom: 5.0, top: 5.0, right: 25.0),
          child: _getTotal(),
        ),
      ),

      resizeToAvoidBottomInset: false,
      //resizeToAvoidBottomPadding: true,
    );
  }


  Widget _getModalLoading() {
    return Consumer<IsLoading>(
      builder: (context, loader, child) {
        print(loader.value);
        if (loader.value) {
          return new Stack(
            children: [
              new Opacity(
                opacity: 0.3,
                child: const ModalBarrier(dismissible: false, color: Colors.grey),
              ),
              new Center(
                child: new CircularProgressIndicator(),
              ),
            ],
          );
        } else {
          return Center();
        }

      },
    );
  }

  Widget _getDropDownDateState() {
    if (userType == 50 || userType == 60) {
      return Center();
    }
    return Column(
        children: [
          Row(
              children:[
                Text('Дата столярка:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
              ]
          ),
          Row(
              children:[
                Container(
                    width: 60,
                    child: TextField(
                      controller: _textFieldController,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
                      decoration: InputDecoration(hintText: "___.___.___"),
                      enabled: false,
                    )
                ),
                //_widgetDatePohiv,
                IconButton(
                    iconSize: 22.0,
                    icon: Icon(
                      Icons.calendar_today,
                    ),
                    onPressed: _setFilterDialogIconDatePoshivPress
                ),
                IconButton(
                    iconSize: 22.0,
                    icon: Icon(
                      Icons.close,
                    ),
                    onPressed: _setFilterDialogIconDateClearPress
                ),
              ]
          ),
        ]
    );
  }

  Widget _getDropDownState(title, stateName, employeeSt, List<int> permission) {
    if (!permission.contains(userType)) {
      return Center();
    }
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Column(children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children:[
                Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)),
              ]
          ),
          Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                new DropdownButton<String>(
                  //hint: Text(title),
                  value: stateStatus[stateName],
                  items: employeeSt.map<DropdownMenuItem<String>>((String value) {
                    var i = employeeSt.indexOf(value);
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal, color: Colors.black)),
                    );
                  }).toList(),
                  onChanged: (String newValue) {
                    setState(() {
                      stateStatus[stateName] = newValue;
                    });

                    //_changeFilter(stateName);

                  },
                )
              ]
          )
        ]);
      },
    );
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

  Widget _dropDownDate(valueDate) {

    _inputDateDropdown = InputDateDropdown(
        labelText: 'Дата производства:',
        valueText: valueDate,
        valueStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),
        onPressed: () {
          //_changeFilterDate(_inputDateDropdown.getDate());
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

  _getBaseFilter() {
    return {'BA': '4'};
  }

  getUserFio() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String getUserFio = await preferences.getString("fio");
    return getUserFio;
  }

  getUserType() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int getUserType = await preferences.getInt("type");
    return getUserType;
  }

  Future<void> logout() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.remove("auth_token");
    pref.remove("is_login");
    pref.remove("fio");
    pref.remove("type");
    pref.remove("filter");
  }
}


