import 'package:flutter/material.dart';

class MusiclickAppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text("Visitor"),
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage("lib/assets/images/defaultbg.jpg"), fit: BoxFit.cover)
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed('/downloads');
            },
            child: ListTile(
              leading: Icon(Icons.history),
              title: Text("Download History"),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed('/queue');
            },
            child: ListTile(
              leading: Icon(Icons.queue),
              title: Text("Download Queue"),
            ),
          )
        ],
      ),
    );
  }
}