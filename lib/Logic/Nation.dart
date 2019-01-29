import 'package:e_nation/Logic/Master.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'dart:math';
import 'dart:async';
import 'dart:io';

class HistoryData{
  List<dynamic> GDP = new List<dynamic>();
  Map<dynamic, dynamic> trade = {};
  Map<dynamic, dynamic> news = {};
  Map<dynamic, dynamic> loan = {};
}

enum NotifyType{
  trade,
  info
}

class Notify{
  Notify({this.dataSnapshot, this.type});

  DataSnapshot dataSnapshot;
  NotifyType type;
}

class Nation{
  Nation({this.name, this.human});

  FirebaseDatabase database = FirebaseDatabase.instance;
  bool created;
  int session = 0;
  bool sessionPart = false; // false mean first half, true mean second half
  String name;
  String imageUrl;
  int human;
  int humanAvailable = 0;
  int land = 0;
  int landAvailable = 0;
  bool developedLand = false;
  int foodSupply = 0;
  Master master = new Master();
  HistoryData historyData = new HistoryData();

  FirebaseUser currentUser;
  List<StreamSubscription<Event>> fireListeners;

  final StreamController<bool> _homeRefresh = StreamController<bool>();
  Stream<bool> get homeRefresh => _homeRefresh.stream;

  final StreamController<bool> _statRefresh = StreamController<bool>();
  Stream<bool> get statRefresh => _statRefresh.stream;//**

  final StreamController<bool> _governRefresh = StreamController<bool>();
  Stream<bool> get governRefresh => _governRefresh.stream;//**

  final StreamController<bool> _tradeHistoryRefresh = StreamController<bool>();
  Stream<bool> get tradeHistoryRefresh => _tradeHistoryRefresh.stream;

  final StreamController<bool> _newsRefresh = StreamController<bool>();
  Stream<bool> get newsRefresh => _newsRefresh.stream;

  final StreamController<bool> _loanDataRefresh = StreamController<bool>();
  Stream<bool> get loanDataRefresh => _loanDataRefresh.stream;

  final StreamController<bool> _FABRefresh = StreamController<bool>();
  Stream<bool> get FABRefresh => _FABRefresh.stream;//waiting for connection && loading

  final StreamController<Notify> _FABNotification = StreamController<Notify>();
  Stream<Notify> get FABNotification => _FABNotification.stream;

  final StreamController<bool> _telecom = StreamController<bool>();
  Stream<bool> get telecom => _telecom.stream;//**

  final StreamController<bool> _nationStream = StreamController<bool>.broadcast();
  Stream<bool> get nationStream => _nationStream.stream;

  Map<dynamic, dynamic> resourcesMatrix = {
    'Wood': false,
    'Sand': false,
    'Steel': false,
    'Rubber': false,
    'Cotton': false,
    'Oil': false,
    'Leather': false,
    'Copper': false,
    'Silver': false,
    'Vegetable': false,
    'Meat': false,
    //'rawFood': 0,
    'Car': false,
    'Shirt': false,
    'Processed Vegetable': false,
    'Processed Meat': false,
    'Solar Panel': false,
    'Furniture': false,
    'Jewellery': false,
    'Gloves': false,
    'Bag': false,
    'Gadget': false,
    'Book': false
  };

  Map<dynamic, dynamic> resources = {
    'Money': 0,
    'Wood': 0,
    'Sand': 0,
    'Steel': 0,
    'Rubber': 0,
    'Cotton': 0,
    'Oil': 0,
    'Leather': 0,
    'Copper': 0,
    'Silver': 0,
    'Vegetable': 0,
    'Meat': 0,
    //'rawFood': 0,
    'Car': 0,
    'Shirt': 0,
    'Processed Vegetable': 0,
    'Processed Meat': 0,
    'Solar Panel': 0,
    'Furniture': 0,
    'Jewellery': 0,
    'Gloves': 0,
    'Bag': 0,
    'Gadget': 0,
    'Book': 0
  };
  Map<dynamic, dynamic> building = {
    'Wood': [],
    'Sand': [],
    'Steel': [],
    'Rubber': [],
    'Cotton': [],
    'Oil': [],
    'Leather': [],
    'Copper': [],
    'Silver': [],
    'Vegetable': [],
    'Meat': [],
    'Car': [],
    'Shirt': [],
    'Processed Vegetable': [],
    'Processed Meat': [],
    'Solar Panel': [],
    'Furniture': [],
    'Jewellery': [],
    'Gloves': [],
    'Bag': [],
    'Gadget': [],
    'Book': [],
  };

  Map<dynamic, dynamic> specialBuilding = {
    'Education': {'level': 0, 'upgrade': false},
    'R&D': {'level': 0, 'upgrade': false},
    'Telecommunication': {'level': 0, 'upgrade': false},
    'Healthcare': {'level': 0, 'upgrade': false}
  };

