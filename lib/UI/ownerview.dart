import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sw_xerox/PDF/download.dart';

class OwnerView extends StatefulWidget {
  final id;

  const OwnerView({Key key,@required this.id}) : super(key: key);
  @override
  _OwnerViewState createState() => _OwnerViewState(shopId: id);
}

class _OwnerViewState extends State<OwnerView> {

  final shopId;
  _OwnerViewState({Key key,@required this.shopId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Documents to be printed"),
        backgroundColor: Colors.deepOrange[300],
      ),
      body: _buildBody(context),
      
    );
  }
  Widget _buildBody(BuildContext context) {
 return StreamBuilder<QuerySnapshot>(
stream: Firestore.instance.collection('Xerox Shops').document(shopId).collection("files received").snapshots(),
//   stream: Firestore.instance.collection('Url').snapshots(),
    builder: (context, snapshot) {
      //if (!snapshot.hasData) return LinearProgressIndicator();
      if (snapshot.data.documents.length != 0) {
        return ListView.builder(
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data.documents[index];
              return _buildListItem(ds);
            }
        );
      }
      else{
        return Center(
          child: Text("No orders yet."),
        );
      }
    }
 );
    }



  Widget _buildListItem(data) {
    //final record = Record.fromSnapshot(data);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(

        child: Card(
          child: Column(
            children: <Widget>[
              ExpansionTile(
                title: Column(
                  children: <Widget>[
                    Text(data["file name"]),
                    Row(
                      children: <Widget>[
                        Text("Ordered by:"),Text(data["ordered by"]),
                      ],
                    ),
                  ],
                ),
                children: <Widget>[
                  RaisedButton.icon(
                    icon: Icon(Icons.cloud_download),
                    label: Text("Download Document"),
                    onPressed: () =>{
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Download(
                                vidurl:data["pdf_url"]
                            )),
                      ),

                    },
                  ),
                  RaisedButton.icon(
                    icon: Icon(Icons.check),
                    label: Text("Processed"),
                    onPressed:() async {
                      await Firestore.instance.collection("Xerox Shops/$shopId/files received").document(data["orderId"]).updateData({"order status":"Processed"});
                    },

                  ),

                ],
              ),
            ],
          ),


        ),

      ),
    );
  }
}