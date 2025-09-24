import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// Get the application documents directory
Future<String> getFilePath() async {
  Directory directory = await getApplicationDocumentsDirectory();
  Item.appDirectoryPath=directory.path;
  return File('${directory.path}/my_file.txt').path;
}

class Item {
  Item({
    required this.id,
    required this.name,
    required this.nickName,
    required this.gift,
    required this.email,
    required this.phone,
    required this.picture,
    required this.notes,
    required this.completed,
  });

  String id;
  String name;
  String nickName;
  String gift;
  String email;
  String phone;
  String picture;
  String notes;
  bool completed;

  static String appDirectoryPath='';
  String getImgFilePath() {
    return '${Item.appDirectoryPath}/${id}.jpg';
}

  static bool exists(String id) {
    for (Item i in items) {
      if (i.id == id) return true;
    }
    return false;
  }

  static bool containsName(String name) {
    for (Item i in items) {
      if (i.name == name) return true;
    }
    return false;
  }

  static add(Item item) {
    for (Item i in items) {
      if (i.name == item.name) ;
    }
    items.add(item);
    writeToFile();
  }

  static void update(Item item) {
    writeToFile().then((v){});
  }

  static void remove(String id) {
    for (Item i in items) {
      if (i.id == id) {
        items.remove(i);
        break;
      }
    }
    writeToFile();
  }

// Write data to a file
  static Future<void> writeToFile() async {
    final file = File(await getFilePath());
    file.writeAsStringSync(''); // blank out the file
    for (var element in items) {
      Map<String, dynamic> data = {
        'id':element.id,
        'name': element.name,
        'nickName':element.nickName,
        'gift':element.gift,
        'email': element.email,
        'phone': element.phone,
        'picture': element.picture,
        'notes': element.notes,
        'completed': element.completed
      };
      file.writeAsStringSync('${jsonEncode(data)}\n', mode: FileMode.append);
    }
  }

// Read data from a file
  static Future readFromFile() async {
    final file = File(await getFilePath());
    if (file.existsSync()) {
      items.clear();
      List<String> lines = file.readAsLinesSync();
      for (var element in lines) {
        final i = jsonDecode(element);
        items.add(Item(
            id:i['id'],
            name: i['name'],
            nickName:i['nickName'],
            gift:i['gift'],
            email: i['email'],
            phone: i['phone'],
            picture: i['picture'],
            notes: i['notes'],
            completed: i['completed']));
      }
    }
  }
}

final List<Item> items = <Item>[
/*  Item(
    name: 'Add New...',
    nickName:'',
    gift:'',
    email: '',
    phone: '',
    picture: '',
    notes: '',
    completed: false,
  ),
  */
];