  Map<dynamic, dynamic> comsumptionDemand = {
    //'Wood': 100,
    //'Sand': 100,
    //'Steel': 100
  };

  Map<dynamic, dynamic> minD = {}; //minimum Demand to maintain happiness

  Map<dynamic, dynamic> comsumptionSupply = {};

  Map<dynamic, dynamic> buildList = {};

  void start(FirebaseUser currentUser){
    //this.humanAvailable = human;
    //historyData.GDP.add({'comsumption': 30000, 'export': 12000, 'import': 10000, 'session': 0, 'human': 5000});
    //historyData.GDP.add({'comsumption': 32000, 'export': 14000, 'import': 8000, 'session': 1, 'human': 6000});
    //historyData.GDP.add({'comsumption': 31000, 'export': 12000, 'import': 15000, 'session': 2, 'human': 7000});
    //historyData.GDP.add({'comsumption': 34000, 'export': 15000, 'import': 10000, 'session': 3, 'human': 8000});
    //test
    bool created = true;
    fireListeners = new List<StreamSubscription<Event>>();
    this.currentUser = currentUser;
    master.masterNation.listen((change){
      if(change == 'resources'){
        _homeRefresh.add(true);
        _nationStream.add(true);
      }else if(change == 'building'){
        _homeRefresh.add(true);
        _nationStream.add(true);
      }else if(change == 'specialBuilding'){
        _governRefresh.add(true);
        _nationStream.add(true);
      }
    });
    addFirebaseListener();
  }

