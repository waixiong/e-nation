import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qrcode_reader/qrcode_reader.dart';
import 'dart:async';
import 'dart:math';
import 'dart:convert';

import 'package:e_nation/Screen/LoginPage.dart';
import 'package:e_nation/Logic/Nation.dart';
import 'package:e_nation/Logic/TradeManager.dart';
import 'package:e_nation/Screen/identityImage.dart';
import 'package:e_nation/Screen/_FactoryCard.dart';

class QRPage extends StatefulWidget{
  QRPage({Key key, this.JSON, this.targetName, this.chosenResource, this.q, this.p, this.price, this.buyerImage});
  String JSON;
  String targetName;
  String chosenResource;
  int q;
  double p;
  double price;
  Widget buyerImage;
  Function dismiss;

  _QRPage createState() => new _QRPage();
}

class _QRPage extends State<QRPage>{

  @override
  void initState(){
    super.initState();
    widget.dismiss = (){
      print('ORPage : detect trade');
      if(this.mounted){
        print('is mounted');
        Navigator.pop(context);
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Container(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Text('Give ${widget.targetName} scan for executing this trade.', style: TextStyle(fontSize: 18,),textAlign: TextAlign.center,),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new QrImage(
                data: widget.JSON,
                size: 200,
                version: 12,
                errorCorrectionLevel: 3,//QrErrorCorrectLevel{L, M, H, Q} in 'package:qr/qr.dart'
              ),
              new Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: widget.buyerImage,
                  ),
                  new Text('${widget.chosenResource}'),
                  new Text('${widget.q} @ \$${widget.price.toStringAsFixed(2)}'),
                  new Text('Total \$${(widget.q*double.parse(widget.p.toStringAsFixed(2))).toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w700),)
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}

class PrivateTrade extends StatefulWidget{
  PrivateTrade({Key key, this.nation, this.tradeManager, this.currentUser});

  Nation nation;
  TradeManager tradeManager;
  FirebaseUser currentUser;
  StreamSubscription<bool> change;
  StreamSubscription<bool> tele;

  _PrivateTradeState createState() => new _PrivateTradeState();
}

class _PrivateTradeState extends State<PrivateTrade> with AutomaticKeepAliveClientMixin<PrivateTrade>{

  int quantity = 0;
  String chosenNation = null;
  String chosenResource = null;
  TextEditingController quantityController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  double price = 0.00;
  final _priceKey = GlobalKey<FormState>();
  final _quantityKey = GlobalKey<FormState>();
  QRPage qr;

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  void initState(){
    super.initState();
    priceController.addListener((){});
    quantityController.addListener((){});
    if(widget.change == null){
      widget.change = widget.tradeManager.privateScan.listen((t){
        print('Trade Page : get');
        if(qr != null){
          print('Trade Page : scan');
          qr.dismiss();
        }
        //Navigator.pop(context);
      });
    }else{
      widget.change.resume();
    }
    if(widget.tele == null){
      widget.tele = widget.nation.telecom.listen((t){
        setState(() {});
      });
    }else{
      widget.tele.resume();
    }
  }

  @override
  void dispose(){
    widget.change.pause();
    widget.tele.pause();
    super.dispose();
  }

  Widget targetChooser(){
    List<DropdownMenuItem<String>> nationArray = <DropdownMenuItem<String>>[];
    widget.tradeManager.nationList.forEach((id, value){
      if(id != widget.currentUser.uid)
        nationArray.add(new DropdownMenuItem<String>(
          value: id,
          child: new Row(
            children: <Widget>[
              new Padding(
                padding: EdgeInsets.only(right: 10),
                child: IdentityPhoto.fromUID(size: 24, uid: id, tradeManager: widget.tradeManager),
              ),
              new Text('${value['name']}')
            ],
          ),
        ));
    });
    if(chosenResource == null)
      return new Card();
    return new Card(
      child: new Padding(
        padding: EdgeInsets.all(20),
        child: new Row(
          children: <Widget>[
            new Expanded(child: new Text('Buyer'), flex: 1,),
            new Expanded(
              flex: 2,
              child: new DropdownButton<String>(
                  value: chosenNation,
                  hint: new Text('Nation'),
                  items: nationArray,
                  onChanged: (String newValue) => setState(() { chosenNation = newValue; })
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget resourceSlider(){//change from slider to text
    if(chosenResource == null)
      return new Card();
    int max = (widget.nation.resources[chosenResource] / 100).floor() * 100;
    return new Card(
      child: new Container(
        width: MediaQuery.of(context).size.width,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
//          new Padding(
//            padding: EdgeInsets.all(20),
//            child: new Slider(
//              value: quantity.toDouble(),
//              min: 0,
//              max: max.toDouble(),
//              divisions: (max >= 100)? (max/100).toInt() : 1,
//              label: '${quantity.round()}',
//              onChanged: (double value){
//                setState(() {
//                  quantity = value.toInt();
//                });
//              },
//              activeColor: Colors.grey.shade500,
//            ),
//          ),
            new Container(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
              width: MediaQuery.of(context).size.width * 0.6,
              child: new Form(
                onChanged: () => _quantityKey.currentState.validate(),
                key: _quantityKey,
                child: new TextFormField(
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  decoration: new InputDecoration(labelText: 'Quantity'),
                  autofocus: false,
                  validator: (value){
                    try{
                      quantity = int.parse(value);
                      if(quantity > widget.nation.resources[chosenResource]){
                        return 'Please enter available quantity\n${widget.nation.resources[chosenResource].toString()} or below';
                      }
                      return null;
                    }catch(e){
                      return 'Please enter a integer as quantity';
                    }
                  },
                  controller: quantityController,
                ),
              ),
            ),
            new Container(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
              width: MediaQuery.of(context).size.width * 0.6,
              child: new Form(
                key: _priceKey,
                child: new TextFormField(
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  decoration: new InputDecoration(labelText: 'Price'),
                  autofocus: false,
                  validator: (value){
                    try{
                      price = double.parse(value);
                      return null;
                    }catch(e){
                      return 'Please enter a two decimals place as price';
                    }
                  },
                  controller: priceController,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<String>> resourcesList = new List<DropdownMenuItem<String>>();
    widget.tradeManager.master.resourcesOrder.forEach((String resource){
      if(widget.nation.resources[resource] > 0) {
        resourcesList.add(new DropdownMenuItem<String>(
          value: resource,
          child: new Row(
            children: <Widget>[
              ResourcePic(resourceImg: widget.nation.master.resources[resource]['img'], radius: 10.0,),
              new Text('${resource}')
            ],
          ),
        ));
      }
    });
    List<Widget> columnList = <Widget>[
      new Card(
        child: new Padding(
          padding: EdgeInsets.all(8),
          child: new Row(
            children: <Widget>[
              new Expanded(
                flex: 1,
                child: Text('Resources', style: new TextStyle(fontWeight: FontWeight.bold)),
              ),
              new Expanded(
                flex: 2,
                child: new DropdownButton<String>(
                    value: chosenResource,
                    hint: new Text('Resource'),
                    items: resourcesList,
                    onChanged: (String newValue) => setState(() { chosenResource = newValue; })
                ),
              )
            ],
          ),
        ),
      )
    ];
    columnList.add(resourceSlider());
    columnList.add(targetChooser());
    columnList.add(new Container(
      //height: MediaQuery.of(context).size.height * 0.15,
      padding: EdgeInsets.all(6),
      child: new Row(
        children: <Widget>[
          new Expanded(
            flex: 4,
            child: RaisedButton(
              child: new Text('Generate QR Trade'),
              onPressed: chosenNation != null? (){
                if(_priceKey.currentState.validate() && _quantityKey.currentState.validate()){
                  if(quantity <= 0){
                    Scaffold.of(context).removeCurrentSnackBar();
                    Scaffold.of(context).showSnackBar(SnackBar(content: new Text('Please enter quantity')));
                  }else{
                    String id = (Random.secure().nextDouble() * 9223372036854775807).floor().toRadixString(16);
                    widget.tradeManager.privateTrade.add(id);
                    //print(id);
                    Map<String, dynamic> ptrade = {
                      'seller': widget.currentUser.uid,
                      'buyer': chosenNation,
                      'resource': chosenResource,
                      'quantity': quantity,
                      'price': price,
                      'id': id
                    };
                    print(id + ' ready to scan');
                    String JSON = json.encode(ptrade);
                    int q = quantity;
                    double p = price;
                    qr = new QRPage(JSON: JSON, targetName: widget.tradeManager.nationList[chosenNation]['name'], chosenResource: chosenResource, p: p, q: q, price: price, buyerImage: IdentityPhoto.fromUID(size: 80, uid: chosenNation, tradeManager: widget.tradeManager),);
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context){
                        return qr;
//                        return new Container(
//                          child: new Column(
//                            crossAxisAlignment: CrossAxisAlignment.center,
//                            children: <Widget>[
//                              new Text('Give ${widget.tradeManager.nationList[chosenNation]['name']} scan for executing this trade.', style: TextStyle(fontSize: 18,),textAlign: TextAlign.center,),
//                              new Row(
//                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                                children: <Widget>[
//                                  new QrImage(
//                                    data: JSON,
//                                    size: 240,
//                                    version: 12,
//                                    errorCorrectionLevel: 3,//QrErrorCorrectLevel{L, M, H, Q} in 'package:qr/qr.dart'
//                                    onError: (ex) {
//                                      print("[QR] ERROR - $ex");
//                                      setState(() {
//                                        print("Error! Maybe your input value is too long?");
//                                      });
//                                    },
//                                  ),
//                                  new Column(
//                                    children: <Widget>[
//                                      new Text('${chosenResource}'),
//                                      new Text('${q}@\$${price.toStringAsFixed(2)}'),
//                                      new Text('Total \$${(q*double.parse(p.toStringAsFixed(2))).toStringAsFixed(2)}')
//                                    ],
//                                  ),
//                                ],
//                              )
//                            ],
//                          ),
//                        );
                      }
                    );
                    setState(() {
                      quantity = 0;
                      quantityController.text = '';
                    });
                  }
                }
              } : null,
            ),
          ),
          new Expanded(
            flex: 4,
            child: RaisedButton(
              onPressed: () async {
                String JSON = await new QRCodeReader()
                    .setAutoFocusIntervalInMs(200) // default 5000
                    .setForceAutoFocus(true) // default false
                    .setTorchEnabled(true) // default false
                    .setHandlePermissions(true) // default true
                    .setExecuteAfterPermissionGranted(true) // default true
                    .scan();
                //print(JSON);
                if(JSON != null){
                  Map<dynamic, dynamic> scanTrade = json.decode(JSON);
                  if(scanTrade['buyer'] == widget.currentUser.uid){
                    if(widget.nation.resources['Money'] < scanTrade['quantity'] * scanTrade['price']) {
                      Scaffold.of(context).hideCurrentSnackBar();
                      Scaffold.of(context).showSnackBar(SnackBar(content: new Text('\$${scanTrade['price'] * scanTrade['quantity']} needed for trade')));
                    }else{
                      String id = scanTrade['id'];
                      scanTrade.remove('id');
                      if(await widget.nation.privateTrade(id, scanTrade))
                        Scaffold.of(context).hideCurrentSnackBar();
                      Scaffold.of(context).showSnackBar(SnackBar(content: new Text('Executing...')));
                    }
                  }else{
                    Scaffold.of(context).hideCurrentSnackBar();
                    Scaffold.of(context).showSnackBar(SnackBar(content: new Text('You are NOT the buyer of this trade', style: TextStyle(color: Colors.red),)));
                  }
                }
              },
              child: Text('Scan QR Trade'),
            ),
          )
        ],
      ),
    ));
    // TODO: implement build
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.nation.specialBuilding['Telecommunication']['level'] > 0? columnList : <Widget>[new Text('Upgrade Telecommunication to \nlevel 1 to unlock private trade', style: TextStyle(fontSize: 16, color: Colors.white),)],
    );
  }
}

class TradeExecutionMakerDialog extends StatefulWidget{
  TradeExecutionMakerDialog({this.resource, this.nation, this.bid});
  String resource;
  Nation nation;
  bool bid;
  @override
  _TradeExecutionMakerDialog createState() => new _TradeExecutionMakerDialog();
}

class _TradeExecutionMakerDialog extends State<TradeExecutionMakerDialog>{

  TextEditingController priceController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  double price = 0.00;
  int quantity = 0;
  final _textKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    int max = widget.bid?  widget.nation.resources['Money'].toInt() : widget.nation.resources[widget.resource];
    return SimpleDialog(
      children: <Widget>[
        new Text('Enter Your Order', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600,),),
        new Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
          //width: MediaQuery.of(context).size.width * 0.6,
          child: new Form(
              key: _textKey,
              child: new Column(
                children: <Widget>[
                  new TextFormField(
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    decoration: new InputDecoration(labelText: 'Price'),
                    validator: (value){
                      try{
                        price = double.parse(value);
                        print(price);
                        return null;
                      }catch(e){
                        return 'Please enter a two decimals place as price';
                      }
                    },
                    controller: priceController,
                  ),
                  new TextFormField(
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.right,
                    decoration: new InputDecoration(labelText: 'Quantity'),
                    validator: (value){
                      try{
                        quantity = int.parse(value);
                        print(widget.nation.resources['Money']/price);
                        if(widget.bid){
                          if(price >= 0)
                            if(widget.nation.resources['Money']/price < quantity)
                              return 'Please enter what you afford';
                        }else{
                          if(widget.nation.resources[widget.resource] < quantity)
                            return 'Please enter what you afford';
                        }
                        return null;
                      }catch(e){
                        return 'Please enter a integer as quantity';
                      }
                    },
                    controller: quantityController,
                  )
                ],
              )
          ),
        ),
        new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new RaisedButton(
              onPressed: (){ Navigator.pop(context); },
              child: new Text('CANCEL', style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            new RaisedButton(
              onPressed: () async {
                if(_textKey.currentState.validate()){
                  String id = (Random.secure().nextDouble() * 9223372036854775807).floor().toRadixString(16);
                  bool success = await widget.nation.publicTradeMaker(widget.bid, quantity, price, widget.resource, id);
//                  List<bool> s = [];
//                  for(int i = 0; i < 10; i++){
//                    String id = (Random.secure().nextDouble() * 9223372036854775807).floor().toRadixString(16);
//                    bool success = await widget.nation.publicTradeMaker(widget.bid, quantity, price, widget.resource, id);
//                    s.add(success);
//                  }
//                  bool success = true;
//                  s.forEach((t){ if(!t) success = false; });
                  if(success)
                    Navigator.pop(context);
                  else {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (BuildContext context){
                        return AlertDialog(
                          title: new Text('ERROR'),
                          content: new Text('Problem occur in the order'),
                        );
                      }
                    );
                  }
                }
              },
              child: new Text('SEND ORDER', style: TextStyle(fontWeight: FontWeight.bold),),
            )
          ],
        )
      ],
    );
  }
}

class TradeExecutionTakerDialog extends StatefulWidget{
  TradeExecutionTakerDialog({this.resource, this.nation, this.tradeManager, this.buy, this.makerData, this.makerKey});
  String resource;
  Nation nation;
  TradeManager tradeManager;
  bool buy;
  Map<dynamic, dynamic> makerData;
  String makerKey;
  Function checkTrade;
  @override
  _TradeExecutionTakerDialog createState() => new _TradeExecutionTakerDialog();
}

class _TradeExecutionTakerDialog extends State<TradeExecutionTakerDialog>{

  TextEditingController quantityController = TextEditingController();
  int quantity = 0;
  final _textKey = GlobalKey<FormState>();

  @override
  void initState(){
    super.initState();
    widget.checkTrade = (String key){
      print('The deleted key is '+key);
      if(this.mounted){
        if(key == widget.makerKey){
          Navigator.pop(context);
          showDialog(
              context: context,
              builder: (BuildContext context){
                return AlertDialog(
                  title: new Text('WARNING'),
                  content: new Text('The trade is delete by the owner'),
                );
              }
          );
        }
      }
    };
  }

  Widget identity(String id){
    return widget.tradeManager.nationList.containsKey(id)?
    IdentityPhoto.fromUID(size: 60, uid: id, tradeManager: widget.tradeManager)
        : new IdentityImage(size: 60, hash: 'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF');
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    int max = widget.buy?  (widget.nation.resources['Money']/widget.makerData['price']).toInt() : widget.nation.resources[widget.resource];
    return SimpleDialog(
      children: <Widget>[
        new Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: new Row(
            children: <Widget>[
              new Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: identity(widget.buy? widget.makerData['seller']:widget.makerData['buyer']),
              ),
              new Expanded(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('${widget.tradeManager.nationList[ widget.buy? widget.makerData['seller']:widget.makerData['buyer'] ]['name']}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
                    Text('Quantity ${widget.buy? 'Sell':'Buy'}: ${widget.makerData['quantity']}'),
                    Text('${widget.buy? 'Ask':'Bid'} Price: ${widget.makerData['price'].toStringAsFixed(2)}')
                  ],
                ),
              )
            ],
          ),
        ),
        new Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: new Text('Enter Your Order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500,),),
        ),
        new Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: new Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
            //width: MediaQuery.of(context).size.width * 0.6,
            child: new Form(
                key: _textKey,
                child: new Column(
                  children: <Widget>[
                    new TextFormField(
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.right,
                      decoration: new InputDecoration(labelText: 'Quantity'),
                      validator: (value){
                        try{
                          quantity = int.parse(value);
                          if(quantity > max)
                            return 'Please enter what you can afford';
                          if(quantity > widget.makerData['quantity'])
                            return 'Please enter available quantity';
                          return null;
                        }catch(e){
                          return 'Please enter a integer as quantity';
                        }
                      },
                      controller: quantityController,
                    ),
                  ],
                )
            ),
          ),
        ),
        new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new RaisedButton(
              onPressed: (){ Navigator.pop(context); },
              child: new Text('CANCEL', style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            new RaisedButton(
              onPressed: () async {
                if(_textKey.currentState.validate()){
                  String id = (Random.secure().nextDouble() * 9223372036854775807).floor().toRadixString(16);
                  bool success = await widget.nation.publicTradeTaker(widget.buy, quantity, widget.resource, id, json.decode(json.encode(widget.makerData)), widget.makerKey);
                  if(success)
                    Navigator.pop(context);
                  else {
                    Navigator.pop(context);
                    showDialog(
                        context: context,
                        builder: (BuildContext context){
                          return AlertDialog(
                            title: new Text('ERROR'),
                            content: new Text('Problem occur in the transaction'),
                          );
                        }
                    );
                  }
                }
              },
              child: new Text('SEND ORDER', style: TextStyle(fontWeight: FontWeight.bold),),
            )
          ],
        )
      ],
    );
  }
}

class TradeCancel extends StatelessWidget{
  TradeCancel({this.resource, this.bid, this.detail});

  String resource;
  bool bid;
  Map<dynamic, dynamic> detail;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new AlertDialog(
      title: Center(child: Text('CANCEL QUEUE?')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children : <Widget>[
          Text(
            'Are you sure want to cancel queue?\nBelow are details of the trade in queue.',
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          Text(
            '\n${bid? 'Bid' : 'Ask'} Order\nResources: ${resource}\nQuantity: ${detail['quantity']}\nPrice: ${detail['price']}',
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Colors.red,
              fontSize: 14
            ),
          )
        ],
      ),
      actions: <Widget>[
        FlatButton(
            child: Text('BACK'),
            onPressed: () {
              Navigator.pop(context, false);
            }),
        FlatButton(
            child: Text('Cancel Queue'),
            onPressed: () {
              Navigator.pop(context, true);
            })
      ],
    );;
  }
}

class TradeResource extends StatefulWidget{
  TradeResource({Key key, this.resource, this.imgPath, this.tradeManager, this.nation});
  String resource;
  String imgPath;
  TradeManager tradeManager;
  Nation nation;
  @override
  State<StatefulWidget> createState() => new _TradeResourceState();
}

class _TradeResourceState extends State<TradeResource>{

  List<String> asks;
  List<String> bids;
  TradeExecutionTakerDialog dialog;
  ScaffoldState _scaffoldState;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    asks = <String>[];
    bids = <String>[];
    DatabaseReference A = FirebaseDatabase.instance.reference().child('trade/${widget.resource}/Ask');
    A.onChildAdded.listen((event){
      widget.tradeManager.tradeQueue[widget.resource]['Ask'][event.snapshot.key] = event.snapshot.value; setState(() {});
      if(asks.length == 0)
        asks.add(event.snapshot.key);
      else {
        bool done = false;
        for (int i = 0; i < asks.length; i++) {
          if(event.snapshot.value['price'] <= widget.tradeManager.tradeQueue[widget.resource]['Ask'][asks[i]]['price']){
            asks.insert(i, event.snapshot.key);
            done = true;
            break;
          }
        }
        if(!done)
          asks.add(event.snapshot.key);
      }
    });
    A.onChildChanged.listen((event){
      widget.tradeManager.tradeQueue[widget.resource]['Ask'][event.snapshot.key] = event.snapshot.value; setState(() {});
    });
    A.onChildRemoved.listen((event){
      print(event.snapshot.key + ' is cancel');
      widget.tradeManager.tradeQueue[widget.resource]['Ask'].remove(event.snapshot.key); setState(() {});
      asks.remove(event.snapshot.key);
      if(dialog != null){
        print(event.snapshot.key + ' is cancel');
        dialog.checkTrade(event.snapshot.key);
      }
    });
    DatabaseReference B = FirebaseDatabase.instance.reference().child('trade/${widget.resource}/Bid');
    B.onChildAdded.listen((event){
      widget.tradeManager.tradeQueue[widget.resource]['Bid'][event.snapshot.key] = event.snapshot.value; setState(() {});
      if(bids.length == 0)
        bids.add(event.snapshot.key);
      else {
        bool done = false;
        for (int i = 0; i < bids.length; i++) {
          if(event.snapshot.value['price'] >= widget.tradeManager.tradeQueue[widget.resource]['Bid'][bids[i]]['price']){
            bids.insert(i, event.snapshot.key);
            done = true;
            break;
          }
        }
        if(!done)
          bids.add(event.snapshot.key);
      }
    });
    B.onChildChanged.listen((event){
      widget.tradeManager.tradeQueue[widget.resource]['Bid'][event.snapshot.key] = event.snapshot.value; setState(() {});
    });
    B.onChildRemoved.listen((event){
      widget.tradeManager.tradeQueue[widget.resource]['Bid'].remove(event.snapshot.key); setState(() {});
      bids.remove(event.snapshot.key);
      if(dialog != null){
        dialog.checkTrade(event.snapshot.key);
      }
    });
    DatabaseReference data = FirebaseDatabase.instance.reference().child('trade/${widget.resource}/data');
    data.onChildAdded.listen((event){
      widget.tradeManager.trade[widget.resource][event.snapshot.key] = event.snapshot.value.toDouble();
      setState(() {});
    });
    data.onChildChanged.listen((event){
      widget.tradeManager.trade[widget.resource][event.snapshot.key] = event.snapshot.value.toDouble();
      setState(() {});
    });
  }

  Widget identity(String id){
    return widget.tradeManager.nationList.containsKey(id)?
    IdentityPhoto.fromUID(size: 24, uid: id, tradeManager: widget.tradeManager)
        : new IdentityImage(size: 24, hash: 'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF');
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    double bid = widget.tradeManager.trade[widget.resource]['BidPrice'];
    double ask = widget.tradeManager.trade[widget.resource]['AskPrice'];
    return new Scaffold(
      body: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints.expand(),
              child: new Column(
                children: <Widget>[
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text('${bid != null && bid != 0? bid.toStringAsFixed(2) : '--'}'),
                      Container(
                        height: 180.0,
                        width: 180.0,
                        padding: EdgeInsets.all(4.0),
                        child: Hero(
                          tag: widget.resource + 'Trade',
                          child: Image.asset(widget.imgPath),
                        ),
                      ),
                      Text('${ask != null && ask != 0? ask.toStringAsFixed(2) : '--'}')
                    ],
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      new OutlineButton(onPressed: (){
                        showDialog(
                          context: context,
                          builder: (BuildContext context){
                            return new TradeExecutionMakerDialog(resource: widget.resource, nation: widget.nation, bid: true,);
                          }
                        );
                      }, child: Text('Buy')),
                      Text('${widget.tradeManager.trade[widget.resource]['LastDone'].toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                      new OutlineButton(onPressed: (){
                        showDialog(
                          context: context,
                          builder: (BuildContext context){
                            return new TradeExecutionMakerDialog(resource: widget.resource, nation: widget.nation, bid: false,);
                          }
                        );
                      }, child: Text('Sell'))
                    ],
                  )
                ],
              ),
            ),
            flex: 3,
          ),
          new Expanded(
            child: Container(
              color: Colors.grey.shade300,
              child: new Row(
                children: <Widget>[
                  new ConstrainedBox(
                    constraints: BoxConstraints.expand(width: MediaQuery.of(context).size.width * 0.5),
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(5.0),
                      itemCount: bids.length,
                      itemBuilder: (BuildContext context, int index){
                        return new Card(
                          child: new ConstrainedBox(
                            constraints: BoxConstraints.expand(height: MediaQuery.of(context).size.height * 0.1),
                            child: new Stack(
                              fit: StackFit.expand,
                              children: <Widget>[
                                new Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    new Row(
                                      children: <Widget>[
                                        new Padding(
                                          padding: EdgeInsets.only(left: 4, right: 0),
                                          child: identity(widget.tradeManager.tradeQueue[widget.resource]['Bid'][bids[index]]['buyer']),
                                        ),
                                        new Expanded(
                                          child: Text('${widget.tradeManager.nationList[widget.tradeManager.tradeQueue[widget.resource]['Bid'][bids[index]]['buyer']]['name']}', style: TextStyle(), textAlign: TextAlign.center,),
                                        )
                                      ],
                                    ),
                                    Text('price: ${widget.tradeManager.tradeQueue[widget.resource]['Bid'][bids[index]]['price'].toStringAsFixed(2)}'),
                                    Text('quantity: ${widget.tradeManager.tradeQueue[widget.resource]['Bid'][bids[index]]['quantity']}')
                                  ],
                                ),
                                Material(
                                  type: MaterialType.transparency,
                                  child: InkWell(onTap: widget.tradeManager.tradeQueue[widget.resource]['Bid'][bids[index]]['buyer'] != widget.nation.currentUser.uid? (){ showDialog(
                                      context: context,
                                      builder: (BuildContext context){
                                        dialog = new TradeExecutionTakerDialog(
                                            resource: widget.resource,
                                            nation: widget.nation,
                                            tradeManager: widget.tradeManager,
                                            buy: false,
                                            makerData: widget.tradeManager.tradeQueue[widget.resource]['Bid'][bids[index]],
                                            makerKey: bids[index]
                                        );
                                        return dialog;
                                      }
                                  ); } : (){
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context){
                                        return new TradeCancel(resource: widget.resource, bid: true, detail: widget.tradeManager.tradeQueue[widget.resource]['Bid'][bids[index]]);
                                      }
                                    ).then((react){
                                      if(react){
                                        widget.nation.cancelMaker(true, widget.resource, bids[index]).then((done){
                                          if(done){
                                            Scaffold.of(context).hideCurrentSnackBar();
                                            Scaffold.of(context).showSnackBar(
                                              SnackBar(
                                                content: new Text('Trade has been cancelled'),
                                                duration: Duration(seconds: 2),
                                                //action: SnackBarAction(label: 'DISMISS', textColor: Colors.white, onPressed: (){ Scaffold.of(context).hideCurrentSnackBar(); }),
                                              )
                                            );
                                          }
                                        });
                                      }
                                    });
                                  }),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  new ConstrainedBox(
                    constraints: BoxConstraints.expand(width: MediaQuery.of(context).size.width * 0.5),
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(5.0),
                      itemCount: asks.length,
                      itemBuilder: (BuildContext context, int index){
                        return new Card(
                          child: new ConstrainedBox(
                            constraints: BoxConstraints.expand(height: MediaQuery.of(context).size.height * 0.1),
                            child: new Stack(
                              fit: StackFit.expand,
                              children: <Widget>[
                                new Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    new Row(
                                      children: <Widget>[
                                        new Padding(
                                          padding: EdgeInsets.only(left: 4, right: 5),
                                          child: identity(widget.tradeManager.tradeQueue[widget.resource]['Ask'][asks[index]]['seller']),
                                        ),
                                        new Expanded(
                                          child: Text('${widget.tradeManager.nationList[widget.tradeManager.tradeQueue[widget.resource]['Ask'][asks[index]]['seller']]['name']}', style: TextStyle(), textAlign: TextAlign.center,),
                                        )
                                      ],
                                    ),
                                    Text('price: ${widget.tradeManager.tradeQueue[widget.resource]['Ask'][asks[index]]['price'].toStringAsFixed(2)}'),
                                    Text('quantity: ${widget.tradeManager.tradeQueue[widget.resource]['Ask'][asks[index]]['quantity']}')
                                  ],
                                ),
                                Material(
                                  type: MaterialType.transparency,
                                  child: InkWell(onTap: widget.tradeManager.tradeQueue[widget.resource]['Ask'][asks[index]]['seller'] != widget.nation.currentUser.uid? (){ showDialog(
                                      context: context,
                                      builder: (BuildContext context){
                                        dialog = new TradeExecutionTakerDialog(
                                            resource: widget.resource,
                                            nation: widget.nation,
                                            tradeManager: widget.tradeManager,
                                            buy: true,
                                            makerData: widget.tradeManager.tradeQueue[widget.resource]['Ask'][asks[index]],
                                            makerKey: asks[index]
                                        );
                                        return dialog;
                                      }
                                  ); } : (){
                                    String cancelID = asks[index];
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context){
                                        return new TradeCancel(resource: widget.resource, bid: false, detail: widget.tradeManager.tradeQueue[widget.resource]['Ask'][cancelID]);
                                      }
                                    ).then((react){
                                      if(react){
                                        widget.nation.cancelMaker(false, widget.resource, cancelID).then((done){
                                          if(done){
                                            Scaffold.of(context).hideCurrentSnackBar();
                                            Scaffold.of(context).showSnackBar(
                                              SnackBar(
                                                content: new Text('Trade has been cancelled'),
                                                duration: Duration(seconds: 2),
                                                //action: SnackBarAction(label: 'DISMISS', textColor: Colors.white, onPressed: (){ Scaffold.of(context).hideCurrentSnackBar(); }),
                                              )
                                            );
                                          }
                                        });
                                      }
                                    });
                                  }),
                                )
                              ],
                            ),
                          )
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
            flex: 5,
          )
        ],
      ),
    );
  }
}

