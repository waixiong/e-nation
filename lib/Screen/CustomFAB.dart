import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity/connectivity.dart';
import 'dart:async';

import 'package:e_nation/Screen/HomePage.dart';
import 'package:e_nation/Screen/LoginPage.dart';
import 'package:e_nation/Logic/Nation.dart';
import 'package:e_nation/Logic/TradeManager.dart';
import 'package:e_nation/Screen/TradePage.dart';
import 'package:e_nation/Screen/Govern.dart';
import 'package:e_nation/Screen/StatPage.dart';
import 'package:e_nation/Screen/Loading.dart';
import 'package:e_nation/Screen/identityImage.dart';
import 'package:e_nation/Screen/CreateNation.dart';
import 'package:e_nation/Screen/TradeHistory.dart';
import 'package:e_nation/Screen/NewsInfo.dart';
import 'package:e_nation/Screen/Loan.dart';
import 'package:e_nation/Screen/Notify.dart';
import 'package:e_nation/Screen/Map.dart';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

import 'package:package_info/package_info.dart';
import 'package:e_nation/Logic/Package.dart';

enum Page {
  HOME, TRADE, GOVERN, STAT
}

class CustomFAB extends StatefulWidget {
  //final Function() onPressed;
  //final String tooltip;
  //final IconData icon;
  FirebaseAuth auth;
  FirebaseUser currentUser;
  final String title;
  StreamSubscription<bool> fabChange;

  CustomFAB({Key key, this.title, this.currentUser, this.auth});

  @override
  _CustomFABState createState() => _CustomFABState();
}

class _CustomFABState extends State<CustomFAB>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _homeColor;
  Animation<Color> _tradeColor;
  Animation<Color> _governColor;
  Animation<Color> _statColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButtonUp;
  Animation<double> _translateButtonDown;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;

  Color customBlue = Color.fromARGB(255, 66, 156, 234);
  Color customGreen = Color.fromARGB(255, 126, 207, 188);
  Color customRed = Color.fromARGB(255, 233, 135, 124);
  Color customYellow = Color.fromARGB(255, 252, 214, 133);

  Nation nation = new Nation(name: 'NATION', human: 0);
  bool created = true;
  TradeManager tradeManager;

  PageController _pageController;
  int p = 0;
  Page page = Page.HOME;
  HomePage homePage;
  TradePage tradePage;
  GovernPage governPage;
  StatPage statPage;
  TradeHistory tradeHistory;
  NewsInfo newsInfo;
  LoanPage loanPage;

  NotifyWidget notifyWidget;
  List<Widget> _stackList;
  
  bool onLoading = false;
  Widget fabLoading = new Container(
    color: Color.fromARGB(128, 0, 0, 0),
    child: NYESLoading(),
  );
  
  StreamSubscription<Notify> notification;

  getDir() async {
    IdentityPhoto.appDir = await getApplicationDocumentsDirectory();
    //IdentityPhoto.tempDir = await getTemporaryDirectory();
    IdentityPhoto.cache = await CacheManager.getInstance();
  }

  @override
  initState() {
    getDir();
    tradeManager = new TradeManager(currentUser: widget.currentUser);
    nation.start(widget.currentUser);
    tradeManager.initialize();
    homePage = new HomePage(currentUser: widget.currentUser, auth: widget.auth, nation: nation,);
    tradePage = new TradePage(currentUser: widget.currentUser, auth: widget.auth, nation: nation, tradeManager: tradeManager,);
    governPage = new GovernPage(currentUser: widget.currentUser, auth: widget.auth, nation: nation,);
    statPage = new StatPage(currentUser: widget.currentUser, auth: widget.auth, nation: nation,);

    tradeHistory = new TradeHistory(nation: nation, tradeManager: tradeManager,);
    //newsInfo = new NewsInfo(nation: nation,);
    loanPage = new LoanPage(nation: nation, currentUser: widget.currentUser, auth: widget.auth, tradeManager: tradeManager,);

    _pageController = PageController(
      initialPage: p,
      keepPage: true
    );
    notifyWidget = new NotifyWidget(nation: nation, tradeManager: tradeManager,);
//    PageView pageView = new PageView(
//      physics: new NeverScrollableScrollPhysics(),
//      controller: _pageController,
//      children: <Widget>[
//        homePage,
//        tradePage,
//        governPage,
//        statPage
//      ],
//    );
//    _stackList = [];
//    _stackList.add(new Container(
//      decoration: BoxDecoration(color: Colors.white),
//      child: pageView,//_pageNow(),
//    ));
//    _stackList.add(notifyWidget);

    notification = nation.FABNotification.listen((Notify notify){
      //print('sending ${notify.dataSnapshot.key}');
      notifyWidget.setNotification(notify);
    });

//    if(widget.fabChange == null){
//      widget.fabChange = nation.FABRefresh.listen((b){
//        setState(() {});
//      });
//    }else{
//      widget.fabChange.resume();
//    }
    StreamSubscription<ConnectivityResult> subscription = new Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      // Got a new connectivity status!
      print('connect ${result.toString()}');
    });

