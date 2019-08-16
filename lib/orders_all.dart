import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'details.dart';
import 'package:decimal/decimal.dart';
import 'api/api.dart';


class OrdersAllPage extends StatefulWidget {
  dynamic post;
  //dynamic filter;
  dynamic dropdownValue;
  OrdersAllPage({Key key}) : super(key: key);
  @override
  _OrdersAllPageState createState() => _OrdersAllPageState();

}

class _OrdersAllPageState extends State<OrdersAllPage> {
  BuildContext _ctx;
  List<String> listDropDown = <String>['По номеру', 'По клиенту', 'По моделе', 'По дате производства'];
  FocusNode myFocusNode;
  TextEditingController editingController = TextEditingController();
  final TextEditingController _filter = new TextEditingController();
  // TODO: Add a variable for Category (104)
  @override
  void initState() {
    super.initState();
    widget.post = Api.fetchOrdersAll(null);
    myFocusNode = FocusNode();
    setState(() {
      widget.dropdownValue = 'По номеру';
    });
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
        });
      } else {
        if (_filter.text.length > 3) {
          if (_filter.text.length > 4) {
            widget.dropdownValue = 'По клиенту';
          }
          String filed = getFieldSearch(widget.dropdownValue);
          setState(() {
            widget.post = Api.fetchOrdersAll({"$filed": _filter.text});
          });
        } else {
          /*setState(() {
                            widget.post = Api.fetchOrdersAll(null);
                          });*/
        }
      }
    });

    print('initstate ordersAll=');
  }
  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();

    super.dispose();
  }
  String _searchText = "";
  List names = new List(); // names we get from API
  List filteredNames = new List(); // names filtered by search text
  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text( 'Заказы' );

  Widget build(BuildContext context) {
    _ctx = context;
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        title: _appBarTitle,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            semanticLabel: 'arrow_back',
          ),
          onPressed: () {
            Navigator.of(_ctx).pushReplacementNamed("/home");
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: _searchIcon,
            onPressed: () {
              setState(() {
                if (this._searchIcon.icon == Icons.search) {
                  this._searchIcon = new Icon(Icons.close);
                  this._appBarTitle = new TextField(
                    controller: _filter,
                    //autofocus: true,
                    decoration: new InputDecoration(
                        prefixIcon: new Icon(Icons.search),
                        hintText: 'Поиск...'
                    ),
                  );
                } else {
                  this._searchIcon = new Icon(Icons.search);
                  this._appBarTitle = new Text('Заказы');
                  filteredNames = names;
                  _filter.clear();
                }
              });
            },
          ),
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

      resizeToAvoidBottomInset: false,
      //resizeToAvoidBottomPadding: true,
    );
  }

  String getFieldSearch (value) {
    if (value == 'По клиенту') {
      return 'F';
    }
    return 'A';
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
                Text("клиент: "+product['F'], style: TextStyle(fontSize: 12, color: Colors.blue)),
                Text("исполнитель: "+product['Z'], style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text("дата клиента: "+product['D'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey)),
                Text("коэф: "+product['AA'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey)),
                Text("дата производства: "+product['AE'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey)),

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

  _navigateDetails(BuildContext context, product) async {

    final result = await Navigator.push(
      _ctx,
      MaterialPageRoute(builder: (context) => DetailsPage(params: product)),
    );

    if (result['changed']) {
      setState(() {
        //widget.post = Api.fetchOrders(null);
      });
    }
  }
}