class TradeCard extends StatefulWidget{
  TradeCard({Key key, this.resource, this.imgPath, this.tradeManager, this.nation});

  String resource;
  String imgPath;
  TradeManager tradeManager;
  Nation nation;

  @override
  State<TradeCard> createState() => new _TradeCardState();
}

class _TradeCardState extends State<TradeCard> with AutomaticKeepAliveClientMixin<TradeCard>{

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    DatabaseReference data = FirebaseDatabase.instance.reference().child('trade/${widget.resource}/data');
    data.onChildAdded.listen((event){
      widget.tradeManager.trade[widget.resource][event.snapshot.key] = event.snapshot.value.toDouble();
      setState(() {});
    });
    data.onChildChanged.listen((event){
      widget.tradeManager.trade[widget.resource][event.snapshot.key] = event.snapshot.value.toDouble();
      setState(() {});
    });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    double bid = widget.tradeManager.trade[widget.resource]['BidPrice'];
    double ask = widget.tradeManager.trade[widget.resource]['AskPrice'];
    return new Card(
      child: new Container(
        height: 200,
        child: new Center(
          child: new Stack(
            fit: StackFit.expand,
            children: <Widget>[
              new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(widget.resource, style: new TextStyle(fontSize: 18.0),),
                  Container(
                    width: 120.0,
                    height: 120.0,
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Hero(
                      tag: widget.resource + 'Trade',
                      child: Image.asset(widget.imgPath),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[Text('Buy'), Text('${bid != null && bid != 0? bid.toStringAsFixed(2) : '--'}')],
                      ),
                      new Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text('${widget.tradeManager.trade[widget.resource]['LastDone'].toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                          Text('Domestic Price : ${widget.tradeManager.master.resources[widget.resource]['price'].toStringAsFixed(2)}')
                        ],
                      ),
                      new Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[Text('Sell'), Text('${ask != null && ask != 0? ask.toStringAsFixed(2) : '--'}')],
                      )
                    ],
                  )
                ],
              ),
              Material(
                type: MaterialType.transparency,
                child: InkWell(onTap: (){ Navigator.push(context, new MaterialPageRoute(builder: (context) => new TradeResource(resource: widget.resource, imgPath: widget.imgPath, tradeManager: widget.tradeManager, nation: widget.nation,))); }),
              )
            ],
          ),
        ),
      ),
    );;
  }
}

