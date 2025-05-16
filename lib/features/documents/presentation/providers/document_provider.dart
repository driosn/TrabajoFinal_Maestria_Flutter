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

  DocumentNotifier(this._documentRepository) : super(DocumentState()) {
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
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

  Future<void> createDocument({
    required String name,
    required String imgLocalPath,
    required int statusId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final document = Document(
        name: name,
        imgLocalPath: imgLocalPath,
        statusId: statusId,
        createdAt: DateTime.now(),
      );
      await _documentRepository.createDocument(document);
      await _loadDocuments();
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
      await _loadDocuments();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> deleteDocument(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _documentRepository.deleteDocument(id);
      await _loadDocuments();
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
}

final documentProvider =
    StateNotifierProvider<DocumentNotifier, DocumentState>((ref) {
  final repository = ref.watch(documentRepositoryProvider);
  return DocumentNotifier(repository);
});
