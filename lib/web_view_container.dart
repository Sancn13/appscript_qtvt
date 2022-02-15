import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
class WebViewContainer extends StatefulWidget {
  final url;
  final page;
  final title;
  final app_data;
  WebViewContainer(this.url, this.page, this.title, this.app_data);
  @override
  createState() => _WebViewContainerState(this.url,this.page,this.title,this.app_data);
}
class _WebViewContainerState extends State<WebViewContainer> {

  var _url;
  var page;
  var title="";
  var app_data;
  String coordinates = "";
  final _key = UniqueKey();
  _WebViewContainerState(this._url,this.page,this.title,this.app_data);

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    } 

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return position;
  }

  void getCurrentLocation()async{
    Position position = await _determinePosition();
    setState(() {
      coordinates = '&&lat=' + position.latitude.toString() + '&&lng=' + position.longitude.toString();
    });
  }

  Icon loadIcon(String name_button){
    if(name_button == 'Dữ liệu tổng hợp'){
      return Icon(Icons.analytics);
    }
    else if(name_button == 'Thêm cơ sở'){
      return Icon(Icons.add);
    }
    else if(name_button == 'Tìm cơ sở'){
      return Icon(Icons.search);
    }
    else if(name_button == 'Tùy chọn'){
      return Icon(Icons.settings);
    }
    else if(name_button == 'Đăng xuất'){
      return Icon(Icons.logout);
    }
    else{
      return Icon(Icons.help_rounded);
    }
  }

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }

  //final List<String> entries = <String>['data-report', 'add-workgroup', 'search-workgroup','setting','logout'];
  //final List<String> colorCodes = <String>['Dữ liệu tổng hợp', 'Thêm cơ sở', 'Tìm cơ sở','Tùy chọn','Đăng xuất'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text('Quản trị vùng trồng',
                style: TextStyle(color: Colors.white)),
              ),
              ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: app_data.length,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: loadIcon(app_data[index][1]),
                    title: Text(app_data[index][1]),
                    onTap: () {
                      Navigator.push(context,MaterialPageRoute(builder: (context) => WebViewContainer(_url,app_data[index][2] + coordinates,app_data[index][1],app_data)),);
                    },
                  );
                },
                separatorBuilder: (BuildContext context, int index) => const Divider(),
              )

            ],
          ),
        ),
        body: title != 'Tùy chọn' ? Column(
          children: [
            Expanded(
                child: WebView(
                    key: _key,
                    javascriptMode: JavascriptMode.unrestricted,
                    initialUrl: page!='logout'?_url + page:'https://accounts.google.com/Logout',
                    gestureNavigationEnabled: true,
                    userAgent: "random",
                  )
            )
          ],
        ):Center(
          child: Text(':3'),
        )
      );
  }
}