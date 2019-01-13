import 'package:e_nation/Logic/Master.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class TradeManager{
  TradeManager({this.currentUser});

  Master master = new Master();
  FirebaseUser currentUser;
  Map<dynamic, dynamic> nationList = {};

  var trade = {
    'Wood': {'LastDone': 2.0, 'AskPrice': null, 'BidPrice': null},
    'Sand': {'LastDone': 2.0, 'AskPrice': null, 'BidPrice': null},
    'Steel': {'LastDone': 5.0, 'AskPrice': null, 'BidPrice': null},
    'Rubber': {'LastDone': 3.5, 'AskPrice': null, 'BidPrice': null},
    'Cotton': {'LastDone': 0.8, 'AskPrice': null, 'BidPrice': null},
    'Petrol': {'LastDone': 1.5, 'AskPrice': null, 'BidPrice': null},
    'Leather': {'LastDone': 8.0, 'AskPrice': null, 'BidPrice': null},
    'Copper': {'LastDone': 6.0, 'AskPrice': null, 'BidPrice': null},
    'Silver': {'LastDone': 15.0, 'AskPrice': null, 'BidPrice': null},
    'Vegetable': {'LastDone': 2.5, 'AskPrice': null, 'BidPrice': null},
    'Meat': {'LastDone': 5.0, 'AskPrice': null, 'BidPrice': null},
    'Car': {'LastDone': 80.0, 'AskPrice': null, 'BidPrice': null},
    'Shirt': {'LastDone': 5.0, 'AskPrice': null, 'BidPrice': null},
    'FoodVegetable': {'LastDone': 10.0, 'AskPrice': null, 'BidPrice': null},
    'FoodMeat': {'LastDone': 14.0, 'AskPrice': null, 'BidPrice': null},
    'HouseholdAppliances': {'LastDone': 25.0, 'AskPrice': null, 'BidPrice': null},
    'Furniture': {'LastDone': 20.0, 'AskPrice': null, 'BidPrice': null},
    'Jewellery': {'LastDone': 40.0, 'AskPrice': null, 'BidPrice': null},
    'Gloves': {'LastDone': 16.0, 'AskPrice': null, 'BidPrice': null},
    'Bag': {'LastDone': 20.0, 'AskPrice': null, 'BidPrice': null},
    'Gadget': {'LastDone': 28.0, 'AskPrice': null, 'BidPrice': null},
    'Book': {'LastDone': 10.0, 'AskPrice': null, 'BidPrice': null}
  };

  dynamic tradeQueue = {
    'Wood': {'Ask' : {}, 'Bid': {}},
    'Sand': {'Ask' : {}, 'Bid': {}},
    'Steel': {'Ask' : {}, 'Bid': {}},
    'Rubber': {'Ask' : {}, 'Bid': {}},
    'Cotton': {'Ask' : {}, 'Bid': {}},
    'Petrol': {'Ask' : {}, 'Bid': {}},
    'Leather': {'Ask' : {}, 'Bid': {}},
    'Copper': {'Ask' : {}, 'Bid': {}},
    'Silver': {'Ask' : {}, 'Bid': {}},
    'Vegetable': {'Ask' : {}, 'Bid': {}},
    'Meat': {'Ask' : {}, 'Bid': {}},
    'Car': {'Ask' : {}, 'Bid': {}},
    'Shirt': {'Ask' : {}, 'Bid': {}},
    'FoodVegetable': {'Ask' : {}, 'Bid': {}},
    'FoodMeat': {'Ask' : {}, 'Bid': {}},
    'HouseholdAppliances': {'Ask' : {}, 'Bid': {}},
    'Furniture': {'Ask' : {}, 'Bid': {}},
    'Jewellery': {'Ask' : {}, 'Bid': {}},
    'Gloves': {'Ask' : {}, 'Bid': {}},
    'Bag': {'Ask' : {}, 'Bid': {}},
    'Gadget': {'Ask' : {}, 'Bid': {}},
    'Book': {'Ask' : {}, 'Bid': {}}
  };

  void initialize(){
    DatabaseReference nations = FirebaseDatabase.instance.reference().child('idToName');
    nations.onChildAdded.listen((event){
      nationList[event.snapshot.key] = event.snapshot.value;
    });
    master.resourcesOrder.forEach((resource){
      trade[resource]['LastDone'] = master.resources[resource]['price'];
    });
  }

  bool privateTrade(Map<String, dynamic> tradeData){

  }
}