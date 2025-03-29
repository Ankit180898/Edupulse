class FlashcardModel {
  final String id;
  final String userId;
  final String question;
  final String answer;
  final String? hint;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final String? noteId;
  final int familiarity; // 1-5 scale (1: Not familiar, 5: Very familiar)
  final DateTime? lastReviewed;

  FlashcardModel({
    required this.id,
    required this.userId,
    required this.question,
    required this.answer,
    this.hint,
    required this.createdAt,
    required this.updatedAt,
    required this.tags,
    this.noteId,
    this.familiarity = 1,
    this.lastReviewed,
  });

  factory FlashcardModel.fromJson(Map<String, dynamic> json) {
    return FlashcardModel(
      id: json['id'],
      userId: json['user_id'],
      question: json['question'],
      answer: json['answer'],
      hint: json['hint'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      tags: json['tags'] != null 
          ? List<String>.from(json['tags'])
          : [],
      noteId: json['note_id'],
      familiarity: json['familiarity'] ?? 1,
      lastReviewed: json['last_reviewed'] != null 
          ? DateTime.parse(json['last_reviewed']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'question': question,
      'answer': answer,
      'hint': hint,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'tags': tags,
      'note_id': noteId,
      'familiarity': familiarity,
      'last_reviewed': lastReviewed?.toIso8601String(),
    };
  }

  FlashcardModel copyWith({
    String? id,
    String? userId,
    String? question,
    String? answer,
    String? hint,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    String? noteId,
    int? familiarity,
    DateTime? lastReviewed,
  }) {
    return FlashcardModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      hint: hint ?? this.hint,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      noteId: noteId ?? this.noteId,
      familiarity: familiarity ?? this.familiarity,
      lastReviewed: lastReviewed ?? this.lastReviewed,
    );
  }

  bool get needsReview {
    if (lastReviewed == null) return true;
    
    final now = DateTime.now();
    final daysSinceLastReview = now.difference(lastReviewed!).inDays;
    
    // Review frequency based on familiarity
    switch (familiarity) {
      case 1: return daysSinceLastReview >= 1;  // Review daily
      case 2: return daysSinceLastReview >= 3;  // Review every 3 days
      case 3: return daysSinceLastReview >= 7;  // Review weekly
      case 4: return daysSinceLastReview >= 14; // Review bi-weekly
      case 5: return daysSinceLastReview >= 30; // Review monthly
      default: return true;
    }
  }
}
