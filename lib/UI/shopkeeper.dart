import 'dart:async';
import 'dart:collection';
import 'package:location/location.dart' as location_class;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sw_xerox/UI/CustomerLanding.dart';
import 'package:flutter/services.dart';
import 'ownerview.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GlobalKey<FormState> _key = GlobalKey();
  bool _validate = false;
  String name, address;
  String contact;
  double lat, lon;
  final databaseReference = Firestore.instance;

  String shopId;
  //Geolocator geolocator = Geolocator();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: new Scaffold(
        backgroundColor: Colors.black54,
        appBar: new AppBar(
          title: new Text('Consumer DEtails'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(color: Colors.white),
              ),
              Center(
                child: new SingleChildScrollView(
                  child: new Container(
                    margin: new EdgeInsets.all(15.0),
                    child: new Form(
                      key: _key,
                      autovalidate: _validate,
                      child: FormUI(),
                    ),
                  ),
                ),
              ),
              Positioned(
                  top: 30,
                  left: 110,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.black26,
                    // child: Image.network(""),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget FormUI() {
    return new Column(
      children: <Widget>[
        new TextFormField(
            decoration: new InputDecoration(
              hintText: 'name',
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
            ),
            validator: validateName,
            onSaved: (String val) {
              name = val;
            }),
        new SizedBox(
          height: 10,
        ),
        new TextFormField(
            decoration: new InputDecoration(
              hintText: 'Address',
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
            ),
            validator: validateAddress,
            onSaved: (String val) {
              address = val;
            }),
        new SizedBox(
          height: 10,
        ),
        new TextFormField(
            decoration: new InputDecoration(
              hintText: 'Contact',
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
            ),
            validator: validateName,
            onSaved: (String val) {
              contact = val;
            }),
        new SizedBox(
          height: 10,
        ),
        new TextFormField(
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              BlacklistingTextInputFormatter(new RegExp('[\\-|\\ ]'))
            ],
            decoration: new InputDecoration(
              hintText: 'Latitude',
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
            ),
            validator: (String value) {
              if (value.isEmpty) {
                return "Invalid Input";
              }
            },
            onSaved: (String val) {
              lat = double.parse(val);
            }),
        new SizedBox(
          height: 10,
        ),
        new TextFormField(
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              BlacklistingTextInputFormatter(new RegExp('[\\-|\\ ]'))
            ],
            decoration: new InputDecoration(
              hintText: 'Longitude',
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
            ),
            validator: (String value) {
              if (value.isEmpty) {
                return "Invalid Input";
              }
            },
            onSaved: (String val) {
              lon = double.parse(val);
            }),
        new SizedBox(height: 15.0),
        new RaisedButton(
          onPressed: () => {
            _sendToServer(),
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OwnerView(id:shopId )),
            )
          },
          child: new Text('Upload'),
        )
      ],
    );
  }

  String validateName(String value) {
    String pattern = r'(^[a-zA-Z0-9]*$)';
    RegExp regExp = new RegExp(pattern);
    if (value.length == 0) {
      return "Name is Required";
    } else if (!regExp.hasMatch(value)) {
      return "Name must be a-z and A-Z";
    }
    return null;
  }

  String validateAddress(String value) {
    String patttern = r'(^[a-zA-Z1-9 ]*$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Address is Required";
    } else if (!regExp.hasMatch(value)) {
      return "Address must be a-z and A-Z";
    }
    return null;
  }

  _sendToServer() async {
    if (_key.currentState.validate()) {
      //No error in validator
      print("yes");
      _key.currentState.save();
      Firestore.instance.runTransaction((Transaction transaction) async {
        DocumentReference reference =
            Firestore.instance.collection('Xerox Shops').document();
        shopId = reference.documentID;
        await reference.setData({
          "name": "$name",
          "contact": "$contact",
          "address": "$address",
          "latitude": lat,
          "longitude": lon,
          "shopID":reference.documentID
        });
//        Map<String, double> data = {"latitude": lat,
//          "longitude": lon};
//        await reference.setData(data);
        _storeuserid(reference.documentID);

        // await reference.add({"name": "$name", "contact": "$contact","address":"address","UserId":widget.id});
      });
    } else {
      // validation error
      print("Not valid");
      setState(() {
        _validate = true;
      });
    }
  }

  _storeuserid(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // print('Pressed $counter times.');
    await prefs.setString('shopId', id);
  }
}
