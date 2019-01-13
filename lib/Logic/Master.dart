class Master{

  List<String> resourcesOrder = ['Wood', 'Sand', 'Steel', 'Rubber', 'Cotton',
  'Petrol', 'Leather', 'Copper', 'Silver', 'Vegetable', 'Meat',
  'Car', 'Shirt', 'FoodVegetable', 'FoodMeat', 'HouseholdAppliances', 'Furniture',
  'Jewellery', 'Gloves', 'Bag', 'Gadget', 'Book'];
  var resources = {
    'Wood': {
      'price': 5.0,
      'img': 'packages/e_nation/Assets/resources/wood.png'
    },
    'Sand': {
      'price': 5.0,
      'img': 'packages/e_nation/Assets/resources/Sand.png'
    },
    'Steel': {
      'price': 20.0,
      'img': 'packages/e_nation/Assets/resources/steel.png'
    },
    'Rubber': {
      'price': 4.0,
      'img': 'packages/e_nation/Assets/resources/Rubber.jpg'
    },
    'Cotton': {
      'price': 2.0,
      'img': 'packages/e_nation/Assets/resources/Cotton.png'
    },
    'Petrol': {
      'price': 125.0,
      'img': 'packages/e_nation/Assets/resources/Oil.jpg'
    },
    'Leather': {
      'price': 15.00,
      'img': 'packages/e_nation/Assets/resources/Leather.png'
    },
    'Copper': {
      'price': 30.00,
      'img': 'packages/e_nation/Assets/resources/copper.png'
    },
    'Silver': {
      'price': 250.00,
      'img': 'packages/e_nation/Assets/resources/Silver.png'
    },
    'Vegetable': {
      'price': 3.00,
      'feed': 1,
      'img': 'packages/e_nation/Assets/resources/Vegetable.png'
    },
    'Meat': {
      'price': 5.00,
      'feed': 2,
      'img': 'packages/e_nation/Assets/resources/Meat.png'
    },
    /*'rawFood': {
      'price': 5.00,
      'feed': 2,
      'img': 'packages/e_nation/Assets/wood.png'
    },*/
    'Car': {
      'price': 80.00,
      'img': 'packages/e_nation/Assets/resources/Car.png'
    },
    'Shirt': {
      'price': 5.00,
      'img': 'packages/e_nation/Assets/resources/shirt.png'
    },
    'FoodVegetable': {
      'price': 10.0,
      'feed': 2,
      'img': 'packages/e_nation/Assets/resources/FoodVege.png'
    },
    'FoodMeat': {
      'price': 14.0,
      'feed': 3,
      'img': 'packages/e_nation/Assets/resources/FoodMeat.png'
    },
    'HouseholdAppliances': {
      'price': 25.0,
      'img': 'packages/e_nation/Assets/resources/HouseholdAppliances.png'
    },
    'Furniture': {
      'price': 20.0,
      'img': 'packages/e_nation/Assets/resources/Furniture.png'
    },
    'Jewellery': {
      'price': 40.0,
      'img': 'packages/e_nation/Assets/resources/Jewellery.png'
    },
    'Gloves': {
      'price': 16.0,
      'img': 'packages/e_nation/Assets/resources/Gloves.png'
    },
    'Bag': {
      'price': 20.0,
      'img': 'packages/e_nation/Assets/resources/Bag.png'
    },
    'Gadget': {
      'price': 28.0,
      'img': 'packages/e_nation/Assets/resources/Gadget.jpg'
    },
    'Book': {
      'price': 10.0,
      'img': 'packages/e_nation/Assets/resources/Book.png'
    }
  };
  dynamic building = {
    'Wood': {
      'rate': {
        'base': 3.0,
        'upgrade': 1.5
      },
      'input':{
        'Money': 7.5
      },
      'upgrade' : [
        {'human': 2500, 'Wood': 3000, 'Sand': 3000, 'Steel': 1500, 'Money': 20000},
        {'human': 2000, 'Wood': 8000, 'Sand': 8000, 'Steel': 4000, 'Money': 50000}
      ],
      'maxHuman': 1000,
      'img': 'Assets/building/logging.jpg'
    },
    'Sand': {
      'rate': {
        'base': 3.0,
        'upgrade': 1.5
      },
      'input':{
        'Money': 7.5
      },
      'upgrade' : [
        {'human': 2500, 'Wood': 3000, 'Sand': 3000, 'Steel': 1500, 'Money': 20000},
        {'human': 2000, 'Wood': 8000, 'Sand': 8000, 'Steel': 4000, 'Money': 50000}
      ],
      'maxHuman': 1000,
      'img': 'Assets/building/quarry.jpg'
    },
    'Steel': {
      'rate': {
        'base': 1.5,
        'upgrade': 0.75
      },
      'input':{
        'Money': 15.0
      },
      'upgrade' : [
        {'human': 2500, 'Wood': 5000, 'Sand': 5000, 'Steel': 2000, 'Money': 37500},
        {'human': 2000, 'Wood': 8000, 'Sand': 8000, 'Steel': 4000, 'Money': 55000}
      ],
      'maxHuman': 1000,
      'img': 'Assets/building/Steel.jpg'
    },
    'Rubber': {
      'rate': {
        'base': 3.0,
        'upgrade': 1.5
      },
      'input':{
        'Money': 5.0
      },
      'upgrade' : [
        {'human': 2500, 'Wood': 4000, 'Sand': 4000, 'Steel': 800, 'Money': 20000},
        {'human': 2000, 'Wood': 8000, 'Sand': 8000, 'Steel': 1500, 'Money': 45000}
      ],
      'maxHuman': 1000,
      'img': 'Assets/building/Rubber.jpg'
    },
    'Cotton': {
      'rate': {
        'base': 8.5,
        'upgrade': 4.25
      },
      'input':{
        'Money': 7.5
      },
      'upgrade' : [
        {'human': 2500, 'Wood': 3500, 'Sand': 3500, 'Steel': 800, 'Money': 30000},
        {'human': 2000, 'Wood': 8000, 'Sand': 8000, 'Steel': 1500, 'Money': 60000}
      ],
      'maxHuman': 1000,
      'img': 'Assets/building/Cotton.jpg'
    },
    'Petrol': {
      'rate': {
        'base': 5.0,
        'upgrade': 2.5
      },
      'input':{
        'Money': 500.0
      },
      'upgrade' : [
        {'human': 2500, 'Wood': 3500, 'Sand': 3500, 'Steel': 800, 'Money': 30000},
        {'human': 2000, 'Wood': 8000, 'Sand': 8000, 'Steel': 1500, 'Money': 60000, 'R&D': 1}
      ],
      'maxHuman': 1000,
      'img': 'Assets/building/Petrol.jpg'
    },
    'Leather': {
      'rate': {
        'base': 1.5,
        'upgrade': 1.0
      },
      'input':{
        'Money': 12.0
      },
      'upgrade' : [
        {'human': 2500, 'Wood': 4000, 'Sand': 4000, 'Steel': 2500, 'Money': 30000},
        {'human': 2000, 'Wood': 8000, 'Sand': 8000, 'Steel': 5000, 'Money': 75000}
      ],
      'maxHuman': 1000,
      'img': 'Assets/building/Leather.jpg'
    },
    'Copper': {
      'rate': {
        'base': 1.3,
        'upgrade': 1.3
      },
      'input':{
        'Money': 20.0
      },
      'upgrade' : [
        {'human': 2500, 'Wood': 5000, 'Sand': 5000, 'Steel': 3500, 'Money': 55000},
        {'human': 2500, 'Wood': 11000, 'Sand': 11000, 'Steel': 8000, 'Money': 130000}
      ],
      'maxHuman': 1000,
      'img': 'Assets/building/Copper.jpg'
    },
    'Silver': {
      'rate': {
        'base': 0.5,
        'upgrade': 0.5
      },
      'input':{
        'Money': 50.0
      },
      'upgrade' : [
        {'human': 2500, 'Wood': 10000, 'Sand': 10000, 'Steel': 5000, 'Money': 200000},
        {'human': 2000, 'Wood': 12500, 'Sand': 12500, 'Steel': 8000, 'Money': 350000, 'R&D': 1}
      ],
      'maxHuman': 1000,
      'img': 'Assets/building/Silver.jpg'
    },
    'Vegetable': {
      'rate': {
        'base': 3,
        'upgrade': 0.6
      },
      'input':{
        'Money': 5.0
      },
      'upgrade' : [
        {'human': 2500, 'Wood': 3000, 'Sand': 3000, 'Steel': 1500, 'Money': 25000},
        {'human': 2000, 'Wood': 8000, 'Sand': 8000, 'Steel': 4000, 'Money': 50000}
      ],
      'maxHuman': 1000,
      'img': 'Assets/building/agriculture.jpg'
    },
    'Meat': {
      'rate': {
        'base': 3,
        'upgrade': 0.9
      },
      'input':{
        'Money': 8.5
      },
      'upgrade' : [
        {'human': 2500, 'Wood': 4500, 'Sand': 4500, 'Steel': 2500, 'Money': 35000},
        {'human': 2000, 'Wood': 8000, 'Sand': 8000, 'Steel': 6000, 'Money': 65000}
      ],
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
        'base': 2,
        'upgrade': 0
      },
      'input':{
        'Money': 16.0,
        'Steel': 2.0,
        'Sand': 4.0,
        'Rubber': 3.0
      },
      'upgrade' : [
        {'human': 2500, 'Wood': 1200, 'Sand': 1500, 'Money': 4000000},
        {'human': 2000, 'Wood': 1000, 'Sand': 1200, 'Money': 3000000, 'R&D': 1}
      ],
      'maxHuman': 500,
      'img': 'Assets/building/Car.jpg'
    },
    'Shirt': {
      'rate': {
        'base': 25,
        'upgrade': 0
      },
      'input':{
        'Money': 8.0,
        'Cotton': 50.0
      },
      'upgrade' : [
        {'human': 2500, 'Steel': 1200, 'Sand': 1500, 'Money': 2500000},
        {'human': 2000, 'Steel': 1000, 'Sand': 1200, 'Money': 2000000, 'R&D': 1}
      ],
      'maxHuman': 500,
      'img': 'Assets/building/Shirt.jpg'
    },
    /*'food': {
      'rate': {
        'base': 16,
        'upgrade': 0
      },
      'input':{
        'money': 10.5,
        /*'vege': 7.5,
        'meat': 6.0,*/
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
    'FoodVegetable': {
      'rate': {
        'base': 16,
        'upgrade': 0
      },
      'input':{
        'Money': 10.5,
        'Vegetable': 7.5,
        //'rawFood': 10.0,
        'Petrol': 16.0,
        'Rubber': 1.8
      },
      'upgrade' : [
        {'human': 2500, 'Steel': 1200, 'Sand': 1500, 'Money': 2500000},
        {'human': 2000, 'Steel': 1000, 'Sand': 1200, 'Money': 2000000}
      ],
      'maxHuman': 500,
      'img': 'Assets/building/FoodVege.jpg'
    },
    'FoodMeat': {
      'rate': {
        'base': 16,
        'upgrade': 0
      },
      'input':{
        'Money': 10.5,
        'Meat': 6.0,
        //'rawFood': 10.0,
        'Petrol': 16.0,
        'Rubber': 1.8
      },
      'upgrade' : [
        {'human': 2500, 'Steel': 1200, 'Sand': 1500, 'Money': 2500000},
        {'human': 2000, 'Steel': 1000, 'Sand': 1200, 'Money': 2000000}
      ],
      'maxHuman': 500,
      'img': 'Assets/building/FoodMeat.jpg'
    },
    'HouseholdAppliances': {
      'rate': {
        'base': 4,
        'upgrade': 0
      },
      'input':{
        'Money': 12.0,
        'Steel': 2.0,
        'Rubber': 4.0,
        'Cooper': 1.0,
      },
      'upgrade' : [
        {'human': 2500, 'Steel': 1200, 'Sand': 1500, 'Money': 2000000},
        {'human': 2000, 'Steel': 1000, 'Sand': 1200, 'Money': 2500000, 'R&D': 1}
      ],
      'maxHuman': 500,
      'img': 'Assets/building/HouseholdAppliances.jpg'
    },
    'Furniture': {
      'rate': {
        'base': 3,
        'upgrade': 0
      },
      'input':{
        'Money': 12.0,
        'Cotton': 24.0,
        'Steel': 2.0,
        'Wood': 2.4
      },
      'upgrade' : [
        {'human': 2500, 'Steel': 1200, 'Sand': 1500, 'Money': 2500000},
        {'human': 2000, 'Steel': 1000, 'Sand': 1200, 'Money': 2000000, 'R&D': 1}
      ],
      'maxHuman': 500,
      'img': 'Assets/building/Furniture.jpg'
    },
    'Jewellery': {
      'rate': {
        'base': 0.6,
        'upgrade': 0
      },
      'input':{
        'Money': 8.0,
        'Silver': 0.8
      },
      'upgrade' : [
        {'human': 2500, 'Steel': 1200, 'Sand': 1500, 'Money': 3500000},
        {'human': 2000, 'Steel': 1000, 'Sand': 1200, 'Money': 3000000, 'R&D': 1}
      ],
      'maxHuman': 1000,
      'img': 'Assets/building/Jewellery.jpg'
    },
    'Gloves': {
      'rate': {
        'base': 1,
        'upgrade': 0
      },
      'input':{
        'Money': 6.25,
        'Rubber': 14.0/8,
      },
      'upgrade' : [
        {'human': 2500, 'Steel': 1200, 'Sand': 1500, 'Money': 2500000},
        {'human': 2000, 'Steel': 1000, 'Sand': 1200, 'Money': 2000000, 'R&D': 1}
      ],
      'maxHuman': 800,
      'img': 'Assets/building/Gloves.jpg'
    },
    'Bag': {
      'rate': {
        'base': 1.5,
        'upgrade': 0
      },
      'input':{
        'Money': 6.875,
        'Cotton': 10.0,
        'Leather': 1.25
      },
      'upgrade': [
        {'human': 2500, 'Steel': 1200, 'Sand': 1500, 'Money': 2300000},
        {'human': 2000, 'Steel': 1000, 'Sand': 1200, 'Money': 1800000, 'R&D': 1}
      ],
      'maxHuman': 800,
      'img': 'Assets/building/Bag.jpg'
    },
    'Gadget': {
      'rate': {
        'base': 2,
        'upgrade': 0
      },
      'input':{
        'Money': 7.0,
        'Steel': 2.0,
        'Copper': 1.5,
        'Sand': 1.5
      },
      'upgrade': [
        {'human': 2500, 'Steel': 1200, 'Sand': 1500, 'Money': 3500000},
        {'human': 2000, 'Steel': 1000, 'Sand': 1200, 'Money': 2500000, 'R&D': 1}
      ],
      'maxHuman': 1000,
      'img': 'Assets/building/Gadget.jpg'
    },
    'Book': {
      'rate': {
        'base': 3,
        'upgrade': 0
      },
      'input':{
        'Money': 40.0/7,
        'Wood': 12.0/7,
      },
      'upgrade' : [
        {'human': 2500, 'Steel': 1200, 'Sand': 1500, 'Money': 2500000},
        {'human': 2000, 'Steel': 1000, 'Sand': 1200, 'Money': 1500000, 'R&D': 1}
      ],
      'maxHuman': 700,
      'img': 'Assets/building/Book.jpg'
    }
  };

  dynamic specialBuilding = {
    'Education': {
      'upgrade' : [
        {'human': 2500, 'Steel': 1200, 'Sand': 1500, 'Money': 2500000},
        {'human': 2000, 'Steel': 1000, 'Sand': 1200, 'Money': 1500000}
      ],
      'img': 'Assets/specialBuilding/education.jpg',
      'description': ''
    },
    'Healthcare': {
      'upgrade' : [
        {'human': 2500, 'Steel': 1200, 'Sand': 1500, 'Money': 2500000},
        {'human': 2000, 'Steel': 1000, 'Sand': 1200, 'Money': 1500000, 'R&D': 1}
      ],
      'img': 'Assets/specialBuilding/healthcare.jpg',
      'description': ''
    },
    'R&D': {
      'upgrade' : [
        {'human': 2500, 'Steel': 1200, 'Sand': 1500, 'Money': 2500000, 'Education': 1},
        {'human': 2000, 'Steel': 1000, 'Sand': 1200, 'Money': 1500000, 'R&D': 1}
      ],
      'img': 'Assets/specialBuilding/r&d.jpg',
      'description': ''
    },
    'Telecommunication': {
      'upgrade' : [
        {'human': 2500, 'Steel': 1200, 'Sand': 1500, 'Money': 2500000},
        {'human': 2000, 'Steel': 1000, 'Sand': 1200, 'Money': 1500000, 'R&D': 1}
      ],
      'img': 'Assets/specialBuilding/telecommunication.jpg',
      'description': ''
    }
  };

}