import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:countup/countup.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Poland COVID-19',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.red,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'COVID19 w Polsce'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _lastUpdate = "";
  double _lastDayInjected = 0;
  double _allInjected = 0;
  double _currentInjected = 0;
  double _death = 0;
  double _deathAll = 0;
  double _recovered  = 0;
  double _hospitalisation = 0;
  double _totalTests = 0;
  double _injectedPerMilion = 0;
  double _testsPerMilion = 0;

  RefreshController _refreshController = RefreshController(initialRefresh: true);

  Future<http.Response> fetchData() {
    return http.get('https://coronavirus-19-api.herokuapp.com/countries/Poland');
  }

  void _onRefresh() async{

    DateTime now = DateTime.now();
    final response = await http.get('https://coronavirus-19-api.herokuapp.com/countries/Poland');

    if (response.statusCode == 200) {
      setState(() {
        Map<String, dynamic> dataResponse = jsonDecode(response.body);

        _lastUpdate = "${now.year.toString()}.${now.month.toString().padLeft(2,'0')}.${now.day.toString().padLeft(2,'0')} ${now.hour.toString()}:${now.minute.toString()}";

        _lastDayInjected = dataResponse['todayCases'].toDouble();
        _allInjected =dataResponse['cases'].toDouble();
        _currentInjected = dataResponse['active'].toDouble();
        _death = dataResponse['todayDeaths'].toDouble();
        _deathAll = dataResponse['deaths'].toDouble();
        _recovered  = dataResponse['recovered'].toDouble();
        _hospitalisation = dataResponse['critical'].toDouble();
        _totalTests = dataResponse['totalTests'].toDouble();
        _injectedPerMilion = dataResponse['casesPerOneMillion'].toDouble();
        _testsPerMilion = dataResponse['testsPerOneMillion'].toDouble();
      });

    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to data');
    }
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    if(mounted)
      setState(() {

      });
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("COVID-19 Polska"),
        backgroundColor: Colors.red,

      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: WaterDropHeader(),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
          child: Column(
            children: [
              Card(
                color: Colors.red[400],
                child: ListTile(
                  leading: Icon(Icons.access_time, size: 40, color: Colors.white,),
                  title: Text("OSTATNIE 24H", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle:
                  Countup(
                    begin: 0,
                    end: _lastDayInjected,
                    duration: Duration(seconds: 1),
                    separator: ' ',
                    style: TextStyle(
                      fontSize: 36,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              Card(
                color: Colors.red[900],
                child: ListTile(
                  leading: Icon(Icons.coronavirus, size: 40, color: Colors.white,),
                  title: Text("AKTUALNIE ZAKAZONYCH", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: Countup(
                    begin: 0,
                    end: _currentInjected,
                    duration: Duration(seconds: 1),
                    separator: ' ',
                    style: TextStyle(
                      fontSize: 36,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Card(
                color: Colors.red[700],
                child: ListTile(
                  leading: Icon(Icons.trending_up, size: 40, color: Colors.white,),
                  title: Text("ŁĄCZNA LICZBA", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: Countup(
                    begin: 0,
                    end: _allInjected,
                    duration: Duration(seconds: 1),
                    separator: ' ',
                    style: TextStyle(
                      fontSize: 36,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Card(
                color: Colors.black54,
                child: ListTile(
                  leading: Icon(Icons.person_remove, size: 40, color: Colors.white,),
                  title: Text("ZGONY 24H", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: Countup(
                    begin: 0,
                    end: _death,
                    duration: Duration(seconds: 1),
                    separator: ' ',
                    style: TextStyle(
                      fontSize: 36,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Card(
                color: Colors.black,
                child: ListTile(
                  leading: Icon(Icons.text_snippet, size: 40, color: Colors.white,),
                  title: Text("ZGONY WSZYSTKIE", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: Countup(
                    begin: 0,
                    end: _deathAll,
                    duration: Duration(seconds: 1),
                    separator: ' ',
                    style: TextStyle(
                      fontSize: 36,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Card(
                color: Colors.green,
                child: ListTile(
                  leading: Icon(Icons.healing, size: 40, color: Colors.white,),
                  title: Text("UZDROWIENCY", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: Countup(
                    begin: 0,
                    end: _recovered,
                    duration: Duration(seconds: 1),
                    separator: ' ',
                    style: TextStyle(
                      fontSize: 36,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Card(
                color: Colors.blue[700],
                child: ListTile(
                  leading: Icon(Icons.local_hospital, size: 40, color: Colors.white,),
                  title: Text("HOSPITALIZACJA", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: Countup(
                    begin: 0,
                    end: _hospitalisation,
                    duration: Duration(seconds: 1),
                    separator: ' ',
                    style: TextStyle(
                      fontSize: 36,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Card(
                color: Colors.grey[700],
                child: ListTile(
                  leading: Icon(Icons.leaderboard, size: 40, color: Colors.white,),
                  title: Text("WYKONANYCH TESTÓW", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: Countup(
                    begin: 0,
                    end: _totalTests,
                    duration: Duration(seconds: 1),
                    separator: ' ',
                    style: TextStyle(
                      fontSize: 36,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Card(
                color: Colors.red[600],
                child: ListTile(
                  leading: Icon(Icons.arrow_forward, size: 40, color: Colors.white,),
                  title: Text("LICZBA ZAKAŻEN NA 1MLN", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: Countup(
                    begin: 0,
                    end: _injectedPerMilion,
                    duration: Duration(seconds: 1),
                    separator: ' ',
                    style: TextStyle(
                      fontSize: 36,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              Card(
                color: Colors.grey[800],
                child: ListTile(
                  leading: Icon(Icons.check, size: 40, color: Colors.white,),
                  title: Text("TESTOW NA 1MLN", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: Countup(
                    begin: 0,
                    end: _testsPerMilion,
                    duration: Duration(seconds: 1),
                    separator: ' ',
                    style: TextStyle(
                      fontSize: 36,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              Container (
                padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text("OSTATNIA AKTUALIZACJA: $_lastUpdate", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          )
        )
      ),
    );
  }



}
