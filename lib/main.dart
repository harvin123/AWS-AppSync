import 'dart:async';

import 'package:flutter/material.dart';
import 'chat.dart';
void main() => runApp(new App());

class App extends StatelessWidget {
  @override
  final textEditingController = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body : Container(
          child: new Padding(
            padding: const EdgeInsets.all(32.0),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new TextFormField(
                  controller: textEditingController,
                  decoration: InputDecoration(
                    hintText: 'Enter the doctor name',
                  ),
                ),
                new SizedBox(height: 16.0),
                new RaisedButton(
                  child: new Text("Validate"),
                  onPressed: () {
                    if (textEditingController.text.isEmpty) {
                      final snackBar = SnackBar(
                          content: Text('Error, your sender name is empty'));
                      _scaffoldKey.currentState.showSnackBar(snackBar);
                      return;
                    }
                          TchatPage(title: textEditingController.text,toUser: textEditingController.text);
                    textEditingController.clear();
                  },
                ),
              ],
            ),
          ),
        ),),
    );
  }
}

