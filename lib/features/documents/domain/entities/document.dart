class Document {
  final int? id;
  final String name;
  final String imgLocalPath;
  final int statusId;
  final DateTime createdAt;

  Document({
    this.id,
    required this.name,
    required this.imgLocalPath,
    required this.statusId,
    required this.createdAt,
  });

  Document copyWith({
    int? id,
    String? name,
    String? imgLocalPath,
    int? statusId,
    DateTime? createdAt,
  }) {
    return Document(
      id: id ?? this.id,
      name: name ?? this.name,
      imgLocalPath: imgLocalPath ?? this.imgLocalPath,
      statusId: statusId ?? this.statusId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
