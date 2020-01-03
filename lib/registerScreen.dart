import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_food_never_waste/homeScreen.dart';
import 'dart:async';
import 'package:my_food_never_waste/loginScreen.dart';
import 'package:flutter/gestures.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';

File _image;
String pathAsset = 'assets/images/take photo.png';
String urlUpload = "http://mobilehost2019.com/MyFoodNeverWaste/php/dbregister.php";
final TextEditingController _nameController = TextEditingController();
final TextEditingController _phoneNoController = TextEditingController();
final TextEditingController _emailController = TextEditingController();
final TextEditingController _passController = TextEditingController();
String _name, _phoneNo, _email, _pass;

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterUserState createState() => _RegisterUserState();
  const RegisterScreen({Key key, File image}) : super(key: key);
}

class _RegisterUserState extends State<RegisterScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return WillPopScope(
      onWillPop: _onBackPressAppBar,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text('Sign Up'),
          centerTitle: true,
          backgroundColor: Color(0xff273b7a),
        ),
        body: SingleChildScrollView(
          reverse: true,
          child: Container(
            margin: const EdgeInsets.only(left: 40, right: 40),
            padding: EdgeInsets.only(bottom: bottom),
            child: RegisterWidget(),
          ),
        ),
      ),
    );
  }

   Future<bool> _onBackPressAppBar() async {
    Navigator.pop(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ));
    return Future.value(false);
  }
}

class RegisterWidget extends StatefulWidget {
  @override
  RegisterWidgetState createState() => RegisterWidgetState();
}

class RegisterWidgetState extends State<RegisterWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(height: 40),
        GestureDetector(
            onTap: _choose,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: _image == null
                        ? AssetImage(pathAsset)
                        : FileImage(_image),
                    fit: BoxFit.fill,
                  )),
            )),
        TextField(
          controller: _nameController,
          keyboardType: TextInputType.text,
          decoration:
              InputDecoration(labelText: 'Username', icon: Icon(Icons.person)),
        ),
        TextField(
          controller: _phoneNoController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              labelText: 'Phone number', icon: Icon(Icons.phone_android)),
        ),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
              labelText: 'Email Address', icon: Icon(Icons.email)),
        ),
        TextField(
          controller: _passController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
              labelText: 'Password',
              icon: Icon(Icons.lock),
              hintStyle: TextStyle(fontSize: 13),
              hintText: 'Must be longer than 6 characters'),
          obscureText: true,
        ),
        SizedBox(
          height: 15,
        ),
        MaterialButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          minWidth: 200,
          height: 40,
          child: Text(
            'Create Account',
            style: TextStyle(fontSize: 16),
          ),
          textColor: Colors.white,
          color: Colors.indigo[900],
          splashColor: Colors.blue,
          elevation: 15,
          onPressed: _onRegister,
        ),
        SizedBox(
          height: 10,
        ),
        RichText(
            text: new TextSpan(
                text: 'Already have account? ',
                style: TextStyle(color: Colors.black),
                children: <TextSpan>[
              TextSpan(
                  text: 'Sign In',
                  style: TextStyle(color: Colors.blueAccent),
                  recognizer: TapGestureRecognizer()..onTap = _backToLogin)
            ]))
      ],
    );
  }

  void _choose() async {
    _image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {});
  }

  void _onRegister() {
    print('onRegister button from registerScreen()');
    print(_image.toString());
    uploadData();
  }

  void _backToLogin() {
    _image = null;
    print('back to Login Screen');
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => LoginScreen()));
  }

  void uploadData() {
    _name = _nameController.text;
    _phoneNo = _phoneNoController.text;
    _email = _emailController.text;
    _pass = _passController.text;

    if (_image == null) {
      Toast.show("Failed. Please take photo.", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else if (_name == "") {
      Toast.show("Failed. Please enter Username.", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else if (_phoneNo == "") {
      Toast.show("Failed. Please enter Phone Number.", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else if (_email == "") {
      Toast.show("Failed. Please enter Email Address.", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else if (!_isEmailValid(_email)) {
      Toast.show("Failed. Please make sure your email is valid.", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else if (_pass == "") {
      Toast.show("Failed. Please enter password.", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else if (_pass.length<6) {
      Toast.show("Failed. Please must sure your password is more than 6 characters.", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else if ((_isEmailValid(_email)) &&
        (_name.length > 1) &&
        (_pass.length > 6) &&
        (_image != null) &&
        (_phoneNo.length > 6)) {
      ProgressDialog pr = new ProgressDialog(context,
          type: ProgressDialogType.Normal, isDismissible: false);
      pr.style(message: "Loading");
      pr.show();

      String base64Image = base64Encode(_image.readAsBytesSync());
      http.post(urlUpload, body: {
        "encoded_string": base64Image,
        "name": _name,
        "phone": _phoneNo,
        "email": _email,
        "password": _pass,
      }).then((res) {
        print(res.statusCode);
        Toast.show(res.body, context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        _image = null;
        _nameController.text = '';
        _phoneNoController.text = '';
        _emailController.text = '';
        _passController.text = '';
        pr.dismiss();
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => LoginScreen()));
      }).catchError((err) {
        print(err);
      });
    }
  }

  bool _isEmailValid(String email) {
    return RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }
}
