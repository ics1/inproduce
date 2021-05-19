import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'details.dart';
import 'package:decimal/decimal.dart';
import 'api/api.dart';
import 'details_table.dart';
//import 'form.dart';
import 'table.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrdersPage extends StatefulWidget {
  dynamic params;
  dynamic post;
  dynamic dropdownValue;
  //dynamic filter;
  OrdersPage({Key key, this.params}) : super(key: key);
  @override
  _OrdersPageState createState() => _OrdersPageState();


}

class _OrdersPageState extends State<OrdersPage> {
  String columnStatus = 'W';//BA
  BuildContext _ctx;
  int userType;
  // TODO: Add a variable for Category (104)
  @override
  void initState() {
    super.initState();
    widget.post = Api.fetchOrdersAll(widget.params['filter']);
    getUserType().then((value) => setType(value));
  }

  didUpdateWidget(obj) {
    super.didUpdateWidget(obj);
    print('ORDERS PAGE didUpdateWidget ==============');
  }

  setType(value) {
    userType = value;
    if (userType == 40) {
      columnStatus = 'BA';
    }
    return userType;
  }

  Widget build(BuildContext context) {
      _ctx = context;

      List <String> employee= ['Все','Социгашев', 'Байталенко', 'Литвин', 'Андреев', 'Буковский', 'Пикущак',
        'Кузьменко','Коцюк','Салыга', 'Скрипник','Ткачук', 'Чеховский', 'Резерв', 'Гаврилашенко'];
      return Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          title: Text('Дата: ' + widget.params['dateValue']),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              semanticLabel: 'arrow_back',
            ),
            onPressed: () {
              Navigator.pop(_ctx, { 'params' : widget.params});
              /*Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OrdersPage(params: product)),
            );*/
            },
          ),
          actions: <Widget>[

            IconButton(
              icon: Icon(
                Icons.tune,
                semanticLabel: 'filter',
              ),
              onPressed: () {
                //_selectDate();
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildListOrders()
              ]
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Container(
            height: 50.0,
            padding: new EdgeInsets.only(left: 63.0, bottom: 5.0, top: 5.0, right: 63.0),
            child: _get_total()
          ),
        ),
        resizeToAvoidBottomInset: false,
      );
  }

  Widget _get_total() {
    return  FutureBuilder<List<dynamic>>(
      future: widget.post,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Decimal sum = Decimal.parse('0');
          for (var i = 0; i< snapshot.data.length; i++) {
            if (snapshot.data[i]['V'] == '') {
              snapshot.data[i]['V'] = '0';
            }
            sum = sum + Decimal.parse(snapshot.data[i]['V'].toString().replaceAll(',','.'));
          }
          sum = sum/Decimal.parse('7860');
          return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Итого'),
                Text(sum.toStringAsFixed(1))
              ]
          );
        }
        return Center();//Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildListOrders() {
    return FutureBuilder<List<dynamic>>(
        future: widget.post,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(8.0),
                shrinkWrap: true,
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(width: 1.0, color: Color(0xFFFFDFDFDF)),
                            ),
                          ),
                          child: _getListOrdersGridCards(snapshot.data[index]) //_buildGridCards(snapshot.data[index])
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
    if (value == '4') {
      return Icon(Icons.check_box, color: Colors.lightBlueAccent, size: 15.0);
    }
    return  Icon(Icons.check_box_outline_blank, color: Colors.grey, size: 15.0,);
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
    //print(product);
    int colors = 0;
    if (product['BA'] =='1' && product['BP'] =='1') {
      colors = 50;
    }
