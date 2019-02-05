import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'package:e_nation/Logic/Nation.dart';

class GovernPage extends StatefulWidget {
  GovernPage({Key key, this.currentUser, this.auth, this.nation}) : super(key: key);

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
  StreamSubscription<bool> change;
  //var orderList = <DataSnapshot>[];

  @override
  _GovernPageState createState() => new _GovernPageState();
}

class _GovernPageState extends State<GovernPage> with AutomaticKeepAliveClientMixin<GovernPage>{
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  _GovernPageState({Key key,});
  List<String> specialBuilding = ['Education', 'Healthcare', 'Telecommunication'];
  List<Color> textColors = [Colors.blue.shade400, Colors.green.shade400, Colors.amber.shade400];
  List<Color> titleColors = [Colors.blue.shade600, Colors.green.shade300, Colors.amber.shade600];

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    print('init govern');
    if(widget.change == null){
      widget.change = widget.nation.nationStream.listen((data){
        setState(() {});
      });
    }else{
      widget.change.resume();
    }
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
    print('deactivate govern');
  }

  @override
  void dispose(){
    widget.change.pause();
    print('dispose govern but keep alive = '+wantKeepAlive.toString());
    super.dispose();
  }

  Future<bool> upgradeDialog(String type) async {
    int level = widget.nation.specialBuilding[type]['level'];
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        Map<dynamic, dynamic> requirement = widget.nation.master.specialBuilding[type]['upgrade'][level];
        String resourcesNeed = '';
        widget.nation.master.resourcesOrder.forEach((r){
          if(requirement.containsKey(r)){
            resourcesNeed += ', ' + requirement[r].toString() + ' ' + r;
          }
        });
        resourcesNeed += ' need';
        resourcesNeed = resourcesNeed.substring(2, resourcesNeed.length);
        //check Govern buidling
        String gR = '';
        if(requirement.containsKey('Education')){
          gR += '\nEducation level need to be at level ${requirement['Education']} or above.';
        }
        // return object of type Dialog
        return AlertDialog(
          title: new Text('Upgrade ${type} to level ${level + 1}'),
          content: new Text('${widget.nation.master.specialBuilding[type]['upgrade'][level]['human']} human need\n${requirement['Money'].toString()} money need\n${resourcesNeed}${gR}'),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("BUILD"),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
            new FlatButton(
              child: new Text("BACK"),
              onPressed: () {
                Navigator.pop(context, false);
              },
            )
          ],
        );
      },
    );
  }

  Future<bool> cancelDialog(String type) async {
    int level = widget.nation.specialBuilding[type]['level'];
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text('Cancel Upgrade'),
          content: new Text('Only 80% of resources and money will be return, are you sure about this?'),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("CANCEL UPGRADE"),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
            new FlatButton(
              child: new Text("BACK"),
              onPressed: () {
                Navigator.pop(context, false);
              },
            )
          ],
        );
      },
    );
  }

  Future<bool> _failDialog(String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text('Project Fail To Start'),
          content: new Text(message),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("BACK"),
              onPressed: () {
                Navigator.pop(context, true);
              },
            )
          ],
        );
      },
    );
  }

  void _detailsDialog(int index){
    showDialog(
      context: context,
      builder: (BuildContext context){
        return SimpleDialog(
          title: Text(specialBuilding[index]),
          children: <Widget>[
            //
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Expanded(
          //height: MediaQuery.of(context).size.height - 85 - 150,
          child: new ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            padding: const EdgeInsets.all(10.0),
            itemCount: specialBuilding.length,
            itemBuilder: (BuildContext context, int index){
              return new Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: new Container(
                  height: 300,
                  child: new Card(
                    child: new Column(
                      children: <Widget>[
                        new SizedBox(
                          height: 180,
                          child: new Stack(
                            children: <Widget>[
                              Positioned.fill(
                                child: Image.asset(widget.nation.master.specialBuilding[specialBuilding[index]]['img'], package: 'e_nation', fit: BoxFit.cover,),
                              ),
                              Positioned(
                                bottom: 16.0,
                                right: 16.0,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text('${specialBuilding[index]}', style: TextStyle(color: titleColors[index], fontSize: 32, fontWeight: FontWeight.w600),),
                                ),
                              )
                            ],
                          ),
                        ),
                        new Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                            child: new Text('${specialBuilding[index]} level ${widget.nation.specialBuilding[specialBuilding[index]]['level']}'),
                          ),
                        ),
                        ButtonTheme.bar(
                          child: ButtonBar(
                            alignment: MainAxisAlignment.start,
                            children: <Widget>[
                              RaisedButton(
                                child: new Container(
                                  width: 100,
                                  child: new Center(
                                    child: widget.nation.specialBuilding[specialBuilding[index]]['upgrade']? new Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        SizedBox(
                                          height: 16,
                                          width: 16,
                                          child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(Colors.white), strokeWidth: 2,),
                                        ),
                                        Text('  CANCEL')
                                      ],
                                    ) : Text('UPGRADE'),
                                  ),
                                ),
                                textColor: Colors.white,//textColors[index],
                                color: textColors[index],
                                onPressed: widget.nation.specialBuilding[specialBuilding[index]]['upgrade']? (){
                                  cancelDialog(specialBuilding[index]).then((react){
                                    if(react) {
                                      widget.nation.cancelUpgradeSpecialBuilding(specialBuilding[index]);
                                    }
                                  });
                                } : (widget.nation.specialBuilding[specialBuilding[index]]['level'] < widget.nation.master.specialBuilding[specialBuilding[index]]['upgrade'].length? () {
                                  upgradeDialog(specialBuilding[index]).then((react){
                                    if(react) {
                                      String reply = widget.nation.upgradeSpecialBuilding(specialBuilding[index]);
                                      if(reply == 'build'){
                                        setState(() {});
                                      }else{
                                        _failDialog(reply);
                                      }
                                    }
                                  });
                                } : null),
                              )
//                              FlatButton(
//                                child: Text('DETAILS'),
//                                textColor: textColors[index],
//                                onPressed: () async {
//                                  DateTime date = new DateTime.fromMillisecondsSinceEpoch(1546245343602, isUtc: false);
//                                },
//                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}