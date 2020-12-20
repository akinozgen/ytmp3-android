import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ytmp3/components/musiclick_appdrawer.dart';

class QueuePage extends StatefulWidget {
  @override
  _QueuePageState createState() => _QueuePageState();
}

class _QueuePageState extends State<QueuePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> _queue = [];

  @override
  void initState() {
    super.initState();
    print("calling: queue page");
    setQueue();
  }

  void setQueue() async {
    final prefs = await SharedPreferences.getInstance();
    var queue = prefs.getString('queue') ?? "";
    if (queue.length == 0) return;

    setState(() {
      _queue = jsonDecode(queue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: MusiclickAppDrawer(),
      appBar: AppBar(
        centerTitle: true,
        title: Text('musiclick'),
        actions: <Widget>[],
      ),
      body: RefreshIndicator(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 20, bottom: 10),
                child: Text("Download Queue", style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w400
                )),
              )
            ],
          ),
          onRefresh: () async {
            await setQueue();
          },
        ),
    );
  }
}