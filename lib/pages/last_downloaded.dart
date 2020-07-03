import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LastDownloadedsPage extends StatefulWidget {
  @override
  _LastDownloadedsPageState createState() => _LastDownloadedsPageState();
}

class _LastDownloadedsPageState extends State<LastDownloadedsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("yakında...", style: TextStyle(fontSize: 16)),
      ),
    );
  }
}