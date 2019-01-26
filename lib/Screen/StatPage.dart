import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:async';

import 'package:e_nation/Logic/Nation.dart';

class DataSession{
  double data;
  int session;
  DataSession({this.data, this.session});
}

abstract class CardChart extends StatefulWidget {
  CardChart({Key, key, this.change});
  Function change;
}

class GDPCard extends CardChart {
  GDPCard({Key key, this.nation, Function change}) : super(key: key, change: change);
  Nation nation;
  @override
  _GDPCardState createState() => new _GDPCardState();
}

class _GDPCardState extends State<GDPCard> {

  int _session;
  Map<String, num> _data;
  List<charts.Series<dynamic, int>> GDPSeriesList;
  //List<Map<dynamic, dynamic>> GDP;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //GDP = new List<Map<dynamic, dynamic>>();
    //GDP = widget.nation.historyData.GDP;
    widget.change = (){
      setState(() {});
    };
  }

  void getSeriesGDP(){
    GDPSeriesList = new List<charts.Series<dynamic, int>>();
    GDPSeriesList.add(new charts.Series(
      id: 'Consumption',
      data: widget.nation.historyData.GDP,
      domainFn: (dynamic data, _) => data['session'],
      measureFn: (dynamic data, _) => data['comsumption'],
    ));
    List<dynamic> defaultGDP = <dynamic>[{'session': 0, 'comsumption': 0, 'export': 0, 'import': 0}];
//    GDPSeriesList.add(new charts.Series(
//      id: 'Trade Balance',
//      data: widget.nation.historyData.GDP,
//      domainFn: (dynamic data, _) => data['session'],
//      measureFn: (dynamic data, _) => data['export'] - data['import'],
//    ));
    GDPSeriesList.add(new charts.Series(
      id: 'GDP',
      data: widget.nation.historyData.GDP.length > 0? widget.nation.historyData.GDP : defaultGDP,
      domainFn: (dynamic data, _) => data['session'],
      measureFn: (dynamic data, _) => data['comsumption'] + data['export'] - data['import'],
    ));
  }

  _onSelectionChanged(charts.SelectionModel model) {
    final selectedDatum = model.selectedDatum;

    int session;
    final measures = <String, num>{};

    // We get the model that updated with a list of [SeriesDatum] which is
    // simply a pair of series & datum.
    //
    // Walk the selection updating the measures map, storing off the sales and
    // series name for each selection point.
    if (selectedDatum.isNotEmpty) {
      session = selectedDatum.first.datum['session'];
      selectedDatum.forEach((charts.SeriesDatum datumPair) {
        if(datumPair.series.id == 'Consumption')
          measures[datumPair.series.id] = datumPair.datum['comsumption'];
        else if(datumPair.series.id == 'GDP'){
          measures[datumPair.series.id] = datumPair.datum['comsumption'] + datumPair.datum['export'] - datumPair.datum['import'];
        }
        measures['Trade Balance'] = datumPair.datum['export'] - datumPair.datum['import'];
      });
    }

    // Request a build.
    setState(() {
      _session = session;
      _data = measures;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    getSeriesGDP();
    List<Widget> contains = <Widget>[];
    contains.add(new Text('GDP'));
    contains.add(new SizedBox(
      height: MediaQuery.of(context).size.height * 0.3,
      child: new charts.LineChart(
        GDPSeriesList,
        behaviors: [new charts.SeriesLegend()],
        selectionModels: [
          new charts.SelectionModelConfig(
            type: charts.SelectionModelType.info,
            changedListener: _onSelectionChanged,
          )
        ],
      ),
    ));
    if(_session != null){
      contains.add(new Text('Session ${_session}'));
      contains.add(new Text('Consumption : ${_data['Consumption']}'));
      contains.add(new Text('Trade Balance : ${_data['Trade Balance']}'));
      contains.add(new Text('GDP : ${_data['GDP']}'));
    }

    return new Card(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: contains,
      ),
    );
  }
}

class TradeCard extends CardChart {
  TradeCard({Key key, this.nation, Function change}) : super(key: key, change: change);
  Nation nation;
  @override
  _TradeCardState createState() => new _TradeCardState();
}

class _TradeCardState extends State<TradeCard> {

