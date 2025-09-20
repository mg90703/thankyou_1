import 'item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:uuid/uuid.dart';

  String getPhoneFromContact(Contact contact,PhoneLabel label )
  {
    if(contact.phones.length==1)return contact.phones[0].number;
    for(Phone p in contact.phones)
    {
      if(p.label==PhoneLabel.mobile) return p.number;
    }
    return '';
  }
  var uuid=Uuid();
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
//    if (await FlutterContacts.requestPermission(readonly: true)) {
      contacts = await FlutterContacts.getContacts(withProperties: true);
      _filteredContacts = List<Contact>.from(contacts);
//    }
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
  Widget setupAlertDialogContainer(context) {
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
            color: Colors.lightBlueAccent,
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
                    subtitle: Text(getPhoneFromContact(contact, PhoneLabel.mobile)),
                    value: Item.exists(contact.id),
                    side:BorderSide(color: (Item.containsName(contact.displayName) && !Item.exists(contact.id))?Colors.red:Colors.black, width: 2.0), 
                    onChanged: (bool? value) {
                      Item item;
                      if (value!) {
                        item = Item(
                          id:contact.id,
                          name: contact.displayName,
                          nickName:'',
                          gift:'',
                          email: contact.emails.isEmpty
                              ? ''
                              : contact.emails[0].address,
                          phone: getPhoneFromContact(contact, PhoneLabel.mobile),
                          picture: '',
                          notes: '',
                          completed: false);
                        Item.add(item);
                      } else {
                        Item.remove(contact.id);
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
                iconSize: 20,
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
                iconSize: 20,
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
                iconSize: 20,
                icon: (item.email == '' && item.phone=='')
                    ? const Icon(
                        Icons.send_outlined,
                        color: Colors.grey,
                      )
                    : item.completed
                        ? Icon(
                            Icons.send,
                            color: Colors.blue,
                          )
                        : Icon(
                            Icons.send_outlined,
                            color: Colors.blue,
                          ),
                alignment: Alignment.centerRight,
                onPressed: () {},
              ),
              IconButton(
                iconSize: 20,
                icon: const Icon(Icons.delete,),
                alignment: Alignment.centerRight,
                onPressed: () {Item.remove(item.id);setState(() {});},
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Visibility(
            child:FloatingActionButton(
              onPressed: () {
                Item item=Item(id:uuid.v4(),name: "", nickName:'',gift:'',email: '', phone: '', picture: '', notes: '', completed: false);
                Item.add(item);
                itemSelectedCallback(item);
              },
              child: Icon(Icons.add),
            ),
            ),
            Visibility(
            child:FloatingActionButton(
              onPressed: () {
                getContacts().then((value) => showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) {
                      return AlertDialog(
                        scrollable: true,
                        title: Text('Count=${contacts.length}'),
                        content: setupAlertDialogContainer(context),
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
                    }
                  ));
              },
              tooltip: 'Add a Guest',
              child: const Icon(Icons.contacts),
              )
              )
            ]
        ))

/*      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getContacts().then((value) => showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  scrollable: true,
                  title: Text('Count=${contacts.length}'),
                  content: setupAlertDialogContainer(context),
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
        child: const Icon(Icons.contacts),
      ),
*/    );
  }
}