//    if (product['BA'] =='1' && product['BP'] =='1' && product['W'] == '1') {
//      colors = 100;
//    }
    return Container(
        color: Colors.green[colors],
        child:ListTile(
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
                    _getClient(product),
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:[
                          Expanded(flex:3, child:Text("обивка:", style: TextStyle(fontSize: 12, color: Colors.grey))),
                          Expanded(flex:3,child:Text(product['Z'].toString(), style: TextStyle(fontSize: 12, color: Colors.grey))),
                          Expanded(flex:2,child:Text(product['AE'].toString(), style: TextStyle(fontSize: 12, color: Colors.grey))),
                          _getGridCardIconStatus(product['W']),

                        ]),
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:[
                          Expanded(flex:3, child:Text("столярка:", style: TextStyle(fontSize: 12, color: Colors.grey))),
                          Expanded(flex:3,child:Text(product['AZ'].toString(), style: TextStyle(fontSize: 12, color: Colors.grey))),
                          Expanded(flex:2,child:Text(product['BB'].toString(), style: TextStyle(fontSize: 12, color: Colors.grey))),
                          _getGridCardIconStatus(product['BA']),

                    ]),
                    /*Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:[
                          Expanded(flex:3, child:Text("крой"+((product['BY'] == '1') ? "/настил:" : ":"), style: TextStyle(fontSize: 12, color: Colors.grey))),
                          Expanded(flex:3,child:Text(product['BV'].toString(), style: TextStyle(fontSize: 12, color: Colors.grey))),
                          Expanded(flex:2,child:Text(product['BX'].toString(), style: TextStyle(fontSize: 12, color: Colors.grey))),
                          _getGridCardIconStatus(product['BW']),

                        ]),*/
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:[
                          Expanded(flex:3, child:Text("швейка:", style: TextStyle(fontSize: 12, color: Colors.grey))),
                          Expanded(flex:3,child:Text(product['BO'].toString(), style: TextStyle(fontSize: 12, color: Colors.grey))),
                          Expanded(flex:2,child:Text(product['BQ'].toString(), style: TextStyle(fontSize: 12, color: Colors.grey))),
                          _getGridCardIconStatus(product['BP']),

                        ]),


                    //Text("материал: "+product['L'].toString()+" "+product['M'].toString(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey)),

                    //Text("исп./швейка: "+product['BO'].toString()+" ("+product['BP'].toString()+') ('+product['BQ'].toString()+")", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    //Text("исп./крой: "+product['BV'].toString()+" ("+product['BW'].toString()+') ('+product['BX'].toString()+")", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text("дата клиента: "+product['D'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey)),
                    Text("дата производства:: "+product['AE'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey)),
                    Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children:[
                          Expanded(flex:3, child:Text("упаковка:", style: TextStyle(fontSize: 12, color: Colors.grey))),
                          Expanded(flex:3,child:Text("", style: TextStyle(fontSize: 12, color: Colors.grey))),
                          Expanded(flex:2,child:Text(product['CG'].toString(), style: TextStyle(fontSize: 12, color: Colors.grey))),
                          _getGridCardIconStatus(product['CF']),

                        ]),
                    Text("коэф: "+product['AA'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey)),
                    Text("коэф в: "+product['AG'].toString(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey)),


                  ],
                ),
              ),
              /* Container(
                width: 80,
                child: CheckboxListTile(
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
              )*/
            ],
          ),
          onTap: () {
            _navigateDetails(_ctx, product);
          },
    ));
  }

  Widget _buildGridCards(dynamic product) {
    //List<Product> products = ProductsRepository.loadProducts(Category.all);

    if (product == null || product.isEmpty) {
      return new ListTile();
    }
    Icon iconStatus = Icon(Icons.check_circle_outline, color: Colors.black);
    final ThemeData theme = Theme.of(context);
    final NumberFormat formatter = NumberFormat.simpleCurrency(
        locale: Localizations.localeOf(context).toString());
    if (product[columnStatus] == '1') {
      iconStatus = Icon(Icons.check_circle_outline, color: Colors.green);
    }
    if (product[columnStatus] == '2') {
      iconStatus = Icon(Icons.check_circle_outline, color: Colors.yellow);
    }
    if (product[columnStatus] == '3') {
      iconStatus = Icon(Icons.check_circle_outline, color: Colors.red);
    }
    return ListTile(
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            //padding: new EdgeInsets.only(left: 4.0, bottom: 14.0, top: 14.0),
            width: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(product['A'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black),)
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(product['I'], style: TextStyle(fontSize: 14, color: Colors.black),),
                _getClient(product),
                Text("исп./обивка: "+product['Z'].toString()+" ("+product['W'].toString()+') ('+product['AE'].toString()+")", style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text("исп./столярка: "+product['AZ'].toString()+" ("+product['BA'].toString()+') ('+product['BB'].toString()+")", style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text("исп./швейка: "+product['BO'].toString()+" ("+product['BP'].toString()+') ('+product['BQ'].toString()+")", style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text("дата клиента: "+product['D'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey)),
                Text("коэф: "+product['AA'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey)),
                Text("дата производства:: "+product['AE'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            width: 20,
            child: IconButton(
                icon: iconStatus,
                tooltip: 'Increase volume by 10'
            ),
          )
        ],
      ),
      onTap: () {
        _navigateDetails(_ctx, product);
      },
    );
  }

  Widget _getClient(product) {
    if ([0,10, 80, 90].contains(userType)) {
      return Text("клиент: " + product['F'],
          style: TextStyle(fontSize: 12, color: Colors.blue));
    }
    return Center();
  }
  _navigateDetails(BuildContext context, product) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    //product['filter'] = widget.params['filter'];
    //product['post'] = widget.post;
    product['user_type'] = userType;
    final result = await Navigator.push(
      _ctx,
      MaterialPageRoute(builder: (context) => DetailsPage(params: product)),
    );

    if (result['changed']) {
        setState(() {
          widget.post = Api.fetchOrdersAll(widget.params['filter']);
        });

    }
  }
}

getUserType() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  int getUserType = await preferences.getInt("type");
  return getUserType;
}
