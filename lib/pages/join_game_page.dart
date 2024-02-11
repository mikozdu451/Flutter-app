import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:first_project/pages/home_page.dart';
import 'package:first_project/pages/create_game_page.dart';
import 'package:first_project/auth.dart';

class JoinGame extends StatefulWidget {
  @override
  State<JoinGame> createState() => _JoinGamePageState();
}

class _JoinGamePageState extends State<JoinGame> {
  final _gameID = TextEditingController();
  final _password = TextEditingController();

  var _error = false;
  var _errorMessage = '';

  void _checkError() {
    if (_gameID.text.isEmpty && (_password.text.isEmpty)) {
      _error = true;
      _errorMessage = "Please put all the informations into the fields!";
      return;
    } else {
      _error = false;
      _errorMessage = '';
    }
  }

  Future<void> signOut() async {
    await Auth().signOut();
  }

  Future<bool> _checkPassword() async {
    var collection = FirebaseFirestore.instance.collection('Games');
    var querySnapshot = await collection.get();
    for (var queryDocumentSnapshot in querySnapshot.docs) {
      if (queryDocumentSnapshot.id == "Game${_gameID.text}") {
        Map<String, dynamic> data = queryDocumentSnapshot.data();

        if (_password.text == data['Password']) {
          return Future.value(true);
        } else {
          return Future.value(false);
        }
      }
    }
    return Future.value(false);
  }

  Widget _joinButton() {
    return ElevatedButton(
      onPressed: () async {
        _checkError();
        if (!_error) {
          setState(() {});
          bool result;

          result = await _checkPassword();

          if (result) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MapSample(
                          gameID: _gameID.text,
                        )));
          } else {
            _error = true;
            _errorMessage = "Wrong password";
            setState(() {});
          }
        } else {
          setState(() {});
        }
      },
      child: const Text('Join game'),
    );
  }

  Widget _createButton() {
    return ElevatedButton(
      onPressed: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateGame())),
      child: const Text('Create game'),
    );
  }

  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: signOut,
      child: const Text('Sign out'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Join game"),
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
              decoration: const InputDecoration(labelText: "Password"),
              controller: _password,
            ),
            if (_error)
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  )),
            _joinButton(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Container(
                height: 1.0,
                width: 800.0,
                color: Colors.black,
              ),
            ),
            _createButton(),
            _signOutButton()
          ],
        ),
      ),
    );
  }
}
