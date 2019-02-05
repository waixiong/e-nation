import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:e_nation/Logic/TradeManager.dart';
import 'package:e_nation/Logic/Nation.dart';
import 'package:e_nation/Screen/identityImage.dart';
import 'dart:async';
import 'dart:math';

double distanceBetween(Map location, Map selfLocation){
  //map width is 5
  if(selfLocation == null){
    return 6;
  }
  int xDelta = (selfLocation['x'] - location['x']).abs();
  int xDistance = min(xDelta, 5 - xDelta);
  int yDelta = (selfLocation['y'] - location['y']).abs();
  int yDistance = yDelta;
  return pow((pow(yDistance, 2) + pow(xDistance, 2)), 0.5).toDouble();
}

class Maps extends StatefulWidget{
  Maps({this.tradeManager, this.nation});

  TradeManager tradeManager;
  Nation nation;

  @override
  _MapsState createState() => new _MapsState();
}

class _MapsState extends State<Maps> {

  List<List<String>> grid = [List<String>(5), List<String>(5), List<String>(5), List<String>(5), List<String>(5)];
  StreamSubscription s;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    s = widget.tradeManager.nationStream.listen((t){
      makeGrid();
      setState(() {});
    });
    makeGrid();
  }

  void makeGrid(){
    print('makeGrid');
    widget.tradeManager.nationList.forEach((key, value){
      if(value.containsKey('location')){
        grid[value['location']['y']][value['location']['x']] = key;
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    s.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    List<Widget> rows = <Widget>[];
    //print('y = '+grid.length.toString());
    for(int y = 0; y < grid.length; y++){
      //print(y);
      List<Widget> theRow = List<Widget>(5);
      for(int x = 0; x < grid[y].length; x++){
        //print('  ${x}');
        if(grid[y][x] != null){
          //print('found');
          theRow[x] = new MapTile(
            uid: grid[y][x],
            identity: IdentityPhoto.fromUID(size: MediaQuery.of(context).size.width*0.14, uid: grid[y][x], tradeManager: widget.tradeManager),
            info: { 'name': widget.tradeManager.nationList[grid[y][x]]['name'], 'distance': distanceBetween({ 'x': x, 'y': y }, widget.tradeManager.nationList[widget.nation.currentUser.uid]['location']) },
          );
        }else{
          //print('not found');
          theRow[x] = new MapTile(
            uid: grid[y][x],
            info: { 'distance': distanceBetween({ 'x': x, 'y': y }, widget.tradeManager.nationList[widget.nation.currentUser.uid]['location']) },
          );
        }
      }
      rows.add(new Row(
        children: theRow,
      ));
    }
    return new Scaffold(
      backgroundColor: Colors.grey[700],
      appBar: AppBar(
        title: Text('Map'),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Container(
              height: 140,
              width: MediaQuery.of(context).size.width * 0.7,
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('E-World Map', style: new TextStyle(fontSize: 24, fontWeight: FontWeight.w700),),
                  Text('This map show the location of all nations, you are advised to trade with neighbour nations to minimize the logistic cost.', textAlign: TextAlign.center,)
                ],
              ),
            ),
            new Container(
              width: MediaQuery.of(context).size.width * 0.9 + 4,
              height: MediaQuery.of(context).size.width * 0.9 + 4,
              decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 2.0)),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: rows,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MapTile extends StatelessWidget{
  MapTile({this.identity, this.uid, this.info});

  String uid;
  IdentityPhoto identity;
  Map<dynamic, dynamic> info;

  Color distanceColor(){
    //give color base on distance
    if(info['distance'] == 0){
      return Colors.lightBlueAccent[100];
    }else if(info['distance'] < 2){
      return Colors.lightGreenAccent[100];
    }else if(info['distance'] < 4){
      return Colors.lightGreenAccent[400];
    }else{
      return Colors.lightGreen[800];
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Container(
      width: MediaQuery.of(context).size.width * 0.18,
      height: MediaQuery.of(context).size.width * 0.18,
      decoration: BoxDecoration(color: distanceColor(), border: Border.all(color: Colors.white, width: 2.0)),
      child: new Center(
        child: this.uid == null? identity : new Tooltip(
          message: '${info['name']}\ndistance: ${info['distance']}',
          child: identity,
        ),
      ),
    );
  }
}