  void addFirebaseListener(){
    DatabaseReference loading = FirebaseDatabase.instance.reference().child('loading');
    loading.onValue.listen((Event event){
      if(event.snapshot.value){
        this.pauseFire();
        _FABRefresh.add(false);
      }else{
        this.resumeFire();
        _FABRefresh.add(true);
      }
    });
    FirebaseDatabase.instance.reference().child('resourcesMatrix/${currentUser.uid}').onValue.listen((Event event){
      resourcesMatrix = event.snapshot.value;
      print('updated matrix');
    });
    FirebaseDatabase.instance.reference().child('session').onValue.listen((Event event){
      session = event.snapshot.value;
      _homeRefresh.add(true);
      _nationStream.add(true);
    });
    FirebaseDatabase.instance.reference().child('sessionPart').onValue.listen((Event event){
      sessionPart = event.snapshot.value;
      _homeRefresh.add(true);
      _nationStream.add(true);
    });
    DatabaseReference data = FirebaseDatabase.instance.reference().child('users/${currentUser.uid}');
    //resources
    fireListeners.add(data.child('resources').onChildAdded.listen((Event event){
      resources[event.snapshot.key] = event.snapshot.value;
      _homeRefresh.add(true);
      _nationStream.add(true);
    }));
    fireListeners.add(data.child('resources').onChildChanged.listen((Event event){
      resources[event.snapshot.key] = event.snapshot.value;
      _homeRefresh.add(true);
      _nationStream.add(true);
    }));
    //building
    fireListeners.add(data.child('building').onChildAdded.listen((Event event){
      building[event.snapshot.key] = event.snapshot.value;
      _homeRefresh.add(true);
      _nationStream.add(true);
    }));
    fireListeners.add(data.child('building').onChildChanged.listen((Event event){
      building[event.snapshot.key] = event.snapshot.value;
      _homeRefresh.add(true);
      _nationStream.add(true);
    }));
    fireListeners.add(data.child('building').onChildRemoved.listen((Event event){
      building[event.snapshot.key] = [];
      _homeRefresh.add(true);
      _nationStream.add(true);
    }));
    fireListeners.add(data.child('humanAvailable').onValue.listen((Event event){
      humanAvailable = event.snapshot.value;
      _homeRefresh.add(true);
      _nationStream.add(true);
    }));
    fireListeners.add(data.child('human').onValue.listen((Event event){
      human = event.snapshot.value;
      _homeRefresh.add(true);
      _FABRefresh.add(true);
      _nationStream.add(true);
    }));
    fireListeners.add(data.child('landAvailable').onValue.listen((Event event){
      landAvailable = event.snapshot.value;
      _homeRefresh.add(true);
      _governRefresh.add(true);
      _nationStream.add(true);
    }));
    fireListeners.add(data.child('land').onValue.listen((Event event){
      land = event.snapshot.value;
      _homeRefresh.add(true);
      _governRefresh.add(true);
      _nationStream.add(true);
    }));
    fireListeners.add(data.child('buildList').onChildAdded.listen((Event event){
      buildList[event.snapshot.key] = event.snapshot.value;
      _homeRefresh.add(true);
      _nationStream.add(true);
    }));
    fireListeners.add(data.child('buildList').onChildChanged.listen((Event event){
      buildList[event.snapshot.key] = event.snapshot.value;
      _homeRefresh.add(true);
      _nationStream.add(true);
    }));
    fireListeners.add(data.child('buildList').onChildRemoved.listen((Event event){
      buildList.remove(event.snapshot.key);
      _homeRefresh.add(true);
      _nationStream.add(true);
    }));
    fireListeners.add(data.child('comsumption/supply').onChildAdded.listen((Event event){
      comsumptionSupply[event.snapshot.key] = event.snapshot.value;
      _homeRefresh.add(true);
      _nationStream.add(true);
    }));
    fireListeners.add(data.child('comsumption/supply').onChildChanged.listen((Event event){
      comsumptionSupply[event.snapshot.key] = event.snapshot.value;
      _homeRefresh.add(true);
      _nationStream.add(true);
    }));
    fireListeners.add(data.child('comsumption/supply').onChildRemoved.listen((Event event){
      comsumptionSupply.remove(event.snapshot.key);
      _homeRefresh.add(true);
      _nationStream.add(true);
    }));
    fireListeners.add(data.child('comsumption/demand').onChildAdded.listen((Event event){
      comsumptionDemand[event.snapshot.key] = event.snapshot.value;
      _homeRefresh.add(true);
      _nationStream.add(true);
    }));
    fireListeners.add(data.child('comsumption/demand').onChildChanged.listen((Event event){
      comsumptionDemand[event.snapshot.key] = event.snapshot.value;
      _homeRefresh.add(true);
      _nationStream.add(true);
    }));
    fireListeners.add(data.child('comsumption/demand').onChildRemoved.listen((Event event){
      comsumptionDemand.remove(event.snapshot.key);
      _homeRefresh.add(true);
      _nationStream.add(true);
    }));
    fireListeners.add(data.child('historyData/GDP').onValue.listen((Event event){
      historyData.GDP = event.snapshot.value?? historyData.GDP;
      _statRefresh.add(true);
      _nationStream.add(true);
    }));
    fireListeners.add(data.child('comsumption/minD').onChildAdded.listen((Event event){
      minD[event.snapshot.key] = event.snapshot.value;
      _homeRefresh.add(true);
      _nationStream.add(true);
    }));
    fireListeners.add(data.child('comsumption/minD').onChildChanged.listen((Event event){
      minD[event.snapshot.key] = event.snapshot.value;
      _homeRefresh.add(true);
      _nationStream.add(true);
    }));
    fireListeners.add(data.child('comsumption/minD').onChildRemoved.listen((Event event){
      minD.remove(event.snapshot.key);
      _homeRefresh.add(true);
      _nationStream.add(true);
    }));
    fireListeners.add(data.child('historyData/trade').onChildAdded.listen((Event event){
      historyData.trade[event.snapshot.key] = event.snapshot.value;
      _tradeHistoryRefresh.add(true);
      _nationStream.add(true);
      //print('get trade ${event.snapshot.value? 'read':'not read'}');
      if(!event.snapshot.value){
        FirebaseDatabase.instance.reference().child('tradeHistory/${event.snapshot.key}').once().then((DataSnapshot snapshot){
          //print('send trade ${snapshot.key}');
          _FABNotification.add(new Notify(dataSnapshot: snapshot, type: NotifyType.trade));
        });
      }
    }));
    fireListeners.add(data.child('historyData/news').onChildAdded.listen((Event event){
      historyData.news[event.snapshot.key] = event.snapshot.value;
      //print('trade added ' + event.snapshot.value.toString());
      _newsRefresh.add(true);
      _nationStream.add(true);
      if(!event.snapshot.value){
        FirebaseDatabase.instance.reference().child('news/${event.snapshot.key}').once().then((DataSnapshot snapshot){
          //print('send trade ${snapshot.key}');
          _FABNotification.add(new Notify(dataSnapshot: snapshot, type: NotifyType.info));
        });
      }
    }));
    fireListeners.add(data.child('historyData/loan').onChildAdded.listen((Event event){
      historyData.loan[event.snapshot.key] = event.snapshot.value;
      _loanDataRefresh.add(true);
    }));
    fireListeners.add(data.child('historyData/loan').onChildRemoved.listen((Event event){
      historyData.loan.remove(event.snapshot.key);
      _loanDataRefresh.add(true);
    }));
    fireListeners.add(data.child('specialBuilding').onValue.listen((Event event){
      specialBuilding = event.snapshot.value?? specialBuilding;
      _governRefresh.add(true);
      _telecom.add(true);
      _nationStream.add(true);
    }));
//    DatabaseReference history = FirebaseDatabase.instance.reference().child('historyData/${currentUser.uid}');
//    fireListeners.add(history.child('GDP').onValue.listen((Event event){
//      historyData.GDP = event.snapshot.value?? historyData.GDP;
//    }));
  }

  void pauseFire(){
    fireListeners.forEach((listener){
      listener.pause();
    });
  }

  void resumeFire(){
    fireListeners.forEach((listener){
      listener.resume();
    });
  }

  void cancelFire(){
    fireListeners.forEach((listener){
      listener.cancel();
    });
  }

