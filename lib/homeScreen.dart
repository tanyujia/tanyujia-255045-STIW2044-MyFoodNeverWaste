import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:my_food_never_waste/registerScreen.dart';
import 'package:my_food_never_waste/slideRightRoute.dart';
import 'package:my_food_never_waste/viewOrder.dart';
import 'viewProfile.dart';
import 'package:my_food_never_waste/user.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'food.dart';
import 'foodDetail.dart';
import 'loginScreen.dart';

double perpage = 1;
int number = 0;

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({Key key, this.user}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
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

    Future.delayed(Duration.zero, () {
      this.makeRequest();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: new AppBar(
          backgroundColor: Colors.indigo[800],
          title: new Text("My Food Never Waste"),
        ),
        drawer: new Drawer(
          child: _userConditiion(),
        ),
        body: Container(
          padding: EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(0.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: 10),
                        Row(
                          children: <Widget>[
                            Flexible(
                              child: Text("  Delivery To:",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.indigo)),
                            )
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                "  " + _currentAddress,
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Image.asset('assets/images/01.png'),
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Card(
                          elevation: 2,
                          child: InkWell(
                            onTap: () => _onFoodDetail(
                              data[index]['foodid'],
                              data[index]['foodprice'],
                              data[index]['fooddesc'],
                              data[index]['foodowner'],
                              data[index]['foodimage'],
                              data[index]['foodtime'],
                              data[index]['foodtitle'],
                              data[index]['foodlatitude'],
                              data[index]['foodlongitude'],
                              data[index]['foodrating'],
                              widget.user.radius,
                              widget.user.name,
                              widget.user.credit,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                      height: 100,
                                      width: 100,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border:
                                              Border.all(color: Colors.white),
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
                                          Text(
                                              "RM " + data[index]['foodprice']),
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
                    })
              ],
            ),
          ),
        ),
      ),
    );
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

  Future init() async {
    this.makeRequest();
  }

  Future<String> makeRequest() async {
    String urlLoadFood =
        "http://mobilehost2019.com/MyFoodNeverWaste/php/load_food.php";
    http.post(urlLoadFood, body: {
      "email": widget.user.email ?? "notavail",
      "latitude": _currentPosition.latitude.toString(),
      "longitude": _currentPosition.longitude.toString(),
      "radius": widget.user.radius ?? "10",
    }).then((res) {
      setState(() {
        var extractdata = json.decode(res.body);
        data = extractdata["food"];
        print("data");
        print(data);
      });
    }).catchError((err) {
      print(err);
    });
    return null;
  }

  _userConditiion() {
    if (widget.user.name == "not register") {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RichText(
            text: new TextSpan(
              text: 'Please ',
              style: TextStyle(color: Colors.black, fontSize: 16),
              children: <TextSpan>[
                TextSpan(
                    text: 'Log In ',
                    style: TextStyle(color: Colors.blueAccent),
                    recognizer: TapGestureRecognizer()..onTap = _onLogin),
                TextSpan(
                  text: 'to Continue',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                )
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          RichText(
              text: new TextSpan(
                  text: 'Don\'t have an account? ',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  children: <TextSpan>[
                TextSpan(
                    text: 'Sign Up',
                    style: TextStyle(color: Colors.blueAccent),
                    recognizer: TapGestureRecognizer()..onTap = _onRegister)
              ])),
        ],
      );
    } else {
      return ListView(
        children: <Widget>[
          new UserAccountsDrawerHeader(
            accountName: new Text(widget.user.name), //Name!!!
            accountEmail: new Text(widget.user.email), //Email!!
            currentAccountPicture: new CircleAvatar(
              backgroundImage: new NetworkImage(
                  "http://mobilehost2019.com/MyFoodNeverWaste/profile/${widget.user.email}.jpg?dummy=${(number)}'"),
              backgroundColor: Colors.transparent,
            ),
            decoration: new BoxDecoration(
                gradient: new LinearGradient(
              colors: [Colors.purple, Colors.indigo[900]],
            )),
          ),
          new ListTile(
            leading: Icon(Icons.person),
            title: new Text("My Profile"),
            onTap: _onProfile,
          ),
          new ListTile(
            leading: Icon(Icons.credit_card),
            title: new Text("Credit: " + widget.user.credit),
          ),
          new ListTile(
            leading: Icon(Icons.filter_none),
            title: new Text("My Order"),
            onTap: _onView,
          ),
        ],
      );
    }
  }

  void _onView() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ViewOrder(
                  user: widget.user,
                )));
  }

  void _onProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ViewProfile(
                  user: widget.user,
                )));
  }

  void _onRegister() {
    print("move to RegisterScreen");
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => RegisterScreen()));
  }

  void _onLogin() {
    print("move to LoginScreen");
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  void _onFoodDetail(
      String foodid,
      String foodprice,
      String fooddesc,
      String foodowner,
      String foodimage,
      String foodtime,
      String foodtitle,
      String foodlatitude,
      String foodlongitude,
      String foodrating,
      String email,
      String name,
      String credit) {
    Food food = new Food(
        foodid: foodid,
        foodtitle: foodtitle,
        foodowner: foodowner,
        fooddes: fooddesc,
        foodprice: foodprice,
        foodtime: foodtime,
        foodimage: foodimage,
        foodworker: null,
        foodlat: foodlatitude,
        foodlon: foodlongitude,
        foodrating: foodrating);
    //print(data);

    Navigator.push(context,
        SlideRightRoute(page: FoodDetail(food: food, user: widget.user)));
  }
}
