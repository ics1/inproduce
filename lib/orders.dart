import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'details.dart';
import 'package:decimal/decimal.dart';
import 'api/api.dart';
import 'details_table.dart';
import 'form.dart';
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
  BuildContext _ctx;
  int userType;
  // TODO: Add a variable for Category (104)
  @override
  void initState() {
    super.initState();
    print('initstate orders=');
    print(widget.params);

    widget.post = Api.fetchOrders(widget.params['filter']);

    /*fetchPost(widget.params['filter']).then((result) {
      setState(() {
        widget.post = result;
      });

    });*/
    getUserType().then((value) => setType(value));
  }

  setType(value) {
    userType = value;
    return userType;
  }

  Widget build(BuildContext context) {
      _ctx = context;
      List<String> employee = ['все', 'социгашев', 'байталенко', 'литвин', 'андреев', 'буковский', 'пикущак'];
      return Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          title: Text('Дата: ' + widget.params['filter']['date']),
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
                print('Filter button');
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
            sum = sum + Decimal.parse(snapshot.data[i]['V'].replaceAll(',','.'));
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
                          child: _buildGridCards(snapshot.data[index])
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

  Widget _buildGridCards(dynamic product) {
    //List<Product> products = ProductsRepository.loadProducts(Category.all);

    if (product == null || product.isEmpty) {
      return new ListTile();
    }
    Icon iconStatus = Icon(Icons.check_circle_outline, color: Colors.black);
    final ThemeData theme = Theme.of(context);
    final NumberFormat formatter = NumberFormat.simpleCurrency(
        locale: Localizations.localeOf(context).toString());
    if (product['W'] == '1') {
      iconStatus = Icon(Icons.check_circle_outline, color: Colors.green);
    }
    if (product['W'] == '2') {
      iconStatus = Icon(Icons.check_circle_outline, color: Colors.yellow);
    }
    if (product['W'] == '3') {
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
                Text("исполнитель: "+product['Z'], style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text("дата: "+product['D'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey)),
                Text("коэф: "+product['AA'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey)),
                //Text("дата: "+product['AE'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey)),
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
        //product['filter'] = widget.params['filter'];
        /*Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailsPage(params: product)),
        );*/
        _navigateDetails(_ctx, product);
      },
    );
  }

  _navigateDetails(BuildContext context, product) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    //product['filter'] = widget.params['filter'];
    //product['post'] = widget.post;
    final result = await Navigator.push(
      _ctx,
      MaterialPageRoute(builder: (context) => DetailsPage(params: product)),
    );

    if (result['changed']) {

        setState(() {
          widget.post = Api.fetchOrders(widget.params['filter']);
        });

    }

    /*fetchPost(widget.filter).then((resultPost) {
      print(resultPost);
      setState(() {
        widget.post = resultPost;
      });

    });*/
      //widget.post = fetchPost(widget.filter);
    //}
  }
}

getUserType() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  print('getUserType=');
  int getUserType = await preferences.getInt("type");
  print(getUserType);
  return getUserType;
}