  void end(){
    cancelFire();
    _nationStream.close();
    _homeRefresh.close();
    _governRefresh.close();
    _statRefresh.close();
    _telecom.close();
    _tradeHistoryRefresh.close();
    _FABNotification.close();
    _FABRefresh.close();
    _loanDataRefresh.close();
    _newsRefresh.close();
  }

//  void endSession(){
//    collectResources();
//    session ++;
//    //for every resources
//    building.forEach((key, value){
//      //for every factory
//      for(int i = 0; i < value.length; i++){
//        var factory = value[i];
//        //check upgrade
//        if(factory['upgrade']){
//          factory['level']++;
//          factory['upgrade'] = false;
//        }
//      }
//    });
//    //check build
//    buildList.forEach((resource, build){
//      if(build)
//        this.building[resource].add({'level': 0, 'input': {'human': 0, 'Money': 0}, 'upgrade': false});
//    });
//    buildList = {};
//
//    this.humanAvailable = human;//reset humanAvailability
//  }
//
//  void collectResources(){
//    building.forEach((key, value){
//      //for every factory
//      for(int i = 0; i < value.length; i++){
//        var factory = value[i];
//        Map<String, dynamic> factoryStat = master.building[key];
//        //add resources
//        resources[key] += (factory['input']['human'] * (factoryStat['rate']['base'] + factory['level'] * factoryStat['rate']['upgrade'])).toInt();
//        //reset factory input
//        factory['input'] = {'human': 0, 'Money': 0};
//      }
//    });
//  }

  void calculateComsumption(){
    comsumptionDemand = {};
    comsumptionDemand['Wood'] = (human*0.1).toInt();
  }

  String assignResources(String resource, int factory, int human){
    Map<String, double> factoryInput = master.building[resource]['input'];//input statistic
    Map<dynamic, dynamic> input = this.building[resource][factory]['input'];//what have been input
    assert(this.humanAvailable + input['human'] >= human, 'Human not enough');
    //print(this.humanAvailable + input['human'] >= human);
    if(!(this.humanAvailable + input['human'] >= human)){
      return 'Human not enough';
    }
    String r = '';
    factoryInput.forEach((key, value){
      //Solar Panel cost -10%
      if(resourcesMatrix['Solar Panel']){
        print('solar panel found');
        value = value * 0.9;
      }
      if(input.containsKey(key)) {
        //assert(this.resources[key] + input[key] >= value * human, '$key not enough');
        if(!(this.resources[key] + input[key] >= value * human)){
          r = '$key not enough';
          return '$key not enough';
        }
      }else {
        //assert(this.resources[key] >= value * human, '$key not enough');
        if(!(this.resources[key] >= value * human)){
          r = '$key not enough';
          return '$key not enough';
        }
      }
    });
    if(r.length > 0){
      return r;
    }
    //if all enough
    //this.humanAvailable += input['human'] - human;
    _resourcesWrite('humanAvailable', (input['human'] - human));
    input['human'] = human;
    factoryInput.forEach((key, value){
      if(resourcesMatrix['Solar Panel']){
        value = value * 0.9;
      }
      if(input.containsKey(key))
        //this.resources[key] += input[key] - (value * human).toInt();
        _resourcesWrite('resources/${key}', (input[key] - (value * human).toInt()));
      else
        //this.resources[key] -= (value * human).toInt();
        _resourcesWrite('resources/${key}', (-(value * human).toInt()));
      input[key] = (value * human).toInt();
    });
    _buildingWrite(resource, this.building[resource]);
    return 'assign';
  }

  String upgradeBuilding(String resource, int factory){
    assignResources(resource, factory, 0);
    Map<dynamic, dynamic> target = this.building[resource][factory];
    Map<String, int> upgrade = master.building[resource]['upgrade'][target['level']+1];
    if(!(this.humanAvailable >= upgrade['human'])){
      return 'No enough labour';
    }
    if(!(this.resources['Money'] >= upgrade['Money'])){
      return 'No enough money';
    }
    List<String> r = [];
    master.resourcesOrder.forEach((s){
      if(upgrade.containsKey(s))
        if(!(this.resources[s] >= upgrade[s])){
          r.add(s);
        }
    });
    if(r.length > 0){
      if(r.length == 1)
        return 'No enough ${r[0]}';
      else{
        String returnString = 'No enough ';
        for(int i = 0; i < r.length-1; i++){
          returnString += r[i] + ', ';
        }
        returnString = returnString.substring(0, returnString.length-2);
        returnString += ' and ${r[r.length-1]}';
      }
    }
    if(upgrade.containsKey('Education')){
      if(specialBuilding['Education']['level'] < upgrade['Education']){
        return 'Education level need to be level ${upgrade['Education']} or above';
      }
    }
    upgrade.forEach((key, value){
      if(key == 'human')
        //humanAvailable -= upgrade['human'];
        _resourcesWrite('humanAvailable', -upgrade['human']);
      else
        //this.resources[key] -= upgrade[key];
        _resourcesWrite('resources/${key}', -upgrade[key]);
    });
    target['upgrade'] = true;
    _buildingWrite(resource, this.building[resource]);
    return 'build';
  }

