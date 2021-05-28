import 'dart:async';

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
  final StreamController _controller = StreamController();

  Stream<Box> boxStream() async* {
    Hive.box('contacts').watch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Hive Database'),
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
    _controller.close();
    super.dispose();
  }

  _buildListView() {
    final contactBox = Hive.box('contacts');

    return FutureBuilder(
      future: Hive.openBox('contacts'),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return ValueListenableBuilder(
            valueListenable: Hive.box('contacts').listenable(),
            builder: (context, Box box, _) {
              if (box.values.isEmpty) {
                return Text('Empty Box');
              } else {
                return ListView.builder(
                    itemCount: contactBox.length,
                    itemBuilder: (context, index) {
                      final contact = contactBox.getAt(index) as Contacts;
                      return ListTile(
                        title: Text(contact.name),
                        subtitle: Text(contact.number.toString()),
                      );
                    });
              }
            });
      },
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
                    decoration: InputDecoration(labelText: 'Name'),
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
                    decoration: InputDecoration(
                      labelText: 'Age',
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
    );
  }
}
