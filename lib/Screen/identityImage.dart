import 'package:flutter/material.dart';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
//import 'package:firebase_storage/firebase_storage.dart';
//import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_nation/Logic/TradeManager.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

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

Future<void> fromCachetoDir(String imageUrl, File imgFile) async {
  //print('IDENTITY : find cache');
  final file = await IdentityPhoto.cache.getFile(imageUrl);
  //print('IDENTITY : cache path -- '+file.path);
  //print('IDENTITY : direc path -- '+imgFile.path);
  bool inCache = await file.exists();
  //print('IDENTITY : cache ${inCache?'':'not'} found');
  if(inCache){
    List<int> bytes = await file.readAsBytes();
    imgFile = await imgFile.create(recursive: true);
    imgFile.writeAsBytesSync(bytes);
    //print('IDENTITY : write completed');
  }
}

class IdentityPhoto extends StatelessWidget{
  IdentityPhoto({Key key, this.size, this.photo});

  double size;
  Widget photo;
  static Directory appDir;
  static Directory tempDir;
  static CacheManager cache;

  static IdentityPhoto fromUID({double size, String uid, TradeManager tradeManager}){
    if(tradeManager.nationList[uid]['url'] != null) {
      //;
      CachedNetworkImageProvider p = new CachedNetworkImageProvider(tradeManager.nationList[uid]['url']);
      return new IdentityPhoto(
        size: size,
        photo: new FutureBuilder<Directory>(
          future: getApplicationDocumentsDirectory(),
          builder: (BuildContext context, AsyncSnapshot<Directory> snapshot){
            Widget defaultImage = new IdentityImage(size: size, hash: tradeManager.nationList[uid]['hash'],);
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.active:
              case ConnectionState.waiting:
                return defaultImage;
              case ConnectionState.done:
                if (snapshot.hasError)
                  return defaultImage;
                File imgFile = new File(snapshot.data.path + '/profileImg/${uid}/${tradeManager.nationList[uid]['hash']}');
                if(!imgFile.existsSync()) {
                  fromCachetoDir(tradeManager.nationList[uid]['url'], imgFile);
                  return new CachedNetworkImage(
                    imageUrl: tradeManager.nationList[uid]['url'],
                    fit: BoxFit.cover,
                    placeholder: new Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        new IdentityImage(
                            size: size, hash: tradeManager.nationList[uid]['hash']),
                        Container(
                          color: Color.fromARGB(128, 0, 0, 0),
                          child: Center(
                            child: Container(
                              height: size/3,
                              width: size/3,
                              child: CircularProgressIndicator(strokeWidth: size * 0.08>4? 4:size * 0.08,),
                            ),
                          ),
                        )
                      ],
                    ),
                    errorWidget: new IdentityImage(size: size, hash: tradeManager.nationList[uid]['hash']),
                  );
                }else {
                  //print('IDENTITY : found directory');
                  return Image.file(imgFile);
                }
            }
          },
        ),
      );
    }else{
      return new IdentityPhoto(
        size: size,
        photo: new IdentityImage(size: size, hash: tradeManager.nationList[uid]['hash'],),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new SizedBox(
      width: size,
      height: size,
      child: new ClipOval(
        clipper: new CircleRect(),
        child: photo,//Image
      ),
    );
  }
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