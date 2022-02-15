import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_qtvt_gas/web_view_container.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class App extends StatefulWidget {
  const App({ Key? key }) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {

  String url_api = "";
  String times = '';
  List<dynamic> menu = [];

  void checkVersion()async{
      var client = http.Client();
      var response = await client.get(Uri.parse('https://script.google.com/macros/s/AKfycbw5VGFfqvZsZ9QiQeoN8fLuHwigB5JRqlA7YCXWYjXhRJF1KlLB0c4igMPnKTTR4ZM/exec?api=last_version'));
      var json = jsonDecode(response.body);
      print(response);
      setState(() {
        print(url_api);
        url_api = json[0][1];
      });
  }

  void getDataApp()async{
    var client = http.Client();
      var response = await client.get(Uri.parse('https://script.google.com/macros/s/AKfycbxo75fXZG1iNhViff0UV8UURb914BlGiy4AHUnAxiTPf45N_ZwlISwVCbI_RIg4WUxV/exec?api=app/drawer'));
      var json = jsonDecode(response.body);
      setState(() {
        menu = json;
      });
  }

 @override
  void initState() {
    checkVersion();
    getDataApp();
    super.initState();
  }

 @override
  Widget build(BuildContext context){
    return MaterialApp(
        title: 'Flutter Web Views',
        theme: ThemeData(
            primarySwatch: Colors.blue,
            fontFamily: "Arial",),
        home: url_api != "" && menu != [] ? WebViewContainer(url_api,menu[2][2],menu[2][1],menu)
        : MaterialApp(
        title: 'Flutter Web Views',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: "Arial",),
        home: Scaffold(
        appBar: AppBar(),
        body: Center(
          child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              Text('loading')
            ],
          )
        ))
      )
    );
  }
}