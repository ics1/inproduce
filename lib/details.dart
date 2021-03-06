import 'package:flutter/material.dart';
import 'api/api.dart';
import 'package:intl/intl.dart';
//import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdf;
import 'package:printing/printing.dart';
import 'dart:io';
import 'pdf_example.dart';
import 'pdf/pdf_part1.dart';
import 'pdf/document.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

import 'dart:async';
import 'dart:typed_data';
import 'package:esc_pos_printer/esc_pos_printer.dart';

import 'package:markdown/markdown.dart' as markdown;
import 'package:path_provider/path_provider.dart';
import 'package:inproduce/view/widgets/comments_list.dart';
import 'package:inproduce/helper/demo_values.dart';
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
      obivkaIzgStatus,
      upakovkaStatus,
      upakovkaIzgStatus;
  List<String> employees = [];
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
  Map<String,List<String>> employees= {};
  List <String> status = [];//['','Наряд выдан', 'Взят в работу, готовность сегодня', 'Остановлен', 'Выполнен', 'Взят в работу, готовность завтра'];
  List <String> statusKeys = [];//['','4', '2', '3', '1', '5'];
  List <String> employeeOb;// ['','Социгашев', 'Байталенко', 'Литвин', 'Андреев', 'Буковский', 'Пикущак', 'Кузьменко','Коцюк','Салыга','Скрипник',
    //'Ткачук', 'Чеховский','Долгиер', 'Ратников','Гаврилашенко','Резерв'];
  List <String> employeeSt= [];//['','Василенко', 'Эклема', 'Лещинский', 'Царалунга', 'Бойко', 'Жарков', 'Ракицкий', 'Тютюнник', 'Жаров', 'Скрипник'];
  List <String> employeeSv= [];//['','Плукчи', 'Социгашева', 'Агарунова', 'Овчарская', 'Логинов', 'Жильников', 'Мачулко', 'Плахотнюк', 'Артемкина','Меднова'  ];
  List <String> employeePackaging= [];//['','Малечик', 'Иксаров', 'Сафиев', 'Солончак'];
  DateFormat dateFormat;
  Map <String, dynamic> stateValues = {};
  Map<String, dynamic> stateStatus = {};
  List _stateSelected = [];

  int userType;
  String userFio;
  String columnDate = 'AE';//BB
  String columnStatus = 'W';//BA
  String columnFio = 'Z';
  final _descrController = TextEditingController();
  final GlobalKey<State<StatefulWidget>> previewContainer = GlobalKey();

  @override
  _DetailsPageState() {
    print('init details _DetailsPageState');


  }

  didUpdateWidget(obj) {
    super.didUpdateWidget(obj);
    print('Details PAGE didUpdateWidget ==============');
    setStartFilter();
  }

  void initState()  {
    // TODO: implement initState

    super.initState();
    getUserFio().then((value) => userFio = value);
    getEmployees('1').then((valueOb) {
      getStatuses().then((valueStatus) {
        List<String> statusKeysNew = [''];
        List<String> statusVal = valueStatus;
        int i = 1;
        valueStatus.forEach((row) {

          if (i != (statusVal.length)) {
            statusKeysNew.add(i.toString());
          }
          i++;
        });
        getEmployees('3').then((valueSv) {
          getEmployees('2').then((valueSt) {
            getEmployees('5').then((valuePackaging) {
              setState(() {
                status = valueStatus;
                statusKeys = statusKeysNew;
                employeeOb = valueOb;
                employeePackaging = valuePackaging;
                employeeSt = valueSt;
                employeeSv = valueSv;

                employees['1'] = valueOb;
                employees['2'] = valueSt;
                employees['3'] = valueSv;
                employees['5'] = valuePackaging;



              });
              getUserType1().then((value) => setType(value));
            });
          });
        });
      });
    });

    //getUserType1().then((value) => setType(value));


    _descrController.text = '';//widget.params['AF'];

  }

  setStartFilter() {

  }

  setType(value) {
    userType = value;
    print('1=');


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

    if (employeeOb == null) {
      return new Scaffold(
        appBar: new AppBar(
          title: new Text("Loading..."),
        ),
      );
    } else {
      //getUserType1().then((value) => setType(value));

      _ctx = context;
      Map <String, dynamic> product = widget.params;
      //print(product['user_type']);
      if (userType == null) {
        userType = product['user_type'];
      }

      //_descrController.text = product['AF'];
      //dynamic currentFilter = widget.params['filter'];
      return RepaintBoundary(
          key: previewContainer,
          child: Scaffold(
            key: key,

            appBar: AppBar(
              title: Text(product['A']),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  semanticLabel: 'arrow_back',
                ),
                onPressed: () {
                  Navigator.pop(
                      _ctx, { 'params': product, 'changed': widget.changed});
                  /*Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrdersPage(params: product)),
              );*/
                },
              ),
              actions: <Widget>[
                IconButton(
                    icon: Icon(
                      Icons.print,
                      semanticLabel: 'print',
                    ),
                    onPressed: _printScreen // {
                  //await Printing.layoutPdf(
                  //onLayout: pdfExample);
                  //              Navigator.push(
                  //                _ctx,
                  //                MaterialPageRoute(builder: (context) => MyApp()),
                  //              );
                  // _printScreen();

                  //},
                ),

              ],
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
                padding: new EdgeInsets.only(
                    left: 10.0, bottom: 10.0, top: 20.0, right: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  //mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _getBody(product),
                ),
              ),
            ),
          )
      );
    }
  }

  Future<void> _printScreen() async {
//    Printer.connect('192.168.0.102', port: 9100).then((printer) {
//      printer.println('Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
//      printer.println('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
//          styles: PosStyles(codeTable: PosCodeTable.westEur));
//      printer.println('Special 2: blåbærgrød',
//          styles: PosStyles(codeTable: PosCodeTable.westEur));
//
//      printer.println('Bold text', styles: PosStyles(bold: true));
//      printer.println('Reverse text', styles: PosStyles(reverse: true));
//      printer.println('Underlined text',
//          styles: PosStyles(underline: true), linesAfter: 1);
//
//      printer.println('Align left', styles: PosStyles(align: PosTextAlign.left));
//      printer.println('Align center',
//          styles: PosStyles(align: PosTextAlign.center));
//      printer.println('Align right',
//          styles: PosStyles(align: PosTextAlign.right), linesAfter: 1);
//
//      printer.println('Text size 200%',
//          styles: PosStyles(
//            height: PosTextSize.size2,
//            width: PosTextSize.size2,
//          ));
//
//      printer.cut();
//      printer.disconnect();
//    });
    //return;
    final RenderRepaintBoundary boundary =
    previewContainer.currentContext.findRenderObject();
    final ui.Image im = await boundary.toImage();
    final ByteData bytes =
    await im.toByteData(format: ui.ImageByteFormat.rawRgba);
    print('Print Screen ${im.width}x${im.height} ...');

    Printing.layoutPdf(onLayout: (PdfPageFormat format) {
      final pdf.Document document = pdf.Document();

      final PdfImage image = PdfImage(document.document,
          image: bytes.buffer.asUint8List(),
          width: im.width,
          height: im.height);

      document.addPage(pdf.Page(
          pageFormat: format,
          build: (pdf.Context context) {
            return pdf.Center(
              child: pdf.Expanded(
                child: pdf.Image(image),
              ),
            ); // Center
          })); // Page

      return document.save();
    });
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

        Padding(
          padding: const EdgeInsets.only(top: 1.0),
          child: ExpansionTile(
            leading: Icon(Icons.check_box_outline_blank),
            //trailing: Text(comments.length.toString()),
            title: Text("Столярка"),
            children: [_buildStolarka(product)],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 1.0),
          child: ExpansionTile(
            leading: Icon(Icons.check_box_outline_blank),
            //trailing: Text(comments.length.toString()),
            title: Text("Швейка"),
            children: [_getStausShveika(product)],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: ExpansionTile(
            leading: Icon(Icons.check_box_outline_blank),
            //trailing: Text(comments.length.toString()),
            title: Text("Обивка"),
            children: [_buildObivka(product)],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: ExpansionTile(
            leading: Icon(Icons.check_box_outline_blank),
            //trailing: Text(comments.length.toString()),
            title: Text("Поролонка"),
            children: [_buildParalon(product)],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: ExpansionTile(
            leading: Icon(Icons.check_box_outline_blank),
            //trailing: Text(comments.length.toString()),
            title: Text("Упаковка"),
            children: [_buildUpakovka(product)],
          ),
        ),



//        _getDynamicWork(product, '1'),
//        _getDynamicWork(product, '2'),
//        _getDynamicWork(product, '3'),
//        _getDynamicWork(product, '5'),
        _getDynamicWork(product,"Обивка доп.", '1'),

//        Padding(
//          padding: const EdgeInsets.only(top: 8.0),
//          child: ExpansionTile(
//            leading: Icon(Icons.add_alarm),
//            //trailing: Text(comments.length.toString()),
//            title: Text("Столярка доп."),
//            children: _getDynamicWork(product, '2'),
//          ),
//        ),
//        Padding(
//          padding: const EdgeInsets.only(top: 8.0),
//          child: ExpansionTile(
//            leading: Icon(Icons.add_alarm),
//            //trailing: Text(comments.length.toString()),
//            title: Text("Швейка доп."),
//            children: _getDynamicWork(product, '3'),
//          ),
//        ),
//        Padding(
//          padding: const EdgeInsets.only(top: 8.0),
//          child: ExpansionTile(
//            leading: Icon(Icons.add_alarm),
//            //trailing: Text(comments.length.toString()),
//            title: Text("Упаковка доп."),
//            children: _getDynamicWork(product, '5'),
//          ),
//        ),

        _getDescSave(product),
        CommentsList(params:product['comment'])




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

  _getDynamicWork(product, title, departmentId) {
    List<Widget> list = _getListTileCheckList(product['orderWork'], departmentId,employees[departmentId]);
    if (list.length > 0) {
      return Padding(
        padding: const EdgeInsets.only(top: 1.0, left: 1.0),
        child: ExpansionTile(

          leading: Icon(Icons.add_alarm),
          //trailing: Text(list.length.toString()),
          title: Text(title),
          children: list,
        ),
      );
    } else {
      return Column();
    }

  }
  _getDescSave(product) {
    return Row(
        children:[

//          Flexible(
//            child:  TextField(
//              //obscureText: true,
//              controller: _descrController,
//              decoration: InputDecoration(
//                border: OutlineInputBorder(),
//                labelText: 'Описание',
//                suffixIcon: IconButton(
//                    icon: Icon(Icons.save),
//                    onPressed: () {
//                      debugPrint(_descrController.text);
//                      _changeData(product['id'], 'descrInput', 'AF', _descrController.text);
//                    }),
//              ),
//
//            ),
//          ),
          Flexible(
            child:  TextField(
              //obscureText: true,
              controller: _descrController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Добавить комментрарий',
                suffixIcon: IconButton(
                    icon: Icon(Icons.save),
                    onPressed: () {
                      var date = new DateFormat('yyyy-MM-dd HH:mm');
                      debugPrint(_descrController.text);
                      _fetchData('post','accounting/comments',
                          {'order_id':product['id'].toString(),'order_no':product['A'].toString(), 'user_name' : userFio, 'date':date.format(DateTime.now()), 'text':_descrController.text},
                          '',
                          'descrInput','comment'
                      );
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
              _dropDownEmployee('accounting/orders',product['id'], "Исполнитель: ", 'shveikaPoshivFio', product['BO'], 'BO', employeeSv),
              _dropDownStatus('accounting/orders',product['id'], "Статус: ", 'shveikaPoshivStatus', product['BP'], 'BP', ['BS','BT','BU'] ),
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
              _dropDownEmployee('accounting/orders',product['id'], "Исполнитель: ", 'shveikaKroiFio', product['BV'], 'BV', employeeSv),
              _dropDownStatus('accounting/orders',product['id'], "Статус: ", 'shveikaKroiStatus', product['BW'], 'BW', ['BX','BY','BZ'] ),

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
              _dropDownEmployee('accounting/orders',product['id'], "Исполнитель: ", 'stolarkaCargiFio', product['AZ'], 'AZ', employeeSt),
              _dropDownStatus('accounting/orders',product['id'], "Статус: ", 'stolarkaCargiStatus', product['BA'], 'BA', ['BB','BC','BD'] ),
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
              _dropDownEmployee('accounting/orders',product['id'], "Исполнитель: ", 'obivkaIzgiFio', product['Z'], 'Z', employeeOb),
              _dropDownStatus('accounting/orders',product['id'], "Статус: ", 'obivkaIzgStatus', product['W'], 'W', ['AH','AI','AJ'] ),
              Text("Обивка/Царги", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), softWrap: true),
              _dropDownEmployee('accounting/orders',product['id'], "Исполнитель: ", 'obivkaCargiFio', product['AK'], 'AK', employeeOb),
              _dropDownStatus('accounting/orders',product['id'], "Статус: ", 'obivkaCargiStatus', product['AL'], 'AL', ['AM','AN','AO'] ),
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
              _dropDownStatus('accounting/orders',product['id'], "Статус: ", 'obivkaIzgStatus', product['W'], 'W', ['AH','AI','AJ'] ),
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
              _dropDownEmployee('accounting/orders',product['id'], "Исполнитель: ", 'paralonCargiFio', product['AU'], 'AU', employeeOb),
              _dropDownStatus('accounting/orders',product['id'], "Статус: ", 'paralonCargiStatus', product['AV'], 'AV', ['AW','AX','AY']),
              Text("Паралонка/Изголовье", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), softWrap: true),
              _dropDownEmployee('accounting/orders',product['id'], "Исполнитель: ", 'paralonIzgFio', product['AP'], 'AP', employeeOb),
              _dropDownStatus('accounting/orders',product['id'], "Статус: ", 'paralonIzgStatus', product['AQ'], 'AQ', ['AR','AS','AT'] ),
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
              _dropDownStatus('accounting/orders',product['id'], "Статус царги: ", 'upakovkaStatus', product['CD'], 'CD', ['CE','CE','CE']),
              _dropDownStatus('accounting/orders',product['id'], "Статус: изголовье", 'upakovkaIzgStatus', product['CF'], 'CF', ['CG','CG','CG']),

            ]
        )
    );
  }
  //final Uint8List fontData = File('open-sans.ttf').readAsBytesSync();
  //final ttf = pdf.Font.ttf(fontData.buffer.asByteData());

  List<int> buildPdf(PdfPageFormat format) {
//    final  pdf.Document doc = pdf.Document();
//
//    doc.addPage(
//      pdf.Page(
//        pageFormat: format,
//        build: (pdf.Context context) {
//          return pdf.Center(
//            child: pdf.Text(widget.params['I']),
//          ); //
//        },
//      ),
//    );
//
//
//
//    return doc.save();
  }

  Widget _buildDescription(product) {
    return Container(
        padding: new EdgeInsets.only(left: 0.0, bottom: 0.0, top: 0.0, right: 0.0),
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


                //_rowParam("Дата производства: ", product['AE']),

                //_rowParam("Толщина спинки: ", ''),
                _rowParam("Тип: ", product['E']),
                _rowParam("Материал: ", product['L']+" "+product['M']),
                _rowParam("Ножки: ", product['N']),
              ExpansionTile(
                leading: Icon(Icons.info),
                //trailing: Text(comments.length.toString()),
                title: Text("Доп.информация"),
                children: [

                  _rowParam("Пуговицы: ", product['O']),
                  _rowParam("Отстрочка: ", product['P']),
                  _rowParam("Дата клиента: ", product['D']),
                ],
              ),

                //_rowParam("Пружина: ", product['Q']),
                //_rowParam("Механизм: ", product['R']),
                //_rowParam("Номер клиента: ", product['S']),
              ExpansionTile(
                initiallyExpanded: true,
                leading: Icon(Icons.info),
                //trailing: Text(comments.length.toString()),
                title: Text("Описание"),
                children: [

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
                  _rowParamDesc("Распил: ", product['desc_sawcut']),
                  _rowParamDesc("Столярка: ", product['desc_carpenter']),
                  _rowParamDesc("Крой: ", product['desc_cut']),
                  _rowParamDesc("Пошив: ", product['desc_sewing']),
                  _rowParamDesc("Обивка: ", product['desc_upholstery']),
                  _rowParamDesc("Упаковка: ", product['desc_packaging']),
                  _rowParamDesc("Отгрузка: ", product['desc_shipment']),
                ],
              )

              //_getListTileCheckList(product['work'], 5),



              //_rowParamPackaging(product['work'], 5),
              //_rowParamPackaging(product['work'], 5),


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

          Flexible(
            flex:1,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: new EdgeInsets.only(left: 10.0, bottom: 5.0, top: 5.0, right: 10.0),
              child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), softWrap: true),
            ),
          ),
//          Container(
//            padding: new EdgeInsets.only(left: 10.0, bottom: 5.0, top: 5.0, right: 10.0),
//            child: Text(title, style: TextStyle(color: Colors.black), softWrap: true),
//          ),
          Flexible(
            flex:2,
            child: Container(
              alignment: Alignment.centerLeft,
              //padding: new EdgeInsets.only(left: 10.0, bottom: 5.0, top: 5.0, right: 10.0),
              child: Text(value.toString(), style: TextStyle( color: Colors.black)),
            ),
          ),
//          Container(
//            padding: new EdgeInsets.only(left: 10.0, bottom: 5.0, top: 5.0, right: 10.0),
//            child:  Text(value.toString(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), softWrap: true),
//          ),
        ]
    );
  }





  List<Widget> _getListTileCheckList(values, departmentId, employees) {
    List<Widget> widgets = [];
    if (values == '' || values==null) return [];
    String id;
    for (var i=0; i<values.length; i++) {

      if (values[i]['department_id'].toString() != departmentId) continue;
      id = values[i]['id'].toString();
      widgets.add(
          Container(
            alignment: Alignment.centerLeft,
            padding: new EdgeInsets.only(left: 5.0, right: 5.0),
            child: Text(values[i]['name'], style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, ),softWrap: true),
          ),

      );
      widgets.add(
          Container(
            alignment: Alignment.centerLeft,
            padding: new EdgeInsets.only(left: 5.0,  right: 5.0),
            child: _dropDownEmployee('accounting/order-works',id, "Исполнитель: ", 'dopWorkStatusFio_'+id, values[i]['employee_name'], 'employee_name', employees),
          ),
      );
      widgets.add(
          Container(
            alignment: Alignment.centerLeft,
            padding: new EdgeInsets.only(left: 5.0,  right: 5.0),
            child: _dropDownStatus('accounting/order-works', id, "Статус: ", 'dopWorkStatus_'+id, values[i]['status'].toString(), 'status', ['date_fact_end','date_fact_start','time_work']),
          )
      );



    }
    return widgets;
  }

  Widget _rowParamDesc(title, value) {
    if (value == '' || value==null) return Column();
    return Column( children: [
      Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:[
            Container(
              padding: new EdgeInsets.only(left: 10.0, bottom: 5.0, top: 5.0, right: 10.0),
              child: Text(title, style: TextStyle(color: Colors.black)),
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
                child: Text(value.toString(), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red), softWrap: true),
              ),
            ),
          ]
      )
    ]);
  }

  Widget _dropDownEmployee(path,productId, title, stateName, productValue, column, List<String> listEmployee) {

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
            child:
            Container(
              padding: const EdgeInsets.only(left: 1.0, right: 1.0),
              decoration: BoxDecoration(
                  //borderRadius: BorderRadius.circular(0.0),
                  //color: Colors.grey,
                  //border: Border.all()
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: (widget.stateStatus[stateName] != null) ? widget.stateStatus[stateName] : productValue,
                  onChanged: (String newValue) {
                    _changeData(path,productId, stateName, column, newValue);
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

  Widget _dropDownStatus(path,productId, title, stateName, productStatusValue, column, timeColumns ) {
    print('1---------------------------------');
    print(productStatusValue);
    print(widget.stateStatus[stateName]);
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

              value: (widget.stateStatus[stateName] != null) ? widget.stateStatus[stateName] : (productStatusValue == '0' || productStatusValue=='null')? '': productStatusValue,
              onChanged: (String newValue) {
                _changeData(path,productId, stateName, column, newValue);
                var now = new DateTime.now();
                var date = new DateFormat('dd-MM-yyyy hh:mm');
                changeStatusTime(path,productId, newValue, timeColumns, date.format(now));

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

  Future <bool> changeStatus(String urlStatus,dynamic recordId, Map <String, String> value) async {
    bool result;
    await Api.updateFields(urlStatus,recordId, value).then( (value) {
      result = value;
    });
    return result;

  }

  Future <dynamic> fetchRecord(String method,String url,dynamic params, String expand) async {
    dynamic result;
    await Api.fetchRecord(method, url, params, expand).then( (value) {
      result = value;
    });
    return result;

  }

  bool changeStatusTime(String path,dynamic recordId, dynamic statusValue, List<String> column, value) {
    int i = statusKeys.indexOf(statusValue);
    Map <String, String> result = {};

    if (status[i] == 'Взят в работу' ) {
      result[column[1]] = value;
    }
    if (status[i] == 'Выполнен' ) {
      result[column[0]] = value;
    }

    if (result != null) {
      Api.updateFields(path, recordId, result);
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
      _changeData('accounting/orders',widget.params['id'], 'dateInproduce', 'AE', widget.params['AE']);
    }
  }

  _changeData(path, productId, stateName, column, newValue) {
      setState(() {
        widget.isLoading = Future(() {
          return true;
        });
      });


      changeStatus(path,productId, {column : newValue}).then((value) {
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

  _fetchData(method, path, Map<String, String> params, String expand, stateName, field) {
    setState(() {
      widget.isLoading = Future(() {
        return true;
      });

    });


    fetchRecord(method, path, params, expand).then((value) {
      if (value != false) {
        setState(() {
          //widget.stateStatus[stateName] = params[field];
          widget.changed = true;
          widget.params['comment'].insert(0,value);
          _descrController.text = '';
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

  getEmployees(departmentId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> employees = preferences.getStringList("employees_"+departmentId);
    return employees;
  }

  getStatuses() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    List<String> statuses = preferences.getStringList("statuses");
    return statuses;
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








