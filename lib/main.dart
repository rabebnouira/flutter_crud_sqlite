import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tpflutter/contactForm.dart';
import 'dart:io';

import 'sql_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Contacts',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _journals = [];
  bool _isLoading = true;

  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals();
  }

  void _navigateToFormPage(int? id) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactFormPage(id: id),
      ),
    );
    if (result != null && result) {
      _refreshJournals();
    }
  }

  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Successfully deleted a contact!'),
      ),
    );
    _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        itemCount: _journals.length,
        itemBuilder: (context, index) => Card(
          color: Colors.blueGrey[100],
          child: ListTile(
            title: Container(
              margin: EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(_journals[index]['name']),
            ),
            subtitle: Container(
              margin: EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(_journals[index]['tel']),
            ),
            leading: _journals[index]['image'] != null
                ? Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: FileImage(File(_journals[index]['image'])),
                  fit: BoxFit.cover,
                ),
              ),
            )
                : null,
            onTap: () {
              FlutterPhoneDirectCaller.callNumber(
                  _journals[index]['tel']);
            },
            trailing: SizedBox(
              width: 100,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () =>
                        _navigateToFormPage(_journals[index]['id']),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () =>
                        _deleteItem(_journals[index]['id']),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _navigateToFormPage(null),
      ),
    );
  }
}


