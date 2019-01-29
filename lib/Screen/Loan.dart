import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:e_nation/Screen/identityImage.dart';
import 'package:e_nation/Logic/Nation.dart';
import 'package:e_nation/Logic/TradeManager.dart';
import 'dart:math';
import 'dart:async';

class ListCard extends StatelessWidget{
  ListCard({Key key, this.liability, this.data, this.tradeManager, this.nation});
  bool liability;
  Map<String, dynamic> data;//key, value
  TradeManager tradeManager;
  Nation nation;

  Color getColor(String state){
    if(state == 'QUEUE'){
      return Colors.blue;
    }else if(state == 'ONGOING'){
      return Color.fromARGB(255, 255, 180, 0);
    }else if(state == 'DEFAULT'){
      return Colors.red;
    }else{
      return Colors.green;
    }
  }

  //get transaction id
  String randomHex(){
    return (Random.secure().nextDouble() * 9223372036854775807).floor().toRadixString(16);
  }

  Future<bool> repayment(bool half, BuildContext context) async {
    double totalAmount = data['value']['amount'] * (1 + data['value']['interest']/100);
    String transactionID = randomHex();
    String result = await nation.repayment((totalAmount * (half? 50:100) /100), data['key'], !half, transactionID);
    print('result : ' + result);
    if(result != 'Sending'){
      showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text('Error'),
            content: Text(result),
          );
        }
      );
      return false;
    }
    return true;
  }

  Widget paymentDialog(BuildContext context){
    double totalAmount = data['value']['amount'] * (1 + data['value']['interest']/100);
    return SimpleDialog(
      contentPadding: EdgeInsets.fromLTRB(0.0, 12.0, 0, 0.0),
      title: Text('Repayment'),
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 12, right: 12),
          child: Text('Early Repayment would not deduct the interest', textAlign: TextAlign.justify,),
        ),
        Padding(
          padding: EdgeInsets.only(left: 12, right: 12),
          child: Text('You can choose to pay either half or full of the loan', textAlign: TextAlign.justify,),
        ),
        new Row(
          children: <Widget>[
            new Expanded(
              child: FlatButton(
                onPressed: (){
                  repayment(true, context).then((react){
                    if(react) Navigator.pop(context);
                  });
                },
                child: Text('Pay ${(totalAmount * 0.5).toStringAsFixed(0)}'),
              ),
            ),
            new Expanded(
              child: FlatButton(
                onPressed: data['value']['pay']==0? (){
                  repayment(false, context).then((react){
                    if(react) Navigator.pop(context);
                  });
                }:null,
                child: Text('Pay ${(totalAmount).toStringAsFixed(0)}'),
              ),
            )
          ],
        )
      ],
    );
  }

  Widget detailDialog(BuildContext context){
    double totalAmount = data['value']['amount'] * (1 + data['value']['interest']/100);
    List<Widget> contents = [];
    //add payment record && detail here
    List<dynamic> payments = data['value']['paymentDetail'];
    payments.forEach((payment){
      DateTime time = DateTime.fromMillisecondsSinceEpoch(payment['timestamp']);
      contents.add(new Padding(
        padding: EdgeInsets.all(5.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text('${payment['id']}${payment['claim']? ' (CLAIMED)':''}', style: TextStyle(fontSize: 10, color: payment['claim']? Colors.red:Colors.black)),
                new Text('${time.hour~/10}${time.hour%10}:${time.minute~/10}${time.minute%10}:${time.second~/10}${time.second%10}', style: TextStyle(fontSize: 12, color: Colors.grey))
              ],
            ),
            new Expanded(
              child: Text('Paid \$${payment['amount']}', textAlign: TextAlign.right,),
            )
          ],
        ),
      ));
      contents.add(Divider());
    });
    if(contents.length == 0){
      contents.add(Center(child: Text('No payment be recorded'),));
    }
    contents.add(new Row(
      children: <Widget>[
        new Expanded(
          child: FlatButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: Text('BACK'),
          ),
        )
      ],
    ));
    return SimpleDialog(
      contentPadding: EdgeInsets.fromLTRB(0.0, 12.0, 0, 0.0),
      title: Center(child: Text('DETAIL'),),
      children: contents,
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    List<Widget> rightColumn = <Widget>[
      Text('${data['value']['pay']}%', style: TextStyle(color: getColor(data['value']['state']), fontSize: 18),),
      Text('${data['value']['state']}', style: TextStyle(color: getColor(data['value']['state'])),)
    ];
    if(liability && data['value']['state']=='ONGOING'){
      rightColumn.add(new Padding(
        padding: EdgeInsets.only(left: 2, right: 2),
        child: OutlineButton(
          borderSide: BorderSide(color: getColor(data['value']['state'])),
          color: getColor(data['value']['state']),
          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(15.0)),
          child: Text('PAY', style: TextStyle(color: getColor(data['value']['state']))),
          onPressed: (){
            showDialog(
              context: context,
              builder: (BuildContext context){
                return paymentDialog(context);
              }
            );
          },
        ),
      ));
    }else{
      rightColumn.add(new Padding(
        padding: EdgeInsets.only(left: 2, right: 2),
        child: OutlineButton(
          borderSide: BorderSide(color: getColor(data['value']['state'])),
          color: getColor(data['value']['state']),
          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(15.0)),
          child: Text('DETAIL', style: TextStyle(color: getColor(data['value']['state']))),
          onPressed: (){
            showDialog(
                context: context,
                builder: (BuildContext context){
                  return detailDialog(context);
                }
            );
          },
        ),
      ));
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 120,
      padding: EdgeInsets.only(left: 0, right: 0),
      child: new Card(
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: liability? data['value']['creditor']=='WorldBank'? CircleAvatar(radius: 30, child: Text('W'),):IdentityImage(size: 60, hash: tradeManager.nationList[data['value']['creditor']]['hash']):IdentityImage(size: 60, hash: tradeManager.nationList[data['value']['debtor']]['hash'],),
            ),
            Expanded(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Debt ${liability? (data['value']['creditor']=='WorldBank'?'to\nWorld Bank':'to\n'+tradeManager.nationList[data['value']['creditor']]['name']):'from\n'+tradeManager.nationList[data['value']['debtor']]['name']}', style: TextStyle(fontSize: 16),),
                  Text('Amount : ${data['value']['amount']}'),
                  Text('Total Interest : ${data['value']['interest']}%'),
                  Text('End At : Session ${data['value']['endSession']}', style: TextStyle(fontWeight: FontWeight.w700),),
                  Text('ID-${data['key']}', style: TextStyle(fontSize: 10, color: Colors.grey),)
                ],
              ),
            ),
            Container(
              width: 88,
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: rightColumn,
              ),
            )
          ],
        ),
      ),
    );
  }

}


