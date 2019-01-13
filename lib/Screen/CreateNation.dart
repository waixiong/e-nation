import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:e_nation/Logic/Nation.dart';
import 'package:e_nation/Screen/identityImage.dart';
import 'package:e_nation/Screen/Loading.dart';

class CreateNation extends StatefulWidget{
  CreateNation({Key key, this.nation}) : super(key: key);

  Nation nation;

  @override
  _CreateNationState createState() => new _CreateNationState();
}

class _CreateNationState extends State<CreateNation>{

  String nationName;
  String nationHash;
  TextEditingController textController = TextEditingController();
  final _textKey = GlobalKey<FormState>();
  int _selectedPopulationIndex;
  List<int> population = <int>[5000, 6000, 7000, 8000, 9000, 10000];

  @override
  void initState(){
    nationName = '';
    nationHash = identityGenerate();
    _selectedPopulationIndex = 0;
  }

  Widget _buildPopulationPicker(BuildContext context) {
    final FixedExtentScrollController scrollController =
    FixedExtentScrollController(initialItem: _selectedPopulationIndex);

    return GestureDetector(
      onTap: () async {
        await showCupertinoModalPopup<void>(
          context: context,
          builder: (BuildContext context) {
            return Container(
              height: 200,
              padding: const EdgeInsets.only(top: 6.0),
              color: CupertinoColors.white,
              child: DefaultTextStyle(
                style: const TextStyle(
                  color: CupertinoColors.black,
                  fontSize: 22.0,
                ),
                child: GestureDetector(
                  // Blocks taps from propagating to the modal sheet and popping.
                  onTap: () {},
                  child: SafeArea(
                    top: false,
                    child: CupertinoPicker(
                      scrollController: scrollController,
                      itemExtent: 40,
                      backgroundColor: CupertinoColors.white,
                      onSelectedItemChanged: (int index) {
                        setState(() => _selectedPopulationIndex = index);
                      },
                      children: List<Widget>.generate(population.length, (int index) {
                        return Center(child:
                          Text(population[index].toString()),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.grey,

          border: Border(
            top: BorderSide(color: Color(0xFFBCBBC1), width: 0.0),
            bottom: BorderSide(color: Color(0xFFBCBBC1), width: 0.0),
          ),
        ),
        height: 44.0,
        width: MediaQuery.of(context).size.width*0.6,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SafeArea(
            top: false,
            bottom: false,
            child: DefaultTextStyle(
              style: const TextStyle(
                letterSpacing: -0.24,
                fontSize: 17.0,
                color: CupertinoColors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text('POPULATION'),
                  Text(
                    population[_selectedPopulationIndex].toString(),
                    style: const TextStyle(
                        color: CupertinoColors.white
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      key: widget.key,
      backgroundColor: Colors.grey.shade800,
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Container(
            width: MediaQuery.of(context).size.width,
            child: new Center(
              child: new Text('Create Nation', style: TextStyle(color: Colors.white70, fontSize: 40), textAlign: TextAlign.center,),
            ),
          ),
          new Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
            width: MediaQuery.of(context).size.width * 0.6,
            child: new Form(
              key: _textKey,
              child: new TextFormField(
                keyboardType: TextInputType.text,
                textAlign: TextAlign.left,
                style: new TextStyle(color: Colors.white70, fontSize: 18),
                decoration: new InputDecoration(labelText: 'Nation Name', labelStyle: TextStyle(color: Colors.white70, fontSize: 14, fontStyle: FontStyle.italic)),
                autofocus: false,
                validator: (value){
                  if(value.length == 0)
                    return 'Please enter name';
                  nationName = value;
                  return null;
                },
                controller: textController,
              ),
            ),
          ),
          _buildPopulationPicker(context),
          new Padding(
            padding: EdgeInsets.only(top: 30),
            child: Text('Below is your identity image', style: TextStyle(color: Colors.grey, fontSize: 18),),
          ),
          new Container(
            width: MediaQuery.of(context).size.width*0.5,
            height: MediaQuery.of(context).size.width*0.5,
            child: new Center(
              child: new IdentityImage(size: MediaQuery.of(context).size.width*0.45, hash: nationHash,),
            ),
          ),
          new FlatButton(
            onPressed: (){
              setState(() {
                nationHash = identityGenerate();
              });
            },
            child: Text('DON\'T LIKE IT? CHANGE IT', style: TextStyle(color: Colors.grey),),
          ),
          new RaisedButton(
            onPressed: (){
              if(_textKey.currentState.validate()) {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return Loading();
                    }
                );
                widget.nation.initiatedNation(nationName, nationHash,
                    population[_selectedPopulationIndex]).then((value) {
                  Navigator.pop(context);
                  if (value) {
                    Navigator.pop(context);
                  }
                });
              }
            },
            child: Text('INITIATED NEW NATION'),
          )
        ],
      ),
    );
  }
}
