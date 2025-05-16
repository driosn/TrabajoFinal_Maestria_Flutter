import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/document.dart';
import '../../domain/repositories/document_repository.dart';

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  throw UnimplementedError('Override this provider');
});

class DocumentState {
  final List<Document> documents;
  final bool isLoading;
  final String? error;

  DocumentState({
    this.documents = const [],
    this.isLoading = false,
    this.error,
  });

  DocumentState copyWith({
    List<Document>? documents,
    bool? isLoading,
    String? error,
  }) {
    return DocumentState(
      documents: documents ?? this.documents,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class DocumentNotifier extends StateNotifier<DocumentState> {
  final DocumentRepository _documentRepository;

  DocumentNotifier(this._documentRepository) : super(DocumentState());

  Future<void> loadDocuments() async {
    state = state.copyWith(isLoading: true);
    try {
      final documents = await _documentRepository.getDocuments();
      state = state.copyWith(documents: documents, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadDocumentsByUser(int userId) async {
    state = state.copyWith(isLoading: true);
    try {
      final documents = await _documentRepository.getDocumentsByUser(userId);
      state = state.copyWith(documents: documents, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createDocument({
    required String name,
    required String imgLocalPath,
    required String scannedText,
    required int statusId,
    required int userId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final document = Document(
        name: name,
        imgLocalPath: imgLocalPath,
        scannedText: scannedText,
        statusId: statusId,
        userId: userId,
        createdAt: DateTime.now(),
      );
      await _documentRepository.createDocument(document);
      await loadDocumentsByUser(userId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateDocument(Document document) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _documentRepository.updateDocument(document);
      await loadDocumentsByUser(document.userId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> deleteDocument(int id, int userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _documentRepository.deleteDocument(id);
      await loadDocumentsByUser(userId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadDocumentsByStatus(int statusId) async {
    state = state.copyWith(isLoading: true);
    try {
      final documents =
          await _documentRepository.getDocumentsByStatus(statusId);
      state = state.copyWith(documents: documents, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadDocumentsByStatusAndUser(int statusId, int userId) async {
    state = state.copyWith(isLoading: true);
    try {
      final documents = await _documentRepository.getDocumentsByStatusAndUser(
          statusId, userId);
      state = state.copyWith(documents: documents, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final documentProvider =
    StateNotifierProvider<DocumentNotifier, DocumentState>((ref) {
  final repository = ref.watch(documentRepositoryProvider);
  return DocumentNotifier(repository);
});
