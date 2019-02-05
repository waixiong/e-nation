import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'package:e_nation/Screen/LoginPage.dart';
import 'package:e_nation/Logic/Nation.dart';
import 'package:e_nation/Screen/_FactoryCard.dart';
import 'package:e_nation/Screen/FoodManagement.dart';
import 'package:e_nation/Screen/ItemComsumption.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.currentUser, this.auth, this.nation}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  FirebaseAuth auth;//auth Holder, used for logout
  FirebaseUser currentUser;
  Nation nation;
  Function refresh;
  StreamSubscription<bool> change;
  //var orderList = <DataSnapshot>[];

  @override
  _HomePageState createState() => new _HomePageState(auth: auth);
  /*_HomePageState createState(){
    if(state == null)
      state = new _HomePageState(auth: auth);
    return state;
  }*/
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin<HomePage>{
  //final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  _HomePageState({Key key, this.auth,});

  FirebaseUser currentUser;//User Holder
  FirebaseAuth auth;//auth Holder, used for logout
  DatabaseReference _orderRef;
  bool loading = true;
  DatabaseReference data;
  StreamSubscription<bool> refresh;

  List<int> _factoryInputState = <int>[];

  bool keepAlive = true;
  @override
  bool get wantKeepAlive => true;

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    print('init home');
    //load user doc
    //loadUserDoc();
    widget.refresh = (){
      if(this.mounted) setState(() {
        //print('Mounted, update HomePage');
      });
//      else
//        print('Unmounted, cant update HomePage');
    };
    if(widget.change == null) {
      widget.change = widget.nation.nationStream.listen((data) {
        if(this.mounted) {
          setState(() {});
        }
      });
    }else{
      widget.change.resume();
    }

  }

  @override
  void deactivate(){
    print('deactivate home');
//    if(!widget.change.isPaused){
//      print('deactivate home');
//      widget.change.pause();
//      super.deactivate();
//    }else{
//      super.deactivate();
//      print('reactivate home');
//      widget.change.resume();
//    }
  }

  @override
  void dispose(){
    print('dispose home');
    widget.change.pause();// remove to deactivate()
    super.dispose();
    //print('Home dispose ' + widget.change.isPaused.toString());
  }

  //LOGOUT METHOD
  void logout(BuildContext context){
    print('logout method in development');
    auth.signOut();
    Navigator.pushAndRemoveUntil(context, new MaterialPageRoute(builder: (context) => new LoginPage()), ModalRoute.withName(Navigator.defaultRouteName));
  }

  Widget mainBar(BuildContext context){
    List<Widget> bar = <Widget>[];
    bar.add(new Expanded(child: new Row(
      children: <Widget>[
        new Padding(
          padding: EdgeInsets.only(left: 4, right: 4),
          child: new Icon(Icons.access_time),
        ),
        new Text('Session ${widget.nation.session}-${widget.nation.sessionPart? 'C':'P'}')
      ],)));
    bar.add(new Expanded(child: new Row(
      children: <Widget>[
        new Icon(Icons.person),
        new Text(widget.nation.humanAvailable.toString())
    ],)));
    bar.add(new Expanded(child: new Row(
      children: <Widget>[
        new Icon(Icons.monetization_on),
        new Text(widget.nation.resources['Money'].toStringAsFixed(2))
      ],)));

    return new Card(
      child: new Container(
        height: 40,
        child: new Row(
          children: bar,
        ),
      ),
    );
  }
  
  String intToString(int amount){
    if(amount < 10000)
      return amount.toString();
    else if(amount < 10000000)
      return (amount/1000).toInt().toString() + 'K';
    else if(amount < 10000000000)
      return (amount/1000000).toInt().toString() + 'M';
    else
      return (amount/1000000000).toInt().toString() + 'B';
  }

  Widget resourcesBar(BuildContext context){
    List<Widget> resourcesList = new List<Widget>();
    List resourcesOrder = widget.nation.master.resourcesOrder;
    for(int i = 0; i < resourcesOrder.length; i+=2) {
      resourcesList.add(new Container(
        padding: const EdgeInsets.all(0.0),
        alignment: Alignment.topLeft,
        width: 86,
        height: 50.0,
        child: new Column(
          children: <Widget>[
            new Container(
              width: 64,
              child: new Row(
                children: <Widget>[
                  ResourcePic(resourceImg: widget.nation.master.resources[resourcesOrder[i]]['img'], radius: 8.0,),
                  new Expanded(child: new Text(intToString(widget.nation.resources[resourcesOrder[i]]), textAlign: TextAlign.right,))],
              ),
            ),
            new Container(
              width: 64,
              child: new Row(
                children: <Widget>[
                  ResourcePic(resourceImg: widget.nation.master.resources[resourcesOrder[i+1]]['img'], radius: 8.0,),
                  new Expanded(child: new Text(intToString(widget.nation.resources[resourcesOrder[i+1]]), textAlign: TextAlign.right,))],
              ),
            )
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      ));
    }
    return new Card(
      child: new Container(
        height: 60,
        child: new ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(6.0),
          shrinkWrap: true,
          itemCount: resourcesList.length,
          itemBuilder: (BuildContext context, int index){
            ///Flexible let's your widget flex in  the given space, dealing with the overflow you have
            return resourcesList[index];
          },
        ),
      ),
    );
  }

  Future<void> factoryInputDialog(String resource) async {
    _factoryInputState = await Navigator.push(context, new MaterialPageRoute(builder: (context) => new FactoryInputList(nation: widget.nation, resource: resource,)));
    setState(() {

    });
  }

  Widget comsumptionList(BuildContext context){
    //print(widget.nation.comsumptionDemand);
    //print('consumption rerender');
    List<Widget> comsumeColumn = new List<Widget>();
    List<Widget> row = new List<Widget>();
    widget.nation.comsumptionDemand.forEach((resource, value){
      int mValue = widget.nation.minD[resource];
      if(value > 0){
        //print(resource + ' ' + (widget.nation.comsumptionSupply.containsKey(resource)? (widget.nation.comsumptionSupply[resource] >= value? Colors.green : (widget.nation.comsumptionSupply[resource] >= mValue? Colors.orange : Colors.red)) : Colors.red).toString());
        row.add(new ItemComsumption(
          size: 58, color: widget.nation.comsumptionSupply.containsKey(resource)? (widget.nation.comsumptionSupply[resource] >= value? Colors.green : (widget.nation.comsumptionSupply[resource] >= mValue? Colors.orange : Colors.red)) : Colors.red, demand: mValue,
          resImg: widget.nation.master.resources[resource]['img'],
          onPress: (){
            showDialog(
                context: context,
                builder: (BuildContext context){
                  return new ComsumptionSlider(nation: widget.nation, resource: resource,);
                }
            );
          },
        ));
      }
      if(row.length >= 6){
        comsumeColumn.add(new Row(
          children: new List.from(row),
        ));
        row = new List<Widget>();
      }
    });
    if(row.length > 0){
      comsumeColumn.add(new Row(
        children: new List.from(row),
      ));
    }
    //calculate food
    bool enough = true;
    if(widget.nation.sessionPart){
      int foodSupply = 0;
      widget.nation.master.foodList.forEach((food){
        print(food+' '+widget.nation.master.resources[food]['feed'].toString());
        foodSupply += (widget.nation.comsumptionSupply[food]?? 0) * widget.nation.master.resources[food]['feed'];
      });
      print('food supply ' + foodSupply.toString());
      if(foodSupply < widget.nation.human)
        enough = false;
    }
    //calculate food
    return Container(
      height: MediaQuery.of(context).size.height - 80 - 150,
      child: new Column(
        children: <Widget>[
          new Card(
            child: new Container(
              height: 140,
              width: MediaQuery.of(context).size.width,
              child: new Center(
                child: new Stack(
                  children: <Widget>[
                    new Container(
                      width: MediaQuery.of(context).size.width,
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Icon(Icons.people, size: 80, color: Colors.black54,),
                          new PopulationText(population: widget.nation.human, enough: enough,)
                        ],
                      ),
                    ),
                    Material(
                      type: MaterialType.transparency,
                      child: InkWell(onTap: (){
                        Navigator.push(context, new MaterialPageRoute(builder: (context) => new FoodManagement(title: 'FOOD MANAGEMENT', currentUser: widget.currentUser, nation: widget.nation,)));
                      }),
                    )
                  ],
                ),
              )
            ),
          ),
          new Expanded(
            child:new Card(
              child: new Container(
                width: MediaQuery.of(context).size.width,
                child: new Column(
                  children: <Widget>[
                    new Text('Internal Demand', style: TextStyle(fontSize: 20),),
                    new Expanded(
                      child: new Container(
                        child: new Column(
                          children: comsumeColumn,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget factoryGrid(BuildContext context){
    List<String> resources1 = ['Wood', 'Sand', 'Steel', 'Rubber', 'Cotton', 'Oil'];
    List<String> r = ['Leather'];
    List<String> resources2 = ['Copper', 'Silver', 'Vegetable', 'Meat'];
    List<String> products1 = ['Car', 'Shirt', 'Processed Vegetable', 'Processed Meat'];
    List<String> p = ['Solar Panel'];
    List<String> products2 = ['Furniture', 'Jewellery', 'Gloves', 'Bag', 'Gadget', 'Book'];
    return Container(
      //height: 450,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverSafeArea(
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Card(
                  child: new Container(
                    height: 100,
                    child: Center(
                      child: Text('RESOURCES', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),),
                    ),
                  ),
                ),
              ],),
            ),
          ),
          SliverSafeArea(
            top: false,
            minimum: const EdgeInsets.all(8.0),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: MediaQuery.of(context).size.width/2),
              delegate: SliverChildListDelegate(
                resources1.map<Widget>((String resource) {
                  return FactoryCard(
                    resource: resource,
                    factoryIndex: 0,
                    factoryData: null,
                    facImg: widget.nation.master.building[resource]['img'],
                    tag: resource,
                    resImg: widget.nation.master.resources[resource]['img'],
                    onPressed: () { factoryInputDialog(resource);},
                  );
                }).toList(),
              ),
            ),
          ),
          SliverSafeArea(
            top: true,
            minimum: const EdgeInsets.all(8.0),
            sliver: SliverList(
              //gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: MediaQuery.of(context).size.width/2),
              delegate: SliverChildListDelegate(
                r.map<Widget>((String resource) {
                  return FactoryCard(
                    resource: resource,
                    factoryIndex: 0,
                    factoryData: null,
                    facImg: widget.nation.master.building[resource]['img'],
                    tag: resource,
                    resImg: widget.nation.master.resources[resource]['img'],
                    onPressed: () { factoryInputDialog(resource);},
                  );
                }).toList(),
              ),
            ),
          ),
          SliverSafeArea(
            top: true,
            minimum: const EdgeInsets.all(8.0),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: MediaQuery.of(context).size.width/2),
              delegate: SliverChildListDelegate(
                resources2.map<Widget>((String resource) {
                  return FactoryCard(
                    resource: resource,
                    factoryIndex: 0,
                    factoryData: null,
                    facImg: widget.nation.master.building[resource]['img'],
                    tag: resource,
                    resImg: widget.nation.master.resources[resource]['img'],
                    onPressed: () { factoryInputDialog(resource);},
                  );
                }).toList(),
              ),
            ),
          ),
          //PRODUCT
          SliverSafeArea(
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Card(
                  child: new Container(
                    height: 100,
                    child: Center(
                      child: Text('PRODUCTS', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),),
                    ),
                  ),
                ),
              ],),
            ),
          ),
          SliverSafeArea(
            top: true,
            minimum: const EdgeInsets.all(8.0),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: MediaQuery.of(context).size.width/2),
              delegate: SliverChildListDelegate(
                products1.map<Widget>((String resource) {
                  return FactoryCard(
                    resource: resource,
                    factoryIndex: 0,
                    factoryData: null,
                    facImg: widget.nation.master.building[resource]['img'],
                    tag: resource,
                    resImg: widget.nation.master.resources[resource]['img'],
                    onPressed: () { factoryInputDialog(resource);},
                  );
                }).toList(),
              ),
            ),
          ),
          SliverSafeArea(
            top: true,
            minimum: const EdgeInsets.all(8.0),
            sliver: SliverList(
              //gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: MediaQuery.of(context).size.width/2),
              delegate: SliverChildListDelegate(
                p.map<Widget>((String resource) {
                  return FactoryCard(
                    resource: resource,
                    factoryIndex: 0,
                    factoryData: null,
                    facImg: widget.nation.master.building[resource]['img'],
                    tag: resource,
                    resImg: widget.nation.master.resources[resource]['img'],
                    onPressed: () { factoryInputDialog(resource);},
                  );
                }).toList(),
              ),
            ),
          ),
          SliverSafeArea(
            top: true,
            minimum: const EdgeInsets.all(8.0),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: MediaQuery.of(context).size.width/2),
              delegate: SliverChildListDelegate(
                products2.map<Widget>((String resource) {
                  return FactoryCard(
                    resource: resource,
                    factoryIndex: 0,
                    factoryData: null,
                    facImg: widget.nation.master.building[resource]['img'],
                    tag: resource,
                    resImg: widget.nation.master.resources[resource]['img'],
                    onPressed: () { factoryInputDialog(resource);},
                  );
                }).toList(),
              ),
            ),
          )
        ],
      ),
    );
  }

//  Future<void> test() async {
//    print('im ${data.key}');
//    final TransactionResult transactionResult =
//    await data.runTransaction((MutableData mutableData) async {
//      print('is ${mutableData.key}');
//      if(mutableData.key == 'resources') {
//        print('run');
//        mutableData.value = mutableData.value['Rubber'] + 200;
//        return mutableData;
//      }
//      return null;
//    });
//
//    if(transactionResult == null){
//      return;
//    }
//
//    if (transactionResult.committed) {
//      print('Transaction success.');
//    } else {
//      print('Transaction not committed.');
//      if (transactionResult.error != null) {
//        print(transactionResult.error.message);
//      }
//    }
//  }

//  @override
//  void dispose(){
//    super.dispose();
//    data.remove();
//  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    //print('render '+this.mounted.toString());
    return new Column(
      children: <Widget>[
        mainBar(context),
        resourcesBar(context),
        new Container(
          height: MediaQuery.of(context).size.height - 198.5,
          child: new PageView(
            scrollDirection: Axis.horizontal,
            controller: PageController(
              initialPage: 0,
              keepPage: false
            ),
            children: <Widget>[
              comsumptionList(context),
              factoryGrid(context)
            ],
          ),
        )
      ],
    );
  }
}