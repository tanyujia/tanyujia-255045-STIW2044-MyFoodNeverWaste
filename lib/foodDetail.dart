import 'dart:async';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'user.dart';
import 'package:toast/toast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'food.dart';
import 'homeScreen.dart';

class FoodDetail extends StatefulWidget {
  final Food food;
  final User user;

  const FoodDetail({Key key, this.food, this.user}) : super(key: key);

  @override
  _FoodDetailState createState() => _FoodDetailState();
}

class _FoodDetailState extends State<FoodDetail> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.indigo));
    return WillPopScope(
      onWillPop: _onBackPressAppBar,
      child: Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            title: Text('Food Details'),
            backgroundColor: Colors.indigo[800],
          ),
          body: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
              child: DetailInterface(
                food: widget.food,
                user: widget.user,
              ),
            ),
          )),
    );
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

class DetailInterface extends StatefulWidget {
  final Food food;
  final User user;
  DetailInterface({this.food, this.user});

  @override
  _DetailInterfaceState createState() => _DetailInterfaceState();
}

class _DetailInterfaceState extends State<DetailInterface> {
  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _myLocation;

  @override
  void initState() {
    super.initState();
    _myLocation = CameraPosition(
      target: LatLng(
          double.parse(widget.food.foodlat), double.parse(widget.food.foodlon)),
      zoom: 17,
    );
    print(_myLocation.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Center(),
        Container(
          width: 280,
          height: 200,
          child: Image.network(
              'http://mobilehost2019.com/MyFoodNeverWaste/image/${widget.food.foodimage}.jpg',
              fit: BoxFit.fill),
        ),
        SizedBox(
          height: 9,
        ),
        Text(widget.food.foodtitle.toUpperCase(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            )),
        SizedBox(height: 4),
        Text(widget.food.foodtime),
        SizedBox(height: 10),
        Container(
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 5,
              ),
              Table(children: [
                TableRow(children: [
                  Text("Food Description",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(widget.food.fooddes),
                ]),
                TableRow(children: [Text(""), Text("")]),
                TableRow(children: [
                  Text("Food Price",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("RM " + widget.food.foodprice),
                ]),
                TableRow(children: [Text(""), Text("")]),
                TableRow(children: [
                  Text("Food Location",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("")
                ]),
              ]),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 120,
                width: 340,
                child: GoogleMap(
                  // 2
                  initialCameraPosition: _myLocation,
                  // 3
                  mapType: MapType.normal,
                  // 4

                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: Container(
                  width: 200,
                  child: MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    height: 40,
                    child: Text(
                      'Order Food',
                      style: TextStyle(fontSize: 18),
                    ),
                    color: Colors.indigo[600],
                    textColor: Colors.white,
                    elevation: 5,
                    onPressed: _onAcceptFood,
                  ),
                  //MapSample(),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  void _onAcceptFood() {
    if (widget.user.email == "user@noregister") {
      Toast.show("Please log in to order", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    } else {
      _showDialog();
    }
    print("Accept Food");
  }

  void _showDialog() {
    // flutter defined function
    if (int.parse(widget.user.credit) < 1) {
      Toast.show("Credit not enough ", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Accept " + widget.food.foodtitle),
          content: new Text("Are your sure?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop();
                acceptRequest();
              },
            ),
            new FlatButton(
              child: new Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> acceptRequest() async {
    String urlLoadFood =
        "http://mobilehost2019.com/MyFoodNeverWaste/php/accept_food.php";
    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(message: "Accepting Food");
    pr.show();
    http.post(urlLoadFood, body: {
      "foodid": widget.food.foodid,
      "email": widget.user.email,
      "credit": widget.user.credit,
    }).then((res) {
      print(res.body);
      if (res.body == "success") {
        Toast.show("Success", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        pr.dismiss();
        _onLogin(widget.user.email, context);
      } else {
        Toast.show("Failed", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        pr.dismiss();
      }
    }).catchError((err) {
      print(err);
      pr.dismiss();
    });
    return null;
  }

  void _onLogin(String email, BuildContext ctx) {
    String urlgetuser =
        "http://mobilehost2019.com/MyFoodNeverWaste/php/getUser.php";

    http.post(urlgetuser, body: {
      "email": email,
    }).then((res) {
      print(res.statusCode);
      var string = res.body;
      List dres = string.split(",");
      print(dres);
      if (dres[0] == "success") {
        User user = new User(
            name: dres[1],
            email: dres[2],
            phone: dres[3],
            radius: dres[4],
            credit: dres[5],
            rating: dres[6]);
        Navigator.push(ctx,
            MaterialPageRoute(builder: (context) => HomeScreen(user: user)));
      }
    }).catchError((err) {
      print(err);
    });
  }
}
