import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable()
class Message extends Object with _$MessageSerializerMixin {

  final String id;
  final String content;
  final String doctorId;
  final String patientId;
  final String type;
  final String author;

  Message({this.id, this.content, this.doctorId,this.patientId,this.type,this.author});


  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

}