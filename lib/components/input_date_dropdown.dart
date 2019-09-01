
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

DateTime picked = new DateTime.now();

class InputDateDropdown extends StatefulWidget {
  final String labelText;
  String valueText;
  final TextStyle valueStyle;
  final VoidCallback onPressed;
  final Widget child;
  InputDateDropdown(
      {Key key,
        this.child,
        this.labelText,
        this.valueText,
        this.valueStyle,
        this.onPressed})
      : super(key: key);

  InputDateDropdownState inputDateDropdownState = new InputDateDropdownState();
  @override
  InputDateDropdownState createState() => inputDateDropdownState;

  void setDate(value) {
    inputDateDropdownState.setDate(value);
  }
  String getDate() {
    return inputDateDropdownState.getDate();
  }

}

class InputDateDropdownState extends State<InputDateDropdown> {
  String _valueText;


  initState() {
    super.initState();
    setState(() {
      _valueText = widget.valueText;

    });
  }

  void setDate(value) {
    setState(() {
      _valueText = value;
      widget.valueText  = _valueText;
    });

  }
  String getDate() {
    return _valueText;
  }
  @override
  Widget build(BuildContext context) {
    return new InkWell(
      onTap: _onClicked,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          new Text(_valueText, style: widget.valueStyle),
          new Icon(Icons.arrow_drop_down,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey.shade700
                  : Colors.white70),
          new IconButton(
            icon: new Icon(Icons.close),
            onPressed: () {
              setState(() {
                _valueText = '';
                widget.valueText  = _valueText;
                widget.onPressed();
              });

            }
          )
        ],
      ),
    );
  }

  void _onClicked() {
    _selectDate(context, _valueText, _onSelectDate);
  }

  _onSelectDate(picked) {

    setState(() {
      _valueText = new DateFormat('dd.MM.yy').format(picked);
      widget.valueText  = _valueText;
    });
    widget.onPressed();
  }

}


Future<Null> _selectDate(context, dateValue, onSelectDateFun) async {
  DateTime dateFormat;
  if (dateValue == '' ) {
    dateValue = DateFormat('dd.MM.yy').format(new DateTime.now());
  }
  dateFormat = new DateFormat('dd.MM.yy').parse(dateValue).add(Duration(milliseconds: DateTime(1970 + 2000).millisecondsSinceEpoch+24*60*60*100));

  picked = await showDatePicker(
      context: context,
      //locale:  Locale('ru', 'RU'),
      initialDate: dateFormat,
      firstDate: new DateTime(1918),
      lastDate: new DateTime(2030)
  );

  if (picked != null) {
    onSelectDateFun(picked);
  }
}

