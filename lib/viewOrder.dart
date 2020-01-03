import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'homeScreen.dart';
import 'user.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:toast/toast.dart';

double perpage = 1;

class ViewOrder extends StatefulWidget {
  final User user;

  ViewOrder({Key key, this.user});

  @override
  _ViewOrderState createState() => _ViewOrderState();
}

class _ViewOrderState extends State<ViewOrder> {
  GlobalKey<RefreshIndicatorState> refreshKey;

  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  Position _currentPosition;
  String _currentAddress = "Searching current location...";
  List data = [];

  @override
  void initState() {
    super.initState();
    refreshKey = GlobalKey<RefreshIndicatorState>();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.indigo));
    return WillPopScope(
        onWillPop: _onBackPressAppBar,
        child: Scaffold(
            resizeToAvoidBottomPadding: false,
            appBar: AppBar(
              title: Text('My Order'),
              backgroundColor: Colors.indigo[800],
            ),
            body: RefreshIndicator(
              key: refreshKey,
              color: Color.fromRGBO(159, 30, 99, 1),
              onRefresh: () async {
                await refreshList();
              },
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.all(2.0),
                      child: Card(
                        elevation: 2,
                        child: InkWell(
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Row(
                              children: <Widget>[
                                Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white),
                                        image: DecorationImage(
                                            fit: BoxFit.fill,
                                            image: NetworkImage(
                                                "http://mobilehost2019.com/MyFoodNeverWaste/image/${data[index]['foodimage']}.jpg")))),
                                Expanded(
                                  child: Container(
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                            data[index]['foodtitle']
                                                .toString()
                                                .toUpperCase(),
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text("RM " + data[index]['foodprice']),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(data[index]['foodtime']),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
            )));
  }

  _getCurrentLocation() async {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        print(_currentPosition);
      });
      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            "${place.name},${place.locality}, ${place.postalCode}, ${place.country}";
        init(); //load data from database into list array 'data'
      });
    } catch (e) {
      print(e);
    }
  }

  Future<String> makeRequest() async {
    String urlLoadFood =
        "http://mobilehost2019.com/MyFoodNeverWaste/php/load_accepted_food.php";
    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(message: "Loading All Accepted Food");
    pr.show();
    http.post(urlLoadFood, body: {
      "email": widget.user.email ?? "notavail",
    }).then((res) {
      setState(() {
        var extractdata = json.decode(res.body);
        data = extractdata["food"];
        perpage = (data.length / 10);
        print("data");
        print(data);
        pr.dismiss();
      });
    }).catchError((err) {
      print(err);
      pr.dismiss();
    });
    return null;
  }

  Future init() async {
    if (widget.user.email == "user@noregister") {
      Toast.show("Please register to view accepted food", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    } else {
      this.makeRequest();
    }
  }

  Future<Null> refreshList() async {
    await Future.delayed(Duration(seconds: 2));
    this.makeRequest();
    return null;
  }

  Future<bool> _onBackPressAppBar() async {
    Navigator.pop(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            user: widget.user,
          ),
        ));
    return Future.value(false);
  }
}
