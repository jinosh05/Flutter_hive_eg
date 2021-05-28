import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_eg/contact_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  List<Color> mycolors = [
    Colors.pink.shade200,
    Colors.orange.shade400,
    Colors.blue.shade400,
    Colors.yellowAccent,
    Colors.purple.shade400
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'Contacts Page With Hive',
            style: TextStyle(
                color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: _buildListView(),
            ),
            ContactForm()
          ],
        ));
  }

  @override
  void dispose() {
    Hive.box('contacts').compact();
    super.dispose();
  }

  _buildListView() {
    final contactBox = Hive.box('contacts');

    double width = MediaQuery.of(context).size.width;
    return FutureBuilder(
      future: Hive.openBox('contacts'),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return ValueListenableBuilder(
            valueListenable: Hive.box('contacts').listenable(),
            builder: (context, Box box, _) {
              if (box.values.isEmpty) {
                return Center(
                  child: Text(
                    'No Contacts added yet',
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                );
              } else {
                return ListView.builder(
                    itemCount: contactBox.length,
                    itemBuilder: (context, index) {
                      final contact = contactBox.getAt(index) as Contacts;
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 5, horizontal: width * 0.025),
                        child: listCard(contact, index, width),
                      );
                    });
              }
            });
      },
    );
  }

  Card listCard(Contacts contact, int index, double width) {
    return Card(
      color: mycolors[index % 5],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: width * 0.75,
              child: Text(
                "Hi I am " +
                    contact.name +
                    " and my age is " +
                    contact.number.toString(),
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
            IconButton(
                onPressed: () {
                  Hive.box('contacts').deleteAt(index);
                },
                icon: Icon(
                  Icons.delete,
                  size: 18,
                  color: Colors.red,
                ))
          ],
        ),
      ),
    );
  }
}

class ContactForm extends StatefulWidget {
  @override
  _ContactFormState createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _formkey = GlobalKey<FormState>();
  late String _name;
  late int _age;

  void addContact(Contacts contacts) async {
    final contactsBox = await Hive.openBox('contacts');
    contactsBox.add(contacts);

    //.add(Contact('John Doe', 20));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formkey,
      child: Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.purple.shade200,
            borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      onSaved: (value) {
                        setState(() {
                          _name = value!;
                        });
                      },
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 25,
                  ),
                  Expanded(
                    child: TextFormField(
                      onSaved: (value) {
                        setState(() {
                          _age = int.parse(value!);
                        });
                      },
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                      decoration: InputDecoration(
                        labelText: 'Age',
                        labelStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            ElevatedButton(
                onPressed: () {
                  _formkey.currentState!.save();
                  final newContact = Contacts(name: _name, number: _age);
                  addContact(newContact);
                  _formkey.currentState!.reset();
                },
                child: Text('Add to Contacts')),
            SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }
}
