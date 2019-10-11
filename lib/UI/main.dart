import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sw_xerox/UI/ownerview.dart';
import 'shopkeeper.dart';
import 'customer.dart';
import 'package:sw_xerox/UI/CustomerLanding.dart';

void main() => runApp(new MaterialApp(
  home: Home(),
  debugShowCheckedModeBanner: false,
));

class Home extends StatefulWidget{

  _HomePage createState() => _HomePage();
}

class _HomePage extends State<Home>{

  bool _iscustomer = false;
  bool _isowner = false;

  String cid;
   String shopId;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    check();
    if(!_isowner && !_iscustomer){
      return Scaffold(
              appBar: AppBar(
                title: Text(
                    "Xerox"
                ),
                backgroundColor: Colors.deepOrange[300],
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 200,
                        height: 100,
                        child: RaisedButton(
                          child: Text(
                            "I am Owner",
                            style: TextStyle(
                              fontSize: 15
                            ),
                          ),
                            onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                            }),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 200,
                        height: 100,
                        child: RaisedButton(
                            child: Text(
                              "I am Customer",
                              style: TextStyle(
                                  fontSize: 15
                              ),
                            ),
                            onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => customer()));
                            }),
                      ),
                    )
                  ],
                ),
              )
      );
    }
    else if(_iscustomer){
      return MyHomePage();
    }
    else{
        return OwnerView(id:shopId);
    }
  }

  void check() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    cid = await prefs.getString("cid");
    shopId = await prefs.getString("shopId");
    if(cid!=null){
      setState(() {
        _iscustomer = true;
      });
    }
    else if(shopId!=null){
      setState(() {
        _isowner = true;
      });
    }
    else{
    }
  }


}