  bool cancelUpgradeBuilding(String resource, int factory){
    Map<dynamic, dynamic> target = this.building[resource][factory];
    Map<String, int> upgrade = master.building[resource]['upgrade'][target['level']+1];
    upgrade.forEach((key, value){
      if(key == 'human')
        //humanAvailable += upgrade['human'];
        _resourcesWrite('humanAvailable', upgrade['human']);
      else
        //this.resources[key] += upgrade[key];
        _resourcesWrite('resources/${key}', (upgrade[key] * 0.8).toInt());
    });
    target['upgrade'] = false;
    _buildingWrite(resource, this.building[resource]);
    return true;
  }

  String newBuilding(String resource){
    Map<String, int> upgrade = master.building[resource]['upgrade'][0];
    if(!(this.humanAvailable >= upgrade['human'])){
      return 'No enough labour';
    }
    if(!(this.resources['Money'] >= upgrade['Money'])){
      return 'No enough money';
    }
    List<String> r = [];
    master.resourcesOrder.forEach((s){
      if(upgrade.containsKey(s))
        if(!(this.resources[s] >= upgrade[s])){
          r.add(s);
        }
    });
    if(r.length > 0){
      if(r.length == 1)
        return 'No enough ${r[0]}';
      else{
        String returnString = 'No enough ';
        for(int i = 0; i < r.length-1; i++){
          returnString += r[i] + ', ';
        }
        returnString = returnString.substring(0, returnString.length-2);
        returnString += ' and ${r[r.length-1]}';
      }
    }
    if(upgrade.containsKey('Education')){
      if(specialBuilding['Education']['level'] < upgrade['Education']){
        return 'Education level need to be level ${upgrade['Education']} or above';
      }
    }
    upgrade.forEach((key, value){
      if(key == 'human')
        //humanAvailable -= upgrade['human'];
        _resourcesWrite('humanAvailable', -upgrade['human']);
      else
        //this.resources[key] -= upgrade[key];
        _resourcesWrite('resources/${key}', -upgrade[key]);
    });
    buildList[resource] = true;
    _resourcesBuild(resource, true);
    return 'build';
  }

  bool cancelNewBuilding(String resource){
    Map<String, int> upgrade = master.building[resource]['upgrade'][0];
    upgrade.forEach((key, value){
      if(key == 'human')
        //humanAvailable += upgrade['human'];
        _resourcesWrite('humanAvailable', upgrade['human']);
      else
        //this.resources[key] += upgrade[key];
        _resourcesWrite('resources/${key}', (upgrade[key] * 0.8).toInt());
    });
    buildList[resource] = false;
    _resourcesBuild(resource, false);
    return true;
  }

  String upgradeSpecialBuilding(String type){
    Map<dynamic, dynamic> target = this.specialBuilding[type];
    Map<String, int> upgrade = master.specialBuilding[type]['upgrade'][target['level']];
    if(!(this.humanAvailable >= upgrade['human'])){
      return 'No enough labour';
    }
    if(!(this.resources['Money'] >= upgrade['Money'])){
      return 'No enough money';
    }
    bool r = true;
    master.resourcesOrder.forEach((s){
      if(upgrade.containsKey(s))
        if(!(this.resources[s] >= upgrade[s])){
          r = false;
        };
    });
    if(!r){
      return 'No enough resources';
    }
    if(upgrade.containsKey('R&D')){
      int level = this.specialBuilding['R&D']['level'];
      if(!(level >= upgrade['R&D'])){
        return 'R&D no enough to support';
      };
    }
    upgrade.forEach((key, value){
      if(key == 'human')
        //humanAvailable -= upgrade['human'];
        _resourcesWrite('humanAvailable', -upgrade['human']);
      else if(key == 'Money')
        //this.resources[key] -= upgrade[key];
        _resourcesWrite('resources/${key}', -upgrade[key]);
    });
    target['upgrade'] = true;
    _specialBuildingWrite(type);
    return 'build';
  }

  bool cancelUpgradeSpecialBuilding(String type){
    Map<dynamic, dynamic> target = this.specialBuilding[type];
    Map<String, int> upgrade = master.specialBuilding[type]['upgrade'][target['level']];
    upgrade.forEach((key, value){
      if(key == 'human')
        //humanAvailable += upgrade['human'];
        _resourcesWrite('humanAvailable', upgrade['human']);
      else if(key == 'Money')
        //this.resources[key] += upgrade[key];
        _resourcesWrite('resources/${key}', (upgrade[key] * 0.8).toInt());
    });
    target['upgrade'] = false;
    _specialBuildingWrite(type);
    return true;
  }