//    DatabaseReference loading = FirebaseDatabase.instance.reference().child('loading');
//    loading.onValue.listen((Event event){
//      if(event.snapshot.value){
//        nation.pauseFire();
//        onLoading = event.snapshot.value;
//        showDialog(
//          context: context,
//          barrierDismissible: false,
//          builder: (BuildContext context){
//            return Loading();
//          }
//        );
//      }else{
//        if(onLoading){
//          nation.resumeFire();
//          Navigator.pop(context);
//          onLoading = event.snapshot.value;
//        }
//      }
//    });
    DatabaseReference nations = FirebaseDatabase.instance.reference().child('idToName');
    nations.onChildAdded.listen((event){
      tradeManager.nationList[event.snapshot.key] = event.snapshot.value;
      if(event.snapshot.key == widget.currentUser.uid){
        setState(() {});
      }
    });

    _animationController =
    AnimationController(vsync: this, duration: Duration(milliseconds: 500))
      ..addListener(() {
        setState(() {});
      });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _homeColor = ColorTween(
      begin: Colors.grey.shade600,
      end: customYellow,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _tradeColor = ColorTween(
      begin: Colors.grey.shade600,
      end: customRed,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _governColor = ColorTween(
      begin: Colors.grey.shade600,
      end: customGreen,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _statColor = ColorTween(
      begin: Colors.grey.shade600,
      end: customBlue,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _translateButtonUp = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
    _translateButtonDown = Tween<double>(
      begin: 0,
      end: 280,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
    super.initState();
  }

  @override
  dispose() {
    //widget.fabChange.pause();
    nation.cancelFire();
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  Widget statistic() {
    return Transform(
      transform: Matrix4.translationValues(
        0.0,
        -70 * p + _translateButtonUp.value * (3-p),
        0.0,
      ),
      child: Container(
        child: FloatingActionButton(
          heroTag: '4',
          backgroundColor: page == Page.STAT ? _statColor.value : customBlue,
          onPressed: page == Page.STAT ? animate : (){ setState(() {
            page = Page.STAT;
            p = 3;
            //_pageController.jumpToPage(p);
          }); animate(); print('Stat'); },
          tooltip: 'Statistic',
          child: page == Page.STAT ? AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _animateIcon,
          ) : Icon(Icons.show_chart),
        ),
      ),
    );
  }

  Widget govern() {
    return Transform(
      transform: Matrix4.translationValues(
        0.0,
        -70 * p + _translateButtonUp.value * ((2-p)>=0 ? (2-p):(6-p)) + ((2-p)<0 ? _translateButtonDown.value:0),
        0.0,
      ),
      child: Container(
        child: FloatingActionButton(
          heroTag: '3',
          backgroundColor: page == Page.GOVERN? _governColor.value : customGreen,
          onPressed: page == Page.GOVERN? animate : (){ setState(() {
            page = Page.GOVERN;
            p = 2;
            //_pageController.jumpToPage(p);
          }); animate(); print('Govern'); },
          tooltip: 'Govern',
          child: page == Page.GOVERN ? AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _animateIcon,
          ) : Icon(Icons.account_balance),
        ),
      ),
    );
  }

  Widget trade() {
    return Transform(
      transform: Matrix4.translationValues(
        0.0,
        -70 * p + _translateButtonUp.value * ((1-p)>=0 ? (1-p):(5-p)) + ((1-p)<0 ? _translateButtonDown.value:0),
        0.0,
      ),
      child: Container(
        child: FloatingActionButton(
          heroTag: '2',
          backgroundColor: page == Page.TRADE ? _tradeColor.value : customRed,
          onPressed: page == Page.TRADE ? animate : (){ setState(() {
            page = Page.TRADE;
            p = 1;
            //_pageController.jumpToPage(p);
          }); animate(); print('Trade'); },
          tooltip: 'Trade',
          child: page == Page.TRADE ? AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _animateIcon,
          ) : Icon(Icons.compare_arrows),
        ),
      ),
    );
  }

  Widget home() {
    return Transform(
      transform: Matrix4.translationValues(
        0.0,
        -70 * p + _translateButtonUp.value * ((-p)>=0 ? (-p):(4-p)) + ((-p)<0 ? _translateButtonDown.value:0),
        0.0,
      ),
      child: Container(
        child: FloatingActionButton(
          heroTag: '1',
          backgroundColor: page == Page.HOME ? _homeColor.value : customYellow,
          onPressed: page == Page.HOME ? animate : (){ setState(() {
            page = Page.HOME;
            p = 0;
            //_pageController.jumpToPage(p);
          }); animate(); print('Home'); },
          tooltip: 'Produce',
          child: page == Page.HOME ? AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _animateIcon,
          ) : Icon(Icons.home),
        ),
      ),
    );
  }

  Widget identity(){
    //print('load images');
    Widget defaultImage = new IdentityImage(size: 72, hash: 'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF');
    return tradeManager.nationList.containsKey(widget.currentUser.uid)?
    IdentityPhoto.fromUID(size: 72, uid: widget.currentUser.uid, tradeManager: tradeManager)
        : defaultImage;
  }

//  Deprecated
//  Widget _pageNow(){
//    if(page == Page.HOME)
//      return homePage;
//    else if(page == Page.TRADE)
//      return tradePage;
//    else if(page == Page.GOVERN)
//      return governPage;
//    else
//      return statPage;
//  }

  @override
  Widget build(BuildContext context) {
    //print('STACK LENGTH : ${_stackList.length.toString()}');
    FirebaseDatabase.instance.reference().child('users/${widget.currentUser.uid}/create').once().then((DataSnapshot snap){
      if(!snap.value && created){
        created = false;
        nation.created = false;
        Navigator.push(context, new MaterialPageRoute(builder: (context) => new CreateNation(nation: nation))).then((value){
          created = true;
        });
      }
    });
    List<Widget> _buttonList;
    if(page == Page.HOME)
      _buttonList = <Widget>[statistic(), govern(), trade(), home()];
    else if(page == Page.TRADE)
      _buttonList = <Widget>[home(), statistic(), govern(), trade()];
    else if(page == Page.GOVERN)
      _buttonList = <Widget>[trade(), home(), statistic(), govern()];
    else
      _buttonList = <Widget>[govern(), trade(), home(), statistic()];

    PageView pageView = new PageView(
      physics: new NeverScrollableScrollPhysics(),
      controller: _pageController,
      children: <Widget>[
        homePage,
        tradePage,
        governPage,
        statPage
      ],
    );
    IndexedStack indexedStack = new IndexedStack(
      index: p,
      children: <Widget>[
        homePage,
        tradePage,
        governPage,
        statPage
      ],
    );
    _stackList = [];
    _stackList.add(new Container(
      decoration: BoxDecoration(color: Colors.white),
      child: indexedStack,//_pageNow(),
    ));
    _stackList.add(notifyWidget);
    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      key: _scaffoldKey,
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title, style: new TextStyle(),),
        centerTitle: true,
        leading: new IconButton(
          icon: new Icon(Icons.person),
          tooltip: 'Profile',
          onPressed: () { _scaffoldKey.currentState.openDrawer(); },
        ),
        //automaticallyImplyLeading : false,
      ),
      drawer: Drawer(
        child: Column(
          //padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: new Column(
                children: <Widget>[
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Padding(
                        padding: EdgeInsets.only(left: 2, right: 2),
                        child: new Container(
                          width: 30, height: 30,
                          decoration: BoxDecoration(color: customBlue, shape: BoxShape.circle),
                          child: new Center(
                            child: new Text('N', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white), textAlign: TextAlign.center),
                          ),
                        ),
                      ),
                      new Padding(
                        padding: EdgeInsets.only(left: 2, right: 2),
                        child: new Container(
                          width: 30, height: 30,
                          decoration: BoxDecoration(color: customGreen, shape: BoxShape.circle),
                          child: new Center(
                            child: new Text('Y', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white), textAlign: TextAlign.center),
                          ),
                        ),
                      ),
                      new Padding(
                        padding: EdgeInsets.only(left: 2, right: 2),
                        child: new Container(
                          width: 30, height: 30,
                          decoration: BoxDecoration(color: customRed, shape: BoxShape.circle),
                          child: new Center(
                            child: new Text('E', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white), textAlign: TextAlign.center),
                          ),
                        ),
                      ),
                      new Padding(
                        padding: EdgeInsets.only(left: 2, right: 2),
                        child: new Container(
                          width: 30, height: 30,
                          decoration: BoxDecoration(color: customYellow, shape: BoxShape.circle),
                          child: new Center(
                            child: new Text('S', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white), textAlign: TextAlign.center),
                          ),
                        ),
                      )
                    ],
                  ),
                  new Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 10),
                    child: identity(),
                  ),
                  new Text('${tradeManager.nationList.containsKey(widget.currentUser.uid)? tradeManager.nationList[widget.currentUser.uid]['name']:'NATION_NAME'}', style: TextStyle(color: Colors.white),)
                ],
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
            ),
            ListTile(
              title: new Row(
                children: <Widget>[
                  Container(
                    width: 40,
                    child: new Icon(Icons.repeat, size: 24,),
                  ),
                  new Text('Trade History')
                ],
              ),
              onTap: (){
                Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => tradeHistory));
              },
            ),
            ListTile(
              title: new Row(
                children: <Widget>[
                  Container(
                    width: 40,
                    child: new Icon(Icons.info, size: 24,),
                  ),
                  new Text('Info')
                ],
              ),
              onTap: (){
                Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new NewsInfo(nation: nation,)));
              },
            ),
            ListTile(
              title: new Row(
                children: <Widget>[
                  Container(
                    width: 40,
                    child: new Icon(Icons.monetization_on, size: 24,),
                  ),
                  new Text('Loan')
                ],
              ),
              onTap: (){
                Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => loanPage));
              },
            ),
            ListTile(
              title: new Row(
                children: <Widget>[
                  Container(
                    width: 40,
                    child: new Icon(Icons.map, size: 24,),
                  ),
                  new Text('Map')
                ],
              ),
              onTap: (){
                print('Map will be shown');
                Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => new Maps(tradeManager: tradeManager, nation: nation,)));
                //Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) => loanPage));
              },
            ),
            ListTile(
              title: Text('LOGOUT'),
              onTap: () {
                nation.cancelFire();
                widget.auth.signOut();
                Navigator.pushReplacement(context, new MaterialPageRoute(builder: (BuildContext context) => new LoginPage()));
              },
            ),
            Expanded(
              child: new Center(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 80,
                      child: Image.asset('Assets/BuiltWithFirebase.png', package: 'e_nation', fit: BoxFit.fitHeight,),
                    ),
                    Text('E-Nation v${Package.packageInfo.version}', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w300),)
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      body: new StreamBuilder(
        stream: nation.FABRefresh,
        builder: (BuildContext context, AsyncSnapshot<bool> snap){
          if(!snap.hasData){
            //if(!onLoading) {
            //  onLoading = false;
              if(_stackList.length > 1){
                _stackList.insert(1, fabLoading);
              }else{
                _stackList.add(fabLoading);
              }
            //}
          }else{
            if(!snap.data){
              //if(!onLoading) {
              //  onLoading = false;
                if(_stackList.length > 1){
                  _stackList.insert(1, fabLoading);
                }else{
                  _stackList.add(fabLoading);
                }
              //}
            }else{
              //onLoading = true;
              if(_stackList.length > 1){
                if(_stackList[1] == fabLoading){
                  _stackList.removeAt(1);
                }
              }
            }
          }
          return new Stack(
            children: _stackList,
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: _buttonList,
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
