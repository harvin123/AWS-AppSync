import 'dart:async';

import 'package:appsync/message.dart';
import 'package:appsync/message_service.dart';
import 'package:flutter/material.dart';
import './loading.dart';

class TchatPage extends StatefulWidget {
  TchatPage({Key key, this.title,@required this.toUser}) : super(key: key);

  final String title;
  final String toUser;

  @override
  _TchatPageState createState() => new _TchatPageState();
}

class _TchatPageState extends State<TchatPage> {
  String _sender = "you";

  final textEditingController = new TextEditingController();

  final messageService = new MessageService();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    messageService.subscribeNewMessage(widget.toUser,_sender);
    _messages.addAll(await messageService.getAllMessages(widget.toUser,_sender));
    //messageService.subscribeNewMessage();
    //_messages.addAll(await messageService.getAllMessages());
    //_messages.addAll(await messageService.getmessages());
    //_messages.sort((a,b)=> b.id.compareTo(a.id));
    if (mounted) {
      setState(() {
        // refresh
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: new Text(widget.title),
        ),
        body: (widget.toUser == null) ? Loading() : _buildTchat());
  }

  StreamSubscription<Message> _streamSubscription;

  List<Message> _messages = [];

  final GlobalKey<AnimatedListState> _animateListKey =
  new GlobalKey<AnimatedListState>();

  Widget _buildTchat() {
    if (_streamSubscription == null) {
      _streamSubscription =
          messageService.messageBroadcast.stream.listen((message) {
            _messages.insert(0, message);
            _animateListKey.currentState?.insertItem(0);
          }, cancelOnError: false, onError: (e) => debugPrint(e));
    }

    return new Column(
      children: <Widget>[
        new Expanded(
          child: _buildList(),
        ),
        new Container(
          color: Colors.grey[200],
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: new Row(
            children: <Widget>[
              new Expanded(
                child: new TextFormField(
                  controller: textEditingController,
                  decoration: const InputDecoration(
                    hintText: 'type your message',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              new IconButton(
                icon: new Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _sendMessage() {
    final content = textEditingController.text;
    if (content.trim().isEmpty) {
      final snackBar = SnackBar(content: Text('Error, your message is empty'));
      _scaffoldKey.currentState.showSnackBar(snackBar);
      return;
    }
    messageService.sendMessage(content, _sender,widget.toUser,"0","1");
    textEditingController.clear();
  }

  Widget _buildList() {
    return new AnimatedList(
      key: _animateListKey,
      reverse: true,
      initialItemCount: _messages.length,
      itemBuilder:
          (BuildContext context, int index, Animation<double> animation) {
        final message = _messages[index];
        return new Directionality(
          textDirection:message.patientId == _sender ? TextDirection.rtl : TextDirection.ltr,
          child: new SizeTransition(
            axis: Axis.vertical,
            sizeFactor: animation,
            child: _buildMessageItem(message),
          ),
        );
      },
    );
  }

  Widget _buildMessageItem(Message message) {
    return new ListTile(
      title: new Text(message.content),
      subtitle: new Text(message.patientId),

    );
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    textEditingController.dispose();
    super.dispose();
  }
}
