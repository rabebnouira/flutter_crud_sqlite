import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'sql_helper.dart';

class ContactFormPage extends StatefulWidget {
  final int? id;

  const ContactFormPage({Key? key, this.id}) : super(key: key);

  @override
  State<ContactFormPage> createState() => _ContactFormPageState();
}

class _ContactFormPageState extends State<ContactFormPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _telController = TextEditingController();
  File? _image;

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      _loadContact();
    }
  }

  void _loadContact() async {
    final data = await SQLHelper.getItem(widget.id!);
    if (data.isNotEmpty) {
      final contact = data.first;
      setState(() {
        _nameController.text = contact['name'];
        _telController.text = contact['tel'];
        if (contact['image'] != null) {
          _image = File(contact['image']);
        }
      });
    }
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  Future<bool> _saveContact() async {
    final name = _nameController.text;
    final tel = _telController.text;
    if (name.isEmpty || tel.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Please enter name and telephone number.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return false;
    }

    try {
      if (widget.id == null) {
        await SQLHelper.createItem(name, tel, _image?.path);
      } else {
        await SQLHelper.updateItem(widget.id!, name, tel, _image?.path);
      }
      return true;
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Please try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == null ? 'Create Contact' : 'Edit Contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: _image != null
                      ? DecorationImage(
                    image: FileImage(_image!),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: _image == null
                    ? Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.grey,
                )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _telController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Telephone',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final result = await _saveContact();
                if (result) {
                  Navigator.pop(context, true);
                }
              },
              child: Text(widget.id == null ? 'Create' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}