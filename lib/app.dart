// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'home.dart';
import 'login.dart';
import 'orders.dart';
import 'orders_all.dart';
import 'colors.dart';
import 'details_table.dart';
import 'table.dart';
import 'details_table_sv.dart';


class IsLoading with ChangeNotifier {
  bool value = false;
  void setState(state) {
    value = state;
    notifyListeners();
  }
}

// TODO: Convert ShrineApp to stateful widget (104)
class GreenSofaApp extends StatelessWidget {

  @override


  Widget build(BuildContext context) {
    final ThemeData _kShrineTheme = _buildShrineTheme();
    return MaterialApp(
      title: 'Shrine',
      // TODO: Change home: to a Backdrop with a HomePage frontLayer (104)
      //home: HomePage(),
      // TODO: Make currentCategory field take _currentCategory (104)
      // TODO: Pass _currentCategory for frontLayer (104)
      // TODO: Change backLayer field value to CategoryMenuPage (104)
      //initialRoute: '/login',
      //onGenerateRoute: _getRoute,
      routes: {
        '/login':         (BuildContext context) => new LoginPage(),
        '/home':         (BuildContext context) => new HomePage(),
        '/orders':         (BuildContext context) => new OrdersPage(),
        '/orders-all':         (BuildContext context) => new OrdersAllPage(),
        '/orders-table':         (BuildContext context) => new DataTableDemo(),
      '/orders-table-shveka':   (BuildContext context) => new TableSveika(),
        '/table':         (BuildContext context) => new MyApp(),
        '/' :          (BuildContext context) => new LoginPage(),
      },
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ru', 'RU'),
      ],
      //theme: _kShrineTheme,
      // TODO: Add a theme (103)
    );
  }

  Route<dynamic> _getRoute(RouteSettings settings) {
    if (settings.name != '/login') {
      return null;
    }

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (BuildContext context) => LoginPage(),
      fullscreenDialog: true,
    );
  }


  ThemeData _buildShrineTheme() {
    final ThemeData base = ThemeData.light();
    return base.copyWith(
      accentColor: kShrineBrown900,
      primaryColor: kShrinePink100,
      buttonTheme: base.buttonTheme.copyWith(
        buttonColor: kShrinePink100,
        textTheme: ButtonTextTheme.normal,
      ),
      scaffoldBackgroundColor: kShrineBackgroundWhite,
      cardColor: kShrineBackgroundWhite,
      textSelectionColor: kShrinePink100,
      errorColor: kShrineErrorRed,
      // TODO: Add the text themes (103)
      textTheme: _buildShrineTextTheme(base.textTheme),
      primaryTextTheme: _buildShrineTextTheme(base.primaryTextTheme),
      accentTextTheme: _buildShrineTextTheme(base.accentTextTheme),
      // TODO: Add the icon themes (103)
      primaryIconTheme: base.iconTheme.copyWith(
          color: kShrineBrown900
      ),
      // TODO: Decorate the inputs (103)
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(),
      ),

    );
  }

  TextTheme _buildShrineTextTheme(TextTheme base) {
    return base.copyWith(
      headline: base.headline.copyWith(
        fontWeight: FontWeight.w500,
      ),
      title: base.title.copyWith(
          fontSize: 18.0
      ),
      caption: base.caption.copyWith(
        fontWeight: FontWeight.w400,
        fontSize: 14.0,
      ),
    ).apply(
      fontFamily: 'Rubik',
      displayColor: kShrineBrown900,
      bodyColor: kShrineBrown900,
    );
  }

}

// TODO: Build a Shrine Theme (103)
// TODO: Build a Shrine Text Theme (103)
