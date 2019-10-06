import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:video/database.dart';
// import 'package:video/user.dart';
import 'package:progress_indicators/progress_indicators.dart';

class Download extends StatefulWidget {
  final String vidurl;

  const Download({Key key, @required this.vidurl}) : super(key: key);
  @override
  DownloadState createState() {
    return new DownloadState();
  }
}

class DownloadState extends State<Download> {
 // User user = new User("", "");
  bool downloading = false;
  var progressString = "";
  @override
  void initState() {
    super.initState();
    downloadFile();
   // _submit();
  }

  Future<void> downloadFile() async {
    var name = widget.vidurl.substring(widget.vidurl.lastIndexOf("appspot.com/o/")+14, (widget.vidurl.lastIndexOf(".pdf")));
    Dio dio = Dio();

    try {
      var dir = await getExternalStorageDirectory();
      //   var user = new User(name, "mp4");
      // var dbHelper = Data_helper();
      // await dbHelper.saveuser(user);

      await dio.download(widget.vidurl, "${dir.path}/$name.pdf",
          onReceiveProgress: (rec, total) {
        print("Rec: $rec , Total: $total");

        setState(() {
          downloading = true;
          progressString = ((rec / total) * 100).toStringAsFixed(0) + "%";
        });
      });
    } catch (e) {
      print(e);
    }

    setState(() {
      downloading = false;
      progressString = "Completed";
    });
    print("Download completed");
  }

  // Future<void> _submit() async {
  //   var name = widget.vidurl.substring(76, (widget.vidurl.lastIndexOf(".mp4")));
  //   var user = new User(name, "mp4");
  //   var dbHelper = Data_helper();
  //   await dbHelper.saveuser(user);
  //   print("saved $user");
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AppBar"),
      ),
      body: Center(
        child: downloading
            ? Container(
                height: 120.0,
                width: 200.0,
                child: Card(
                  color: Colors.yellowAccent.shade700,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CollectionScaleTransition(
                        children: <Widget>[
                          Icon(Icons.android),
                          Icon(Icons.apps),
                          Icon(Icons.announcement),
                        ],
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Text(
                        "Downloading File: $progressString",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      )
                    ],
                  ),
                ),
              )
            : progressString == "100"
                ? Text("download completed")
                : Text("No Data"),
      ),
    );
  }
}