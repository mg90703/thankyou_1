import 'item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ItemListing extends StatefulWidget {
  const ItemListing({super.key, 
    required this.itemSelectedCallback,
    required this.selectedItem,
  });
  final ValueChanged<Item> itemSelectedCallback;
  final Item selectedItem;

  @override
  State<ItemListing> createState() => ItemListingState(
      itemSelectedCallback: itemSelectedCallback, selectedItem: selectedItem);
}

class ItemListingState extends State<ItemListing> {
  ItemListingState({
    required this.itemSelectedCallback,
    required this.selectedItem,
  });
  @override
  initState() async {
    await Item.readFromFile().then((value) => setState(() {}));
    super.initState();
  }

  bool showContacts = false;
  late List<Contact> contacts;
  late List<Contact> _filteredContacts;
  final ValueChanged<Item> itemSelectedCallback;
  final Item selectedItem;
  late void Function(void Function()) _ss;
  Future getContacts() async {
 //   if (await FlutterContacts.requestPermission(readonly: true)) {
      contacts = await FlutterContacts.getContacts(withProperties: true);
      _filteredContacts = List<Contact>.from(contacts);
 //   }
  }

  Future<void> onSearchTextChanged(String text) async {
    _filteredContacts.clear();
    for (var c in contacts) {
      if (text.isEmpty ||
          c.displayName.toLowerCase().contains(text.toLowerCase())) {
        _filteredContacts.add(c);
      }
    }
    _ss(() {});
  }


  final TextEditingController _controller = TextEditingController();
  Widget setupAlertDialoadContainer(context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _controller,
          onChanged: (value) => onSearchTextChanged(value),
          decoration: InputDecoration(
            labelText: 'Search',
            suffixIcon: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                _controller.text = '';
                onSearchTextChanged(_controller.text);
              },
            ),
          ),
        ),

/*        new Container(
          color: Theme.of(context).primaryColor,
          child: new Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Card(
              child: new ListTile(
                leading: new Icon(Icons.search),
                title: new TextField(
                  decoration: new InputDecoration(
                      hintText: 'Search', border: InputBorder.none),
                  onChanged: onSearchTextChanged,
                ),
                trailing: new IconButton(
                  icon: new Icon(Icons.cancel),
                  onPressed: () {
                    onSearchTextChanged('');
                  },
                ),
              ),
            ),
          ),
        ),
*/
        Container(
            color: Colors.grey,
            height: 300.0, // Change as per your requirement
            width: 300.0, // Change as per your requirement
            child: StatefulBuilder(
              builder: (context, setState) => ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredContacts.length,
                itemBuilder: (BuildContext context, int index) {
                  final contact = _filteredContacts[index];
                  _ss = setState;
                  return CheckboxListTile(
                    title: Text(contact.displayName),
                    value: Item.contains(contact.displayName),
                    onChanged: (bool? value) {
                      Item item;
                      if (value!) {
                        item = Item(
                            name: contact.displayName,
                            email: contact.emails.isEmpty
                                ? ''
                                : contact.emails[0].address,
                            phone: contact.phones.isEmpty
                                ? ''
                                : contact.phones[0].number,
                            picture: '',
                            notes: '',
                            completed: false);
                        Item.add(item);
                      } else {
                        Item.remove(contact.displayName);
                      }
                      setState(() {}); // for the dialog's checkbox
                      setState(() {}); // for the main list
                    },
                  );
                },
              ),
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
/*      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Guest List'),
      ),
*/
      body: ListView(
        children: items.map((item) {
          return ListTile(
            title: Card(
                child: Row(children: <Widget>[
              Expanded(
                child: Text(item.name),
              ),
              IconButton(
                iconSize: 30,
                icon: (item.notes == '')
                    ? const Icon(
                        Icons.note,
                        color: Colors.grey,
                      )
                    : const Icon(
                        Icons.note,
                        color: Colors.blue,
                      ),
                alignment: Alignment.centerRight,
                onPressed: () {},
              ),
              IconButton(
                iconSize: 30,
                icon: (item.picture == '')
                    ? const Icon(
                        Icons.image,
                        color: Colors.grey,
                      )
                    : const Icon(
                        Icons.image,
                        color: Colors.blue,
                      ),
                alignment: Alignment.centerRight,
                onPressed: () {},
              ),
              IconButton(
                iconSize: 30,
                icon: (item.email == '')
                    ? const Icon(
                        Icons.email_outlined,
                        color: Colors.grey,
                      )
                    : item.completed
                        ? Icon(
                            Icons.email,
                            color: Colors.blue,
                          )
                        : Icon(
                            Icons.email_outlined,
                            color: Colors.blue,
                          ),
                alignment: Alignment.centerRight,
                onPressed: () {},
              ),
            ])),
            onTap: () {
              itemSelectedCallback(item);
            },
            selected: selectedItem == item,
            selectedColor: Colors.amber,
            selectedTileColor: Colors.blue,
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getContacts().then((value) => showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  scrollable: true,
                  title: Text('Count=${this.contacts.length}'),
                  content: setupAlertDialoadContainer(context),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('ok'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {});
                      },
                    ),
                  ],
                );
              }));
        },
        tooltip: 'Add a Guest',
        child: const Icon(Icons.add),
      ),
    );
  }
}
