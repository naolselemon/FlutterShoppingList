import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import "package:http/http.dart" as http;

import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});
  @override
  State<GroceryList> createState() {
    return _GroceryListState();
  }
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];

  var _isLoading = true;

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  void _loadData() async {
    await dotenv.load(
        fileName: ".env"); // wait for dotenv then continue to next part.

    final firebaseUrl = dotenv.env["FIREBASE_URL"]!;
    final apiKey = dotenv.env["SHOPPING_LIST"]!;

    final url = Uri.https(firebaseUrl, apiKey);
    final response = await http.get(url);
    Map<String, dynamic> resData = json.decode(response.body);

    List<GroceryItem> loadItems = [];

    for (final item in resData.entries) {
      final category = categories.entries
          .firstWhere(
              (catItem) => catItem.value.title == item.value["category"])
          .value;

      loadItems.add(
        GroceryItem(
          id: item.key,
          name: item.value["name"],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
    }

    setState(() {
      _groceryItems = loadItems;
      _isLoading = false;
    });
  }

  void newItem(BuildContext context) async {
    final response = await Navigator.push<GroceryItem>(
        context, MaterialPageRoute(builder: (context) => const NewItem()));

    if (response == null) {
      return;
    }

    setState(() {
      _groceryItems.add(response);
    });
  }

  void _removeItem(GroceryItem item) {
    setState(() {
      _groceryItems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) {
          return Dismissible(
            key: ValueKey(_groceryItems[index]),
            onDismissed: (direction) {
              _removeItem(_groceryItems[index]);
            },
            child: ListTile(
              title: Text(_groceryItems[index].name),
              leading: Container(
                height: 24,
                width: 24,
                color: _groceryItems[index].category.color,
              ),
              trailing: Text(_groceryItems[index].quantity.toString()),
            ),
          );
        });

    if (_groceryItems.isEmpty) {
      content = const Center(child: Text('No groceries added yet.'));
    }

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("Your Groceries"),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                newItem(context);
              },
            ),
          ],
        ),
        body: content);
  }
}
