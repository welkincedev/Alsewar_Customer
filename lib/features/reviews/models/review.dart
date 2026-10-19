class CustomerReview {
  final int id;
  final int visitId;
  final Map<String, dynamic>? visitDetails;
  final Map<String, dynamic>? branchDetails;
  final int rating;
  final String? comment;
  final bool isApproved;
  final String createdAt;

  const CustomerReview({
    required this.id,
    required this.visitId,
    this.visitDetails,
    this.branchDetails,
    required this.rating,
    this.comment,
    required this.isApproved,
    required this.createdAt,
  });

  factory CustomerReview.fromJson(Map<String, dynamic> json) {
    return CustomerReview(
      id: (json['id'] as num).toInt(),
      visitId: (json['visit_id'] as num? ?? 0).toInt(),
      visitDetails: json['visit_details'] as Map<String, dynamic>?,
      branchDetails: json['branch_details'] as Map<String, dynamic>?,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment']?.toString() ?? json['feedback']?.toString(),
      isApproved: (json['is_approved'] as bool?) ?? true,
      createdAt: (json['created_at'] ?? '').toString(),
    );
  }

  String get visitNumber => (visitDetails?['visit_number'] ?? '').toString();
  String get branchName => (branchDetails?['name'] ?? '').toString();
}

class ReviewRequest {
  final int visitId;
  final int rating;
  final String? comment;

  const ReviewRequest({
    required this.visitId,
    required this.rating,
    this.comment,
  });

  Map<String, dynamic> toJson() {
    return {
      'visit_id': visitId,
      'rating': rating,
      if (comment != null && comment!.trim().isNotEmpty)
        'comment': comment!.trim(),
    };
  }
}
