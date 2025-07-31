import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String movieId;
  final String userId;
  final String userFullName;
  final String? userPhotoUrl;
  final String content;
  final DateTime createdAt;
  final int likes;
  final bool isEdited;

  CommentModel({
    required this.id,
    required this.movieId,
    required this.userId,
    required this.userFullName,
    this.userPhotoUrl,
    required this.content,
    required this.createdAt,
    this.likes = 0,
    this.isEdited = false,
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      movieId: data['movieId'],
      userId: data['userId'],
      userFullName: data['userFullName'],
      userPhotoUrl: data['userPhotoUrl'],
      content: data['content'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      likes: data['likes'] ?? 0,
      isEdited: data['isEdited'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'movieId': movieId,
      'userId': userId,
      'userFullName': userFullName,
      'userPhotoUrl': userPhotoUrl,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'likes': likes,
      'isEdited': isEdited,
    };
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  CommentModel copyWith({
    String? id,
    String? movieId,
    String? userId,
    String? userFullName,
    String? userPhotoUrl,
    String? content,
    DateTime? createdAt,
    int? likes,
    bool? isEdited,
  }) {
    return CommentModel(
      id: id ?? this.id,
      movieId: movieId ?? this.movieId,
      userId: userId ?? this.userId,
      userFullName: userFullName ?? this.userFullName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      isEdited: isEdited ?? this.isEdited,
    );
  }
}
