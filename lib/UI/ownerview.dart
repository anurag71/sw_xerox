import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sw_xerox/PDF/download.dart';

class OwnerView extends StatefulWidget {
  final id;

  const OwnerView({Key key,@required this.id}) : super(key: key);
  @override
  _OwnerViewState createState() => _OwnerViewState();
}

class _OwnerViewState extends State<OwnerView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Documents to be printed"),
        centerTitle: true,
      ),
      body: _buildBody(context),
      
    );
  }
  Widget _buildBody(BuildContext context) {
 return StreamBuilder<QuerySnapshot>(
  // stream: Firestore.instance.collection('Xerox Shops').document('${widget.id}').collection("files received").snapshots(),
   stream: Firestore.instance.collection('Url').snapshots(),
    builder: (context, snapshot) {
     if (!snapshot.hasData) return LinearProgressIndicator();

     return _buildList(context, snapshot.data.documents);
   },
 );
}

 Widget _buildList(BuildContext context,List<DocumentSnapshot> snapshot) {
   return ListView(
     scrollDirection: Axis.vertical,
      cacheExtent:10000000,
     padding: const EdgeInsets.only(top: 20.0),
     children: snapshot.map((data) => _buildListItem(context, data)).toList(),
   );
 }

Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
 final record = Record.fromSnapshot(data);
    return Padding(
     key: ValueKey(record.name),
     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
     child: Container(
       
       child: Card(
         child: Column(
           children: <Widget>[
             ExpansionTile(
               title: Text(record.name.substring(record.name.lastIndexOf("appspot.com/o/")+14,record.name.lastIndexOf(".pdf"))+".pdf"),
               children: <Widget>[
                 IconButton(
                    icon: Icon(Icons.arrow_downward),
                    tooltip: "press to download",
                    splashColor: Colors.yellowAccent,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Download(
                                vidurl:record.name
                                    )),
                      );
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

class Record {
final String name;
final DocumentReference reference;

 Record.fromMap(Map<String, dynamic> map, {this.reference})
     : assert(map['name'] != null),
       name = map['name'];

 Record.fromSnapshot(DocumentSnapshot snapshot)
     : this.fromMap(snapshot.data, reference: snapshot.reference);

 }