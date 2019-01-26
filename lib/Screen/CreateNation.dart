import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:e_nation/Logic/Nation.dart';
import 'package:e_nation/Screen/identityImage.dart';
import 'package:e_nation/Screen/Loading.dart';

import 'dart:io';
//import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:path_provider/path_provider.dart';

class CreateNation extends StatefulWidget{
  CreateNation({Key key, this.nation}) : super(key: key);

  Nation nation;

  @override
  _CreateNationState createState() => new _CreateNationState();
}

class _CreateNationState extends State<CreateNation>{
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String nationName;
  String nationHash;
  TextEditingController textController = TextEditingController();
  final _textKey = GlobalKey<FormState>();
  int _selectedPopulationIndex;
  List<int> population = <int>[5000, 6000, 7000, 8000, 9000, 10000];

  File _image;
  StorageUploadTask uploadTask;
  String _imageUrl;
  bool _isLoading = false;
  double _progress = 0.0;

  @override
  void initState(){
    nationName = '';
    nationHash = identityGenerate();
    _selectedPopulationIndex = 0;
  }

  Future<void> getImage(ImageSource source) async {
    var image = await ImagePicker.pickImage(source: source, maxWidth: 1000, maxHeight: 1000,);
    print('IMAGE FROM: '+image.path);
    if(image != null){
      print('before : '+image.lengthSync().toString());
      ImageProperties properties = await FlutterNativeImage.getImageProperties(image.path);
      if(properties.width > 360 && properties.height > 360){
        image = await FlutterNativeImage.compressImage(
          image.path,
          quality: 80,
          targetWidth: properties.width < properties.height? 360 : (properties.width * 360 ~/ properties.height),
          targetHeight: properties.height > properties.width? (properties.height * 360 ~/ properties.width) : 360
        );
      }
      properties = await FlutterNativeImage.getImageProperties(image.path);
      int size = properties.width <= properties.height? properties.width : properties.height;
      image = await FlutterNativeImage.cropImage(image.path, (properties.width~/2 - (size/2).round()) , (properties.height~/2 - (size/2).round()), size, size);
      print('processed : '+image.lengthSync().toString());
      if(uploadTask != null){
        uploadTask.cancel();
      }
      setState(() {
        _image = image;
      });
      _uploadFile().then((snapshot){
        _isLoading = false;
      });
    }
  }

  Future<StorageTaskSnapshot> _uploadFile() async {
    final StorageReference ref = FirebaseStorage.instance.ref().child('photo').child('${widget.nation.currentUser.uid}/${nationHash}');
    print('Uploading...');
    StorageUploadTask uploadTask = ref.putFile(
      _image,
      StorageMetadata(
        contentLanguage: 'en',
        customMetadata: <String, String>{'profile': 'test'},
      ),
    );
    uploadTask.events.listen((event) async {
      setState(() {
        _isLoading = true;
        _progress = event.snapshot.bytesTransferred.toDouble() / event.snapshot.totalByteCount.toDouble();
      });
      print(_progress.toString());
      if(_progress >= 1.0){
        _imageUrl = await ref.getDownloadURL();
        setState(() { _isLoading = false; });
      }
    });
//    StorageTaskSnapshot s = await uploadTask.onComplete;
//    _imageUrl = await ref.getDownloadURL();
//    setState(() { _isLoading = false; });
//    return s;
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
      key: _scaffoldKey,
      backgroundColor: Colors.grey.shade800,
      body: Center(
        child: SingleChildScrollView(
          child: new Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: new Column(
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
                  child: Text('Put your identity image', style: TextStyle(color: Colors.grey, fontSize: 16),),
                ),
                new Row(
                  children: <Widget>[
                    new Container(
                      width: MediaQuery.of(context).size.width*0.4,
                      height: MediaQuery.of(context).size.height*0.4,
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          new Container(
                            width: MediaQuery.of(context).size.width*0.4,
                            height: MediaQuery.of(context).size.width*0.4,
                            child: new Center(
                              child: new IdentityImage(size: MediaQuery.of(context).size.width*0.3, hash: nationHash,),
                            ),
                          ),
                          new FlatButton(
                            onPressed: (){
                              setState(() {
                                nationHash = identityGenerate();
                              });
                            },
                            child: Text('DON\'T LIKE IT? CHANGE IT', style: TextStyle(color: Colors.grey), textAlign: TextAlign.center,),
                          )
                        ],
                      ),
                    ),
                    new Container(
                      width: MediaQuery.of(context).size.width*0.2,
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          new Padding(
                            padding: EdgeInsets.only(bottom: 5.0),
                            child: new FloatingActionButton(
                              heroTag: ImageSource.gallery,
                              onPressed: (){ getImage(ImageSource.gallery); },
                              tooltip: 'Pick from gallery',
                              child: Icon(Icons.photo_library),
                            ),
                          ),
                          new Padding(
                            padding: EdgeInsets.only(top: 5.0),
                            child: new FloatingActionButton(
                              heroTag: ImageSource.camera,
                              onPressed: (){ getImage(ImageSource.camera); },
                              tooltip: 'Take a photo',
                              child: Icon(Icons.photo_camera),
                            ),
                          )
                        ],
                      ),
                    ),
                    new Container(
                      width: MediaQuery.of(context).size.width*0.4,
                      height: MediaQuery.of(context).size.height*0.4,
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          new Container(
                            width: MediaQuery.of(context).size.width*0.4,
                            height: MediaQuery.of(context).size.width*0.4,
                            child: new Center(
                              child: _image != null? new Stack(
                                fit: StackFit.expand,
                                children: <Widget>[
                                  new IdentityPhoto(size: MediaQuery.of(context).size.width*0.36, photo: Image.file(_image, fit: BoxFit.cover,),),
                                  CircularProgressIndicator(value: _progress, strokeWidth: 6.0, valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),)
                                ],
                              )
                                  : CircleAvatar(radius: MediaQuery.of(context).size.width*0.18, backgroundColor: Colors.grey, child: Text('Upload Your Image', textAlign: TextAlign.center, style: TextStyle(fontSize: 10),),),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
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
                      if(_image != null){
//                        _uploadFile().then((snapshot){
//                          //
//                        });
                        if(_progress >= 1){
                          widget.nation.initiatedNation(nationName, nationHash, population[_selectedPopulationIndex], _imageUrl).then((value) {
                            Navigator.pop(context);
                            if (value) {
                              Navigator.pop(context);
                            }
                          });
                        }else{
                          Navigator.pop(context);
                          print(_progress);
                          _scaffoldKey.currentState.hideCurrentSnackBar();
                          _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Waiting for image upload...',), duration: Duration(seconds: 4),));
                        }
                      }else{
                        widget.nation.initiatedNation(nationName, nationHash, population[_selectedPopulationIndex], null).then((value) {
                          Navigator.pop(context);
                          if (value) {
                            Navigator.pop(context);
                          }
                        });
                      }
                    }
                  },
                  child: Text('INITIATED NEW NATION'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
