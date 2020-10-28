// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => new Message(
    id: json['id'] as String,
    content: json['content'] as String,
    patientId: json['patientId'] as String,
    doctorId: json['doctorId'] as String,
    type: json['type'] as String,
    author: json['author'] as String);

abstract class _$MessageSerializerMixin {
  String get id;
  String get content;
  String get patientId;
  String get doctorId;
  String get type;
  String get author;
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'id': id, 'content': content, 'patientId': patientId,'doctorId':doctorId,'type':type,'author':author};
}
