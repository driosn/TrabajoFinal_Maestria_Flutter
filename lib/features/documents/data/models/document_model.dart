import '../../domain/entities/document.dart';

class DocumentModel extends Document {
  DocumentModel({
    int? id,
    required String name,
    required String imgLocalPath,
    required int statusId,
    required DateTime createdAt,
  }) : super(
          id: id,
          name: name,
          imgLocalPath: imgLocalPath,
          statusId: statusId,
          createdAt: createdAt,
        );

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'],
      name: json['name'],
      imgLocalPath: json['imgLocalPath'],
      statusId: json['statusId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  factory DocumentModel.fromDocument(Document document, {int? id}) {
    return DocumentModel(
      id: id ?? document.id,
      name: document.name,
      imgLocalPath: document.imgLocalPath,
      statusId: document.statusId,
      createdAt: document.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imgLocalPath': imgLocalPath,
      'statusId': statusId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
