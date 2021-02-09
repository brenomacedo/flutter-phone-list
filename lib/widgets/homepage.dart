import 'dart:io';

import 'package:flutter/material.dart';
import 'package:phone_list/helpers/contact_helper.dart';
import 'package:phone_list/widgets/contactpage.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  ContactHelper helper = ContactHelper();

  List<Contact> contacts = List();

  @override
  void initState() {
    super.initState();

    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        centerTitle: true
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemBuilder: (context, index) {
          return _contactCard(context, index);
        },
        itemCount: contacts.length,
      )
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: contacts[index].img != null ?
                      FileImage(File(contacts[index].img)) :
                        AssetImage("images/felixcalc.png")
                  )
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  children: [
                    Text(contacts[index].name ?? "",
                      style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
                    Text(contacts[index].email ?? "",
                      style: TextStyle(fontSize: 18.0)),
                    Text(contacts[index].phone ?? "",
                      style: TextStyle(fontSize: 18.0))
                  ]
                )
              )
            ],
          ),
        ),
      ),
      onTap: () {
        _showOptions(context, index);
      },
    );
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          builder: (context) {
            return Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Text("Ligar", style: TextStyle(color: Colors.red, fontSize: 20.0)),
                      onPressed: () {
                        launch("tel:${contacts[index].phone}");
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Text("Editar", style: TextStyle(color: Colors.red, fontSize: 20.0)),
                      onPressed: () {
                        Navigator.pop(context);
                        _showContactPage(contact: contacts[index]);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: FlatButton(
                      child: Text("Excluir", style: TextStyle(color: Colors.red, fontSize: 20.0)),
                      onPressed: () {
                        helper.deleteContact(contacts[index].id);
                        setState(() {
                          contacts.removeAt(index);
                          Navigator.pop(context);
                        });
                      },
                    ),
                  ),
                ],
              ),
              padding: EdgeInsets.all(10.0),
            );
          },
          onClosing: () {

          },
        );
      }
    );
  }

  void _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactPage(contact: contact)
      )
    );
    if(recContact != null) {
      if(contact != null) {
        await helper.updateContact(recContact);
      } else {
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  void _getAllContacts() {
    helper.getAllContacts().then((list) {
      setState(() {
        contacts = list;
      });
    });
  }
}