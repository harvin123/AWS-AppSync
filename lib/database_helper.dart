import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
final String ChatData = 'ChatData';
final String ChatContent = "content";
final String ChatId = 'id';
final String ChatSender = 'sender';

//data model class
class DatabaseMessage
{
  int id;
  String content;
  String sender;
  DatabaseMessage();

  DatabaseMessage.fromMap(Map<String,dynamic> map)
  {
    id = map[ChatId];
    content = map[ChatContent];
    sender = map[ChatSender];
  }

  Map<String,dynamic> toMap()
  {
    var map=<String,dynamic>{
      ChatContent: content,
      ChatSender : sender
    };
    if (id !=null)
      map[ChatId] = id;
    return map;
  }
}

class DatabaseHelper {

  static final _databaseName = "MyDatabase.db";
  static  final _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database _database;

  // Only allow a single open connection to the database.
  Future<Database> get database async{
    if(_database!=null)
      return _database;
    _database = await _initDatabase();
    return _database;
  }

  // open the database
  _initDatabase() async{
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path,_databaseName);
    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(path,version:_databaseVersion,onCreate: _onCreate);
  }

  Future _onCreate(Database db,int  version) async{
    await db.execute(''' CREATE TABLE $ChatData (
                $ChatId INTEGER PRIMARY KEY,
                $ChatContent TEXT NOT NULL,
                $ChatSender TEXT NOT NULL
              )'''
    );
  }

  // Database helper methods:
  Future<int> insert(DatabaseMessage mesg) async {
    Database db = await database;
    int id = await db.insert(ChatData, mesg.toMap());
    return id;
  }

  Future<DatabaseMessage> queryMsg(int id) async {
    Database db = await database;
    List<Map> maps = await db.query(ChatData,
        columns: [ChatId, ChatContent, ChatContent],
        where: '$ChatId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return DatabaseMessage.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Map>> queryAllMsg() async {
    Database db = await database;
    List<Map> maps = await db.query(ChatData);
    return maps;
  }
}