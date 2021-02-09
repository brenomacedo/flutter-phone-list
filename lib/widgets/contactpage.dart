import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phone_list/helpers/contact_helper.dart';

enum OrderOptions {orderaz, orderza}

class ContactPage extends StatefulWidget {

  final Contact contact;

  ContactPage({ this.contact });

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  Contact _editedContact;

  bool _userEdited = false;

  final _nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    if(widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap());

      _nameController.text = _editedContact.name;
      _emailController.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;
    }
  }

  final ImagePicker imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(_editedContact.name ?? "Novo Contato"),
          centerTitle: true
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.save),
          backgroundColor: Colors.red,
          onPressed: () {
            if(_editedContact.name.isNotEmpty && _editedContact.name != null) {
              Navigator.pop(context, _editedContact);
            } else {
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              GestureDetector(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: _editedContact.img != null ?
                        FileImage(File(_editedContact.img)) :
                          AssetImage("images/felixcalc.png")
                    )
                  ),
                ),
                onTap: () {
                  imagePicker.getImage(
                    source: ImageSource.camera
                  ).then((file) {
                    if(file == null) return;

                    setState(() {
                      _editedContact.img = file.path;
                    });
                  });
                },
              ),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Nome"
                ),
                focusNode: _nameFocus,
                onChanged: (val) {
                  _userEdited = true;
                  setState(() {
                    _editedContact.name = val;
                  });
                },
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email"
                ),
                onChanged: (val) {
                  _userEdited = true;
                  _editedContact.email = val;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: "Phone"
                ),
                onChanged: (val) {
                  _userEdited = true;
                  _editedContact.phone = val;
                },
                keyboardType: TextInputType.phone,
              )
            ],
          ),
        ),
      ),
      onWillPop: _requestPop,
    );
  }

  Future<bool> _requestPop() {
    if(_userEdited) {
      showDialog(context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Descartar alterações?"),
          content: Text("Se sair, as alterações serão perdidas!"),
          actions: [
            FlatButton(
              child: Text("Cancelar"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text("Sair"),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        );
      });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}