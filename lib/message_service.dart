import 'dart:async';
import 'dart:convert';

import 'package:appsync/constants.dart';
import 'package:appsync/message.dart';
import 'package:flutter/services.dart';

import './database_helper.dart';

class MessageService {
  static const CHANNEL_NAME = 'com.ineat.appsync';
  static const QUERY_GET_ALL_MESSAGES = 'getAllMessages';
  static const MUTATION_NEW_MESSAGE = 'newMessage';
  static const SUBSCRIBE_NEW_MESSAGE = 'subscribeNewMessage';
  static const SUBSCRIBE_NEW_MESSAGE_RESULT = 'subscribeNewMessageResult';

  static const Map<String, dynamic> _DEFAULT_PARAMS = <String, dynamic>{
    'endpoint': AWS_APP_SYNC_ENDPOINT,
    'apiKey': AWS_APP_SYNC_KEY
  };

  static const MethodChannel APP_SYNC_CHANNEL =
      const MethodChannel(CHANNEL_NAME);

  MessageService() {
    APP_SYNC_CHANNEL.setMethodCallHandler(_handleMethod);
  }

  final StreamController<Message> messageBroadcast =
      new StreamController<Message>.broadcast();

  Future<List<Message>> getAllMessages(String patientId ,String doctorId) async {
    final params = {"doctorId": doctorId,"patientId": patientId};
    String jsonString = await APP_SYNC_CHANNEL.invokeMethod(
        QUERY_GET_ALL_MESSAGES, _buildParams(otherParams: params));
    List<dynamic> values = json.decode(jsonString);
    return values.map((value) => Message.fromJson(value)).toList();
  }

  Future<Message> sendMessage(String content, String doctorId,String patientId,String type,String author) async {
    final params = {"content": content, "doctorId": doctorId,"patientId": patientId,"type":type,"author":author};
    String jsonString = await APP_SYNC_CHANNEL.invokeMethod(
        MUTATION_NEW_MESSAGE, _buildParams(otherParams: params));
    Map<String, dynamic> values = json.decode(jsonString);
    return Message.fromJson(values);
  }

    void subscribeNewMessage(String patientId,String doctorId) {
    final params = {"patientId": patientId, "doctorId":doctorId};
    APP_SYNC_CHANNEL.invokeMethod(SUBSCRIBE_NEW_MESSAGE, _buildParams(otherParams: params));
  }

  Future<Null> _handleMethod(MethodCall call) async {
    if (call.method == SUBSCRIBE_NEW_MESSAGE_RESULT) {
      String jsonString = call.arguments;
      try {
        Map<String, dynamic> values = json.decode(jsonString);
        //values["id"] =  int.parse(values["id"]);
        Message message = Message.fromJson(values);
        //_save(message);
        messageBroadcast.add(message);
      } catch (e) {
        print(e);
      }
    }
    return null;
  }
/*
  _save(Message message) async {
    DatabaseMessage dbmsg = DatabaseMessage();
    dbmsg.content = message.content;
    dbmsg.sender = message.sender;
    DatabaseHelper helper = DatabaseHelper.instance;
    int id = await helper.insert(dbmsg);
    print('inserted row: $id');
  }

  _read() async {
    DatabaseHelper helper = DatabaseHelper.instance;
    int rowId = 1;
    DatabaseMessage dbmsg = await helper.queryMsg(rowId);
    if (dbmsg == null) {
      print('read row $rowId: empty');
    } else {
      print('read row $rowId: ${dbmsg.content} ${dbmsg.sender}');
    }
  }

  Future<List<Message>> getmessages() async
  {
    DatabaseHelper helper = DatabaseHelper.instance;
    List<Map> dbmsg = await helper.queryAllMsg();
    //return dbmsg.
    return dbmsg.map((value) => Message.fromJson(value)).toList();
  }
*/
  Map<String, dynamic> _buildParams({Map<String, dynamic> otherParams}) {
    final params = new Map<String, dynamic>.from(_DEFAULT_PARAMS);
    if (otherParams != null) {
      params.addAll(otherParams);
    }
    return params;
  }
}
