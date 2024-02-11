import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:first_project/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_project/auth.dart';

class CreateGame extends StatefulWidget {
  @override
  State<CreateGame> createState() => _CreateGamePageState();
}

class _CreateGamePageState extends State<CreateGame> {
  final User? user = Auth().currentUser;
  final _gameID = TextEditingController();
  final _date = TextEditingController();
  final _passwordRed = TextEditingController();
  final _passwordBlue = TextEditingController();
  final _passwordOrg = TextEditingController();

  var _error = false;
  var _errorMessage = '';

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  void _checkError() {
    if (_gameID.text.isEmpty ||
        _passwordRed.text.isEmpty ||
        _passwordBlue.text.isEmpty ||
        _date.text.isEmpty ||
        _passwordOrg.text.isEmpty) {
      _error = true;
      _errorMessage = "Information missing!";
      return;
    } else {
      _error = false;
      _errorMessage = '';
    }
  }

  void _addGame() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection('Games').doc('Game${_gameID.text}').set({
      'GameID': _gameID.text,
      'PasswordRed': _passwordRed.text,
      'PasswordBlue': _passwordBlue.text,
      'Date': _date.text,
      'Owner': user!.email.toString(),
      'PasswordOrg': _passwordOrg.text
    });
  }

  Widget _createButton() {
    return ElevatedButton(
      onPressed: () {
        _checkError();
        if (!_error) {
          setState(() {});
          _addGame();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MapSample(
                        gameID: _gameID.text,
                      )));
        } else {
          setState(() {});
        }
      },
      child: const Text('Create game'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create game"),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(labelText: "Game ID"),
              controller: _gameID,
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Date"),
              controller: _date,
            ),
            TextField(
              decoration:
                  const InputDecoration(labelText: "Password for Red team"),
              controller: _passwordRed,
            ),
            TextField(
              decoration:
                  const InputDecoration(labelText: "Password for Blue team"),
              controller: _passwordBlue,
            ),
            TextField(
              decoration:
                  const InputDecoration(labelText: "Password for Organizers"),
              controller: _passwordOrg,
            ),
            if (_error)
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  )),
            _createButton(),
          ],
        ),
      ),
    );
  }
}
