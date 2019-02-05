import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer';
import 'package:e_nation/Logic/Nation.dart';

abstract class _ResourceItem extends StatelessWidget {
  const _ResourceItem({ Key key, @required this.resourceImg, this.radius})
      : super(key: key);

  final String resourceImg;
  final double radius;

  Widget buildItem(BuildContext context, TextStyle style, EdgeInsets padding) {
    BoxDecoration decoration;
    return Container(
      padding: padding,
      decoration: decoration,
      child: CircleAvatar(backgroundImage: AssetImage(resourceImg), backgroundColor: Colors.white, radius: radius)/*Text(resource, style: style)*/,
    );
  }
}

class ResourcePic extends _ResourceItem {
  const ResourcePic({ Key key, String resourceImg, double radius }) : super(key: key, resourceImg: resourceImg, radius: radius);

  @override
  Widget build(BuildContext context) {
    return buildItem(
      context,
      new TextStyle(inherit: false, color: Colors.black87, fontSize: 10, fontWeight: FontWeight.w500, textBaseline: TextBaseline.alphabetic),
      const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0)
    );
  }
}

class FactoryCard extends StatelessWidget {
  FactoryCard({ Key key, @required this.resource, this.factoryIndex, this.tag, this.facImg, this.resImg, this.factoryData, this.onPressed })
      : super(key: key);

  final String resource;
  final int factoryIndex;
  final VoidCallback onPressed;
  final String tag;
  final String facImg;
  final String resImg;
  Map<dynamic, dynamic> factoryData;

  @override
  Widget build(BuildContext context) {
    //print('Fac Img is : '+facImg);
    return Card(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width/2 - 16.0,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width/2,
                  height: MediaQuery.of(context).size.width/32*9,
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  child: Hero(
                    tag: tag,
                    child: Image.asset(
                      facImg,//image
                      package: 'e_nation',
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width/2,
                  height: 62.75,
                  //padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Center(
                    child: Text('${resource}\nProduction Line', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w200),),
                  ),
                )
              ],
            ),
            Align(
              alignment: Alignment.topRight,
              child: ResourcePic(resourceImg: resImg, radius: 24.0,),
            ),
            Material(
              type: MaterialType.transparency,
              child: InkWell(onTap: onPressed),
            ),
          ],
        ),
      ),
    );
  }
}

class FactoryInputList extends StatefulWidget{
  FactoryInputList({Key key, this.nation, this.resource}) : super(key: key);

  Nation nation;
  String resource;

  @override
  _FactoryInputList createState() => new _FactoryInputList();
}

