import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:e_nation/Screen/identityImage.dart';
import 'package:e_nation/Screen/_FactoryCard.dart';
import 'package:e_nation/Logic/Nation.dart';
import 'package:e_nation/Logic/TradeManager.dart';

class TradeHistory extends StatefulWidget{
  TradeHistory({Key key, this.nation, this.tradeManager});

  Nation nation;
  TradeManager tradeManager;
  StreamSubscription<bool> change;

  @override
  _TradeHistoryState createState() => new _TradeHistoryState();
}

class _TradeHistoryState extends State<TradeHistory>{

  List<DataSnapshot> data = new List<DataSnapshot>();
  Map<String, bool> exist = {};

  @override
  void initState(){
    super.initState();
    if(widget.change == null){
      widget.change = widget.nation.tradeHistoryRefresh.listen((data){
        getTradeHistory();
      });
    }else{
      widget.change.resume();
    }
    getTradeHistory();
  }

  void getTradeHistory() async {
    print('is ' + widget.nation.historyData.trade.toString());
    DatabaseReference tradeHistory = FirebaseDatabase.instance.reference().child('tradeHistory');
    widget.nation.historyData.trade.forEach((k, v){
      if(!exist.containsKey(k)){
        exist[k] = true;
        print('start ' + k);
        tradeHistory.child(k).once().then((snap){
          bool insert = false;
          for(int i = 0; i < data.length; i++){
            if(snap.value['timestamp'] > data[i].value['timestamp']){
              data.insert(i, snap);
              insert = true;
              break;
            }
          }
          print(insert);
          if(!insert){
            print('run');
            data.add(snap);
          }
          setState(() {});
        });
      }
    });
    print(exist);
    print(data);
  }

  @override
  void dispose(){
    widget.change.pause();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 164.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('TRADE HISTORY'),
              background: Image.asset('packages/e_nation/Assets/trade.jpg', fit: BoxFit.cover,),
            ),
          ),
          SliverSafeArea(
            sliver: data.length > 0? SliverList(
              delegate: SliverChildBuilderDelegate((BuildContext context, int index){
                if(index%2 == 1){
                  return Divider();
                }else{
                  Widget _leading, _title, _content, _trailing;
                  _trailing = ResourcePic(resourceImg: widget.nation.master.resources[data[index~/2].value['resource']]['img'], radius: 14,);
                  DateTime time = DateTime.fromMillisecondsSinceEpoch(data[index~/2].value['timestamp']);
                  _content = Column(
                    children: <Widget>[
                      new Container(
                        alignment: Alignment.centerLeft,
                        child: Text('ID: ${data[index~/2].key}', style: TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.left,),
                      ),
                      new Container(
                        alignment: Alignment.centerLeft,
                        child: Text('${data[index~/2].value['quantity']} ${data[index~/2].value['resource']} @ price ${data[index~/2].value['price'].toStringAsFixed(2)}', textAlign: TextAlign.left,),
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text('${data[index~/2].value['type']} TRADE', style: TextStyle(fontSize: 12), textAlign: TextAlign.left,),
                          ),
                          Text('Trade at ${time.hour~/10}${time.hour%10}:${time.minute~/10}${time.minute%10}:${time.second~/10}${time.second%10}', style: TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.right,)
                        ],
                      )
                    ],
                  );
                  if(data[index~/2].value['buyer'] == widget.nation.currentUser.uid){
                    _leading = IdentityImage(size: 44, hash: widget.tradeManager.nationList[data[index~/2].value['seller']]['hash'],);
                    _title = Text('Buy from ${widget.tradeManager.nationList[data[index~/2].value['seller']]['name']}');
                  }else{
                    _leading = IdentityImage(size: 24, hash: widget.tradeManager.nationList[data[index~/2].value['buyer']]['hash'],);
                    _title = Text('Sell to ${widget.tradeManager.nationList[data[index~/2].value['buyer']]['name']}');
                  }
                  return ListTile(
                    isThreeLine: true,
                    leading: _leading,
                    title: _title,
                    trailing: _trailing,
                    subtitle: _content,
                  );
                }
              }, childCount: data.length*2-1),
            ) : SliverList(
              delegate: SliverChildListDelegate(
                [Text('Trade history will be shown here')]
              ),
            ),
          )
        ],
      ),
    );
  }
}

class TradeRecord extends StatelessWidget{

  bool buy;
  String user;
  String resource;
  int quantity;
  double price;
  bool seen;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      decoration: null,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[

        ],
      ),
    );
  }
}
