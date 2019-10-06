import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sw_xerox/main.dart';

void main() => runApp(new MaterialApp(
  home: customer(),
  debugShowCheckedModeBanner: false,
));

class customer extends StatefulWidget{

  @override
  custRegister createState() => custRegister();
}

class custRegister extends State<customer>{
  
  CollectionReference collectionReference = Firestore.instance.collection("customer");
  String cid;

  var _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Xerox"
        ),
        backgroundColor: Colors.deepOrange[300],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.only(top: 200.0),
          child: ListView(
            children: <Widget>[
              Text("Please enter the following details",
                  textAlign: TextAlign.center,
                  style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: 44.0)),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(color: Colors.black54, fontSize: 24.0),
                  decoration: InputDecoration(
                      labelText: "Name",
                      hintText: "Enter Name",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0))),
                  controller: _nameController,
                  validator: (String value) {
                    if (value.isEmpty) {
                      return "Invalid Input";
                    }
                  },
                ),
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                  child:
                  RaisedButton(
                    child: Text("Proceed"),
                    onPressed: () {
                      setState(() {
                        if (_formKey.currentState.validate()) {
                          //---------GO TO NEXT PAGE---------------//
                          FocusScope.of(context).requestFocus(FocusNode());
                          _createDocument();
                          Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage(_nameController.value.text)),);
                        }
                      });
                    },
                  )

              )
            ],
          ),
        ),
      ),
    );
  }

  void _createDocument() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DocumentReference documentReference = collectionReference.document();
    cid = documentReference.documentID;
    documentReference.setData({"name": _nameController.value.text, "cid":cid});
    await prefs.setString("cid", cid);
  }
}