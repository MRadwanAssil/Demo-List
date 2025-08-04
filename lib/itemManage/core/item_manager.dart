import 'package:flutter/material.dart';

class Item {
  Item({required this.title});
  String title;
  bool checked = false;
  Key key = Key(DateTime.now().toString());
}

class ItemManager {
  static List<Item> items = List.generate(
    10,
    (index) => Item(title: '${index + 1}'),
  );

  static void deleteItem(Item item) async {
    items.remove(item);
  }

  static void dragItem(int newIndex, int oldIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final movedItem = items.removeAt(oldIndex);
    items.insert(newIndex, movedItem);
  }

  static void checkAndMove(Item item) async {
    item.checked = !item.checked;

    items.remove(item);

    if (item.checked) {
      items.add(item);
    } else {
      items.insert(0, item);
    }
  }
}
