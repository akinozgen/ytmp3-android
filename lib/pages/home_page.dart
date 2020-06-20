import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:share_extend/share_extend.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String appBarState = "Default";
  TextEditingController _searchController = new TextEditingController();
  final String search_endpoint = "http://ytmp3serverandroid001.tk";
  List<dynamic> _searchResults;
  String _sharedText = "";
  StreamSubscription _intentStream;
  List<dynamic> _history;
  bool _isDownloading = false;
  int _downloadingProgress = 0;
  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();
    print("calling");

    _intentStream = ReceiveSharingIntent.getTextStream().listen((String value) {
      if (value.length > 0) {
        setState(() {
          _sharedText = value.split('/').last;
          refreshVideoInfo();
        });
      }
    }, onError: (err) {
      print("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String value) {
      if (value.length > 0) {
        setState(() {
          _sharedText = value.split('/').last;
          refreshVideoInfo();
        });
      }
    });

    getHistory();
  }

  void getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<dynamic> history = jsonDecode(
        prefs.getString('history') != null ? prefs.getString('history') : '[]');
    setState(() {
      _history = history;
    });
  }

  void download( String videoId, String title, Map<dynamic, dynamic> snippet) async {
    var downloadsPath = await ExtStorage.getExternalStoragePublicDirectory(
        ExtStorage.DIRECTORY_MUSIC);
    String url = "http://ytmp3serverandroid001.tk/get-mp3/" +
        videoId +
        "/" +
        title +
        ".mp3";

    downloadFile(url,
        id: videoId,
        filename: (snippet['title'] + ".mp3"),
        path: downloadsPath,
        snippet: snippet);
    setState(() {
      var dialog =  new ProgressDialog(context, type: ProgressDialogType.Download, isDismissible: false, showLogs: true);
      dialog.style(
        message: snippet['title'] + " dönüştürülüyor.",
        borderRadius: 6.0,
        backgroundColor: Colors.white,
        progressWidget: CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        progress: 0.0,
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
          color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
          color: Colors.black, fontSize: 16.0)
        );
        _progressDialog = dialog;
    });
    Navigator.of(context).pop(false);
    await _progressDialog.show();
  }

  void downloadFile(String url, {String id, String filename, String path, Map<dynamic, dynamic> snippet}) async {
    var httpClient = http.Client();
    print("Request sent.");
    var request = new http.Request('GET', Uri.parse(url));
    var response = httpClient.send(request);
    String dir = path;

    List<List<int>> chunks = new List();
    int downloaded = 0;

    setState(() {
      _isDownloading = true;
    });

    response.asStream().listen((http.StreamedResponse r) {
      r.stream.listen((List<int> chunk) {
        // Display percentage of completion
        debugPrint('downloadPercentage: ${downloaded / r.contentLength * 100}');
        setState(() {
          var percentage = downloaded / r.contentLength * 100;
          _downloadingProgress = percentage.toInt();
          _progressDialog != null ? _progressDialog.update(progress: percentage.toInt().toDouble(), message: snippet['title'] + " indiriliyor...",) : null;
        });

        chunks.add(chunk);
        downloaded += chunk.length;
      }, onDone: () async {
        // Display percentage of completion
        debugPrint('downloadPercentage: ${downloaded / r.contentLength * 100}');

        // Save the file
        String disposition = (r.headers['content-disposition']);
        String filename = disposition.split('filename=')[1];

        File file = new File('$dir/$filename');
        final Uint8List bytes = Uint8List(r.contentLength);
        int offset = 0;
        for (List<int> chunk in chunks) {
          bytes.setRange(offset, offset + chunk.length, chunk);
          offset += chunk.length;
        }
        await file.writeAsBytes(bytes);

        snippet['filename'] = (path + '/' + filename).replaceAll('//', '/');
        snippet['id'] = id;
        final prefs = await SharedPreferences.getInstance();
        List<dynamic> history = jsonDecode(prefs.getString('history') != null
            ? prefs.getString('history')
            : '[]');
        history.add(snippet);
        prefs.setString("history", jsonEncode(history));

        setState(() {
          _history = history;
          _isDownloading = false;
          _downloadingProgress = 0;
          _progressDialog.update(progress: 0);
        });
        await _progressDialog.hide();
        return;
      });
    });
  }

  void requestPermissions(callback) async {
    if (!(await Permission.storage.request().isGranted)) {
      await Permission.storage.request();
    }
    if ((await Permission.storage.request().isGranted)) {
      callback();
    }
  }

  void refreshVideoInfo() async {
    var results = await http.get(search_endpoint + "/get-info/" + _sharedText);

    if (results.statusCode == 200) {
      showVideo(jsonDecode(results.body));
    }
  }

  void showVideo(videoInfo) {
    var snippet = videoInfo['items'][0]['snippet'];
    var thumbnail = snippet['thumbnails']['default']['url'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          actions: <Widget>[
            FlatButton(
                onPressed: () {
                  requestPermissions(
                      () => download(_sharedText, _sharedText, snippet));
                },
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Text("İndir"),
                    Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Icon(Icons.cloud_download))
                  ],
                ))
          ],
          content: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(snippet['title'],
                      style: Theme.of(context).textTheme.subtitle1)),
              Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(snippet['channelTitle'],
                      style: Theme.of(context).textTheme.subtitle2)),
              Image.network(thumbnail,
                  width: double.infinity, fit: BoxFit.cover),
            ],
          ),
        );
      },
    );
  }

  void handleAction(snippet, action) async {
    switch (action) {
      case 'play':
        OpenFile.open(snippet['filename']);
        break;
      case 'delete_history':
        deleteFromHistory(snippet);
        break;
      case 'delete_file':
        final file = File(snippet['filename']);
        file.deleteSync();
        deleteFromHistory(snippet);
        break;
      case 're_download':
        // download(snippet['id'], snippet['title'], snippet);
        // deleteFromHistory(snippet);
        break;
      case 'share':
        await ShareExtend.share(snippet['filename'], "file", sharePanelTitle: snippet['title'], subject: snippet['title']+'.mp3');
        break;
    }
  }

  String getThumbnailURL(_item) {
    return _item['thumbnails']['maxres'] != null ? _item['thumbnails']['maxres']['url'] : _item['thumbnails']['default']['url'];
  }

  Widget historyListItem(_item) {
    var actions = [
      { "action": "play", "text": "Oynat" },
      { "action": "delete_history", "text": "Geçmişten Sil" },
      File(_item['filename']).existsSync() ? { "action": "delete_file", "text": "Dosyayı Sil" } : { "action": "re_download", "text": "Tekrar İndir" },
      { "action": "share", "text": "Paylaş" }
    ];
    return Container(
      padding: EdgeInsets.only(bottom: 16, left: 10, right: 10),
      child: InkWell(
        borderRadius: BorderRadius.all(
          Radius.circular(5)
        ),
        onLongPress: () {
        },
        child: ListTile(
          title: Text(_item['title']),
          subtitle: Text(_item['channelTitle']),
          leading: Image(image: NetworkImage(getThumbnailURL(_item))),
          trailing: PopupMenuButton(
            captureInheritedThemes: true,
            onSelected: (_) {
              var params = _.split(',');
              handleAction(_item, params[1]);
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) {
              return actions.map((text) {
                return PopupMenuItem(
                  value: _item['id'] + ',' + text['action'],
                  child: Text(text['text']),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  void deleteFromHistory(item) async {
    var history = _history;
    history.remove(item);
    setState(() {
      _history = history;
    });
    final _prefs = await SharedPreferences.getInstance();
    _prefs.setString('history', jsonEncode(history));
  }

  Widget circularIndicator() {
    return Theme(
      data: Theme.of(context).copyWith(accentColor: Colors.brown.shade100),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: CircularProgressIndicator()
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('MP3 İndir'),
        leading: IconButton(tooltip: "Son İndirmeler", icon: Icon(Icons.history), onPressed: () {
          Navigator.of(context).pushNamed('/last_downloaded');
        }),
      ),
      body: RefreshIndicator(
        child: ListView.builder(
          padding: EdgeInsets.only(top: 16),
          itemCount: _history != null ? _history.length : 0,
          itemBuilder: (context, index) {
            return historyListItem(_history[index]);
          },
        ),
        onRefresh: () async {
          await getHistory();
        },
      ),
    );
  }
}
