import 'item.dart';
import 'item_details.dart';
import 'item_listing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';

class MasterDetailContainer extends StatefulWidget {
  @override
  _ItemMasterDetailContainerState createState() =>
      _ItemMasterDetailContainerState();
}

class _ItemMasterDetailContainerState extends State<MasterDetailContainer> {
//  static const int kTabletBreakpoint = 600;

  Item _selectedItem = Item(
      id:"",name: "", nickName:'',gift:'',email: '', phone: '', picture: '', notes: '', completed: false);

  Widget _buildMobileLayout() {
    return ItemListing(
      selectedItem: _selectedItem,
      itemSelectedCallback: (item) {
        setState(() {});
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) {
              return ItemDetails(
                isInTabletLayout: false,
                item: item,
              );
            },
          ),
        ).then((_) {
          Item.update(item);
          setState(() {});
        });
      },
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: <Widget>[
        Flexible(
          flex: 1,
          child: Material(
            elevation: 4.0,
            child: ItemListing(
              itemSelectedCallback: (item) {
                setState(() {
                  _selectedItem = item;
                });
              },
              selectedItem: _selectedItem,
            ),
          ),
        ),
        Flexible(
          flex: 3,
          child: ItemDetails(
            isInTabletLayout: true,
            item: _selectedItem,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    Widget settingsPage;
    var shortestSide = MediaQuery.of(context).size.shortestSide;

//    if (shortestSide < kTabletBreakpoint) {
      content = _buildMobileLayout();
//    } else {
//      content = _buildTabletLayout();
//    }
    settingsPage = SettingsList(
      sections: [
        SettingsSection(
          title: Text('Common'),
          tiles: <SettingsTile>[
            SettingsTile.navigation(
              leading: Icon(Icons.language),
              title: Text('Language'),
              value: Text('English'),
            ),
            SettingsTile.switchTile(
              onToggle: (value) {},
              initialValue: true,
              leading: Icon(Icons.format_paint),
              title: Text('Enable custom theme'),
            ),
          ],
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Guest List'),
      ),
      drawer: settingsPage,
      body: content,
    );
  }
}
