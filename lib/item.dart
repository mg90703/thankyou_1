import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// Get the application documents directory
Future<String> getFilePath() async {
  Directory directory = await getApplicationDocumentsDirectory();
  return File('${directory.path}/my_file.txt').path;
}

class Item {
  Item({
    required this.name,
    required this.email,
    required this.phone,
    required this.picture,
    required this.notes,
    required this.completed,
  });

  String name;
  String email;
  String phone;
  String picture;
  String notes;
  bool completed;

  static bool contains(String name) {
    for (Item i in items) if (i.name == name) return true;
    return false;
  }

  static add(Item item) {
    for (Item i in items) if (i.name == item.name) ;
    items.add(item);
    writeToFile();
  }

  static remove(String name) {
    for (Item i in items)
      if (i.name == name) {
        items.remove(i);
      }
    writeToFile();
  }

// Write data to a file
  static writeToFile() async {
    final file = File(await getFilePath());
    file.writeAsStringSync(''); // blank out the file
    items.forEach((element) {
      Map<String, dynamic> data = {
        'name': element.name,
        'email': element.email,
        'phone': element.phone,
        'picture': element.picture,
        'notes': element.notes,
        'completed': element.completed
      };
      file.writeAsStringSync(jsonEncode(data) + '\n', mode: FileMode.append);
    });
  }

// Read data from a file
  static Future readFromFile() async {
    final file = File(await getFilePath());
    if (file.existsSync()) {
      items.clear();
      List<String> lines = file.readAsLinesSync();
      lines.forEach((element) {
        final i = jsonDecode(element);
        items.add(Item(
            name: i['name'],
            email: i['email'],
            phone: i['phone'],
            picture: i['picture'],
            notes: i['notes'],
            completed: i['completed']));
      });
    }
  }
}

final List<Item> items = <Item>[
  Item(
    name: 'Add New...',
    email: '',
    phone: '',
    picture: '',
    notes: '',
    completed: false,
  ),
];
