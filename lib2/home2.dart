import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'pdfview.dart';
import 'savelist.dart';

class FilePickerDemo extends StatefulWidget {
  @override
  _FilePickerDemoState createState() => new _FilePickerDemoState();
}

class _FilePickerDemoState extends State<FilePickerDemo> {
  String _fileName = '...';
   String assetPDFPath = ' ';
  String _path = '...';
  final db = Firestore.instance;
//String _extension="PDF";
  //bool _hasValidMime = false;
  FileType _pickingType = FileType.CUSTOM;
  //TextEditingController _controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
   }
  
  void _openFileExplorer() async {
    //if (_pickingType == FileType.CUSTOM || _hasValidMime) {
    try {
      _path = await FilePicker.getFilePath(
          type: _pickingType, fileExtension: "pdf");
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }

    if (!mounted) return;

    setState(() {
      _fileName = _path != null ? _path.split('/').last : '...';
    });
    //}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: const Text('Pdf proxy'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.view_list),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => Savedlist()));
            },
            tooltip: "List of online documents",
          )
        ],
      ),
      body: SingleChildScrollView(
        child: new Center(
            child: new Padding(
          padding: const EdgeInsets.only(top: 50.0, left: 10.0, right: 10.0),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // new Padding(
              //   padding: const EdgeInsets.only(top: 20.0),
              //   child: new DropdownButton(
              //       hint: new Text('LOAD PATH FROM'),
              //       value: _pickingType,
              //       items: <DropdownMenuItem>[
              //         new DropdownMenuItem(
              //           child: new Text('FROM AUDIO'),
              //           value: FileType.AUDIO,
              //         ),
              //         new DropdownMenuItem(
              //           child: new Text('FROM GALLERY'),
              //           value: FileType.IMAGE,
              //         ),
              //         new DropdownMenuItem(
              //           child: new Text('FROM VIDEO'),
              //           value: FileType.VIDEO,
              //         ),
              //         new DropdownMenuItem(
              //           child: new Text('FROM ANY'),
              //           value: FileType.ANY,
              //         ),
              //         new DropdownMenuItem(
              //           child: new Text('CUSTOM FORMAT'),
              //           value: FileType.CUSTOM,
              //         ),
              //       ],
              //       onChanged: (value) => setState(() => _pickingType = value)),
              // ),
              // new ConstrainedBox(
              //   constraints: new BoxConstraints(maxWidth: 150.0),
              //   child: _pickingType == FileType.CUSTOM
              //       ? new TextFormField(
              //     maxLength: 20,
              //     autovalidate: true,
              //     controller: _controller,
              //     decoration: InputDecoration(labelText: 'File type'),
              //     keyboardType: TextInputType.text,
              //     textCapitalization: TextCapitalization.none,
              //     validator: (value) {
              //       RegExp reg = new RegExp(r'[^a-zA-Z0-9]');
              //       if (reg.hasMatch(value)) {
              //         _hasValidMime = false;
              //         return 'Invalid format';
              //       }
              //       _hasValidMime = true;
              //     },
              //   )
              //       : new Container(),
              // ),
              new Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: new RaisedButton(
                  onPressed: () => _openFileExplorer(),
                  child: new Text("Open file picker"),
                ),
              ),
              _uploadpdf(),
              new Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: new RaisedButton(
                  onPressed: () => _viewpdf(),
                  child: new Text("View the document"),
                ),
              ),
              new Text(
                'URI PATH ',
                textAlign: TextAlign.center,
                style: new TextStyle(fontWeight: FontWeight.bold),
              ),
              new Text(
                _path ?? '...',
                textAlign: TextAlign.center,
                softWrap: true,
                textScaleFactor: 0.85,
              ),
              new Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: new Text(
                  'FILE NAME ',
                  textAlign: TextAlign.center,
                  style: new TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              new Text(
                _fileName,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )),
      ),
    );
  }


  Widget _viewpdf() {
                 Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>  PdfViewPage(path: _path)));

    
  }

  Widget _uploadpdf() {
    
    return Center(
      child: Column(
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: new RaisedButton(
              onPressed: () async {
                final StorageReference storageRef =
                    FirebaseStorage.instance.ref().child(_fileName);
                final StorageUploadTask uploadTask = storageRef.putFile(
                  File(_path),
                  StorageMetadata(
                    contentType: "document" + '/' + "pdf",
                  ),
                );
                final StorageTaskSnapshot downloadUrl =
                    (await uploadTask.onComplete);
                final String url = (await downloadUrl.ref.getDownloadURL());
                print('URL Is $url');
                DocumentReference ref = await db
                    .collection('Url')
                    .add({'name': '$url'});
              },
              child: new Text("Upload File"),
            ),
          ),
        ],
      ),
    );
  }
}