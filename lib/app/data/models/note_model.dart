class NoteModel {
  final String id;
  final String userId;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? summary;
  final List<String> tags;
  final String? filePath;
  final String? fileUrl;
  final String? fileName;
  final int fileSize;

  NoteModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.summary,
    required this.tags,
    this.filePath,
    this.fileUrl,
    this.fileName,
    this.fileSize = 0,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      summary: json['summary'],
      tags: json['tags'] != null 
          ? List<String>.from(json['tags'])
          : [],
      filePath: json['file_path'],
      fileUrl: json['file_url'],
      fileName: json['file_name'],
      fileSize: json['file_size'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'summary': summary,
      'tags': tags,
      'file_path': filePath,
      'file_url': fileUrl,
      'file_name': fileName,
      'file_size': fileSize,
    };
  }

  NoteModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? summary,
    List<String>? tags,
    String? filePath,
    String? fileUrl,
    String? fileName,
    int? fileSize,
  }) {
    return NoteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      summary: summary ?? this.summary,
      tags: tags ?? this.tags,
      filePath: filePath ?? this.filePath,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
    );
  }

  bool get hasFile => filePath != null && filePath!.isNotEmpty;
}
