import '../entities/document.dart';

abstract class DocumentRepository {
  Future<List<Document>> getDocuments();
  Future<List<Document>> getDocumentsByUser(int userId);
  Future<Document> createDocument(Document document);
  Future<void> deleteDocument(int id);
  Future<Document> updateDocument(Document document);
  Future<List<Document>> getDocumentsByStatus(int statusId);
  Future<List<Document>> getDocumentsByStatusAndUser(int statusId, int userId);
}
