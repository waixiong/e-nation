import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:e_nation/Logic/Nation.dart';
import 'package:e_nation/Logic/TradeManager.dart';
import 'package:e_nation/Screen/identityImage.dart';
import 'package:e_nation/Screen/_FactoryCard.dart';
import 'package:e_nation/Screen/Loading.dart';

class NotifyWidget extends StatefulWidget{
  NotifyWidget({this.nation, this.tradeManager});

  Nation nation;
  TradeManager tradeManager;
  Function setNotification;

  _NofifyState createState() => new _NofifyState();
}

class _NofifyState extends State<NotifyWidget>{

  List<Widget> card = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print('init Notification');
    //card.add(new Card())
    widget.setNotification = setNotification;
  }

  onTimeout(Widget widget){
    setState(() {
      card.remove(widget);
    });
  }

  setNotification(Notify notify){
    //Key dismissKey = Key(notify.dataSnapshot.key);
    int indexNow = card.length;
    Dismissible notification = Dismissible(
      key: Key(notify.dataSnapshot.key),
      onDismissed: (direction){
        print('dismiss');
        //timer.cancel();
        setState(() {
          card.removeLast();
        });
      },
      child: notify.type == NotifyType.trade? new TradeNotifyCard(snapshot: notify.dataSnapshot, nation: widget.nation, tradeManager: widget.tradeManager,)
          :new InfoNotifyCard(snapshot: notify.dataSnapshot, nation: widget.nation, tradeManager: widget.tradeManager,),
    );
    card.add(notification);
    Timer timer = new Timer(Duration(seconds: 7), (){ onTimeout(notification); });
    setRead(notify.dataSnapshot.key, notify.type);
    setState(() {});
  }

  setRead(String key, NotifyType type) async {
    TransactionResult transactionResult = await FirebaseDatabase.instance.reference().child('users/${widget.nation.currentUser.uid}/historyData/${type == NotifyType.trade? 'trade':'news'}/${key}').runTransaction((MutableData mutableData) async {
      //if(mutableData.value != null) {
        mutableData.value = true;
      //}
      return mutableData;
    });
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
    print('Notification deactivate');
  }

  @override
  void dispose() {
    // TODO: implement dispose
    print('Notification dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    //print('Notifying');
    return Stack(
      children: card,
    );
  }
}

class TradeNotifyCard extends StatelessWidget{
  TradeNotifyCard({this.snapshot, this.nation, this.tradeManager});

  DataSnapshot snapshot;
  Nation nation;
  TradeManager tradeManager;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    print('Trade Notify');
    Widget _leading, _title, _content, _trailing;
    if(snapshot.value['buyer'] == nation.currentUser.uid){
      _leading = IdentityPhoto.fromUID(size: 44, uid: snapshot.value['seller'], tradeManager: tradeManager);
      _title = Text('Import from ${tradeManager.nationList[snapshot.value['seller']]['name']}', style: TextStyle(fontWeight: FontWeight.w700),);
    }else{
      _leading = IdentityPhoto.fromUID(size: 44, uid: snapshot.value['buyer'], tradeManager: tradeManager);
      _title = Text('Export to ${tradeManager.nationList[snapshot.value['buyer']]['name']}', style: TextStyle(fontWeight: FontWeight.w700),);
    }
    _trailing = ResourcePic(resourceImg: nation.master.resources[snapshot.value['resource']]['img'], radius: 14,);
    _content = Column(
      children: <Widget>[
        new Container(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('ID: ${snapshot.key}', style: TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.left,),
              Text(
                '${snapshot.value['exe']=='S'? 'SUCCESS':(snapshot.value['exe']=='P'? 'PARTIAL':(snapshot.value['exe']=='V'?'VOID':'FAIL'))}',
                style: TextStyle(
                    fontSize: 10,
                    color: snapshot.value['exe']=='S'? Colors.green:(snapshot.value['exe']=='P'? Colors.orange:Colors.red)
                ),
                textAlign: TextAlign.right,
              )
            ],
          ),
        ),
        new Container(
          alignment: Alignment.centerLeft,
          child: Text('${snapshot.value['quantity']} ${snapshot.value['resource']} @ price ${snapshot.value['price'].toStringAsFixed(2)}', textAlign: TextAlign.left,),
        ),

      ],
    );
    return new Card(
      child: Container(
        padding: EdgeInsets.all(4.0),
        height: MediaQuery.of(context).size.width/5,
        width: MediaQuery.of(context).size.width,
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 5.0, right: 8.0),
              child: _leading,
            ),
            new Expanded(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _title,
                  _content
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: _trailing,
            )
          ],
        ),
      ),
    );
  }

}

class InfoNotifyCard extends StatelessWidget{
  InfoNotifyCard({this.snapshot, this.nation, this.tradeManager});

  DataSnapshot snapshot;
  Nation nation;
  TradeManager tradeManager;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    print('Trade Notify');
    Widget _leading, _title, _content, _trailing;
    _leading = Icon(Icons.info_outline, size: 44,);
    _title = Text(snapshot.value['title'], style: TextStyle(fontWeight: FontWeight.w700),);
    //_trailing = ResourcePic(resourceImg: nation.master.resources[snapshot.value['resource']]['img'], radius: 14,);
    _content = Column(
      children: <Widget>[
        new Container(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('Contract ID: ${snapshot.value['contract']}', style: TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.left,),
            ],
          ),
        ),
        new Container(
          alignment: Alignment.centerLeft,
          child: Text(snapshot.value['info'], textAlign: TextAlign.left, style: TextStyle(fontSize: 9),),
        ),

      ],
    );
    return new Card(
      child: Container(
        padding: EdgeInsets.all(4.0),
        height: MediaQuery.of(context).size.width/5,
        width: MediaQuery.of(context).size.width,
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 5.0, right: 8.0),
              child: _leading,
            ),
            new Expanded(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _title,
                  _content
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: new FutureBuilder(
                future: FirebaseDatabase.instance.reference().child('contract/${snapshot.value['contract']}').once(),
                builder: (BuildContext context, AsyncSnapshot<DataSnapshot> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.active:
                    case ConnectionState.waiting:
                      return new Container(
                        width: 28,
                        height: 28,
                        child: Loading(),
                      );
                    case ConnectionState.done:
                      if (snapshot.hasError)
                        return CircleAvatar(backgroundColor: Colors.grey, radius: 14,);
                      String uid;
                      snapshot.data.value['parties'].forEach((party, v){
                        if(party != nation.currentUser.uid){
                          uid = party;
                        }
                      });
                      return IdentityPhoto.fromUID(size: 28, uid: uid, tradeManager: tradeManager);
                  }
                }
              ),
            )
          ],
        ),
      ),
    );
  }

}

//ListTile(
//isThreeLine: true,
//leading: _leading,
//title: _title,
//trailing: _trailing,
//subtitle: _content,
//)