import 'package:flutter/material.dart';
import 'dart:math';

String identityGenerate(){
  BigInt h = BigInt.from(Random.secure().nextInt(4294967296));
  h *= BigInt.from(Random.secure().nextInt(4294967296));
  h *= BigInt.from(Random.secure().nextInt(4294967296));
  h *= BigInt.from(Random.secure().nextInt(4294967296));
  String hash =  h.toRadixString(16);
  while(hash.length < 32){
    hash = '0' + hash;
  }
  return hash;
}

class IdentityImage extends StatelessWidget{
  IdentityImage({Key key, this.size, this.hash});

  double size;
  String hash;//128bit, 32chars

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    String first = hash.substring(0, 16);
    String second = hash.substring(16, 32);
    int firstA = int.parse(first.substring(0, 8), radix: 16);
    int firstB = int.parse(first.substring(8, 16), radix: 16);
    int secondA = int.parse(second.substring(0, 8), radix: 16);
    int secondB = int.parse(second.substring(8, 16), radix: 16);
    return new SizedBox(
      width: size,
      height: size,
      child: new ClipOval(
        clipper: new CircleRect(),
        child: new Stack(
          children: <Widget>[
            new CustomPaint(
              foregroundPainter: new MainColor(color: Color.fromARGB(255, int.parse(hash.substring(0, 2), radix: 16), int.parse(hash.substring(8, 10), radix: 16), int.parse(hash.substring(16, 18), radix: 16))),
            ),
            new Transform.rotate(
              angle: pi*(int.parse(hash.substring(28, 30), radix: 16)%64-32)/180,
              child: new CustomPaint(
                painter: new SecondColor(
                    color: Color.fromARGB(255, int.parse(hash.substring(2, 4), radix: 16), int.parse(hash.substring(10, 12), radix: 16), int.parse(hash.substring(18, 20), radix: 16)),
                    left: -((firstA ^ firstB) % 60 * (size/200)).toDouble(), top: -((firstA ^ firstB) % 60 * (size/200)).toDouble(), width: (30*size/200) + ((firstA & firstB)~/1000 % 200 * (size/200)), height: (30*size/200) + ((firstA & firstB)~/100000 % 200 * (size/200))
                ),
              ),
            ),
            new Transform.rotate(
              angle: pi*(int.parse(hash.substring(30, 32), radix: 16)%64-32)/180,
              child: new CustomPaint(
                painter: new SecondColor(
                    color: Color.fromARGB(255, int.parse(hash.substring(4, 6), radix: 16), int.parse(hash.substring(12, 14), radix: 16), int.parse(hash.substring(20, 22), radix: 16)),
                    left: size+((firstA ^ firstB) % 60 * (size/200)).toDouble(), top: size+((firstA ^ firstB) % 60 * (size/200)).toDouble(), width: -(30*size/200) - ((firstA & firstB)~/1000 % 200 * (size/200)), height: -(30*size/200) - ((firstA & firstB)~/100000 % 200 * (size/200))
                ),
              ),
            ),
            new Transform.rotate(
              angle: pi*(int.parse(hash.substring(25, 28), radix: 16)%360)/180,
              child: new CustomPaint(
                painter: new SecondColor(
                    color: Color.fromARGB(255, int.parse(hash.substring(4, 6), radix: 16), int.parse(hash.substring(12, 14), radix: 16), int.parse(hash.substring(20, 22), radix: 16)),
                    left: size*0.4 +((firstA ^ secondA) % 40 * (size/200)).toDouble(), top: size*0.4 +((firstB ^ secondB) % 40 * (size/200)).toDouble(), width: -size + ((firstA & secondB)~/1000 % 400 * (size/200)), height: -size + ((secondA & firstB)~/100000 % 400 * (size/200))
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MainColor extends CustomPainter{
  MainColor({this.color});

  Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    canvas.drawColor(color, BlendMode.src);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}

class SecondColor extends CustomPainter{
  SecondColor({this.color, this.left, this.top, this.width, this.height});

  Color color;
  double left;
  double top;
  double width;
  double height;

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    Paint paint = new Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;
    canvas.drawRect(new Rect.fromLTWH(left, top, width, height), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
  }
}

class CircleRect extends CustomClipper<Rect>{
  @override
  Rect getClip(Size size) {
    // TODO: implement getClip
    Rect rect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);
    return rect;
  }
  @override
  bool shouldReclip(CircleRect oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }
}

class RectangleRect extends CustomClipper<Rect>{
  RectangleRect({this.left, this.top, this.right, this.bottom});
  double left;
  double top;
  double right;
  double bottom;

  @override
  Rect getClip(Size size) {
    // TODO: implement getClip
    Rect rect = Rect.fromLTRB(left, top, right, bottom);
    return rect;
  }
  @override
  bool shouldReclip(CircleRect oldClipper) {
    // TODO: implement shouldReclip
    return false;
  }
}