  bool resourcesComsumption(String resource, int amount){
    if(comsumptionSupply.containsKey(resource)){
      //this.resources[resource] += (comsumptionSupply[resource] - amount);
      _resourcesWrite('resources/${resource}', (comsumptionSupply[resource] - amount));
    }else{
      //this.resources[resource] += (-amount);
      _resourcesWrite('resources/${resource}', ( - amount));
    }
    _comsumptionWrite(resource, amount);
  }

  String developLand(){
    if(land >= 30){
      return 'Reach maximum development for land';
    }
    //check resources
//    if(!(this.humanAvailable >= upgrade['human'])){
//      return 'No enough labour';
//    }
//    if(!(this.resources['Money'] >= upgrade['Money'])){
//      return 'No enough money';
//    }
//    bool r = true;
//    master.resourcesOrder.forEach((s){
//      if(upgrade.containsKey(s))
//        if(!(this.resources[s] >= upgrade[s])){
//          r = false;
//        };
//    });
//    if(!r){
//      return 'No enough resources';
//    }
    //if can
    //_resourcesWrite()
    //_developL(true)
  }

  bool cancelDevelopLand(){
    //_resourcesWrite()
    //_developL(false)
  }

  Future<String> repayment(double amount, String id, bool full, String transactionID) async {
    if(amount > resources['Money']){
      return 'Not enough money for repayment';
    }
    bool getMoney = await _resourcesWrite('resources/Money', (-amount).toInt());
    if(getMoney){
      TransactionResult transactionResult = await FirebaseDatabase.instance.reference().child('loan/pay/${transactionID}').runTransaction((MutableData mutableData) async {
        mutableData.value = {};
        mutableData.value['loanID'] = id;
        mutableData.value['full'] = full;
        mutableData.value['amount'] = amount;
        return mutableData;
      });
      return transactionResult.committed? 'Sending':'Error in sending';
    }
    return 'Error in getting money';
  }

  //FIREBASE FUNCTION//
  Future<void> _resourcesBuild(String resource, bool build) async {
    DatabaseReference _resource = FirebaseDatabase.instance.reference().child('users/${currentUser.uid}/buildList/${resource}');
    final TransactionResult transactionResult =
    await _resource.runTransaction((MutableData mutableData) async {
      //print('${resource} This is ${await mutableData.value}');
      mutableData.value = build;
      //print('${resource} Now is ${mutableData.value}');
      return mutableData;
    });
    final TransactionResult usedLand = await FirebaseDatabase.instance.reference().child('users/${currentUser.uid}/landAvailable').runTransaction((MutableData mutableData) async {
      mutableData.value = (mutableData.value ?? this.landAvailable) + (build? 1:-1);
      print('land Updated == '+ mutableData.value.toString());
      return mutableData;
    });

    if (transactionResult.committed && usedLand.committed) {
      //print('success');
    } else {
      print('Transaction not committed.');
      if (transactionResult.error != null) {
        print(transactionResult.error.message);
      }
    }
  }

  Future<bool> _resourcesWrite(String resource, int amount) async {
    DatabaseReference _resource = FirebaseDatabase.instance.reference().child('users/${currentUser.uid}/${resource}');
    final TransactionResult transactionResult =
    await _resource.runTransaction((MutableData mutableData) async {
      //print('This is ${await mutableData.value}');
      mutableData.value = (mutableData.value ?? this.resources[resource]) + amount;
      //print('Now is ${mutableData.value}');
      return mutableData;
    });

    if (transactionResult.committed) {
      //print('success');
    } else {
      print('Transaction not committed.');
      if (transactionResult.error != null) {
        print(transactionResult.error.message);
      }
    }
    return transactionResult.committed;
  }

  Future<void> _buildingWrite(String resource, dynamic input) async {
    DatabaseReference _resource = FirebaseDatabase.instance.reference().child('users/${currentUser.uid}/building/${resource}');
    final TransactionResult transactionResult =
    await _resource.runTransaction((MutableData mutableData) async {
      //print('This is ${await mutableData.value}');
      mutableData.value = input;
      //print('Now is ${mutableData.value}');
      return mutableData;
    });

    if (transactionResult.committed) {
      //print('success');
    } else {
      print('Transaction not committed.');
      if (transactionResult.error != null) {
        print(transactionResult.error.message);
      }
    }
  }

  Future<void> _specialBuildingWrite(String type) async {
    DatabaseReference _type = FirebaseDatabase.instance.reference().child('users/${currentUser.uid}/specialBuilding/${type}/upgrade');
    final TransactionResult transactionResult =
    await _type.runTransaction((MutableData mutableData) async {
      mutableData.value = specialBuilding[type]['upgrade'];
      return mutableData;
    });

    if (transactionResult.committed) {
      //print('success');
    } else {
      print('Transaction not committed.');
      if (transactionResult.error != null) {
        print(transactionResult.error.message);
      }
    }
  }

