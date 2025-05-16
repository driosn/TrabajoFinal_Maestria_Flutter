class Document {
  final int? id;
  final String name;
  final String imgLocalPath;
  final String scannedText;
  final int statusId;
  final int userId;
  final DateTime createdAt;

  Document({
    this.id,
    required this.name,
    required this.imgLocalPath,
    required this.scannedText,
    required this.statusId,
    required this.userId,
    required this.createdAt,
  });

  Document copyWith({
    int? id,
    String? name,
    String? imgLocalPath,
    String? scannedText,
    int? statusId,
    int? userId,
    DateTime? createdAt,
  }) {
    return Document(
      id: id ?? this.id,
      name: name ?? this.name,
      imgLocalPath: imgLocalPath ?? this.imgLocalPath,
      scannedText: scannedText ?? this.scannedText,
      statusId: statusId ?? this.statusId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
