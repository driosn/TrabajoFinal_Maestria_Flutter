import '../../domain/entities/document.dart';

class DocumentModel extends Document {
  DocumentModel({
    required super.name,
    required super.imgLocalPath,
    required super.scannedText,
    required super.statusId,
    required super.userId,
    required super.createdAt,
    super.id,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as int,
      name: json['name'] as String,
      imgLocalPath: json['imgLocalPath'] as String,
      scannedText: json['scannedText'] as String,
      statusId: json['statusId'] as int,
      userId: json['userId'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  factory DocumentModel.fromDocument(Document document, {int? id}) {
    return DocumentModel(
      id: id ?? document.id,
      name: document.name,
      imgLocalPath: document.imgLocalPath,
      scannedText: document.scannedText,
      statusId: document.statusId,
      userId: document.userId,
      createdAt: document.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imgLocalPath': imgLocalPath,
      'scannedText': scannedText,
      'statusId': statusId,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
