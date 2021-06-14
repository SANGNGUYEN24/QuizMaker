import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quiz_maker_app/helper/functions.dart';
import 'package:quiz_maker_app/models/user.dart';
import 'package:quiz_maker_app/services/auth.dart';
import 'package:quiz_maker_app/views/signin.dart';
import 'package:quiz_maker_app/widgets/widgets.dart';
import 'package:email_validator/email_validator.dart';

import 'home.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  AuthService authService = new AuthService();
  String name = "";
  String email = "";
  String password = "";
  String error = "";
  bool _isLoading = false;

  FirebaseAuth _auth = FirebaseAuth.instance;

  void showSnackBarLoading() {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.fixed,
      content: Container(
        height: 40,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );

    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  void showSnackBarMessage(String mess) {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.fixed,
      content: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.white,
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(child: Text(mess)),
        ],
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  // User object based on FirebaseUser
  Userne _userFromFirebaseUser(User user) {
    // ignore: unnecessary_null_comparison
    return user != null ? Userne(uid: user.uid) : null;
  }

  Future signUpEmailAndPassword(String email, String password) async {
    try {
      UserCredential authResult = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User firebaseUser = authResult.user;

      // change value of _isLoading
      setState(() {
        _isLoading = true;
      });

      return _userFromFirebaseUser(firebaseUser);
    } catch (e) {
      if (e.code == 'email-already-in-use')
        showSnackBarMessage(
            "The email address is already in use by another account");
      return null;
    }
  }

  signUp() async {
    if (_formKey.currentState.validate()) {
      showSnackBarLoading();
      dynamic val = await signUpEmailAndPassword(email, password);
      if (val != null) {
        setState(() {
          _isLoading = false;
        });
        HelperFunctions.saveUserLoggedInDetail(isLoggedIn: true);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Home()));
      } else {
        setState(() {
          error = "The email address is already in use by another account";
        });
        showSnackBarMessage(error);
        return null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          centerTitle: true,
          title: appBar(context),
        ),
        body: _isLoading
            ? Container(
                child: Center(
                child: CircularProgressIndicator(),
              ))
            : SingleChildScrollView(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  alignment: Alignment.topCenter,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            validator: (val) {
                              return val.isEmpty ? "Enter name!" : null;
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: Icon(Icons.person),
                              hintText: "Name",
                            ),
                            onChanged: (val) {
                              name = val;
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: Icon(Icons.mail),
                              hintText: "Email",
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (email) {
                              return !EmailValidator.validate(email)
                                  ? "Enter a valid email!"
                                  : null;
                            },
                            autofillHints: [AutofillHints.email],
                            onChanged: (val) {
                              email = val;
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: true,
                            validator: (val) {
                              return val.length < 6
                                  ? "Password at least 6 characters"
                                  : null;
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: Icon(Icons.vpn_key),
                              hintText: "Password",
                            ),
                            onChanged: (val) {
                              password = val;
                            },
                          ),
                          SizedBox(
                            height: 24,
                          ),
                          GestureDetector(
                            onTap: () {
                              signUp();
                            },
                            child:
                                blueButton(context: context, label: "Sign up with your email"),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          OutlinedButton(
                            onPressed: () {},
                            child: Text('Sign up with Google', style: TextStyle(fontSize: 16),),
                            style: OutlinedButton.styleFrom(
                              minimumSize: Size(MediaQuery.of(context).size.width - 48,54),
                              shape: StadiumBorder(),
                              side: BorderSide(color: Colors.blue),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account?",
                                style: TextStyle(fontSize: 15),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SignIn()));
                                },
                                child: Text(
                                  " Sign in",
                                  style: TextStyle(
                                    fontSize: 15,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 100,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ));
  }
}
