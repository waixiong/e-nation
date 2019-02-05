import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class Master{

  List<String> foodList = <String>['Vegetable', 'Meat', 'Processed Vegetable', 'Processed Meat'];
  List<String> resourcesOrder = ['Wood', 'Sand', 'Steel', 'Rubber', 'Cotton',
  'Oil', 'Leather', 'Copper', 'Silver', 'Vegetable', 'Meat',
  'Car', 'Shirt', 'Processed Vegetable', 'Processed Meat', 'Solar Panel', 'Furniture',
  'Jewellery', 'Gloves', 'Bag', 'Gadget', 'Book'];
  Map resources = {
    'Wood': {
      'price': 5.0,
      'img': 'packages/e_nation/Assets/resources/wood.png',
      'happy': 5
    },
    'Sand': {
      'price': 5.0,
      'img': 'packages/e_nation/Assets/resources/Sand.png',
      'happy': 5
    },
    'Steel': {
      'price': 20.0,
      'img': 'packages/e_nation/Assets/resources/steel.png',
      'happy': 5
    },
    'Rubber': {
      'price': 4.0,
      'img': 'packages/e_nation/Assets/resources/Rubber.jpg',
      'happy': 4
    },
    'Cotton': {
      'price': 2.0,
      'img': 'packages/e_nation/Assets/resources/Cotton.png',
      'happy': 4
    },
    'Oil': {
      'price': 50.0,
      'img': 'packages/e_nation/Assets/resources/Oil.jpg',
      'happy': 4
    },
    'Leather': {
      'price': 15.00,
      'img': 'packages/e_nation/Assets/resources/Leather.png',
      'happy': 3
    },
    'Copper': {
      'price': 30.00,
      'img': 'packages/e_nation/Assets/resources/copper.png',
      'happy': 3
    },
    'Silver': {
      'price': 70.00,
      'img': 'packages/e_nation/Assets/resources/Silver.png',
      'happy': 3
    },
    'Vegetable': {
      'price': 3.00,
      'feed': 1,
      'img': 'packages/e_nation/Assets/resources/Vegetable.png',
      'happy': 0
    },
    'Meat': {
      'price': 5.00,
      'feed': 2,
      'img': 'packages/e_nation/Assets/resources/Meat.png',
      'happy': 0
    },
    /*'rawFood': {
      'price': 5.00,
      'feed': 2,
      'img': 'packages/e_nation/Assets/wood.png'
    },*/
    'Car': {
      'price': 6400.00,
      'img': 'packages/e_nation/Assets/resources/Car.png',
      'happy': 2
    },
    'Shirt': {
      'price': 28.00,
      'img': 'packages/e_nation/Assets/resources/shirt.png',
      'happy': 3
    },
    'Processed Vegetable': {
      'price': 15.0,
      'feed': 2,
      'img': 'packages/e_nation/Assets/resources/FoodVege.png',
      'happy': 1
    },
    'Processed Meat': {
      'price': 19.0,
      'feed': 3,
      'img': 'packages/e_nation/Assets/resources/FoodMeat.png',
      'happy': 1
    },
    'Solar Panel': {
      'price': 2500.0,
      'img': 'packages/e_nation/Assets/resources/SolarPanel.jpg',
      'happy': 1
    },
    'Furniture': {
      'price': 200.0,
      'img': 'packages/e_nation/Assets/resources/Furniture.png',
      'happy': 1
    },
    'Jewellery': {
      'price': 1350.0,
      'img': 'packages/e_nation/Assets/resources/Jewellery.png',
      'happy': 1
    },
    'Gloves': {
      'price': 20.0,
      'img': 'packages/e_nation/Assets/resources/Gloves.png',
      'happy': 2
    },
    'Bag': {
      'price': 150.0,
      'img': 'packages/e_nation/Assets/resources/Bag.png',
      'happy': 2
    },
    'Gadget': {
      'price': 1100.0,
      'img': 'packages/e_nation/Assets/resources/Gadget.jpg',
      'happy': 3
    },
    'Book': {
      'price': 30.0,
      'img': 'packages/e_nation/Assets/resources/Book.png',
      'happy': 2
    }
  };
  Map building = {
    'Wood': {
      'rate': {
        'base': 3.0,
        'upgrade': 1.5
      },
      'step': 10,
      'input':{
        'Money': 7.5
      },
      'upgrade' : [
        {'human': 2500, 'Wood': 2000, 'Sand': 2000, 'Steel': 500, 'Money': 10000},
        {'human': 2000, 'Wood': 5000, 'Sand': 5000, 'Steel': 1250, 'Money': 25000}
      ],
      'mortgageValue': [25000, 60000],
      'maxHuman': 1000,
      'img': 'Assets/building/logging.jpg'
    },
    'Sand': {
      'rate': {
        'base': 3.0,
        'upgrade': 1.5
      },
      'step': 10,
      'input':{
        'Money': 7.5
      },
      'upgrade' : [
        {'human': 2500, 'Wood': 2000, 'Sand': 2000, 'Steel': 500, 'Money': 10000},
        {'human': 2000, 'Wood': 5000, 'Sand': 5000, 'Steel': 1250, 'Money': 25000}
      ],
      'mortgageValue': [25000, 60000],
      'maxHuman': 1000,
      'img': 'Assets/building/quarry.jpg'
    },
    'Steel': {
      'rate': {
        'base': 2.0,
        'upgrade': 1.5
      },
      'step': 10,
      'input':{
        'Money': 15.0
      },
      'upgrade' : [
        {'human': 2500, 'Wood': 3000, 'Sand': 3000, 'Steel': 750, 'Money': 22500},
        {'human': 2000, 'Wood': 7500, 'Sand': 7500, 'Steel': 1875, 'Money': 40000}
      ],
      'mortgageValue': [45000, 90000],
      'maxHuman': 1000,
      'img': 'Assets/building/Steel.jpg'
    },
    'Rubber': {
      'rate': {
        'base': 3.0,
        'upgrade': 1.5
      },
      'step': 10,
      'input':{
        'Money': 5.0
      },
      'upgrade' : [
        {'human': 2500, 'Wood': 2000, 'Sand': 2000, 'Steel': 500, 'Money': 12000},
        {'human': 2000, 'Wood': 5000, 'Sand': 5000, 'Steel': 1250, 'Money': 35000}
      ],
      'mortgageValue': [27000, 70000],
      'maxHuman': 1000,
      'img': 'Assets/building/Rubber.jpg'
    },
    'Cotton': {
      'rate': {
        'base': 10.0,
        'upgrade': 4.25
      },
      'step': 20,
      'input':{
        'Money': 7.5
      },
      'upgrade' : [
        {'human': 2500, 'Wood': 2000, 'Sand': 2000, 'Steel': 350, 'Money': 25000},
        {'human': 2000, 'Wood': 5000, 'Sand': 5000, 'Steel': 1250, 'Money': 40000}
      ],
      'mortgageValue': [30000, 50000],
      'maxHuman': 1000,
      'img': 'Assets/building/Cotton.jpg'
    },
    'Oil': {
      'rate': {
        'base': 5.0,
        'upgrade': 1.2
      },
      'step': 5,
      'input':{
        'Money': 12.0
      },
      'upgrade' : [
        {'human': 2500, 'Wood': 2000, 'Sand': 2000, 'Steel': 3500, 'Money': 30000},
        {'human': 2000, 'Wood': 7500, 'Sand': 7500, 'Steel': 8750, 'Money': 50000}
      ],
      'mortgageValue': [75000, 160000],
      'maxHuman': 100,
      'img': 'Assets/building/Oil.jpg'
    },
    'Leather': {
      'rate': {
        'base': 1.5,
        'upgrade': 1.0
      },
      'step': 10,
      'input':{
        'Money': 12.0
      },
      'upgrade' : [
        {'human': 2500, 'Wood': 3000, 'Sand': 3000, 'Steel': 500, 'Money': 12000},
        {'human': 2000, 'Wood': 7500, 'Sand': 7500, 'Steel': 1250, 'Money': 30000}
      ],
      'mortgageValue': [30000, 75000],
      'maxHuman': 1000,
      'img': 'Assets/building/Leather.jpg'
    },
    'Copper': {
      'rate': {
        'base': 1.5,
        'upgrade': 0.5
      },
      'step': 10,
      'input':{
        'Money': 20.0
      },
      'upgrade' : [
        {'human': 2500, 'Wood': 3000, 'Sand': 2000, 'Steel': 2000, 'Money': 20000},
        {'human': 2500, 'Wood': 7500, 'Sand': 5000, 'Steel': 1250, 'Money': 40000}
      ],
      'mortgageValue': [50000, 85000],
      'maxHuman': 1000,
      'img': 'Assets/building/Copper.jpg'
    },
    'Silver': {
      'rate': {
        'base': 0.5,
        'upgrade': 0.2
      },
      'step': 10,
      'input':{
        'Money': 20.0
      },
      'upgrade' : [
        {'human': 2500, 'Wood': 2000, 'Sand': 2000, 'Steel': 1500, 'Money': 30000},
        {'human': 2000, 'Wood': 5000, 'Sand': 5000, 'Steel': 3750, 'Money': 50000}
      ],
      'mortgageValue': [60000, 110000],
      'maxHuman': 1000,
      'img': 'Assets/building/Silver.jpg'
    },
    'Vegetable': {
      'rate': {
        'base': 3,
        'upgrade': 1.0
      },
      'step': 10,
      'input':{
        'Money': 5.0
      },
      'upgrade' : [
        {'human': 2500, 'Wood': 2000, 'Sand': 4000, 'Steel': 500, 'Money': 10000},
        {'human': 2000, 'Wood': 5000, 'Sand': 10000, 'Steel': 1250, 'Money': 25000}
      ],
      'mortgageValue': [30000, 70000],
      'maxHuman': 1000,
      'img': 'Assets/building/agriculture.jpg'
    },
    'Meat': {
      'rate': {
        'base': 3,
        'upgrade': 0.9
      },
      'step': 10,
      'input':{
        'Money': 8.5
      },
      'upgrade' : [
        {'human': 2500, 'Wood': 2000, 'Sand': 4000, 'Steel': 500, 'Money': 15000},
        {'human': 2000, 'Wood': 5000, 'Sand': 10000, 'Steel': 1250, 'Money': 35000}
      ],
      'mortgageValue': [33000, 80000],
      'maxHuman': 1000,
      'img': 'Assets/building/Meat.jpg'
    },
    /*'rawFood': {
      'rate': {
        'base': 3,
        'upgrade': 0
      },
      'input':{
        'Money': 7.5
      },
      'upgrade' : [
        {'human': 2500, 'wood': 900, 'sand': 900, 'Steel': 1000, 'money': 4000000},
        {'human': 2000, 'wood': 700, 'sand': 700, 'Steel': 800, 'money': 3000000}
      ],
      'maxHuman': 1500,
      'img': 'Assets/logging.jpg'
    },*/
    'Car': {
      'rate': {
        'base': 0.22,
        'upgrade': 0
      },
      'step': 50,
      'input':{
        'Money': 750.0,
        'Steel': 20.0,
        'Sand': 50.0,
        'Rubber': 60.0,
        'Copper': 10.0
      },
      'upgrade' : [
        {'human': 2500, 'Wood': 6000, 'Sand': 6000, 'Steel': 6000, 'Money': 100000, 'Education': 3}
      ],
      'mortgageValue': [190000],
      'maxHuman': 500,
      'img': 'Assets/building/Car.jpg'
    },
    'Shirt': {
      'rate': {
        'base': 3.3,
        'upgrade': 0
      },
      'step': 10,
      'input':{
        'Money': 40.0,
        'Cotton': 40.0
      },
      'upgrade' : [
        {'human': 2500, 'Wood': 2000, 'Sand': 2000, 'Steel': 500, 'Money': 40000, 'Education': 1}
      ],
      'mortgageValue': [60000],
      'maxHuman': 1000,
      'img': 'Assets/building/Shirt.jpg'
    },
    /*'food': {
      'rate': {
        'base': 16,
        'upgrade': 0
      },
      'input':{
        'money': 10.5,
        'vege': 7.5,
        'meat': 6.0,
        'rawFood': 10.0,
        'oil': 16,
        'rubber': 1.8
      },
      'upgrade' : [
        {'human': 2500, 'steel': 1200, 'sand': 1500, 'money': 2500000},
        {'human': 2000, 'steel': 1000, 'sand': 1200, 'money': 2000000}
      ],
      'maxHuman': 500,
      'img': 'Assets/logging.jpg'
    },*/
    'Processed Vegetable': {
      'rate': {
        'base': 9.6,
        'upgrade': 0
      },
      'step': 10,
      'input':{
        'Money': 35.0,
        'Vegetable': 20.0,
        'Oil': 1.0,
        'Rubber': 5.0
      },
      'upgrade' : [
        {'human': 2500, 'Wood': 3000, 'Sand': 3000, 'Steel': 1000, 'Money': 45000, 'Education': 1}
      ],
      'mortgageValue': [70000],
      'maxHuman': 500,
      'img': 'Assets/building/FoodVege.jpg'
    },
    'Processed Meat': {
      'rate': {
        'base': 10,
        'upgrade': 0
      },
      'step': 10,
      'input':{
        'Money': 50.0,
        'Meat': 20.0,
        'Oil': 1.0,
        'Rubber': 5.0
      },
      'upgrade' : [
        {'human': 2500, 'Wood': 3000, 'Sand': 3000, 'Steel': 1000, 'Money': 60000, 'Education': 1}
      ],
      'mortgageValue': [80000],
      'maxHuman': 500,
      'img': 'Assets/building/FoodMeat.jpg'
    },
    'Solar Panel': {
      'rate': {
        'base': 0.875,//  7/8 step 8
        'upgrade': 0
      },
      'step': 8,
      'input':{
        'Money': 1850.0,
        'Sand': 30.0,
        'Steel': 20.0,
        'Rubber': 20.0,
      },
      'upgrade' : [
        {'human': 2500, 'Wood': 8000, 'Sand': 8000, 'Steel': 5000, 'Money': 120000, 'Education': 3}
      ],
      'mortgageValue': [210000],
      'maxHuman': 480,
      'img': 'Assets/building/SolarPanel.jpg'
    },
    'Furniture': {
      'rate': {
        'base': 1.5,
        'upgrade': 0
      },
      'step': 10,
      'input':{
        'Money': 78.0,
        'Cotton': 30.0,
        'Steel': 8.0,
        'Wood': 28.0
      },
      'upgrade' : [
        {'human': 2500, 'Wood': 5000, 'Sand': 5000, 'Steel': 2000, 'Money': 70000, 'Education': 2}
      ],
      'mortgageValue': [120000],
      'maxHuman': 800,
      'img': 'Assets/building/Furniture.jpg'
    },
    'Jewellery': {
      'rate': {
        'base': 0.75,
        'upgrade': 0
      },
      'step': 4,
      'input':{
        'Money': 370.0,
        'Silver': 7.0,
        'Steel': 5.0
      },
      'upgrade' : [
        {'human': 2500, 'Wood': 2000, 'Sand': 2000, 'Steel': 5000, 'Money': 90000, 'Education': 3}
      ],
      'mortgageValue': [150000],
      'maxHuman': 380,
      'img': 'Assets/building/Jewellery.jpg'
    },
    'Gloves': {
      'rate': {
        'base': 6,
        'upgrade': 0
      },
      'step': 10,
      'input':{
        'Money': 32.0,
        'Rubber': 25.0,
      },
      'upgrade' : [
        {'human': 2500, 'Wood': 6000, 'Sand': 6000, 'Steel': 1500, 'Money': 60000, 'Education': 1}
      ],
      'mortgageValue': [100000],
      'maxHuman': 800,
      'img': 'Assets/building/Gloves.jpg'
    },
    'Bag': {
      'rate': {
        'base': 3.08, // step 25
        'upgrade': 0
      },
      'step': 25,
      'input':{
        'Money': 90.0,
        'Cotton': 40.0,
        'Leather': 20.0
      },
      'upgrade': [
        {'human': 2500, 'Wood': 6000, 'Sand': 6000, 'Steel': 2000, 'Money': 60000, 'Education': 1}
      ],
      'mortgageValue': [100000],
      'maxHuman': 650,
      'img': 'Assets/building/Bag.jpg'
    },
    'Gadget': {
      'rate': {
        'base': 80.0/75.0, // step 15
        'upgrade': 0
      },
      'step': 15,
      'input':{
        'Money': 820.0,
        'Steel': 10.0,
        'Copper': 10.0,
        'Sand': 15.0
      },
      'upgrade': [
        {'human': 2500, 'Wood': 2000, 'Sand': 2000, 'Steel': 6000, 'Money': 45000, 'Education': 2}
      ],
      'mortgageValue': [120000],
      'maxHuman': 750,
      'img': 'Assets/building/Gadget.jpg'
    },
    'Book': {
      'rate': {
        'base': 2.75, // step 4
        'upgrade': 0
      },
      'step': 8,
      'input':{
        'Money': 10.0,
        'Wood': 20.0,
      },
      'upgrade' : [
        {'human': 2500, 'Wood': 3000, 'Sand': 1500, 'Steel': 500, 'Money': 40000, 'Education': 1}
      ],
      'mortgageValue': [60000],
      'maxHuman': 1000,
      'img': 'Assets/building/Book.jpg'
    }
  };

  dynamic landDevelopment = {
    'human': 1000,
    'Money': 40000
  };

  Map specialBuilding = {
    'Education': {
      'upgrade' : [
        {'human': 1000, 'Money': 75000, 'Land': 1},
        {'human': 1500, 'Money': 100000, 'Land': 2},
        {'human': 2000, 'Money': 125000, 'Land': 3}
      ],
      'img': 'Assets/specialBuilding/education.jpg',
      'description': ''
    },
    'Healthcare': {
      'upgrade' : [
        {'human': 1000, 'Money': 75000, 'Land': 1},
        {'human': 1500, 'Money': 100000, 'Land': 2},
        {'human': 2000, 'Money': 125000, 'Land': 3}
      ],
      'img': 'Assets/specialBuilding/healthcare.jpg',
      'description': ''
    },
//    'R&D': {
//      'upgrade' : [
//        {'human': 2500, 'Steel': 0, 'Sand': 0, 'Money': 25000, 'Education': 1},
//        {'human': 2000, 'Steel': 0, 'Sand': 0, 'Money': 15000, 'R&D': 1}
//      ],
//      'img': 'Assets/specialBuilding/r&d.jpg',
//      'description': ''
//    },
    'Telecommunication': {
      'upgrade' : [
        {'human': 1500, 'Money': 75000, 'Land': 1},
        {'human': 2500, 'Money': 100000, 'Land': 2}
      ],
      'img': 'Assets/specialBuilding/telecommunication.jpg',
      'description': ''
    }
  };

  final StreamController<String> _masterNation = StreamController<String>.broadcast();
  Stream<String> get masterNation => _masterNation.stream;

  List<StreamSubscription<Event>> fireListeners = [];

  void addFirebaseListener(){
    DatabaseReference data = FirebaseDatabase.instance.reference().child('MASTER');
    //resources
    fireListeners.add(data.child('resources').onChildAdded.listen((Event event){
      resources[event.snapshot.key] = event.snapshot.value;
      //print('R '+ event.snapshot.value.toString());
      _masterNation.add('resources');
    }));
    fireListeners.add(data.child('resources').onChildChanged.listen((Event event){
      resources[event.snapshot.key] = event.snapshot.value;
      //print('B '+ event.snapshot.value.toString());
      _masterNation.add('resources');
    }));
    //building
    fireListeners.add(data.child('building').onChildAdded.listen((Event event){
      building[event.snapshot.key] = event.snapshot.value;
      //print('B '+ event.snapshot.value.toString());
      _masterNation.add('building');
    }));
    fireListeners.add(data.child('building').onChildChanged.listen((Event event){
      building[event.snapshot.key] = event.snapshot.value;
      _masterNation.add('building');
    }));
    //specialBuilding
    fireListeners.add(data.child('specialBuilding').onChildAdded.listen((Event event){
      specialBuilding[event.snapshot.key] = event.snapshot.value;
      //print('S '+ event.snapshot.value.toString());
      _masterNation.add('specialBuilding');
    }));
    fireListeners.add(data.child('specialBuilding').onChildChanged.listen((Event event){
      specialBuilding[event.snapshot.key] = event.snapshot.value;
      _masterNation.add('specialBuilding');
    }));
  }

  void pauseFire(){
    fireListeners.forEach((listener){
      listener.pause();
    });
  }

  void resumeFire(){
    fireListeners.forEach((listener){
      listener.resume();
    });
  }

  void cancelFire(){
    fireListeners.forEach((listener){
      listener.cancel();
    });
  }
}
