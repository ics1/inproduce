import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Api {
  //static final Api _instance = new Api.internal();
  //factory Api() => _instance;

  static String _url = 'http://admin.startsell.biz/api/';
  static String _urlBitrix = 'https://greensofa.bitrix24.ua/rest/1/6u40o9w4ficrhka0/';

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
      //print(json.decode(response.body)['items']);
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
    String path = 'accounting/orders?_dc=1563489532611&page=1&start=0&per-page=500&expand=orderWork,comment&sort=[{"property":"'+sort+'","direction":"ASC"},{"property":"index","direction":"ASC"}]';

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

  static Future<List<dynamic>> fetchEmployees(dynamic filterItems, {String sort = 'name'}) async {
    String filter = '&filter='+jsonEncode(filterItems);
    String path = 'accounting/employees?per-page=-1&sort=[{"property":"department_id","direction":"ASC"},{"property":"'+sort+'","direction":"ASC"}]';

    String token;
    await getToken().then((value) {
      token = value;
    });
    var url =_url+path+'&auth_token='+token+filter;
    print('Api: fetchEmployees========================');
    print(url);
    print(filter);

    final response = await http.get(
        url,
        headers: { "Content-Type" : "application/json"}
    );
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.

      return json.decode(response.body)['data'];
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post');
    }
  }

  static Future<List<dynamic>> fetch(String urlRest, dynamic filterItems, String sort) async {
    String filter = '&filter='+jsonEncode(filterItems);
    String path = urlRest+'?per-page=-1&sort=[{"property":"'+sort+'","direction":"ASC"}]';

    String token;
    await getToken().then((value) {
      token = value;
    });
    var url =_url+path+'&auth_token='+token+filter;
    print('Api: fetch'+urlRest+'========================');
    print(url);
    print(filter);

    final response = await http.get(
        url,
        headers: { "Content-Type" : "application/json"}
    );
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.

      return json.decode(response.body)['data'];
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post');
    }
  }

  static Future<List<dynamic>> fetchWorkTime(dynamic dateFrom, dynamic dateTo,{String sort = 'date_work'}) async {
    String filter = '&dateFrom='+dateFrom+'&dateTo='+dateTo;
    String path = 'accounting/employee/visits?sort=name';

    String token;
    await getToken().then((value) {
      token = value;
    });
    var url =_url+path+'&auth_token='+token+filter;
    print('Api: fetchWorkTime========================');
    print(url);
    print(filter);

    final response = await http.get(
        url,
        headers: { "Content-Type" : "application/jsonn"}
    );
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      return json.decode(response.body)['data'];
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post');
    }
  }


  static Future<dynamic> updateOrderStatus(dynamic recordId, Map<String,String> group) async {

    //updateOrderStatusBitrix(recordId, group);
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
      //print(json.decode(response.body));
      return true;
    } else {
      //print(json.decode(response.body));
      return false;

      throw Exception('Failed to load post');
    }
  }

  static Future<dynamic> updateFields(String path, dynamic recordId, Map<String,String> group) async {

    //updateOrderStatusBitrix(recordId, group);
    //String path = 'accounting/orders';
    String token;
    await getToken().then((value) {
      token = value;
    });

    var url =_url + path+'/'+ recordId.toString()+'?auth_token='+token;
    print(jsonEncode(group));
    print(url);

    final response = await http.put(
      url,
      headers: { "Content-Type" : "application/json", "Accept" : "application/json"},
      body: jsonEncode(group),
    );
    if (response.statusCode == 200) {
      //print(json.decode(response.body));
      return true;
    } else {
      //print(json.decode(response.body));
      return false;

      throw Exception('Failed to load post');
    }
  }

  static Future<dynamic> fetchRecord(String method, String path,  Map<String,String> group, String expand) async {

    //updateOrderStatusBitrix(recordId, group);
    //String path = 'accounting/orders';
    String token;
    await getToken().then((value) {
      token = value;
    });
    String expandUrl = '';
    if (expand != '') {
      expandUrl = '&expand='+expand;
    }
    var url =_url + path+''+ '?auth_token='+token+expandUrl;
    print(jsonEncode(group));
    print(url);;
    var response;

    if (method == 'post') {
      response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: jsonEncode(group),
      );
    }
    if (method == 'put') {
      response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json"
        },
        body: jsonEncode(group),
      );
    }
    if (response.statusCode == 200) {
      //print(json.decode(response.body));
      return json.decode(response.body);
    } else {
      //print(json.decode(response.body));
      return false;

      throw Exception('Failed to load post');
    }
  }

  static Future<dynamic> updateOrderStatusBitrix(dynamic recordId, Map<String,String> group) async {
    print(group);
    Map<String,String> status = {
      '1' : '567',
      '4' : '565',
      '' : '565',
      '2' : '565',
      '3' : '565',
      '5' : '565'
    };
    print(status[group['W']]);
    String path = 'lists.element.get';
    String token;
    await getToken().then((value) {
      token = value;
    });
    Map<String,dynamic> groupGetList = {};
    Map<String,dynamic> groupSetList = {};
    Map<String,String> filter = {};
    filter['=PROPERTY_497'] = "12071";
    groupGetList['IBLOCK_TYPE_ID'] = "lists_socnet";
    groupGetList['IBLOCK_ID'] = "81";
    groupGetList['SOCNET_GROUP_ID'] = "3";
    groupGetList['FILTER'] = filter;


    var url =_urlBitrix + path;
    //+ recordId.toString()+'?auth_token='+token;
    //print(jsonEncode(groupGetList));
    //print(url);

    final responseGetList = await http.post(
      url,
      headers: { "Content-Type" : "application/json", "Accept" : "application/json"},
      body: jsonEncode(groupGetList),
    );
    //print(responseGetList.body);
    if (responseGetList.statusCode == 200) {
      Map<String,dynamic> resultList = {};
      resultList = json.decode(responseGetList.body);
      groupSetList = resultList['result'][0];
      groupSetList['PROPERTY_1773'] = status[group['W']];

      groupGetList = {};
      groupGetList['IBLOCK_TYPE_ID'] = "lists_socnet";
      groupGetList['IBLOCK_ID'] = "81";
      groupGetList['SOCNET_GROUP_ID'] = "3";
      groupGetList['ELEMENT_ID'] = groupSetList['ID'];
      groupGetList['FIELDS'] = groupSetList;

      print(groupGetList);

      url =_urlBitrix + 'lists.element.update';
      //print(groupSetList);


      final response = await http.post(
        url,
        headers: { "Content-Type" : "application/json", "Accept" : "application/json"},
        body: jsonEncode(groupGetList),
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        print(json.decode(response.body));
        return true;
      } else {
        //throw Exception('Failed to load bitrix');
        print('Failed to load bitrix');
        print(json.decode(response.body));
        return false;

      }

    } else {
      print(json.decode(responseGetList.body));
      return false;
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
      //print(json.decode(response.body));
      return true;
    } else {
      //print(json.decode(response.body));
      return false;

      throw Exception('Failed to load post');
    }
  }
  static Future<dynamic> updateAllWorkTime(Map<String,dynamic> group) async {
    String path = 'accounting/employee-time-work/update-all';
    String token;
    await getToken().then((value) {
      token = value;
    });
    //_url = 'http://admin.startsellshop.local/api/';
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
  static Future<dynamic> updateWorkTime(dynamic recordId, Map<String,dynamic> group) async {

    //updateOrderStatusBitrix(recordId, group);
    String path = 'accounting/employee-time-works/';
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

  static getToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String getToken = await preferences.getString("auth_token");
    return getToken;
  }

}