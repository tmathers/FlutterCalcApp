import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;


void main() => runApp(new MyApp());

/**
 * The Stateless widget class
 *
 */
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Calc App',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Calculation App'),
    );
  }
}

/**
 * The stateful widget class.
 *
 */
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

/**
 * The state class
 */
class _MyHomePageState extends State<MyHomePage> {
  String _calc = "";
  bool _calculating = false;
  List<String> _history = [];

  final String url = "http://test.ethorstat.com/test.ashx";

  /**
   * Performs the calculation and updates the state.
   *
   */
  void _doCalc() async {
      _setCalculating(true);

      await Future.delayed(const Duration(seconds: 1));

      Map decoded = await _getJsonData();

      int parm1 = decoded['parm1'];
      int parm2 = decoded['parm2'];
      String op = decoded['op'];

      String equation = decoded['parm1'].toString() + " " + op + " "
          + decoded['parm2'].toString() + " = ";
      double answer = 0.0;

      switch (op) {
        case "+":
          equation += (parm1 + parm2).toString();
          break;
        case "-":
          equation += (parm1 - parm2).toString();
          break;
        case "*":
          equation += (parm1 * parm2).toString();
          break;
        case "/":
          double answer = parm1 / parm2;
          if (answer % 1 == 0) {
            equation += answer.toInt().toString();
          } else {
            equation += answer.toStringAsFixed(3);
          }
          break;
        default:
          print("Unrecognozed op: " + op);
          equation += "?";
      }

      if (_calculating) {
        _calc = equation;

        // Add to top of history
        _history.insert(0, _calc);
        _setCalculating(false);
      }

  }

  /**
   * Gets the JSON data from the URL
   *
   * @return A Map of the JSON data
   */
  Future<Map> _getJsonData() async {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // If the call to the server was successful, return the JSON
      return json.decode(response.body);
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load calc data ');
    }
  }

  /**
   * Sets the calculating variable
   *
   * @param bool calulating
   */
  void _setCalculating(bool calculating) {
    setState(() {
      _calculating = calculating;
      if (calculating) {
        // reset the calculation
        _calc = "";
      }
      print ("Setting state: " + calculating.toString());
      print ("History: " + _history.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(

        appBar: new AppBar(
          title: new Text(widget.title),
        ),
        body: new Column(

            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    new RaisedButton(
                      child: Text(_calculating ? "Stop" : "Start"),
                      elevation: 4.0,
                      splashColor: Colors.blueGrey,
                      onPressed: () {
                        if (_calculating) {
                          _setCalculating(false);
                          // stop calculating
                        } else {
                          _doCalc();
                        }
                      },

                    ),
                    new Container(
                      margin: const EdgeInsets.only(top: 20.0),
                      child : new Text(
                        '$_calc',
                        style: Theme
                          .of(context)
                          .textTheme
                          .display1,
                      ),
                    ),
                  ],
                ),
                flex: 1,
              ),
              Expanded(
                child: new Scrollbar( child:
                    new ListView.builder(
                      shrinkWrap: true,

                      padding: const EdgeInsets.all(20.0),
                      itemBuilder: (BuildContext context, int index) {
                          return new Text(_history[index],
                            style: new TextStyle(fontSize: 20.0),
                          );
                      },
                      itemCount: _history.length,

                    ),
                ),
                flex:1
              ),
            ],
          ),
        )
    ;
  }
}
