import '../../../../core/database/database_helper.dart';
import '../../domain/entities/document.dart';
import '../../domain/repositories/document_repository.dart';
import '../models/document_model.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final DatabaseHelper _databaseHelper;

  DocumentRepositoryImpl(this._databaseHelper);

  @override
  Future<List<Document>> getDocuments() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('documents');
    return List.generate(maps.length, (i) => DocumentModel.fromJson(maps[i]));
  }

  @override
  Future<Document> createDocument(Document document) async {
    final db = await _databaseHelper.database;
    final id = await db.insert(
        'documents', DocumentModel.fromDocument(document).toJson());
    return DocumentModel.fromDocument(document, id: id);
  }

  @override
  Future<void> deleteDocument(int id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'documents',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<Document> updateDocument(Document document) async {
    final db = await _databaseHelper.database;
    await db.update(
      'documents',
      DocumentModel.fromDocument(document).toJson(),
      where: 'id = ?',
      whereArgs: [document.id],
    );
    return document;
  }

  @override
  Future<List<Document>> getDocumentsByStatus(int statusId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'documents',
      where: 'statusId = ?',
      whereArgs: [statusId],
    );
    return List.generate(maps.length, (i) => DocumentModel.fromJson(maps[i]));
  }
}
