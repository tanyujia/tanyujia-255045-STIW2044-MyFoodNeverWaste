import 'package:flutter/material.dart';
import 'package:my_food_never_waste/loginScreen.dart';
import 'package:my_food_never_waste/registerScreen.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';

String urlReset =
    "http://mobilehost2019.com/MyFoodNeverWaste/php/forgot_password.php";

final TextEditingController _emailController = TextEditingController();
String _email;

class ResetPassScreen extends StatefulWidget {
  @override
  _ResetPassState createState() => _ResetPassState();
}

class _ResetPassState extends State<ResetPassScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressAppBar,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text('Forgot Password'),
          centerTitle: true,
          backgroundColor: Color(0xff273b7a),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.fromLTRB(40, 15, 40, 20),
            child: ResetPassWidget(),
          ),
        ),
      ),
    );
  }

  Future<bool> _onBackPressAppBar() async {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ));
    return Future.value(false);
  }
}

class ResetPassWidget extends StatefulWidget {
  @override
  ResetPassWidgetState createState() => ResetPassWidgetState();
}

class ResetPassWidgetState extends State<ResetPassWidget> {
  bool _validate = false;

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 65),
          Image.asset(
            "assets/images/lock.jfif",
            width: 150,
            height: 150,
          ),
          SizedBox(height: 10),
          Text(
            'Trouble Logging In?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
              'Enter your email address and we\'ll send you a link to get back into your account.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17)),
          SizedBox(height: 10),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration:
                InputDecoration(labelText: 'Email', icon: Icon(Icons.email)),
          ),
          SizedBox(height: 15),
          MaterialButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            minWidth: 200,
            height: 40,
            child: Text(
              'Send Login Link',
              style: TextStyle(fontSize: 16),
            ),
            textColor: Colors.white,
            color: Colors.indigo[900],
            splashColor: Colors.blue,
            elevation: 15,
            onPressed: _onSendLink,
          ),
          SizedBox(height: 10),
          Text('OR'),
          SizedBox(height: 10),
          GestureDetector(
              onTap: _onRegister,
              child: Text('Create New Account',
                  style: TextStyle(fontSize: 16, color: Colors.blueAccent))),
        ]);
  }

  void _onSendLink() {
    _email = _emailController.text;
    if (_isEmailValid(_email)) {
      ProgressDialog pr = new ProgressDialog(context,
          type: ProgressDialogType.Normal, isDismissible: false);
      pr.style(message: "Checking your email.");
      pr.show();

      http.post(urlReset, body: {
        "email": _email,
      }).then((res) {
        print(res.statusCode);
        Toast.show(res.body, context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        pr.dismiss();
        if (res.body == "Please check your mailbox") {
          //print('hjh');
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => LoginScreen()));
        } else {
          pr.dismiss();
        }
      }).catchError((err) {
        pr.dismiss();
        print(err);
      });
    } else {
      setState(() {
        _validate = true;
      });
      Toast.show("Check your email format and must enter your email", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  void _onRegister() {
    print("move to RegisterScreen");
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => RegisterScreen()));
  }

  bool _isEmailValid(String email) {
    return RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }
}
