import 'package:flutter/material.dart';
import 'package:e_nation/Logic/Nation.dart';

class ItemComsumption extends StatelessWidget{
  ItemComsumption({Key key, this.size, this.color, this.demand, this.onPress, this.resImg});

  double size;
  Color color;
  int demand;
  String resImg;
  Function onPress;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    ImageProvider imageProvider = AssetImage(resImg);
    return new SizedBox(
      width: size,
      height: size,
      child: new Stack(
        fit: StackFit.expand,
        children: <Widget>[
          new Center(
            child: new CircleAvatar(
              backgroundImage: imageProvider,
              backgroundColor: Colors.white,
              radius: size * 0.36,
            ),
          ),
          new CustomPaint(
            painter: new OutCircle(color: color),
          ),
          new CustomPaint(
            painter: new TagCircle(color: color),
            child: new Stack(
              children: <Widget>[
                new Positioned(
                  bottom: 0, right: 0,
                  child: new SizedBox(
                    height: size*0.4, width: size*0.4,
                    child: new Center(
                      child: new Text('${demand.toString()}', style: TextStyle(fontSize: size*0.1, color: Colors.white, fontWeight: FontWeight.w900)),
                    ),
                  ),
                )
              ],
            ),
          ),
          new Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onPress,
            ),
          )
        ],
      ),
    );
  }
}

class OutCircle extends CustomPainter{
  OutCircle({this.color});

  Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    Paint paint = new Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width*0.12;
    Offset center = new Offset(size.width/2, size.height/2);
    canvas.drawCircle(center, size.width*0.45, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}

class TagCircle extends CustomPainter{
  TagCircle({this.color});

  Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    Paint paint = new Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;
    Offset center = new Offset(size.width*0.8, size.height*0.8);
    double radius = size.width*0.20;
    canvas.drawCircle(center, radius, paint);
    Paint line = new Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width*0.05;
    canvas.drawCircle(center, radius*1.1, line);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}

class ComsumptionSlider extends StatefulWidget {
  ComsumptionSlider({Key key, this.nation, this.resource}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  Nation nation;
  String resource;
  //var orderList = <DataSnapshot>[];

  @override
  _ComsumptionSliderState createState() => new _ComsumptionSliderState();
}

class _ComsumptionSliderState extends State<ComsumptionSlider> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  _ComsumptionSliderState({Key key,});
  bool loading = true;

  int _inputState = 0;
  int quantity = 0;
  final _quantityKey = GlobalKey<FormState>();
  TextEditingController quantityController = TextEditingController();

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    getAvailableFood();
  }

  void getAvailableFood(){
    bool existInStock = false;
    if(widget.nation.comsumptionSupply.containsKey(widget.resource)){
      existInStock = (widget.nation.comsumptionSupply[widget.resource] > 0);
    }
    if(widget.nation.resources[widget.resource] > 0 || existInStock){
      if(widget.nation.comsumptionSupply[widget.resource] != null) {
        setState(() {
          _inputState = widget.nation.comsumptionSupply[widget.resource];
          quantity = widget.nation.comsumptionSupply[widget.resource];
          if(quantity == 0)
            quantityController.text = '';
          else
            quantityController.text = quantity.toString();
        });
      }else {
        setState(() {
          _inputState = 0;
          quantityController.text = '';
        });
      }
    }
  }

  List<Widget> buildSlider(){//change from slider to text
    List<Widget> list = <Widget>[];
    int max = widget.nation.comsumptionSupply.containsKey(widget.resource) ? ((widget.nation.resources[widget.resource] + widget.nation.comsumptionSupply[widget.resource])) : ((widget.nation.resources[widget.resource]));
    list.add(new Container(height: 60, alignment: Alignment.center, child: new Text('${widget.resource} Consumption', style: TextStyle(fontWeight: FontWeight.w700 ), textAlign: TextAlign.center,),));
    list.add(Slider(
      value: _inputState.toDouble(),
      min: 0,
      max: max.toDouble(),
      divisions: (max != 0)? (max).toInt() : 1,
      label: '${_inputState.round()}',
      onChanged: (double value){
        setState(() {
          //factoryList[i]['input']['human'] = value.toInt();
          _inputState = value.toInt();
          quantity = _inputState;
          if(quantity == 0)
            quantityController.text = '';
          else
            quantityController.text = quantity.toString();
        });
      },
      activeColor: Colors.grey.shade500,
    ));
    list.add(new Container(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
      width: MediaQuery.of(context).size.width * 0.6,
      child: new Form(
        onChanged: () => _quantityKey.currentState.validate(),
        key: _quantityKey,
        child: new TextFormField(
          keyboardType: TextInputType.number,
          textAlign: TextAlign.right,
          decoration: new InputDecoration(labelText: 'Quantity Supply'),
          autofocus: false,
          validator: (value){
            try{
              quantity = int.parse(value);
              if(quantity > max){
                setState(() { _inputState = max; });
                quantityController.text = max.toString();
                return 'Please enter available quantity\n${max.toString()} or below';
              }else if(quantity < 0){
                setState(() { _inputState = 0; });
                quantityController.text = 0.toString();
                return 'Please enter available quantity\nIn between 0 and ${max.toString()}';
              }
              setState(() { _inputState = quantity; });
              return null;
            }catch(e){
              if(value.length == 0){
                quantityController.text = '';
                setState(() { _inputState = 0; });
                return null;
              }else {
                quantityController.text = _inputState.toString();
              }
              return 'Please enter a integer as quantity';
            }
          },
          controller: quantityController,
        ),
      ),
    ));
    int need = widget.nation.comsumptionDemand[widget.resource] - _inputState;
    int min = widget.nation.minD[widget.resource] - _inputState;
    list.add(new Text('${need>0? '${need} needed' : 'Supply is enough for demand'}', textAlign: TextAlign.center,));
    list.add(new Text('${min>0? '${min} needed to meet requirement' : 'Supply is meet minimum requirement'}', textAlign: TextAlign.center,));
    list.add(Container(height: 24,));
    list.add(new ButtonBar(
      children: <Widget>[
        new FlatButton(
          child: new Text('CANCEL'),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        new FlatButton(
          child: new Text('SUPPLY'),
          onPressed: (){
            comsumption();
            Navigator.pop(context);
          },
        )
      ],
    ));
    return list;
  }

  Future<bool> comsumption() async {
    await widget.nation.resourcesComsumption(widget.resource, _inputState);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return new SimpleDialog(
      children: buildSlider(),
    );
  }
}