import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'package:e_nation/Logic/Nation.dart';

class FoodManagement extends StatefulWidget {
  FoodManagement({Key key, this.title, this.currentUser, this.nation}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  FirebaseUser currentUser;
  Nation nation;
  //var orderList = <DataSnapshot>[];

  @override
  _FoodManagementState createState() => new _FoodManagementState();
}

class _FoodManagementState extends State<FoodManagement> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  _FoodManagementState({Key key,});
  DatabaseReference _orderRef;
  bool loading = true;
  DatabaseReference data;
  List<String> foodList = <String>['Vegetable', 'Meat', 'FoodVegetable', 'FoodMeat'];

  Map<String, int> _foodInputState = {};

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    getAvailableFood();
  }

  void getAvailableFood(){
    foodList.forEach((food){
      print(widget.nation.comsumptionSupply);
      bool existInStock = false;
      if(widget.nation.comsumptionSupply.containsKey(food)){
        print('the ' + food + '  ' + (widget.nation.comsumptionSupply[food] > 0).toString());
        existInStock = (widget.nation.comsumptionSupply[food] > 0);
      }
      if(widget.nation.resources[food] > 0 || existInStock){
        if(widget.nation.comsumptionSupply[food] != null) {
          setState(() {
            _foodInputState[food] = widget.nation.comsumptionSupply[food];
          });
          print(food + '  ' + _foodInputState[food].toString());
        }else {
          setState(() {
            _foodInputState[food] = 0;
          });
          print(food + '  ' + _foodInputState[food].toString());
        }
    }});
  }

  List<Widget> buildSlider(){
    List<Widget> list = <Widget>[];
    _foodInputState.forEach((food, amount){
      int max = widget.nation.comsumptionSupply.containsKey(food) ? ((widget.nation.resources[food] + widget.nation.comsumptionSupply[food])/ 100).floor() * 100 : ((widget.nation.resources[food])/ 100).floor() * 100;
      list.add(new Text('${food}', textAlign: TextAlign.left,));
      list.add(Slider(
        value: _foodInputState[food].toDouble(),
        min: 0,
        max: max.toDouble(),
        divisions: (max >= 100)? (max/100).toInt() : 1,
        label: '${_foodInputState[food].round()}',
        onChanged: (double value){
          setState(() {
            //factoryList[i]['input']['human'] = value.toInt();
            _foodInputState[food] = value.toInt();
          });
        },
        activeColor: Colors.grey.shade500,
      ));
      int feed = widget.nation.master.resources[food]['feed'];
      list.add(new Text('Can feed ${feed * _foodInputState[food]} people', textAlign: TextAlign.center,));
      list.add(Container(height: 24,));
    });
    if(list.length == 0){
      list.add(Text('No Food For Comsumption'));
    }
    return list;
  }

  Future<bool> allComsumption() async {
    _foodInputState.forEach((food, amount){
      widget.nation.resourcesComsumption(food, amount);
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      child: new Scaffold(
        key: _scaffoldKey,
        body: new Container(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: buildSlider(),
          ),
        ),
        // This trailing comma makes auto-formatting nicer for build methods.
      ),
      onWillPop: (){ return allComsumption();},
    );
  }
}