  Future<void> _comsumptionWrite(String resource, int input) async {
    DatabaseReference _resource = FirebaseDatabase.instance.reference().child('users/${currentUser.uid}/comsumption/supply/${resource}');
    final TransactionResult transactionResult =
    await _resource.runTransaction((MutableData mutableData) async {
      //print('This is ${await mutableData.value}');
      mutableData.value = input;
      //print('Now is ${mutableData.value}');
      return mutableData;
    });

    if (transactionResult.committed) {
      //print('success');
    } else {
      print('Transaction not committed.');
      if (transactionResult.error != null) {
        print(transactionResult.error.message);
      }
    }
  }


  /* TRADE */
  Future<bool> privateTrade(String id, Map<String, dynamic> tradeData) async {
    DatabaseReference _ref = FirebaseDatabase.instance.reference().child('privateTrade/${id}');
    final TransactionResult transactionResult = await _ref.runTransaction((MutableData mutableData) async {
      mutableData.value = tradeData;
      return mutableData;
    });
    return transactionResult.committed;
  }

  Future<bool> publicTradeMaker(bool bid, int quantity, double price, String resource, String id) async {
    DatabaseReference _user = FirebaseDatabase.instance.reference().child('users/${currentUser.uid}');
    DatabaseReference _trade = FirebaseDatabase.instance.reference().child('trade/${resource}/${bid? 'Bid':'Ask'}/${id}');
    if(bid){
      TransactionResult resourceChange = await _user.child('resources').runTransaction((MutableData mutableData) async {
        if(mutableData.value != null) {
          mutableData.value['Money'] -= quantity * price;
        }
        return mutableData;
      });
      while(!(await resourceChange.committed)){
        print('resourceChange recommit');
        resourceChange = await _user.child('resources').runTransaction((MutableData mutableData) async {
          if(mutableData.value != null) {
            mutableData.value['Money'] -= quantity * price;
          }
          return mutableData;
        });
      }
      TransactionResult tradepoolChange = await _user.child('tradepool').runTransaction((MutableData mutableData) async {
        if(mutableData.value != null){
          if(mutableData.value['Money'] == null)
            mutableData.value['Money'] = quantity * price;
          else
            mutableData.value['Money'] += quantity * price;
        }
        return mutableData;
      });
      while(!(await tradepoolChange.committed)){
        print('tradepoolChange recommit');
        tradepoolChange = await _user.child('tradepool').runTransaction((MutableData mutableData) async {
          if(mutableData.value == null) {
            mutableData.value = {};
            mutableData.value['Money'] = quantity * price;
          }else {
            mutableData.value['Money'] += quantity * price;
          }
          return mutableData;
        });
      }
      TransactionResult tradeAdd = await _trade.runTransaction((MutableData mutableData) async {
        mutableData.value = {
          'buyer': currentUser.uid,
          'price': price,
          'quantity': quantity
        };
        return mutableData;
      });
      while(!(await tradeAdd.committed)){
        print('tradeAdd recommit');
        tradeAdd = await _trade.runTransaction((MutableData mutableData) async {
          mutableData.value = {
            'buyer': currentUser.uid,
            'price': price,
            'quantity': quantity
          };
          return mutableData;
        });
      }
      print('bid completed');
      return (resourceChange.committed && tradepoolChange.committed && tradeAdd.committed);
    }else{
      TransactionResult resourceChange = await _user.child('resources').runTransaction((MutableData mutableData) async {
        if(mutableData.value != null) {
          mutableData.value[resource] -= quantity;
        }
        return mutableData;
      });
      while(!resourceChange.committed){
        resourceChange = await _user.child('resources').runTransaction((MutableData mutableData) async {
          if(mutableData.value != null) {
            mutableData.value[resource] -= quantity;
          }
          return mutableData;
        });
      }
      TransactionResult tradepoolChange = await _user.child('tradepool').runTransaction((MutableData mutableData) async {
        if(mutableData.value != null) {
          if(mutableData.value[resource] == null)
            mutableData.value[resource] = quantity;
          else
            mutableData.value[resource] += quantity;
        }
        return mutableData;
      });
      while(!tradepoolChange.committed){
        tradepoolChange = await _user.child('tradepool').runTransaction((MutableData mutableData) async {
          if(mutableData.value != null) {
            if(mutableData.value[resource] == null)
              mutableData.value[resource] = quantity;
            else
              mutableData.value[resource] += quantity;
          }
          return mutableData;
        });
      }
      TransactionResult tradeAdd = await _trade.runTransaction((MutableData mutableData) async {
        mutableData.value = {
          'seller': currentUser.uid,
          'price': price,
          'quantity': quantity
        };
        return mutableData;
      });
      while(!tradeAdd.committed){
        tradeAdd = await _trade.runTransaction((MutableData mutableData) async {
          mutableData.value = {
            'seller': currentUser.uid,
            'price': price,
            'quantity': quantity
          };
          return mutableData;
        });
      }
      return (resourceChange.committed && tradepoolChange.committed && tradeAdd.committed);
    }
  }