class _FactoryInputList extends State<FactoryInputList>{
  List<int> _factoryInputState = <int>[];
  List<dynamic> factoryList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    factoryList = widget.nation.building[widget.resource];
    for(int i = 0; i < factoryList.length; i++) {
      _factoryInputState.add(factoryList[i]['input']['human']);
    }
  }

  Future<bool> _cancel() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text('Project Cancelation'),
          content: new Text('Only 80% of resources and money will be return, are you sure about this?'),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("CANCEL PROJECT"),
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

  @override
  Widget build(BuildContext context) {
    List<Widget> dialogList = <Widget>[];
    dialogList.add(Container(
      width: 220.0,
      height: 220.0,
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Hero(
        tag: widget.resource,
        child: Image.asset(
          widget.nation.master.building[widget.resource]['img'],//image
          package: 'e_nation',
          fit: BoxFit.contain,
        ),
      ),
    ));
    String neededList = '';
    Map<dynamic, dynamic> map = widget.nation.master.building[widget.resource]['input'];
    map.forEach((resource, value){
      if(widget.nation.resourcesMatrix['Solar Panel']){
        value = value * 0.9;
      }
      neededList += (value*100).toInt().toString() + ' '+ resource + ', ';
    });
    neededList = neededList.substring(0, neededList.length - 2);
    neededList += ' needed';
    dialogList.add(Text(neededList, textAlign: TextAlign.center,));
    dialogList.add(Text('For Every Hundred Labour'));
    dialogList.add(Container(height: 20,));
    if(factoryList.length > 0){
      int max = widget.nation.master.building[widget.resource]['maxHuman'];
      for(int i = 0; i < factoryList.length; i++){
        List<Widget> factoryTitle = <Widget>[
          Expanded(
            child: Text('${widget.resource} Production ${i+1} - Level ${factoryList[i]['level']+1}', textAlign: TextAlign.left,),
          ),
          IconButton(icon: Icon(Icons.arrow_upward), onPressed: (factoryList[i]['level'] < (widget.nation.master.building[widget.resource]['upgrade'].length-1) && !factoryList[i]['upgrade'])? (){
            showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                // return object of type Dialog
                Map<dynamic, dynamic> requirement = widget.nation.master.building[widget.resource]['upgrade'][factoryList[i]['level']+1];
                String resourcesNeed = '';
                widget.nation.master.resourcesOrder.forEach((r){
                  if(requirement.containsKey(r)){
                    resourcesNeed += requirement[r].toString() + ' ' + r + '\n';
                  }
                });
                //resourcesNeed += ' need';
                //resourcesNeed = resourcesNeed.substring(2, resourcesNeed.length);
                //check Govern buidling
                String gR = '';
                if(requirement.containsKey('Education')){
                  gR += '\nEducation level ${requirement['Education']} or above.';
                }
                return AlertDialog(
                  title: new Text('Upgrade ${widget.resource} Production to level ${factoryList[i]['level']+2}'),
                  content: new Text('${requirement['human'].toString()} labour\n${requirement['Money'].toString()} money\n${resourcesNeed}${gR}'),
                  actions: <Widget>[
                    // usually buttons at the bottom of the dialog
                    new FlatButton(
                      child: new Text("UPGRADE"),
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
            ).then((react){
              if(react) {
                String reply = widget.nation.upgradeBuilding(widget.resource, i);
                if(reply == 'build'){
                  setState(() {_factoryInputState[i] = 0;});
                }else{
                  _failDialog(reply);
                }
              }
            });
          } : null)
        ];
        if(factoryList[i]['upgrade']){
          factoryTitle.add(IconButton(icon: Icon(Icons.cancel), onPressed: (){
            _cancel().then((react){
              if(react){
                widget.nation.cancelUpgradeBuilding(widget.resource, i);
                setState(() {});
              }
            });
          }));
        }
        dialogList.add(new Padding(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: new Row(
            children: factoryTitle,
          ),
        ));
        dialogList.add(Slider(
          value: _factoryInputState[i].toDouble(),
          min: 0,
          max: max.toDouble(),
          divisions: (max/widget.nation.master.building[widget.resource]['step']).toInt(),
          label: '${_factoryInputState[i].round()}',
          onChanged: !factoryList[i]['upgrade'] ? (double value){
            setState(() {
              //factoryList[i]['input']['human'] = value.toInt();
              _factoryInputState[i] = value.toInt();
            });
          } : null,
          activeColor: Colors.grey.shade500,
        ));
        dialogList.add(Text('Labour Input: ${_factoryInputState[i]}',));
        dialogList.add(Container(height: 20,));
      }
    }
    if(factoryList.length < 3){
      dialogList.add(Divider());
      bool alreadyBuild = false;
      if(widget.nation.buildList.containsKey(widget.resource))
        alreadyBuild = widget.nation.buildList[widget.resource];
      dialogList.add(!alreadyBuild ?
        SimpleDialogOption(
          onPressed: (){
            showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                Map<dynamic, dynamic> requirement = widget.nation.master.building[widget.resource]['upgrade'][0];
                String resourcesNeed = '';
                widget.nation.master.resourcesOrder.forEach((r){
                  if(requirement.containsKey(r)){
                    resourcesNeed += requirement[r].toString() + ' ' + r + '\n';
                  }
                });
                //resourcesNeed += ' need';
                //resourcesNeed = resourcesNeed.substring(2, resourcesNeed.length);
                //check Govern buidling
                String gR = '';
                if(requirement.containsKey('Education')){
                  gR += '\nEducation level ${requirement['Education']} or above.';
                }
                // return object of type Dialog
                return AlertDialog(
                  title: new Text('Build ${factoryList.length == 0? 'a':'another'} ${widget.resource} production line?'),
                  content: new Text('${requirement['human'].toString()} labour\n${requirement['Money'].toString()} money\n${resourcesNeed}${gR}\n'),//new Text('${widget.nation.master.building[widget.resource]['upgrade'][0]['human']} human need'),
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
            ).then((react){
              if(react) {
                String reply = widget.nation.newBuilding(widget.resource);
                if(reply == 'build'){
                  setState(() {});
                }else{
                  _failDialog(reply);
                }
              }
            });},
          child: Text('Build ${factoryList.length == 0? 'a':'another'} ${widget.resource} production line', style: TextStyle(fontWeight: FontWeight.w900),),
        ) : SimpleDialogOption(
          onPressed: () {
            _cancel().then((react){
              if(react) {
                widget.nation.cancelNewBuilding(widget.resource);
                setState(() {});
              }
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(),
              ),
              Text('   Building In Progress')
            ],
          ),
        )
      );
      dialogList.add(Container(height: 20,));
    }
    dialogList.add(Divider());
    int total = 0;
    for(int i = 0; i < _factoryInputState.length; i++){
      total += (_factoryInputState[i] * (widget.nation.master.building[widget.resource]['rate']['base'] + widget.nation.building[widget.resource][i]['level'] * widget.nation.master.building[widget.resource]['rate']['upgrade'])).toInt();
    }
    dialogList.add(
      new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 4),
            child: ResourcePic(resourceImg: widget.nation.master.resources[widget.resource]['img'], radius: 12,),
          ),
          Text('${total} ${widget.resource} will be produced.')
        ],
      )
    );

    return new Scaffold(
      body: new WillPopScope(
        child: new Center(
          child: new SingleChildScrollView(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: dialogList,
            ),
          ),
        ),
        onWillPop: (){
          try {
            bool enough = true;
            String r = '';
            for(int i = 0; i < _factoryInputState.length; i++) {
              //print('pop');
              String result = widget.nation.assignResources(widget.resource, i, _factoryInputState[i]);
              print(result);
              if(result != 'assign'){
                r = result;
                enough = false;
                break;
              }
            }
            if(enough) {
              Navigator.pop(context, null);
            }else{
              showDialog(
                context: context,
                builder: (BuildContext context){
                  return AlertDialog(
                    title: new Text('Error'),
                    content: new Text('${r}'),
                    actions: <Widget>[
                      // usually buttons at the bottom of the dialog
                      new FlatButton(
                        child: new Text("Close"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                }
              );
            }
          }catch(e){
            print(e);
            showDialog(
              context: context,
              builder: (BuildContext context) {
                // return object of type Dialog
                return AlertDialog(
                  title: new Text('Error'),
                  content: new Text(e.toString() + ' '),
                  actions: <Widget>[
                    // usually buttons at the bottom of the dialog
                    new FlatButton(
                      child: new Text("Close"),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}