import 'dart:async';
import 'package:flutter/material.dart';
import 'package:e_nation/Screen/CustomFAB.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io' show Platform;

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  _LoginPageState({Key key}) : super();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseDatabase database = FirebaseDatabase.instance;

  String _email = '';
  String _password = '';
  final formKey = new GlobalKey<FormState>();//for save and submit text used

  //final FirebaseAuth auth = FirebaseAuth.instance;
  Future<FirebaseUser> _hasUser() async{
    FirebaseUser currentUser = await auth.currentUser();
    if(currentUser != null)
      return currentUser;
    else
      return null;
  }

  //googleSignIn
  Future<FirebaseUser> _signIn() async {
    final FirebaseUser user = await auth.signInWithEmailAndPassword(email: _email, password: _password);
    assert(user.email != null);
    //assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    FirebaseUser currentUser = await auth.currentUser();
    assert(user.uid == currentUser.uid);

    print('user is ' + currentUser.uid);
    return currentUser;
  }

  @override
  Widget build(BuildContext context) {
    _hasUser().then((b){
      //print('login $b');
      if(b != null) {
        Navigator.pushReplacement(context, new MaterialPageRoute(builder: (context) => new CustomFAB(title: 'E-Nation', currentUser: b, auth: auth,)));
      }else{
        print('no user');
      }
    });

    return new Scaffold(
      body: new Center(
        child: new Container(
          margin: const EdgeInsets.fromLTRB(20.0, 36.0, 20.0, 36.0),
          decoration: new BoxDecoration(
              border: new Border.all(color: Theme.of(context).primaryColor)
          ),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Container(
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 2.0),
                child: new Text(
                  'E-NATION', style: new TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 32.0,
                  color: Theme.of(context).primaryColor,
                ),
                ),
              ),
              new Container(
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                child: new Text(
                  'LOGIN', style: new TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: Theme.of(context).primaryColor,
                ),
                ),
              ),
              new Form(
                key: formKey,
                child: new Column(
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new TextFormField(
                        onSaved: (val) => setState((){_email = val;}),
                        decoration: new InputDecoration(labelText: "Email"),
                      ),
                    ),
                    new Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new TextFormField(
                        onSaved: (val) => setState((){_password = val;}),
                        obscureText: true,
                        validator: (val) {
                          return val.length < 6
                              ? "Password must have atleast 6 chars or numbers"
                              : null;
                        },
                        decoration: new InputDecoration(labelText: "Password"),
                      ),
                    ),
                  ],
                ),
              ),
              new Container(
                padding: const EdgeInsets.fromLTRB(40.0, 8.0, 40.0, 8.0),
                child: new RaisedButton(
                  onPressed: () async {
                    final form = formKey.currentState;
                    form.save();
                    if(formKey.currentState.validate()){
                      print('start Login');
                      FirebaseUser currentUser = await _signIn();
                      print('finish Login');
                      //login firebase email auth
                      Navigator.pushReplacement(context, new MaterialPageRoute(builder: (context) => new CustomFAB(title: 'E-Nation', currentUser: currentUser, auth: auth,)));
                    }
                  },
                  color: Theme.of(context).primaryColor,
                  child: new Center(
                      child: new Text('Login',
                        style: new TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: Colors.white,
                        ),)
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}