  Future<bool> publicTradeTaker(bool buy, int quantity, String resource, String id, Map<dynamic, dynamic> makerData, String makerKey) async  {
    String transactionId = makerKey.substring(1, 4) + id + makerKey.substring(11, 14);
    DatabaseReference _publicTrade = FirebaseDatabase.instance.reference().child('publicTrade/${transactionId}');
    if(buy){
      makerData['buyer'] = currentUser.uid;
      makerData['type'] = 'buy';
    }else{
      makerData['seller'] = currentUser.uid;
      makerData['type'] = 'sell';
    }
    makerData['quantity'] = quantity;
    makerData['resource'] = resource;
    makerData['makerKey'] = makerKey;
    final TransactionResult transactionResult = await _publicTrade.runTransaction((MutableData mutableData) async {
      mutableData.value = makerData;
      return mutableData;
    });
    return transactionResult.committed;
  }

  Future<bool> cancelMaker(bool bid, String resource, String id) async {
    DatabaseReference _user = FirebaseDatabase.instance.reference().child('users/${currentUser.uid}');
    DatabaseReference _trade = FirebaseDatabase.instance.reference().child('trade/${resource}/${bid? 'Bid':'Ask'}/${id}');
    MutableData trade;
    dynamic tradeData;
    TransactionResult cancelTrade = await _trade.runTransaction((MutableData mutableData) async {
      if(mutableData.value != null){
        trade = mutableData;
        tradeData = trade.value;
        mutableData.value = {};
      }
      return mutableData;
    });
    trade.value = tradeData;
    if(bid){
      TransactionResult resourceChange = await _user.child('resources').runTransaction((MutableData mutableData) async {
        if(mutableData.value != null){
          mutableData.value['Money'] += trade.value['quantity'] * trade.value['price'];
        }
        return mutableData;
      });
      TransactionResult tradepoolChange = await _user.child('tradepool').runTransaction((MutableData mutableData) async {
        if(mutableData.value != null){
          mutableData.value['Money'] -= trade.value['quantity'] * trade.value['price'];
        }
        return mutableData;
      });
      return (resourceChange.committed && tradepoolChange.committed);
    }else{
      TransactionResult resourceChange = await _user.child('resources').runTransaction((MutableData mutableData) async {
        if(mutableData.value != null){
          mutableData.value[resource] += trade.value['quantity'];
        }
        return mutableData;
      });
      TransactionResult tradepoolChange = await _user.child('tradepool').runTransaction((MutableData mutableData) async {
        if(mutableData.value != null){
          mutableData.value[resource] -= trade.value['quantity'];
        }
        return mutableData;
      });
      return (resourceChange.committed && tradepoolChange.committed);
    }
  }

  Future<bool> initiatedNation(String name, String hash, int population, String url) async {
    if(created)
      return created;
    TransactionResult addNationList = await FirebaseDatabase.instance.reference().child('idToName/${currentUser.uid}').runTransaction((MutableData mutableData) async {
      Map<dynamic, dynamic> data = {};
      data['name'] = name;
      data['hash'] = hash;
      data['url'] = url;
      print(url);
      mutableData.value = data;
      return mutableData;
    });
    DatabaseReference _user = FirebaseDatabase.instance.reference().child('users/${currentUser.uid}');
    TransactionResult setc = await _user.child('create').runTransaction((MutableData mutableData) async {
      mutableData.value = true;
      return mutableData;
    });
    TransactionResult setPopulation = await _user.child('human').runTransaction((MutableData mutableData) async {
      mutableData.value = population;
      return mutableData;
    });
    TransactionResult setP = await _user.child('humanAvailable').runTransaction((MutableData mutableData) async {
      mutableData.value = population;
      return mutableData;
    });
    created = addNationList.committed && setPopulation.committed && setP.committed && setc.committed;
    return created;
  }

  void tradeHistoryRead() async {
    historyData.trade.forEach((k, v){
      historyData.trade[k] = true;
    });
    TransactionResult transactionResult = await FirebaseDatabase.instance.reference().child('users/${currentUser.uid}/historyData/trade').runTransaction((MutableData mutableData) async {
      mutableData.value = historyData.trade;
      return mutableData;
    });
    //print('Trade Read ${transactionResult.committed}');
  }

  void newsRead() async {
//    historyData.trade.forEach((k, v){
//      historyData.news[k] = true;
//    });
//    TransactionResult transactionResult = await FirebaseDatabase.instance.reference().child('users/${currentUser.uid}/historyData/news').runTransaction((MutableData mutableData) async {
//      mutableData.value = historyData.news;
//      return mutableData;
//    });
//    print('News Read ${transactionResult.committed}');
  }

  Future<void> _developL(bool develop) async {
    TransactionResult transactionResult = await FirebaseDatabase.instance.reference().child('users/${currentUser.uid}/developedLand').runTransaction((MutableData mutableData) async {
      mutableData.value = develop;
      return mutableData;
    });
  }
}
