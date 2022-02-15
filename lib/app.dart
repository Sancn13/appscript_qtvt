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


  /*void checkVersion()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if( prefs.getString('version') != ""){
      print('case1');
      setState(() {
        url_api = prefs.getString('version')!;
        print(prefs.getString('version'));
      });
    }
    else{
      print('case2');
      var client = http.Client();
      var response = await client.get(Uri.parse('https://script.google.com/macros/s/AKfycbwYat3L816IAx_MVHEk2QsXE7_qi4qyB68EOnkmEIPpXyANiRaNeGgIt0DSK50r4vwe/exec?api=test_version'));
      var json = jsonDecode(response.body);
      print(json);
      setState(() {
        print(url_api);
        url_api = json[0][1];
      });
      await prefs.setString('version', url_api);
    }
  }*/

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

 @override
  void initState() {
    checkVersion();
    super.initState();
  }

 @override
  Widget build(BuildContext context){
    return MaterialApp(
        title: 'Flutter Web Views',
        theme: ThemeData(
            primarySwatch: Colors.blue,
            fontFamily: "Arial",),
        home: url_api != "" ? WebViewContainer(url_api,'search-workgroup','Tìm cơ sở')
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