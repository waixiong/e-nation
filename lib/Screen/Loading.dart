import 'package:flutter/material.dart';

class Loading extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Center(
      child: new SizedBox(
        height: 30,
        width: 30,
        child: CircularProgressIndicator(
          strokeWidth: 8.0,
        ),
      ),
    );
  }
}

class AuthLoading extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Center(
      child: new SizedBox(
        height: 50,
        width: 50,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.asset(
              'Assets/FirebaseAuthentication.png',
              package: 'e_nation',
            ),
            CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
              strokeWidth: 8,
            )
          ],
        ),
      ),
    );
  }
}

class NYESLoading extends StatefulWidget {
  NYESLoading();

  @override
  _NYESLoadingState createState() => _NYESLoadingState();
}

class _NYESLoadingState extends State<NYESLoading>
    with SingleTickerProviderStateMixin {
  Animation<double> animation_b;
  Animation<double> animation_g;
  Animation<double> animation_r;
  Animation<double> animation_y;
  AnimationController controller;

  Color customBlue = Color.fromARGB(255, 66, 156, 234);
  Color customGreen = Color.fromARGB(255, 126, 207, 188);
  Color customRed = Color.fromARGB(255, 233, 135, 124);
  Color customYellow = Color.fromARGB(255, 252, 214, 133);

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: Duration(milliseconds: 1200), vsync: this);

    animation_b = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 0.70, curve: Curves.linear),
      ),
    );
    animation_g = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.1, 0.80, curve: Curves.linear),
      ),
    );
    animation_r = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.2, 0.90, curve: Curves.linear),
      ),
    );
    animation_y = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.3, 1.00, curve: Curves.linear),
      ),
    );

    controller.addListener(() {
      setState(() {
        //print(animation_1.value);
      });
    });

    controller.repeat();
  }

  @override
  void dispose() {
    print('loading dispose');
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Firebase Amber : ${Colors.amber[400].red} ${Colors.amber[400].green} ${Colors.amber[400].blue}');
    return Container(
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
//          Opacity(
//            opacity: (animation_b.value <= 0.4 ? 2.5 * animation_b.value : (animation_b.value > 0.40 && animation_b.value <= 0.60) ? 1.0 : 2.5 - (2.5 * animation_b.value)),
//            child: new Padding(
//              padding: const EdgeInsets.only(right: 4.0, left: 4.0),
//              child: Dot(
//                color: customBlue,
//              ),
//            ),
//          ),
          new Transform.translate(
            offset: Offset(0.0, -30 * (animation_b.value <= 0.50 ? animation_b.value : 1.0 - animation_b.value),),
            child: new Padding(
              padding: const EdgeInsets.only(right: 4.0, left: 4.0),
              child: Dot(
                color: customBlue,
              ),
            ),
          ),
          new Transform.translate(
            offset: Offset(0.0, -30 * (animation_g.value <= 0.50 ? animation_g.value : 1.0 - animation_g.value),),
            child: new Padding(
              padding: const EdgeInsets.only(right: 4.0, left: 4.0),
              child: Dot(
                color: customGreen,
              ),
            ),
          ),
          new Transform.translate(
            offset: Offset(0.0, -30 * (animation_r.value <= 0.50 ? animation_r.value : 1.0 - animation_r.value),),
            child: new Padding(
              padding: const EdgeInsets.only(right: 4.0, left: 4.0),
              child: Dot(
                color: customRed,
              ),
            ),
          ),
          new Transform.translate(
            offset: Offset(0.0, -30 * (animation_y.value <= 0.50 ? animation_y.value : 1.0 - animation_y.value),),
            child: new Padding(
              padding: const EdgeInsets.only(right: 4.0, left: 4.0),
              child: Dot(
                color: customYellow,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class Dot extends StatelessWidget {
  final Color color;

  Dot({this.color});

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

class TradeExecuting extends StatefulWidget {
  TradeExecuting();

  @override
  _TradeExecutingState createState() => _TradeExecutingState();
}

class _TradeExecutingState extends State<TradeExecuting>
    with SingleTickerProviderStateMixin {
  Animation<double> animation_b;
  Animation<double> animation_g;
  Animation<double> animation_r;
  Animation<double> animation_y;
  AnimationController controller;

  Color FirebaseYellow = Colors.amber[400];

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: Duration(milliseconds: 1000), vsync: this);

    animation_b = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.00, 0.55, curve: Curves.linear),
      ),
    );
    animation_g = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.15, 0.70, curve: Curves.linear),
      ),
    );
    animation_r = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.30, 0.85, curve: Curves.linear),
      ),
    );
    animation_y = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.45, 1.00, curve: Curves.linear),
      ),
    );

    controller.addListener(() {
      setState(() {
        //print(animation_1.value);
      });
    });

    controller.repeat();
  }

  @override
  void dispose() {
    //print('loading dispose');
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Opacity(
            opacity: (animation_b.value <= 0.4 ? 2.5 * animation_b.value : (animation_b.value > 0.40 && animation_b.value <= 0.60) ? 1.0 : 2.5 - (2.5 * animation_b.value)),
            child: new Padding(
              padding: const EdgeInsets.only(right: 4.0, left: 4.0),
              child: Dot(
                color: FirebaseYellow,
              ),
            ),
          ),
          Opacity(
            opacity: (animation_b.value <= 0.4 ? 2.5 * animation_b.value : (animation_b.value > 0.40 && animation_b.value <= 0.60) ? 1.0 : 2.5 - (2.5 * animation_b.value)),
            child: new Padding(
              padding: const EdgeInsets.only(right: 4.0, left: 4.0),
              child: Dot(
                color: FirebaseYellow,
              ),
            ),
          ),
          Opacity(
            opacity: (animation_b.value <= 0.4 ? 2.5 * animation_b.value : (animation_b.value > 0.40 && animation_b.value <= 0.60) ? 1.0 : 2.5 - (2.5 * animation_b.value)),
            child: new Padding(
              padding: const EdgeInsets.only(right: 4.0, left: 4.0),
              child: Dot(
                color: FirebaseYellow,
              ),
            ),
          ),
          Opacity(
            opacity: (animation_b.value <= 0.4 ? 2.5 * animation_b.value : (animation_b.value > 0.40 && animation_b.value <= 0.60) ? 1.0 : 2.5 - (2.5 * animation_b.value)),
            child: new Padding(
              padding: const EdgeInsets.only(right: 4.0, left: 4.0),
              child: Dot(
                color: FirebaseYellow,
              ),
            ),
          ),
          new Padding(
            padding: const EdgeInsets.only(right: 4.0, left: 4.0),
            child: Container(
              height: 36,
              width: 36,
              child: Image.asset(
                'Assets/FirebaseRealtimeDatabase.png',//image
                package: 'e_nation',
                fit: BoxFit.fitWidth,
              ),
            ),
          )
        ],
      ),
    );
  }
}