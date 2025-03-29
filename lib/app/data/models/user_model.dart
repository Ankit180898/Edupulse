class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final DateTime createdAt;
  final bool isSubscribed;
  final DateTime? subscriptionExpiry;
  final int dailyQueriesUsed;
  final int dailyQueriesLimit;
  final DateTime lastQueryReset;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    required this.createdAt,
    required this.isSubscribed,
    this.subscriptionExpiry,
    required this.dailyQueriesUsed,
    required this.dailyQueriesLimit,
    required this.lastQueryReset,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      photoUrl: json['photo_url'],
      createdAt: DateTime.parse(json['created_at']),
      isSubscribed: json['is_subscribed'] ?? false,
      subscriptionExpiry: json['subscription_expiry'] != null 
          ? DateTime.parse(json['subscription_expiry']) 
          : null,
      dailyQueriesUsed: json['daily_queries_used'] ?? 0,
      dailyQueriesLimit: json['daily_queries_limit'] ?? 5,
      lastQueryReset: json['last_query_reset'] != null 
          ? DateTime.parse(json['last_query_reset']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photo_url': photoUrl,
      'created_at': createdAt.toIso8601String(),
      'is_subscribed': isSubscribed,
      'subscription_expiry': subscriptionExpiry?.toIso8601String(),
      'daily_queries_used': dailyQueriesUsed,
      'daily_queries_limit': dailyQueriesLimit,
      'last_query_reset': lastQueryReset.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    DateTime? createdAt,
    bool? isSubscribed,
    DateTime? subscriptionExpiry,
    int? dailyQueriesUsed,
    int? dailyQueriesLimit,
    DateTime? lastQueryReset,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      dailyQueriesUsed: dailyQueriesUsed ?? this.dailyQueriesUsed,
      dailyQueriesLimit: dailyQueriesLimit ?? this.dailyQueriesLimit,
      lastQueryReset: lastQueryReset ?? this.lastQueryReset,
    );
  }

  bool get hasReachedQueryLimit => dailyQueriesUsed >= dailyQueriesLimit;
  
  bool get shouldResetDailyQueries {
    final now = DateTime.now();
    return now.difference(lastQueryReset).inDays > 0;
  }
}