  List<charts.Series<dynamic, String>> SeriesList;
  //List<Map<dynamic, dynamic>> GDP;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //GDP = new List<Map<dynamic, dynamic>>();
    //GDP = widget.nation.historyData.GDP;
    widget.change = (){
      setState(() {});
    };
  }

  bool valid(){
    if(widget.nation.historyData.GDP.length == 0)
      return false;
    return !(widget.nation.historyData.GDP[widget.nation.historyData.GDP.length - 1]['export'] == 0 && widget.nation.historyData.GDP[widget.nation.historyData.GDP.length - 1]['import'] == 0);
  }

  void getSeriesList(){
    List<dynamic> data = new List<dynamic>();
    if(widget.nation.historyData.GDP.length > 0) {
      data.add({
        'type': 'Import',
        'data': widget.nation.historyData.GDP[widget.nation.historyData.GDP
            .length - 1]['import']
      });
      data.add({
        'type': 'Export',
        'data': widget.nation.historyData.GDP[widget.nation.historyData.GDP
            .length - 1]['export']
      });
    }
    SeriesList = new List<charts.Series<dynamic, String>>();
    SeriesList.add(new charts.Series(
      id: 'Comsumption',
      data: data,
      domainFn: (dynamic data, _) => data['type'],
      measureFn: (dynamic data, _) => data['data'],
      labelAccessorFn: (dynamic data, _) => '${data['type']}\n${data['data']}',
    ));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    getSeriesList();
    List<Widget> contains = <Widget>[];
    contains.add(new Text('TRADE'));
    contains.add(new SizedBox(
      height: MediaQuery.of(context).size.height * 0.3,
      child: valid()? new charts.PieChart(
        SeriesList,
        defaultRenderer: new charts.ArcRendererConfig(
            arcWidth: 60,
            arcRendererDecorators: [new charts.ArcLabelDecorator()]),
      ) : new Center(
        child: Text('No Import && Export for last session'),
      ),
    ));

    return new Card(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: contains,
      ),
    );
  }
}

class PopulationCard extends CardChart {
  PopulationCard({Key key, this.nation, Function change}) : super(key: key, change: change);
  Nation nation;
  @override
  _PopulationCardState createState() => new _PopulationCardState();
}

class _PopulationCardState extends State<PopulationCard> {

  List<charts.Series<dynamic, String>> SeriesList;
  //List<Map<dynamic, dynamic>> GDP;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //GDP = new List<Map<dynamic, dynamic>>();
    //GDP = widget.nation.historyData.GDP;
    widget.change = (){
      setState(() {});
    };
  }

  void getSeriesList(){
    SeriesList = new List<charts.Series<dynamic, String>>();
    SeriesList.add(new charts.Series(
      id: 'Comsumption',
      data: widget.nation.historyData.GDP,
      domainFn: (dynamic data, _) => data['session'].toString(),
      measureFn: (dynamic data, _) => data['human'],
    ));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    getSeriesList();
    List<Widget> contains = <Widget>[];
    contains.add(new Text('POPULATION'));
    contains.add(new SizedBox(
      height: MediaQuery.of(context).size.height * 0.3,
      child: new charts.BarChart(
        SeriesList,
      ),
    ));

    return new Card(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: contains,
      ),
    );
  }
}

class GrowthCard extends CardChart {
  GrowthCard({Key key, this.nation, Function change}) : super(key: key, change: change);
  Nation nation;
  @override
  _GrowthCardState createState() => new _GrowthCardState();
}

class _GrowthCardState extends State<GrowthCard> {

