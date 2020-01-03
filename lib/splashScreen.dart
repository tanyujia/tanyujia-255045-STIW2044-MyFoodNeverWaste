import 'package:flutter/material.dart';
import 'package:my_food_never_waste/homeScreen.dart';
import 'package:my_food_never_waste/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

String _email, _password;
String urlLogin = "http://mobilehost2019.com/MyFoodNeverWaste/php/dblogin.php";

void main() => runApp(SplashScreen());

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/icon.png',
                width: 180,
                height: 180,
              ),
              Image.asset(
                'assets/images/title.png',
                height: 50,
                width: 250,
              ),
              SizedBox(
                height: 20,
              ),
              new ProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

class ProgressIndicator extends StatefulWidget {
  @override
  _ProgressIndicatorState createState() => _ProgressIndicatorState();
}

class _ProgressIndicatorState extends State<ProgressIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    animation = Tween(begin: 0.0, end: 1.0).animate(controller)
      ..addListener(() {
        setState(() {
          if (animation.value > 0.99) {
            loadpref(this.context);
          }
        });
      });
    controller.repeat();
  }

  @override
  void dispose() {
    controller.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Center(
        child: new Container(
      width: 160,
      child: LinearProgressIndicator(
        value: animation.value,
        backgroundColor: Colors.black,
        valueColor: new AlwaysStoppedAnimation<Color>(Colors.indigo[800]),
      ),
    ));
  }
}

void loadpref(BuildContext ctx) async {
  print('Inside loadpref()');
  SharedPreferences prefs = await SharedPreferences.getInstance();
  _email = (prefs.getString('email') ?? '');
  _password = (prefs.getString('pass') ?? '');
  print("Splash:Preference");
  print(_email);
  print(_password);

  if (_isEmailValid(_email ?? "no email")) {
    _onLogin(_email, _password, ctx);
  } else {
    User user = new User(
      name: "not register",
      email: "user@noregister",
      phone: "not register",
    );
    Navigator.push(
        ctx, MaterialPageRoute(builder: (context) => HomeScreen(user: user)));
  }
}

bool _isEmailValid(String email) {
  return RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
}

void _onLogin(String email, String pass, BuildContext ctx) {
  http.post(urlLogin, body: {
    "email": _email,
    "password": _password,
  }).then((res) {
    print(res.statusCode);
    var string = res.body;
    List dres = string.split(",");
    print("SPLASH:loading");
    print(dres);
    if (dres[0] == "success") {
      User user = new User(
        name: dres[1],
        email: dres[2],
        phone: dres[3],
      );
      Navigator.push(
          ctx, MaterialPageRoute(builder: (context) => HomeScreen(user: user)));
    } else {
      //allow login as unregistered user
      User user = new User(
        name: "not register",
        email: "user@noregister",
        phone: "not register",
      );
      Navigator.push(
          ctx, MaterialPageRoute(builder: (context) => HomeScreen(user: user)));
    }
  }).catchError((err) {
    print(err);
  });
}
