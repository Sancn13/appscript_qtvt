import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webview_flutter/webview_flutter.dart';
class WebViewContainer extends StatefulWidget {
  final url;
  final page;
  final title;
  WebViewContainer(this.url, this.page, this.title);
  @override
  createState() => _WebViewContainerState(this.url,this.page,this.title);
}
class _WebViewContainerState extends State<WebViewContainer> {

  var _url;
  var page;
  var title="";
  String coordinates = "";
  final _key = UniqueKey();
  _WebViewContainerState(this._url,this.page,this.title);

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

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }

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
              ListTile(
                leading: Icon(Icons.analytics),
                title: const Text('Dữ liệu tổng hợp'),
                onTap: () {
                  Navigator.push(context,MaterialPageRoute(builder: (context) => WebViewContainer(_url,'data-report','Dữ liệu tổng hợp')),);
                },
              ),
              ListTile(
                leading: Icon(Icons.add),
                title: const Text('Thêm cơ sở'),
                onTap: () {
                  Navigator.push(context,MaterialPageRoute(builder: (context) => WebViewContainer(_url,'add-workgroup' + coordinates,'Thêm cơ sở')),);
                },
              ),
              ListTile(
                leading: Icon(Icons.search),
                title: const Text('Tìm cơ sở'),
                onTap: () {
                  Navigator.push(context,MaterialPageRoute(builder: (context) => WebViewContainer(_url,'search-workgroup' + coordinates,'Tìm cơ sở')),);
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: const Text('Tùy chọn'),
                onTap: () {
                  Navigator.push(context,MaterialPageRoute(builder: (context) => WebViewContainer(_url,'search-workgroup' + coordinates,'Tùy chọn')),);
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: const Text('Đăng xuất'),
                onTap: () {

                  Navigator.push(context,MaterialPageRoute(builder: (context) => WebViewContainer(_url,"logout","Đăng xuất")),);
                },
              ),
            ],
          ),
        ),
        body: title != 'Tùy chọn' ? Column(
          children: [
            Expanded(
                child: WebView(
                    key: _key,
                    javascriptMode: JavascriptMode.unrestricted,
                    initialUrl: page!='logout'?_url + "?page=" + page:'https://accounts.google.com/Logout',
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