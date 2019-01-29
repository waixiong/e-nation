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