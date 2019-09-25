import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(new MaterialApp(

home: MyHomePage(),
debugShowCheckedModeBanner: false,));


class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  LocationData _currentLocation;

  StreamSubscription<LocationData> _locationSubscription;

  CollectionReference collectionReference = Firestore.instance.collection("Xerox Shops");

  Location _locationService  = new Location();
  bool _permission = false;
  String error;

  bool currentWidget = true;

  Completer<GoogleMapController> _controller = Completer();
  static final CameraPosition _initialCamera = CameraPosition(
    target: LatLng(0, 0),
    zoom: 4,
  );

  CameraPosition _currentCameraPosition;

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Map<String,List<String>> shops = new Map();

  GoogleMap googleMap;

  Map<String,List<double>> data = new Map();

  @override
  void initState() {
    super.initState();
    _getDocuments();

  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    await _locationService.changeSettings(accuracy: LocationAccuracy.HIGH, interval: 1000);

    LocationData location;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      bool serviceStatus = await _locationService.serviceEnabled();
      print("Service status: $serviceStatus");
          var _permit = await _locationService.requestPermission();
      if (serviceStatus) {
        setState(() {
          _permission = _permit;
        });
        if (_permission) {
          location = await _locationService.getLocation();

          _locationSubscription = _locationService.onLocationChanged().listen((LocationData result) async {
            _currentCameraPosition = CameraPosition(
                target: LatLng(result.latitude, result.longitude),
                zoom: 16.5
            );

            final GoogleMapController controller = await _controller.future;
            controller.animateCamera(CameraUpdate.newCameraPosition(_currentCameraPosition));

            if(mounted){
              setState(() {
                _currentLocation = result;
              });
            }
          });
        }
      } else {
        bool serviceStatusResult = await _locationService.requestService();
        print("Service status activated after request: $serviceStatusResult");
        if(serviceStatusResult){
          initPlatformState();
        }
      }
    } on PlatformException catch (e) {
      print(e);
      if (e.code == 'PERMISSION_DENIED') {
        error = e.message;
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        error = e.message;
      }
      location = null;
    }



  }





  @override
  Widget build(BuildContext context) {

    googleMap = GoogleMap(
      mapType: MapType.normal,
      myLocationEnabled: true,
      initialCameraPosition: _initialCamera,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      markers: Set<Marker>.of(markers.values),
    );
//    _storeDocuments();

    return
      (_permission)?
      Scaffold(
          body: googleMap,
    ):
      Scaffold(
        body: Center(
          child: AlertDialog(
            title: Text("Location Required"),
            actions: <Widget>[
              FlatButton(
                  onPressed: (){
                    initPlatformState();

                  },
                  child: Text("Grant"))
            ],
          ),
          ),
      );
  }

   _getDocuments() async {

     List<DocumentSnapshot> list;



     QuerySnapshot querySnapshot = await collectionReference.getDocuments();
    list = querySnapshot.documents;




    list.forEach((DocumentSnapshot snap) =>
    {
      data.addAll({snap.data["name"]: [snap.data["latitude"], snap.data["longitude"]]}),
      shops.addAll({snap.data["name"]: [snap.data["address"], snap.data["contact"]]})
    }
    );
    print("The is the data fetched");
    print(data);

    data.forEach((key,value)=>(
    _add(key)
    ));

    print("Added markers");

  }

  _add(name){
    MarkerId markerId = MarkerId(name);

    Marker marker = Marker(
      markerId: markerId,

      position: LatLng(data[markerId.value][0],data[markerId.value][1]),
      infoWindow:
    InfoWindow(title: markerId.value),
      onTap: () {
        _showModal(markerId.value);
      },
    );

    setState(() {
      // adding a new marker to map
      markers[markerId] = marker;
    });
  }

  void _showModal(name) {
    Future<void> future = showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            child: Wrap(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 40
                      ),
                    ),
                    Text(
                      shops[name][0],
                      style: TextStyle(
                          fontSize: 25
                      ),
                    ),
                    Text(
                      shops[name][1],
                      style: TextStyle(
                          fontSize: 25
                      ),
                    ),
                  ],
                ),
              ],

            ),
          ),
        );
      },
    );
    future.then((void value) => _closeModal(value));
  }

  void _closeModal(void value) {
//      Navigator.pop(context)
  }

}
