import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:e_nation/Screen/identityImage.dart';
import 'package:e_nation/Screen/_FactoryCard.dart';
import 'package:e_nation/Logic/Nation.dart';

class NewsInfo extends StatefulWidget{
  NewsInfo({Key key, this.nation});

  Nation nation;
  StreamSubscription<bool> change;

  @override
  _NewsInfoState createState() => new _NewsInfoState();
}

class _NewsInfoState extends State<NewsInfo>{

  List<DataSnapshot> news = new List<DataSnapshot>();
  Map<String, bool> exist = {};

  @override
  void initState(){
    super.initState();
    if(widget.change == null){
      widget.change = widget.nation.newsRefresh.listen((data){
        getNews();
      });
    }else{
      widget.change.resume();
    }
    getNews();
  }

  void getNews() async {
    print(widget.nation.historyData.news);
    DatabaseReference tradeHistory = FirebaseDatabase.instance.reference().child('news');
    widget.nation.historyData.news.forEach((k, v){
      if(!exist.containsKey(k)){
        exist[k] = true;
        tradeHistory.child(k).once().then((snap){
          bool insert = false;
          for(int i = 0; i < news.length; i++){
            if(snap.value['timestamp'] > news[i].value['timestamp']){
              news.insert(i, snap);
              insert = true;
              break;
            }
          }
          if(!insert){
            news.add(snap);
          }
          setState(() {});
        });
      }
    });
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
            expandedHeight: 160.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('NEWS AND INFO'),
              background: Random.secure().nextBool()? Image.asset('packages/e_nation/Assets/news1.jpg', fit: BoxFit.fitWidth,) : Image.asset('packages/e_nation/Assets/news2.jpg', fit: BoxFit.fitHeight,),
            ),
          ),
          SliverSafeArea(
            sliver: news.length > 0? SliverList(
              delegate: SliverChildBuilderDelegate((BuildContext context, int index){
                DateTime time = DateTime.fromMillisecondsSinceEpoch(news[index].value['timestamp']);
                return new Container(
                  margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0,),
                  child: new Stack(
                    children: <Widget>[
                      new Container(
                        height: 124,
                        margin: EdgeInsets.only(left: 40),
                        decoration: new BoxDecoration(
                          color: Color(0xFF333366),
                          shape: BoxShape.rectangle,
                          borderRadius: new BorderRadius.circular(8.0),
                          boxShadow: <BoxShadow>[new BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 10))]
                        ),
                        child: new Container(
                          margin: EdgeInsets.only(left: 54, top: 10, bottom: 10, right: 10),
                          child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text('${news[index].value['title']}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),),
                              Expanded(
                                child: Text('${news[index].value['info']}', style: TextStyle(color: Colors.white70, fontSize: 13),),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text('${news[index].value['from']}', style: TextStyle(color: Colors.white30, fontSize: 10)),
                                  new Expanded(
                                    child: Text('${time.hour~/10}${time.hour%10}:${time.minute~/10}${time.minute%10}:${time.second~/10}${time.second%10}', style: TextStyle(color: Colors.white30, fontSize: 10), textAlign: TextAlign.right,),
                                  )
                                ],
                              )
                            ],
                          ),
                        )
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 22),
                        alignment: FractionalOffset.centerLeft,
                        child: Image.asset('packages/e_nation/Assets/news/redCircle.png', width: 80, height: 80,),
                      )
                    ],
                  ),
                );
              }, childCount: news.length),
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