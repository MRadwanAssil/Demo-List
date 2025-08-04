import 'package:demo_list/itemManage/core/item_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ItemList extends StatefulWidget {
  const ItemList({super.key});

  @override
  State<ItemList> createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> with TickerProviderStateMixin {
  final Map<Item, AnimationController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (var item in ItemManager.items) {
      _controllers[item] = _createController();
      _controllers[item]!.value = 1;
    }
  }

  AnimationController _createController() {
    return AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    for (var ctrl in _controllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void checkAndMove(Item item) async {
    await _controllers[item]!.reverse();

    setState(() {
      ItemManager.checkAndMove(item);
    });

    await _controllers[item]!.forward();
  }

  void deleteItem(Item item) async {
    await _controllers[item]!.reverse();
    setState(() {
      ItemManager.deleteItem(item);
      _controllers[item]!.dispose();
      _controllers.remove(item);
    });
  }

  void dragItem(int newIndex, int oldIndex) {
    setState(() {
      ItemManager.dragItem(newIndex, oldIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      physics: BouncingScrollPhysics(),
      onReorder: (oldIndex, newIndex) => dragItem(newIndex, oldIndex),
      buildDefaultDragHandles: false,
      padding: EdgeInsets.symmetric(vertical: 8),
      children: <Widget>[
        for (final item in ItemManager.items)
          SizeTransition(
            key: ValueKey(item.title),
            sizeFactor: _controllers[item]!.drive(
              CurveTween(curve: Curves.easeInOut),
            ),
            axisAlignment: 0.0,
            child: Dismissible(
              key: ValueKey(item.title),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 20),
                child: Icon(Icons.delete_outline_rounded, color: Colors.white),
              ),
              secondaryBackground: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20),
                child: Icon(Icons.delete_outline_rounded, color: Colors.white),
              ),
              onDismissed: (direction) => deleteItem(item),
              child: ReorderableDelayedDragStartListener(
                index: ItemManager.items.indexOf(item),
                child: Material(
                  child: Ink(
                    child: InkWell(
                      onTap: () => checkAndMove(item),
                      child: ListTile(
                        title: Text(
                          item.title,
                          style: TextStyle(
                            decoration: item.checked
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        leading: Checkbox(
                          value: item.checked,
                          onChanged: (value) => checkAndMove(item),
                        ),
                        trailing: Ink(
                          width: 50,
                          height: 50,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(25),
                            onTap: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => Scaffold(
                                    appBar: AppBar(title: const Text("Chat")),
                                    body: Center(child: Text(item.title)),
                                  ),
                                ),
                              );
                            },
                            child: const Icon(Icons.arrow_right_rounded),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