class TradePage extends StatefulWidget {
  TradePage({Key key, this.currentUser, this.auth, this.nation, this.tradeManager}) : super(key: key);

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
  TradeManager tradeManager;
  //var orderList = <DataSnapshot>[];
  PrivateTrade _privateTrade;

  @override
  _TradePageState createState() => new _TradePageState(auth: auth);
}

class _TradePageState extends State<TradePage> with SingleTickerProviderStateMixin<TradePage>, AutomaticKeepAliveClientMixin<TradePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  _TradePageState({Key key, this.auth,});
  FirebaseUser currentUser;//User Holder
  FirebaseAuth auth;//auth Holder, used for logout
  DatabaseReference _orderRef;
  bool loading = true;
  DatabaseReference data;
  Nation nation = new Nation(name: 'LASTOLK', human: 8000);
  String chosenResource = 'Wood';

  TabController _tabController;
  static const _tabs = <Tab>[
    Tab(icon: Icon(Icons.cloud), text: 'PUBLIC',),
    //Tab(icon: Icon(Icons.cloud), text: 'PUBLIC\nResources',),
    //Tab(icon: Icon(Icons.cloud), text: 'PUBLIC\nProduct',),
    Tab(icon: Icon(Icons.forum), text: 'PRIVATE',)
  ];
  List<Widget>_tabPages;
  PrivateTrade _privateTrade;
  PageController _publicPageController;
  PageView _publicPage;

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    //print(widget.tradeManager.nationList);
    loading = true;
    chosenResource = null;
    if(widget._privateTrade == null){
      widget._privateTrade = privateTrade();
    }
    _publicPageController = PageController(
        initialPage: 0,
        keepPage: true
    );
    _publicPage = PageView(
      physics: NeverScrollableScrollPhysics(),
      controller: _publicPageController,
      children: <Widget>[
        publicResourcesTrade(),
        publicProductTrade()
      ],
    );
