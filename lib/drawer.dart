import 'package:flutter/material.dart';

class DrawerWebView extends StatefulWidget {
  const DrawerWebView({ Key? key }) : super(key: key);

  @override
  _DrawerWebViewState createState() => _DrawerWebViewState();
}

class _DrawerWebViewState extends State<DrawerWebView> {
  @override
  Widget build(BuildContext context) {
    return ListView(
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
          },
        ),
        ListTile(
          leading: Icon(Icons.add),
          title: const Text('Thêm cơ sở'),
          onTap: () {
          },
        ),
        ListTile(
          leading: Icon(Icons.search),
          title: const Text('Tìm cơ sở'),
          onTap: () {
          },
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: const Text('Tùy chọn'),
          onTap: () {
          },
        ),
        ListTile(
          leading: Icon(Icons.logout),
          title: const Text('Đăng xuất'),
          onTap: () {
          },
        ),
      ],
    );
  }
}