import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  //static final Api _instance = new Api.internal();
  //factory Api() => _instance;

  static String _url = 'http://admin.startsell.biz/api/';
  static Map<String, String> _contentType = {"Content-Type": "application/json"};
  //Api.internal();

  static Future<bool> isLoggedIn() async {

    String path = 'users/is-logged?auth_token=7110eda4d09e062aa5e4a390b0a572ac0d2c0220';
    print(_url+path);
    final response =
    await http.get(_url+path, headers: _contentType);
    if (response.statusCode == 200) {
      dynamic result =json.decode(response.body);
      print(result);
      return result['success'];
    } else {
      throw Exception('Ошибка сервера isLoggedIn()');
    }
  }

  static Future<List<dynamic>> fetchPost(dynamic filterItems) async {
    String path = 'accounting/orders?_dc=1563489532611&page=1&start=0&per-page=1000&sort=[{"property":"AE","direction":"ASC"}]';
    String filter='&filter={"AE":{"!=":""}';
    if (filterItems != null && filterItems['date'] != null) {
      if (filterItems['date'].length == 2)  {

        filter = '&filter={"AE":{">=":"'+filterItems['date'][0]+'","<=":"'+filterItems['date'][1]+'"}';
      } else {
        filter = '&filter={"AE":"' + filterItems['date'] + '"';
      }
    }
    if (filterItems != null) {
      if (filterItems['fio'] != null && filterItems['fio'] != 'Все') {
        filter += ',"Z":"'+filterItems['fio']+'"';
      }
    }
    if (filterItems != null) {
      if (filterItems['fioSt'] != null && filterItems['fioSt'] != 'Все') {
        filter += ',"AZ":"'+filterItems['fioSt']+'"';
      }
    }
    filter += '}';

    String token;
    await getToken().then((value) {
      token = value;
    });

    var url =_url+path+'&auth_token='+token+filter;
    print('Get home');
    print(filter);
    print(url);
    final response = await http.get(
        url,
        headers: { "Content-Type" : "application/json"}
    );
    List<dynamic> res = [];
    if (response.statusCode == 200) {
      print(json.decode(response.body)['items']);
      res = json.decode(response.body)['items'];
       return res;
    } else {
      //print(json.decode(response.body));
      return null;
      //throw Exception('Failed to load post');
    }
  }

  static Future<List<dynamic>> fetchOrders(dynamic filterItems) async {
    String filter = '&filter={"AE":{"!=":""}';

    print(filter);
    String path = 'accounting/orders?_dc=1563489532611&page=1&start=0&per-page=1000&sort=[{"property":"AE","direction":"ASC"}]';
    if (filterItems != null) {
      filter = '&filter={"AE":"' + filterItems['date'] + '"';
    }

    if (filterItems != null) {
      if (filterItems['fio'] != null && filterItems['fio'] != 'Все') {
        filter += ',"Z":"'+filterItems['fio']+'"';
      }
    }
    if (filterItems != null) {
      if (filterItems['fioSt'] != null && filterItems['fioSt'] != 'Все') {
        filter += ',"AZ":"'+filterItems['fioSt']+'"';
      }
    }

    filter += '}';

    String token;
    await getToken().then((value) {
      token = value;
    });
    var url =_url+path+'&auth_token='+token+filter;
    print('Get orders=');
    print(filter);
    print(url);

    final response = await http.get(
        url,
        headers: { "Content-Type" : "application/json"}
    );
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.

      return json.decode(response.body)['items'];
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post');
    }
  }

  static Future<List<dynamic>> fetchOrdersAll(dynamic filterItems, {String sort = 'AE'}) async {
    String filter = '&filter='+jsonEncode(filterItems);
    String path = 'accounting/orders?_dc=1563489532611&page=1&start=0&per-page=500&sort=[{"property":"'+sort+'","direction":"ASC"}]';

    String token;
    await getToken().then((value) {
      token = value;
    });
    var url =_url+path+'&auth_token='+token+filter;
    print('Api: fetchOrdersAll========================');
    print(url);
    print(filter);

    final response = await http.get(
        url,
        headers: { "Content-Type" : "application/json"}
    );
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.

      return json.decode(response.body)['items'];
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post');
    }
  }

  static Future<dynamic> updateOrderStatus(dynamic recordId, Map<String,String> group) async {
    String path = 'accounting/orders/';
    String token;
    await getToken().then((value) {
      token = value;
    });

    var url =_url + path+ recordId.toString()+'?auth_token='+token;
    print(jsonEncode(group));
    print(url);

    final response = await http.put(
      url,
      headers: { "Content-Type" : "application/json", "Accept" : "application/json"},
      body: jsonEncode(group),
    );
    if (response.statusCode == 200) {
      print(json.decode(response.body));
      return true;
    } else {
      print(json.decode(response.body));
      return false;

      throw Exception('Failed to load post');
    }
  }

  static Future<dynamic> updateAll(Map<String,dynamic> group) async {
    String path = 'accounting/orders/update-all';
    String token;
    await getToken().then((value) {
      token = value;
    });

    var url =_url + path+'?auth_token='+token;
    print(jsonEncode(group));
    print(url);

    final response = await http.put(
      url,
      headers: { "Content-Type" : "application/json", "Accept" : "application/json"},
      body: jsonEncode(group),
    );
    if (response.statusCode == 200) {
      print(json.decode(response.body));
      return true;
    } else {
      print(json.decode(response.body));
      return false;

      throw Exception('Failed to load post');
    }
  }

  static getToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String getToken = await preferences.getString("auth_token");
    return getToken;
  }

}