//    _tabPages = <Widget>[
//      publicTrade(),
//      //publicResourcesTrade(),
//      //publicProductTrade(),
//      widget._privateTrade,
//    ];
    _tabController = TabController(length: _tabs.length, vsync: this);
    print('init TradePage');
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
    print('deactivate trade');
  }

  @override
  void dispose(){
    print('dispose trade');
    //widget.change.pause();// remove to deactivate()
    super.dispose();
    //print('Home dispose ' + widget.change.isPaused.toString());
  }

  @override
  bool get wantKeepAlive => true;

  Widget publicTrade(BuildContext context){
    return Column(
      children: <Widget>[
        new Container(
          height: 50,
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new Container(
                width: MediaQuery.of(context).size.width * 0.4,
                child: OutlineButton(
                  onPressed: (){
                    setState(() { _publicPageController.jumpToPage(0); });
                  },
                  shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(25.0)),
                  child: Text('RESOURCE', style: TextStyle(color: Colors.white),),
                ),
              ),
              new Container(
                width: MediaQuery.of(context).size.width  * 0.4,
                child: OutlineButton(
                  onPressed: (){
                    setState(() { _publicPageController.jumpToPage(1); });
                  },
                  shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(25.0)),
                  child: Text('PRODUCT', style: TextStyle(color: Colors.white),),
                ),
              )
            ],
          ),
        ),
        new Expanded(
          child: _publicPage,
        )
      ],
    );
