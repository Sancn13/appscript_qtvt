import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
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

  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        supportMultipleWindows: true,
        useHybridComposition: true,
        displayZoomControls: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  late PullToRefreshController pullToRefreshController;
  late ContextMenu contextMenu;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

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
    if(name_button == 'D??? li???u t???ng h???p'){
      return Icon(Icons.analytics);
    }
    else if(name_button == 'Th??m c?? s???'){
      return Icon(Icons.add);
    }
    else if(name_button == 'T??m c?? s???'){
      return Icon(Icons.search);
    }
    else if(name_button == 'T??y ch???n'){
      return Icon(Icons.settings);
    }
    else if(name_button == '????ng xu???t'){
      return Icon(Icons.logout);
    }
    else if(name_button == '?????ng b??? d??? li???u'){
      return Icon(Icons.sync);
    }
    else{
      return Icon(Icons.help_rounded);
    }
  }

  Future<String> someFutureStringFunction() async {
    return Future.delayed(const Duration(seconds: 1), () => "someText");
  }

  Widget loadPage(title){
    if (title == 'T??y ch???n'){
      return Center(
        child: Text(':3'),
      );
    }
    else if(title == '????ng xu???t'){
      return Expanded(
          child: Stack(
            children: [
              InAppWebView(
                key: webViewKey,
                // contextMenu: contextMenu,
                initialUrlRequest:
                URLRequest(url: Uri.parse('https://accounts.google.com/Logout')),
                // initialFile: "assets/index.html",
                initialUserScripts: UnmodifiableListView<UserScript>([]),
                initialOptions: options,
                pullToRefreshController: pullToRefreshController,
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                onLoadStart: (controller, url) {
                  setState(() {
                    this.url = url.toString();
                    urlController.text = this.url;
                  });
                },
                androidOnPermissionRequest: (controller, origin, resources) async {
                  return PermissionRequestResponse(
                      resources: resources,
                      action: PermissionRequestResponseAction.GRANT);
                },
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  var uri = navigationAction.request.url!;

                  if (![
                    "http",
                    "https",
                    "file",
                    "chrome",
                    "data",
                    "javascript",
                    "about"
                  ].contains(uri.scheme)) {
                    if (await canLaunch(url)) {
                      // Launch the App
                      await launch(
                        url,
                      );
                      // and cancel the request
                      return NavigationActionPolicy.CANCEL;
                    }
                  }

                  return NavigationActionPolicy.ALLOW;
                },
                onLoadStop: (controller, url) async {
                  pullToRefreshController.endRefreshing();
                  setState(() {
                    this.url = url.toString();
                    urlController.text = this.url;
                  });
                },
                onLoadError: (controller, url, code, message) {
                  pullToRefreshController.endRefreshing();
                },
                onProgressChanged: (controller, progress) {
                  if (progress == 100) {
                    pullToRefreshController.endRefreshing();
                  }
                  setState(() {
                    this.progress = progress / 100;
                    urlController.text = this.url;
                  });
                },
                onUpdateVisitedHistory: (controller, url, androidIsReload) {
                  setState(() {
                    this.url = url.toString();
                    urlController.text = this.url;
                  });
                },
                onConsoleMessage: (controller, consoleMessage) {
                  print(consoleMessage);
                },
              ),
              progress < 1.0
                  ? LinearProgressIndicator(value: progress)
                  : Container(),
            ],
          ),
      );
    }
    else if(title == 'T???ng h???p d??? li???u'){
      String page_data_studio = '';
      if(page == 'x??'){
        page_data_studio = _url + '?page=data-report-ward';
      }
      else if(page == 'huy???n'){
        page_data_studio = _url + '?page=data-report-district';
      }
      else if(page == 't???nh'){
        page_data_studio = _url + '?page=data-report-province';
      }
      else{
        page_data_studio = 'https://datastudio.google.com/';
      }

      return Expanded(
          child: Stack(
            children: [
              InAppWebView(
                key: webViewKey,
                // contextMenu: contextMenu,
                initialUrlRequest:
                URLRequest(url: Uri.parse(page_data_studio)),
                // initialFile: "assets/index.html",
                initialUserScripts: UnmodifiableListView<UserScript>([]),
                initialOptions: options,
                pullToRefreshController: pullToRefreshController,
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                onLoadStart: (controller, url) {
                  setState(() {
                    this.url = url.toString();
                    urlController.text = this.url;
                  });
                },
                androidOnPermissionRequest: (controller, origin, resources) async {
                  return PermissionRequestResponse(
                      resources: resources,
                      action: PermissionRequestResponseAction.GRANT);
                },
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  var uri = navigationAction.request.url!;

                  if (![
                    "http",
                    "https",
                    "file",
                    "chrome",
                    "data",
                    "javascript",
                    "about"
                  ].contains(uri.scheme)) {
                    if (await canLaunch(url)) {
                      // Launch the App
                      await launch(
                        url,
                      );
                      // and cancel the request
                      return NavigationActionPolicy.CANCEL;
                    }
                  }

                  return NavigationActionPolicy.ALLOW;
                },
                onLoadStop: (controller, url) async {
                  pullToRefreshController.endRefreshing();
                  setState(() {
                    this.url = url.toString();
                    urlController.text = this.url;
                  });
                },
                onLoadError: (controller, url, code, message) {
                  pullToRefreshController.endRefreshing();
                },
                onProgressChanged: (controller, progress) {
                  if (progress == 100) {
                    pullToRefreshController.endRefreshing();
                  }
                  setState(() {
                    this.progress = progress / 100;
                    urlController.text = this.url;
                  });
                },
                onUpdateVisitedHistory: (controller, url, androidIsReload) {
                  setState(() {
                    this.url = url.toString();
                    urlController.text = this.url;
                  });
                },
                onConsoleMessage: (controller, consoleMessage) {
                  print(consoleMessage);
                },
              ),
              progress < 1.0
                  ? LinearProgressIndicator(value: progress)
                  : Container(),
            ],
          ),
      );
    }
    else {
      return Expanded(
        child: Stack(
          children: [
            InAppWebView(
              key: webViewKey,
              // contextMenu: contextMenu,
              initialUrlRequest:
              URLRequest(url: Uri.parse(_url + page)),
              // initialFile: "assets/index.html",
              initialUserScripts: UnmodifiableListView<UserScript>([]),
              initialOptions: options,
              pullToRefreshController: pullToRefreshController,
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              onLoadStart: (controller, url) {
                setState(() {
                  this.url = url.toString();
                  urlController.text = this.url;
                });
              },
              androidOnPermissionRequest: (controller, origin, resources) async {
                return PermissionRequestResponse(
                    resources: resources,
                    action: PermissionRequestResponseAction.GRANT);
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                var uri = navigationAction.request.url!;

                if (![
                  "http",
                  "https",
                  "file",
                  "chrome",
                  "data",
                  "javascript",
                  "about"
                ].contains(uri.scheme)) {
                  if (await canLaunch(url)) {
                    // Launch the App
                    await launch(
                      url,
                    );
                    // and cancel the request
                    return NavigationActionPolicy.CANCEL;
                  }
                }

                return NavigationActionPolicy.ALLOW;
              },
              onLoadStop: (controller, url) async {
                pullToRefreshController.endRefreshing();
                setState(() {
                  this.url = url.toString();
                  urlController.text = this.url;
                });
              },
              onLoadError: (controller, url, code, message) {
                pullToRefreshController.endRefreshing();
              },
              onProgressChanged: (controller, progress) {
                if (progress == 100) {
                  pullToRefreshController.endRefreshing();
                }
                setState(() {
                  this.progress = progress / 100;
                  urlController.text = this.url;
                });
              },
              onUpdateVisitedHistory: (controller, url, androidIsReload) {
                setState(() {
                  this.url = url.toString();
                  urlController.text = this.url;
                });
              },
              onConsoleMessage: (controller, consoleMessage) {
                print(consoleMessage);
              },
            ),
            progress < 1.0
                ? LinearProgressIndicator(value: progress)
                : Container(),
          ],
        ),
          );
    }
  }

  @override
  void initState() {
    
    contextMenu = ContextMenu(
        menuItems: [
          ContextMenuItem(
              androidId: 1,
              iosId: "1",
              title: "Special",
              action: () async {
                print("Menu item Special clicked!");
                print(await webViewController?.getSelectedText());
                await webViewController?.clearFocus();
              })
        ],
        options: ContextMenuOptions(hideDefaultSystemContextMenuItems: false),
        onCreateContextMenu: (hitTestResult) async {
          print("onCreateContextMenu");
          print(hitTestResult.extra);
          print(await webViewController?.getSelectedText());
        },
        onHideContextMenu: () {
          print("onHideContextMenu");
        },
        onContextMenuActionItemClicked: (contextMenuItemClicked) async {
          var id = (Platform.isAndroid)
              ? contextMenuItemClicked.androidId
              : contextMenuItemClicked.iosId;
          print("onContextMenuActionItemClicked: " +
              id.toString() +
              " " +
              contextMenuItemClicked.title);
        });

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
    getCurrentLocation();
    super.initState();
  }

  bool _isExpanded = false;

  //final List<String> entries = <String>['data-report', 'add-workgroup', 'search-workgroup','setting','logout'];
  //final List<String> colorCodes = <String>['D??? li???u t???ng h???p', 'Th??m c?? s???', 'T??m c?? s???','T??y ch???n','????ng xu???t'];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode (SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 30),
              child: GestureDetector(
                child: Icon(Icons.refresh),
                onTap: () {
                  webViewController?.reload();
                },
              ),
            ),
          ]
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text('Qu???n tr??? v??ng tr???ng',
                style: TextStyle(color: Colors.white)),
              ),
              ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: app_data.length,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  if(app_data[index][1] == 'D??? li???u t???ng h???p'){
                    return ExpansionTile(
                      title: ListTile(
                          leading: loadIcon('D??? li???u t???ng h???p'),
                          title: Text('D??? li???u t???ng h???p'),
                      ),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 30, right: 60),
                          child: ListTile(
                            title: Text('D??? li???u t???nh'),
                            onTap: () {
                              Navigator.push(context,MaterialPageRoute(builder: (context) => WebViewContainer(_url,'t???nh','T???ng h???p d??? li???u',app_data)),);
                            }
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 30, right: 60),
                          child: ListTile(
                            title: Text('D??? li???u huy???n'),
                            onTap: () {
                              Navigator.push(context,MaterialPageRoute(builder: (context) => WebViewContainer(_url,'huy???n','T???ng h???p d??? li???u',app_data)),);
                            }
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 30, right: 60),
                          child: ListTile(
                            title: Text('D??? li???u x??/ph?????ng'),
                            onTap: () {
                              Navigator.push(context,MaterialPageRoute(builder: (context) => WebViewContainer(_url,'x??','T???ng h???p d??? li???u',app_data)),);
                            }
                          ),
                        ),
                      ],
                    );
                  }
                  else{
                    return Padding(
                      padding: const EdgeInsets.only(left:15),
                      child: ListTile(
                        leading: loadIcon(app_data[index][1]),
                        title: Text(app_data[index][1]),
                        onTap: () {
                          Navigator.push(context,MaterialPageRoute(builder: (context) => WebViewContainer(_url,app_data[index][2] + coordinates,app_data[index][1],app_data)),);
                        },
                      ),
                    );
                  }
                },
                separatorBuilder: (BuildContext context, int index) => const Divider(),
              )

            ],
          ),
        ),
        body: SafeArea(
          child: Column(children: <Widget>[
            loadPage(title),
        ]))
    );
  }
}