class LoanPage extends StatefulWidget {
  LoanPage({Key key, this.currentUser, this.auth, this.nation, this.tradeManager}) : super(key: key);

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
  StreamSubscription<bool> change;
  //var orderList = <DataSnapshot>[];

  @override
  _LoanPageState createState() => new _LoanPageState();
}

class _LoanPageState extends State<LoanPage> with SingleTickerProviderStateMixin<LoanPage>, AutomaticKeepAliveClientMixin<LoanPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  _LoanPageState({Key key});
  DatabaseReference _orderRef;
  bool loading = true;
  DatabaseReference data;

  TabController _tabController;
  static const _tabs = <Tab>[
    Tab(child: Text('ONGOING\nLOAN', textAlign: TextAlign.center,),),
    Tab(child: Text('LOAN\nHISTORY', textAlign: TextAlign.center,),),
    Tab(text: 'DEBTOR',)
  ];
  List<Widget>_tabPages;

  Map<String, dynamic> debts = {};
  Map<String, dynamic> credits = {};
  List<Map<String, dynamic>> ongoingDebt = [];
  List<Map<String, dynamic>> historyDebt = [];
  List<Map<String, dynamic>> creditsList = [];

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    if(widget.change == null){
      widget.change = widget.nation.loanDataRefresh.listen((data){
        //getLoanData();
      });
    }else{
      widget.change.resume();
    }
    loading = true;
    _tabPages = <Widget>[
      ongoingLoan(),
      historyLoan(),
      creditLoan()
    ];
    _tabController = TabController(length: _tabs.length, vsync: this);
    print('init LoanPage');
    Query debt = FirebaseDatabase.instance.reference().child('loan/loanData').orderByChild('debtor').equalTo(widget.currentUser.uid);
    debt.onChildAdded.listen((Event event){
      print('detect debt');
      debts[event.snapshot.key] = event.snapshot.value;
      setState(() {});
    });
    debt.onChildChanged.listen((Event event){
      debts[event.snapshot.key] = event.snapshot.value;
      setState(() {});//
    });
    debt.onChildRemoved.listen((Event event){
      debts.remove(event.snapshot.key);
      setState(() {});
    });
    Query credit = FirebaseDatabase.instance.reference().child('loan/loanData').orderByChild('creditor').equalTo(widget.currentUser.uid);
    credit.onChildAdded.listen((Event event){
      credits[event.snapshot.key] = event.snapshot.value;
      setState(() {});
    });
    credit.onChildChanged.listen((Event event){
      credits[event.snapshot.key] = event.snapshot.value;
      setState(() {});//
    });
    credit.onChildRemoved.listen((Event event){
      credits.remove(event.snapshot.key);
      setState(() {});
    });
  }

  void getLoanData(){
    print('get');
    ongoingDebt = [];
    historyDebt = [];
    creditsList = [];
    debts.forEach((k, v){
      if(v['state'] == 'ONGOING' || v['state'] == 'QUEUE'){
        bool insert = false;
        for(int i = 0; i < ongoingDebt.length; i++){
          if(v['state'] == 'QUEUE'){
            ongoingDebt.insert(0, { 'key': k, 'value': v });
            insert = true;
            break;
          }
          if(ongoingDebt[i]['value']['endSession'] > v['endSession']){
            ongoingDebt.insert(i, { 'key': k, 'value': v });
            insert = true;
            break;
          }
        }
        if(!insert){
          ongoingDebt.add({ 'key': k, 'value': v });
        }
      }else{
        bool insert = false;
        for(int i = 0; i < historyDebt.length; i++){
          if(historyDebt[i]['value']['ftimestamp'] < v['ftimestamp']){
            historyDebt.insert(i, { 'key': k, 'value': v });
            insert = true;
            break;
          }
        }
        if(!insert){
          historyDebt.add({ 'key': k, 'value': v });
        }
      }
    });
    credits.forEach((k, v){
      bool insert = false;
      for(int i = 0; i < creditsList.length; i++){
        if(creditsList[i]['value']['timestamp'] < v['timestamp']){
          creditsList.insert(i, { 'key': k, 'value': v });
          insert = true;
          break;
        }
      }
      if(!insert){
        creditsList.add({ 'key': k, 'value': v });
      }
    });
    print('debts list ' + ongoingDebt.toString());
  }

  @override
  bool get wantKeepAlive => true;

  Widget ongoingLoan(){
    if(ongoingDebt.length == 0){
      return new Center(
        child: Text('Any ongoing loan will be shown here', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),),
      );
    }
    return new ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      padding: const EdgeInsets.all(10.0),
      itemCount: ongoingDebt.length,
      itemBuilder: (BuildContext context, int index){
        return new ListCard(liability: true, data: ongoingDebt[index], tradeManager: widget.tradeManager, nation: widget.nation,);
        //return new TradeCard(resource: widget.nation.master.resourcesOrder[index], imgPath: widget.nation.master.resources[widget.nation.master.resourcesOrder[index]]['img'], tradeManager: widget.tradeManager, nation: widget.nation,);
      },
    );
  }

  Widget historyLoan(){
    if(historyDebt.length == 0){
      return new Container(
        color: Colors.white,
        child: new Center(
          child: Text('Any loan history will be shown here', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w800, color: Colors.grey.shade800),),
        ),
      );
    }
    return new Scaffold(
      body: new ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        padding: const EdgeInsets.all(10.0),
        itemCount: historyDebt.length,
        itemBuilder: (BuildContext context, int index){
          return new ListCard(liability: true, data: historyDebt[index], tradeManager: widget.tradeManager, nation: widget.nation,);
        //return new TradeCard(resource: widget.nation.master.resourcesOrder[index], imgPath: widget.nation.master.resources[widget.nation.master.resourcesOrder[index]]['img'], tradeManager: widget.tradeManager, nation: widget.nation,);
        },
      ),
    );
    //return new PrivateTrade(nation: widget.nation, tradeManager: widget.tradeManager, currentUser: widget.currentUser,);
  }

  Widget creditLoan(){
    if(creditsList.length == 0){
      return new Center(
        child: Text('Any loan that given to others will be shown here', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white),),
      );
    }
    return new ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      padding: const EdgeInsets.all(10.0),
      itemCount: creditsList.length,
      itemBuilder: (BuildContext context, int index){
        return new ListCard(liability: false, data: creditsList[index], tradeManager: widget.tradeManager, nation: widget.nation,);
        //return new TradeCard(resource: widget.nation.master.resourcesOrder[index], imgPath: widget.nation.master.resources[widget.nation.master.resourcesOrder[index]]['img'], tradeManager: widget.tradeManager, nation: widget.nation,);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    getLoanData();
    super.build(context);
    return new Scaffold(
      appBar: new AppBar(
        title: Text('Loan'),
      ),
      body: new Container(
        decoration: BoxDecoration(color: Colors.grey.shade800),
        child: TabBarView(
          children: <Widget>[
            ongoingLoan(),
            historyLoan(),
            creditLoan()
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