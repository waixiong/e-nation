import 'package:flutter/material.dart';

import 'package:e_nation/Logic/Master.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_nation/Screen/identityImage.dart';

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
    'Oil': {'LastDone': 1.5, 'AskPrice': null, 'BidPrice': null},
    'Leather': {'LastDone': 8.0, 'AskPrice': null, 'BidPrice': null},
    'Copper': {'LastDone': 6.0, 'AskPrice': null, 'BidPrice': null},
    'Silver': {'LastDone': 15.0, 'AskPrice': null, 'BidPrice': null},
    'Vegetable': {'LastDone': 2.5, 'AskPrice': null, 'BidPrice': null},
    'Meat': {'LastDone': 5.0, 'AskPrice': null, 'BidPrice': null},
    'Car': {'LastDone': 80.0, 'AskPrice': null, 'BidPrice': null},
    'Shirt': {'LastDone': 5.0, 'AskPrice': null, 'BidPrice': null},
    'Processed Vegetable': {'LastDone': 10.0, 'AskPrice': null, 'BidPrice': null},
    'Processed Meat': {'LastDone': 14.0, 'AskPrice': null, 'BidPrice': null},
    'Solar Panel': {'LastDone': 25.0, 'AskPrice': null, 'BidPrice': null},
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
    'Oil': {'Ask' : {}, 'Bid': {}},
    'Leather': {'Ask' : {}, 'Bid': {}},
    'Copper': {'Ask' : {}, 'Bid': {}},
    'Silver': {'Ask' : {}, 'Bid': {}},
    'Vegetable': {'Ask' : {}, 'Bid': {}},
    'Meat': {'Ask' : {}, 'Bid': {}},
    'Car': {'Ask' : {}, 'Bid': {}},
    'Shirt': {'Ask' : {}, 'Bid': {}},
    'Processed Vegetable': {'Ask' : {}, 'Bid': {}},
    'Processed Meat': {'Ask' : {}, 'Bid': {}},
    'Solar Panel': {'Ask' : {}, 'Bid': {}},
    'Furniture': {'Ask' : {}, 'Bid': {}},
    'Jewellery': {'Ask' : {}, 'Bid': {}},
    'Gloves': {'Ask' : {}, 'Bid': {}},
    'Bag': {'Ask' : {}, 'Bid': {}},
    'Gadget': {'Ask' : {}, 'Bid': {}},
    'Book': {'Ask' : {}, 'Bid': {}}
  };

  List<String> privateTrade = [];
  final StreamController<bool> _privateScan = StreamController<bool>();
  Stream<bool> get privateScan => _privateScan.stream;

  List<String> publicTrade = [];
  final StreamController<Map<String, bool>> _publicResult = StreamController<Map<String, bool>>();
  Stream<Map<String, bool>> get publicResult => _publicResult.stream;

  void initialize(){
    DatabaseReference nations = FirebaseDatabase.instance.reference().child('idToName');
    nations.onChildAdded.listen((event){
      nationList[event.snapshot.key] = event.snapshot.value;
    });
    master.resourcesOrder.forEach((resource){
      trade[resource]['LastDone'] = master.resources[resource]['price'];
    });
    DatabaseReference privateT = FirebaseDatabase.instance.reference().child('privateTrade');
    privateT.onChildAdded.listen((event){
      print('the p_trade is '+event.snapshot.key);
      bool found = false;
      privateTrade.forEach((k){
        print('mine is '+k);
        if(k == event.snapshot.key){
          found = true;
          //_privateScan.add(true);
        }
      });
      if(found){
        print('Trade Manager : found scan');
        privateTrade.remove(event.snapshot.key);
        _privateScan.add(true);
      }
    });
    DatabaseReference publicT = FirebaseDatabase.instance.reference().child('publicTrade');
    publicT.onChildAdded.listen((event){
      publicTrade.forEach((k) async {
        if(k == event.snapshot.key){
          publicTrade.remove(k);
          await FirebaseDatabase.instance.reference().child('tradeHistory/${k}/exe').once().then((snap){
            _publicResult.add({ event.snapshot.key : snap.value()});
          });
        }
      });
    });
  }
}