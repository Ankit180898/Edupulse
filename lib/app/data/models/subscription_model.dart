class SubscriptionModel {
  final String id;
  final String userId;
  final SubscriptionType type;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final double price;
  final String? transactionId;
  final String? paymentMethod;
  final int aiCreditsUsed;
  final int aiCreditsTotal;

  SubscriptionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.price,
    this.transactionId,
    this.paymentMethod,
    this.aiCreditsUsed = 0,
    this.aiCreditsTotal = 0,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'],
      userId: json['user_id'],
      type: _parseSubscriptionType(json['type']),
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      isActive: json['is_active'] ?? false,
      price: (json['price'] ?? 0).toDouble(),
      transactionId: json['transaction_id'],
      paymentMethod: json['payment_method'],
      aiCreditsUsed: json['ai_credits_used'] ?? 0,
      aiCreditsTotal: json['ai_credits_total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.toString().split('.').last,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_active': isActive,
      'price': price,
      'transaction_id': transactionId,
      'payment_method': paymentMethod,
      'ai_credits_used': aiCreditsUsed,
      'ai_credits_total': aiCreditsTotal,
    };
  }

  static SubscriptionType _parseSubscriptionType(String? type) {
    switch (type) {
      case 'monthly':
        return SubscriptionType.monthly;
      case 'quarterly':
        return SubscriptionType.quarterly;
      case 'yearly':
        return SubscriptionType.yearly;
      default:
        return SubscriptionType.free;
    }
  }

  int get daysRemaining {
    final now = DateTime.now();
    if (endDate.isBefore(now)) return 0;
    return endDate.difference(now).inDays;
  }

  bool get isExpired => DateTime.now().isAfter(endDate);

  String get formattedStartDate {
    return '${startDate.day}/${startDate.month}/${startDate.year}';
  }

  String get formattedEndDate {
    return '${endDate.day}/${endDate.month}/${endDate.year}';
  }

  SubscriptionModel copyWith({
    String? id,
    String? userId,
    SubscriptionType? type,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    double? price,
    String? transactionId,
    String? paymentMethod,
    int? aiCreditsUsed,
    int? aiCreditsTotal,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      price: price ?? this.price,
      transactionId: transactionId ?? this.transactionId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      aiCreditsUsed: aiCreditsUsed ?? this.aiCreditsUsed,
      aiCreditsTotal: aiCreditsTotal ?? this.aiCreditsTotal,
    );
  }

  String get planName {
    switch (type) {
      case SubscriptionType.free:
        return 'Free Plan';
      case SubscriptionType.monthly:
        return 'Monthly Plan';
      case SubscriptionType.quarterly:
        return 'Quarterly Plan';
      case SubscriptionType.yearly:
        return 'Yearly Plan';
    }
  }

  int get queryLimit {
    switch (type) {
      case SubscriptionType.free:
        return 5;
      case SubscriptionType.monthly:
        return 50;
      case SubscriptionType.quarterly:
        return 100;
      case SubscriptionType.yearly:
        return 200;
    }
  }
}

enum SubscriptionType {
  free,
  monthly,
  quarterly,
  yearly,
}