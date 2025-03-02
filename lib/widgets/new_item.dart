import 'dart:convert';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});
  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var _isSending = false;

  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.carbs]!;

  @override
  void initState() {
    super.initState();
    _loadEnv();
  }

  Future<void> _loadEnv() async {
    return await dotenv.load(fileName: ".env");
  }

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isSending = true;
      });

      final url = dotenv.env["FIREBASE_URL"]!;
      final shopping = dotenv.env["SHOPPING_LIST"]!;

      final databaseUrl = Uri.https(url, shopping);

      final body = {
        "name": _enteredName,
        "quantity": _enteredQuantity,
        "category": _selectedCategory.title,
      };

      final response = await http.post(databaseUrl,
          headers: {"Content-Type": 'application/json'},
          body: jsonEncode(body));

      if (!context.mounted) {
        return;
      }

      if (response.statusCode == 200) {
        final newItem = json.decode(response.body);

        Navigator.of(context).pop(GroceryItem(
            id: newItem["name"],
            name: _enteredName,
            quantity: _enteredQuantity,
            category: _selectedCategory));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add new item"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    label: Text("Name"),
                  ),
                  maxLength: 50,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length <= 1 ||
                        value.trim().length > 50) {
                      return "Must be between 1 and 50 characters.";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _enteredName = value!;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          label: Text("Quantity"),
                        ),
                        initialValue: "1",
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null ||
                              int.tryParse(value)! <= 0) {
                            return "Enter a valid value.";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _enteredQuantity = int.parse(value!);
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: DropdownButtonFormField<Category>(
                          value: _selectedCategory,
                          items: [
                            for (final category in categories.entries)
                              DropdownMenuItem<Category>(
                                  value: category.value,
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 20,
                                        width: 20,
                                        color: category.value.color,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(category.value.title)
                                    ],
                                  ))
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value!;
                            });
                          }),
                    )
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: _isSending
                            ? null
                            : () {
                                _formKey.currentState!.reset();
                                setState(() {
                                  _enteredName = '';
                                  _enteredQuantity = 1;
                                  _selectedCategory =
                                      categories[Categories.carbs]!;
                                });
                              },
                        child: const Text("Reset")),
                    const SizedBox(
                      width: 12,
                    ),
                    ElevatedButton(
                        onPressed: _isSending ? null : _saveItem,
                        child: _isSending
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(),
                              )
                            : const Text("Save"))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
