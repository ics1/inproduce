import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth/auth.dart';


class LoginPage extends StatefulWidget {
  @override
  String errorUsername = null;
  String errorPassword = null;
  _LoginPageState createState() => _LoginPageState();


}

class _LoginPageState extends State<LoginPage> {
  // TODO: Add text editing controllers (101)
  BuildContext _ctx;

  @override
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();


  @override

  /*_LoginPageState() {
    //dynamic isLogin = isUserLogin();
    /*isLogin.then((value){
      if (value == true) {
         Navigator.of(_ctx).pushReplacementNamed("/home");
      }
    });*/
    /*getUsername().then((value) {
      _usernameController.text = value;
    });*/
    /*getPassword().then((value) {
      _passwordController.text = value;
    });*/
  }*/
  void initState() {
    super.initState();
    dynamic isLogin = isUserLogin();
    isLogin.then((value){
      if (value == true) {
         Navigator.of(_ctx).pushReplacementNamed("/home");
      }
    });
    getUsername().then((value) {
      _usernameController.text = value;
    });
    getPassword().then((value) {
      _passwordController.text = value;
    });
  }

  Widget build(BuildContext context) {
    _ctx = context;
    //final key = new GlobalKey<ScaffoldState>();
    return Scaffold(
      //key: key,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            SizedBox(height: 80.0),
            Column(
              children: <Widget>[
                //Image.asset('assets/diamond.png'),
                SizedBox(height: 16.0),
                /*Image.network(
                  'http://greensofa.net/uploads/product/greensofa/system-settings/5a8b09bf31121.png',
                ),*/
                new Image.asset(
                  'assets/logo.png',
                  width: 210.0,
                  height: 40.0,
                  fit: BoxFit.cover,
                ),
                //Text('GreenSofa'),
              ],
            ),
            SizedBox(height: 120.0),
            // TODO: Wrap Username with AccentColorOverride (103)
            // TODO: Remove filled: true values (103)
            // TODO: Wrap Password with AccentColorOverride (103)
            // TODO: Add TextField widgets (101)
            // TODO: Add button bar (101)
            AccentColorOverride(
              color: kShrineBrown900,
              child: TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorText: widget.errorUsername,
                ),
              ),
            ),
            // spacer
            SizedBox(height: 12.0),
            // [Password]
            AccentColorOverride(
              color: kShrineBrown900,
              child: TextField(
                obscureText: true,
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  errorText: widget.errorPassword,
                ),
              ),
            ),
            ButtonBar(
              // TODO: Add a beveled rectangular border to CANCEL (103)
              children: <Widget>[
                // TODO: Add an elevation to NEXT (103)
                // TODO: Add a beveled rectangular border to NEXT (103)
                RaisedButton(
                  child: Text('Вход'),
                  elevation: 8.0,
                  onPressed: () async {
                    Future<dynamic> result = fetchLogin(_usernameController.text, _passwordController.text);
                    result.then((value) {
                        if (value['success'] == true) {
                          setUserLogin(value, _usernameController.text, _passwordController.text);
                          Navigator.of(_ctx).pushReplacementNamed("/home");
                        } else if(value['success'] == false) {
                          validateForm(value['errors']);
                        } else {
                          Scaffold.of(_ctx).showSnackBar(new SnackBar(
                            content: new Text(value['message']),
                          ));
                        }
                    });
                  },
                ),
                // TODO: Add buttons (101)
              ],
            ),
          ],
        ),
      ),
    );
  }

  String validateForm(errors) {
    if (errors['username'] != null) {
      setState(() {
        widget.errorUsername = errors['username'][0];
      });
    }
    if (errors['password'] != null) {
      setState(() {
        widget.errorPassword = errors['password'][0];
      });
    }

  }
}


class AccentColorOverride extends StatelessWidget {
  const AccentColorOverride({Key key, this.color, this.child})
      : super(key: key);

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      child: child,
      data: Theme.of(context).copyWith(
        accentColor: color,
        brightness: Brightness.dark,
      ),
    );
  }
}



Future<dynamic> fetchLogin(String username, String password) async {
  var url = 'http://admin.startsell.biz/api/users/login';
  final response =
  await http.post(
      url,
      body: {'username':username, 'password': password},
      headers: {
        "Accept": "*/*",
        "Content-Type": "application/x-www-form-urlencoded"
      },
      encoding: Encoding.getByName("utf-8")

  );
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    // If that response was not OK, throw an error.

    return json.decode(response.body);
    //throw Exception('Failed to load post');
  }
}

Future<void> setUserLogin(dynamic user, String username, String password) async{
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setString("auth_token", user['token']);
  pref.setBool("is_login", true);
  pref.setString("username", username);
  pref.setString("password", password);
  pref.setString("fio", user['user']['username']);
  pref.setInt("type", user['user']['type']);
}

Future<dynamic> isUserLogin() async{
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getBool("is_login");
}

getUsername() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  String getUsername = await preferences.getString("username");
  return getUsername;
}

getPassword() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();

  String getPassword = await preferences.getString("password");
  return getPassword;
}