//    return new ListView.builder(
//      scrollDirection: Axis.vertical,
//      shrinkWrap: true,
//      padding: const EdgeInsets.all(10.0),
//      itemCount: 22,
//      itemBuilder: (BuildContext context, int index){
//        return new TradeCard(resource: widget.nation.master.resourcesOrder[index], imgPath: widget.nation.master.resources[widget.nation.master.resourcesOrder[index]]['img'], tradeManager: widget.tradeManager, nation: widget.nation,);
//      },
//    );
  }

  Widget publicResourcesTrade(){
    return new ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      padding: const EdgeInsets.all(10.0),
      itemCount: 11,
      itemBuilder: (BuildContext context, int index){
        return new TradeCard(resource: widget.nation.master.resourcesOrder[index], imgPath: widget.nation.master.resources[widget.nation.master.resourcesOrder[index]]['img'], tradeManager: widget.tradeManager, nation: widget.nation,);
      },
    );
  }

  Widget publicProductTrade(){
    return new ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      padding: const EdgeInsets.all(10.0),
      itemCount: 11,
      itemBuilder: (BuildContext context, int index){
        return new TradeCard(resource: widget.nation.master.resourcesOrder[index+11], imgPath: widget.nation.master.resources[widget.nation.master.resourcesOrder[index+11]]['img'], tradeManager: widget.tradeManager, nation: widget.nation,);
      },
    );
  }

  Widget privateTrade(){
    return new PrivateTrade(nation: widget.nation, tradeManager: widget.tradeManager, currentUser: widget.currentUser,);
  }

  String randomHex(){
    return (Random.secure().nextDouble() * 9223372036854775807).floor().toRadixString(16);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return new Scaffold(
      body: new Container(
        decoration: BoxDecoration(color: Colors.grey.shade800),
        child: TabBarView(
          children: <Widget>[
            publicTrade(context),
            widget._privateTrade
          ],
          controller: _tabController,
        ),
      ),
      bottomNavigationBar: new Material(
        color: Theme.of(context).primaryColor,
        child: TabBar(
          tabs: _tabs,
          controller: _tabController,
        ),
      ),
    );
  }
}