  int _session;
  Map<String, num> _data;
  List<charts.Series<dynamic, int>> GDPSeriesList;
  //List<Map<dynamic, dynamic>> GDP;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //GDP = new List<Map<dynamic, dynamic>>();
    //GDP = widget.nation.historyData.GDP;
    widget.change = (){
      setState(() {});
    };
  }

  void getSeriesGDP(){
    GDPSeriesList = new List<charts.Series<dynamic, int>>();
    List<Map<dynamic, dynamic>> grow = new List<Map<dynamic, dynamic>>();
    for(int i = 1; i < widget.nation.historyData.GDP.length; i++){
      double GDPdiff = (widget.nation.historyData.GDP[i]['comsumption'] - widget.nation.historyData.GDP[i-1]['comsumption'] +
          widget.nation.historyData.GDP[i]['export'] - widget.nation.historyData.GDP[i-1]['export'] -
          widget.nation.historyData.GDP[i]['import'] + widget.nation.historyData.GDP[i-1]['import']).toDouble();
      double oldGDP = (widget.nation.historyData.GDP[i-1]['comsumption'] + widget.nation.historyData.GDP[i-1]['export'] + widget.nation.historyData.GDP[i-1]['import']).toDouble();
      grow.add({
        'session': i,
        'Comsumption': (widget.nation.historyData.GDP[i]['comsumption'] - widget.nation.historyData.GDP[i-1]['comsumption']).toDouble() / widget.nation.historyData.GDP[i-1]['comsumption'] * 100.00,
        //'Export': (widget.nation.historyData.GDP[i]['export'] - widget.nation.historyData.GDP[i-1]['export']).toDouble() / widget.nation.historyData.GDP[i-1]['export'] * 100.00,
        //'Import': (widget.nation.historyData.GDP[i]['import'] - widget.nation.historyData.GDP[i-1]['import']).toDouble() / widget.nation.historyData.GDP[i-1]['import'] * 100.00,
        'GDP': GDPdiff / oldGDP * 100.00,
        'Population': (widget.nation.historyData.GDP[i]['human'] - widget.nation.historyData.GDP[i-1]['human']).toDouble() / widget.nation.historyData.GDP[i-1]['human'] * 100.00
      });
    }
    GDPSeriesList.add(new charts.Series(
      id: 'Comsumption',
      data: grow,
      domainFn: (dynamic data, _) => data['session'],
      measureFn: (dynamic data, _) => data['Comsumption'],
    ));
    GDPSeriesList.add(new charts.Series(
      id: 'GDP',
      data: grow,
      domainFn: (dynamic data, _) => data['session'],
      measureFn: (dynamic data, _) => data['GDP'],
    ));
//    GDPSeriesList.add(new charts.Series(
//      id: 'Export',
//      data: grow,
//      domainFn: (dynamic data, _) => data['session'],
//      measureFn: (dynamic data, _) => data['Export'],
//    ));
//    GDPSeriesList.add(new charts.Series(
//      id: 'Import',
//      data: grow,
//      domainFn: (dynamic data, _) => data['session'],
//      measureFn: (dynamic data, _) => data['Import'],
//    ));
    GDPSeriesList.add(new charts.Series(
      id: 'Population',
      data: grow,
      domainFn: (dynamic data, _) => data['session'],
      measureFn: (dynamic data, _) => data['Population'],
    ));
  }

  _onSelectionChanged(charts.SelectionModel model) {
    final selectedDatum = model.selectedDatum;

    int session;
    final measures = <String, num>{};

    // We get the model that updated with a list of [SeriesDatum] which is
    // simply a pair of series & datum.
    //
    // Walk the selection updating the measures map, storing off the sales and
    // series name for each selection point.
    if (selectedDatum.isNotEmpty) {
      session = selectedDatum.first.datum['session'];
      selectedDatum.forEach((charts.SeriesDatum datumPair) {
        measures[datumPair.series.id] = datumPair.datum[datumPair.series.id];
      });
    }

    // Request a build.
    setState(() {
      _session = session;
      _data = measures;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    getSeriesGDP();
    List<Widget> contains = <Widget>[];
    contains.add(new Text('Growth Rate %'));
    contains.add(new SizedBox(
      height: MediaQuery.of(context).size.height * 0.3,
      width: MediaQuery.of(context).size.width,
      child: new charts.LineChart(
        GDPSeriesList,
        behaviors: [new charts.SeriesLegend(
          cellPadding: new EdgeInsets.only(right: 4.0, bottom: 4.0),
          position: charts.BehaviorPosition.end,
        )],
        selectionModels: [
          new charts.SelectionModelConfig(
            type: charts.SelectionModelType.info,
            changedListener: _onSelectionChanged,
          )
        ],
      ),
    ));
    if(_session != null){
      contains.add(new Text('Session ${_session}'));
      _data.forEach((k, v){
        contains.add(new Text('${k}: ${v.toStringAsFixed(2)}%'));
      });
    }

    return new Card(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: contains,
      ),
    );
  }
}

class StatPage extends StatefulWidget {
  StatPage({Key key, this.currentUser, this.auth, this.nation}) : super(key: key);

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
  _StatPageState createState() => new _StatPageState(auth: auth);
}

class _StatPageState extends State<StatPage> with AutomaticKeepAliveClientMixin<StatPage>{
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  _StatPageState({Key key, this.auth,});
  FirebaseUser currentUser;//User Holder
  FirebaseAuth auth;//auth Holder, used for logout
  DatabaseReference _orderRef;
  bool loading = true;
  DatabaseReference data;

  List<CardChart> _cardList = <CardChart>[];

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    //load user doc
    //loadUserDoc();
    print('init stat');
    if(widget.change == null){
      widget.change = widget.nation.statRefresh.listen((data){
        _cardList.forEach((CardChart card){
          card.change();
        });
      });
    }else{
      widget.change.resume();
    }
    loading = true;
    _cardList.add(new GDPCard(nation: widget.nation,));
    _cardList.add(new TradeCard(nation: widget.nation,));
    _cardList.add(new PopulationCard(nation: widget.nation,));
    _cardList.add(new GrowthCard(nation: widget.nation,));
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
    print('deactivate stat');
  }

  @override
  void dispose(){
    //widget.change.pause();
    print('dispose stat but keep alive = '+wantKeepAlive.toString());
    widget.change.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      padding: const EdgeInsets.all(10.0),
      itemCount: _cardList.length,
      itemBuilder: (BuildContext context, int index){
        return _cardList[index];
      },
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}