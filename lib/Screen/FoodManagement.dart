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
  List<String> foodList;

  Map<String, int> _foodInputState = {};
  Map<String, int> quantity = {};//for text input
  Map<String, GlobalKey<FormState>> _quantityKey = {};
  Map<String, TextEditingController> quantityController = {};

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    foodList = widget.nation.master.foodList;
    getAvailableFood();
  }

  void getAvailableFood(){
    foodList.forEach((food){
      //print(widget.nation.comsumptionSupply);
      _quantityKey[food] = GlobalKey<FormState>();
      bool existInStock = false;
      if(widget.nation.comsumptionSupply.containsKey(food)){
        //print('the ' + food + '  ' + (widget.nation.comsumptionSupply[food] > 0).toString());
        existInStock = (widget.nation.comsumptionSupply[food] > 0);
      }
      if(widget.nation.resources[food] > 0 || existInStock){
        _quantityKey[food] = GlobalKey<FormState>();
        quantityController[food] = TextEditingController();
        if(widget.nation.comsumptionSupply[food] != null) {
          setState(() {
            _foodInputState[food] = widget.nation.comsumptionSupply[food];
            quantity[food] = widget.nation.comsumptionSupply[food];
            if(quantity[food] == 0)
              quantityController[food].text = '';
            else
              quantityController[food].text = quantity[food].toString();
          });
          //print(food + '  ' + _foodInputState[food].toString());
        }else {
          setState(() {
            _foodInputState[food] = 0;
            quantity[food] = 0;
            quantityController[food].text = '';
          });
          //print(food + '  ' + _foodInputState[food].toString());
        }
    }});
  }

  List<Widget> buildSlider(){
    List<Widget> list = <Widget>[];
    int humanFeed = 0;
    _foodInputState.forEach((food, amount){
      humanFeed += _foodInputState[food] * widget.nation.master.resources[food]['feed'];
    });
    list.add(Container(
      padding: EdgeInsets.only(bottom: 10),
      child: Center(
        child: new Text('You have fed ${humanFeed>widget.nation.human? widget.nation.human:humanFeed} people', style: TextStyle(color: Colors.grey.shade600, fontSize: 20, fontWeight: FontWeight.w300),),
      ),
    ));
    _foodInputState.forEach((food, amount){
      int max = widget.nation.comsumptionSupply.containsKey(food) ? ((widget.nation.resources[food] + widget.nation.comsumptionSupply[food])) : ((widget.nation.resources[food]));
      list.add(new Text('${food}', textAlign: TextAlign.left,));
      list.add(Slider(
        value: _foodInputState[food].toDouble(),
        min: 0,
        max: max.toDouble(),
        divisions: (max > 0)? max : 1,
        label: '${_foodInputState[food].round()}',
        onChanged: (double value){
          setState(() {
            //factoryList[i]['input']['human'] = value.toInt();
            _foodInputState[food] = value.toInt();
            quantity[food] = _foodInputState[food];
            if(quantity[food] == 0)
              quantityController[food].text = '';
            else
              quantityController[food].text = quantity[food].toString();
          });
        },
        activeColor: Colors.grey.shade500,
      ));
      list.add(new Container(
        padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width*0.2, 0, MediaQuery.of(context).size.width*0.2, 10),
        width: MediaQuery.of(context).size.width,
        child: new Form(
          onChanged: () => _quantityKey[food].currentState.validate(),
          key: _quantityKey[food],
          child: new TextFormField(
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            decoration: new InputDecoration(labelText: 'Quantity Supply'),
            autofocus: false,
            validator: (value){
              try{
                quantity[food] = int.parse(value);
                if(quantity[food] > max){
                  setState(() { _foodInputState[food] = max; });
                  quantityController[food].text = max.toString();
                  return 'Please enter available quantity\n${max.toString()} or below';
                }else if(quantity[food] < 0){
                  setState(() { _foodInputState[food] = 0; });
                  quantityController[food].text = 0.toString();
                  return 'Please enter available quantity\nIn between 0 and ${max.toString()}';
                }
                setState(() { _foodInputState = quantity; });
                return null;
              }catch(e){
                if(value.length == 0){
                  quantityController[food].text = '';
                  setState(() { _foodInputState[food] = 0; });
                  return null;
                }else {
                  quantityController[food].text = _foodInputState[food].toString();
                }
                return 'Please enter a integer as quantity';
              }
            },
            controller: quantityController[food],
          ),
        ),
      ));
      int feed = widget.nation.master.resources[food]['feed'];
      list.add(new Text('Can feed ${feed * _foodInputState[food]} people', textAlign: TextAlign.center,));
      list.add(Container(height: 24,));
    });
    if(list.length == 1){
      list.add(new Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width * 0.6,
        child: new Center(child: Text('No Food For Comsumption', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700),),),
      ));
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
//          child: new Column(
//            mainAxisAlignment: MainAxisAlignment.center,
//            crossAxisAlignment: CrossAxisAlignment.center,
//            children: buildSlider(),
//          ),
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                expandedHeight: 164.0,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text('FOOD MANAGEMENT'),
                  background: Image.asset('packages/e_nation/Assets/food.jpg', fit: BoxFit.cover,),
                ),
              ),
              SliverSafeArea(
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    buildSlider()
                  ),
                ),
              )
            ],
          ),
        ),
        // This trailing comma makes auto-formatting nicer for build methods.
      ),
      onWillPop: (){ return allComsumption();},
    );
  }
}

class PopulationText extends StatefulWidget{
  PopulationText({this.population, this.enough});

  int population;
  bool enough;

  @override
  _PopulationTextState createState() {
    // TODO: implement createState
    return new _PopulationTextState();
  }
}

class _PopulationTextState extends State<PopulationText> with TickerProviderStateMixin<PopulationText> {

  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
    new AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animationController.repeat();
  }

  @override
  void dispose(){
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return widget.enough? Text(
      '${widget.population}',
      style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
    ) : FadeTransition(
      opacity: _animationController,
      child: Text(
        '${widget.population}',
        style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.red.shade900),
      ),
    );
  }
}

