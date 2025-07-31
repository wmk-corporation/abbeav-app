import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MovieModel {
  final String id;
  final String title;
  final Map<String, String>? descriptions;
  //final String? description;
  final List<String> categories; // Film, Série, Documentaire
  final List<String> genres; // Action, Sci-Fi, Thriller
  final String type; // 'movie' or 'series'
  final int? seasonNumber; // Pour les séries
  final int? episodeNumber; // Pour les séries
  final String thumbnailUrl;
  final String videoUrl;
  final List<String>? galleryImages;
  final List<CastModel>? cast;
  final DateTime releaseDate;
  final DateTime publishDate;
  final Duration duration;
  final bool isFree;
  final double rating;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final Map<String, dynamic>? metadata; // Résolution, taille, etc.
  final bool? isFeatured;
  final bool? isTrending;
  final bool? isNewRelease;
  final String? director;
  final List<String>? languages;
  final List<String>? subtitles;
  double? watchedProgress; // Pour la progression de visionnage

  MovieModel({
    required this.id,
    required this.title,
    this.descriptions,
    required this.categories,
    required this.genres,
    required this.type,
    this.seasonNumber,
    this.episodeNumber,
    required this.thumbnailUrl,
    required this.videoUrl,
    this.galleryImages,
    this.cast,
    required this.releaseDate,
    required this.publishDate,
    required this.duration,
    required this.isFree,
    required this.rating,
    required this.viewCount,
    required this.likeCount,
    required this.commentCount,
    this.metadata,
    this.isFeatured,
    this.isTrending,
    this.isNewRelease,
    this.director,
    this.languages,
    this.subtitles,
    this.watchedProgress,
  });

  factory MovieModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Conversion des descriptions
    final description = data['descriptions'] != null
        ? Map<String, String>.from(data['descriptions'])
        : {'fr': data['description'] ?? '', 'en': data['description'] ?? ''};

    // Fonction helper améliorée pour la conversion des listes
    List<String> _convertToStringList(dynamic list) {
      if (list == null) return [];
      if (list is List<String>) return list;
      return List<String>.from(list.map((e) => e.toString()));
    }

    // Fonction pour convertir les données des acteurs
    List<CastModel>? _convertToCastList(dynamic list) {
      if (list == null) return null;
      return List<CastModel>.from(
          list.map((x) => CastModel.fromMap(x as Map<String, dynamic>)));
    }

    return MovieModel(
      id: doc.id,
      title: data['title'] ?? '',
      descriptions: data['description'] != null
          ? Map<String, String>.from(data['description'])
          : null,
      categories: _convertToStringList(data['categories']),
      genres: _convertToStringList(data['genres']),
      type: data['type'] ?? 'movie',
      seasonNumber: data['seasonNumber'],
      episodeNumber: data['episodeNumber'],
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
      galleryImages: _convertToStringList(data['galleryImages']),
      cast: _convertToCastList(data['cast']),
      releaseDate: (data['releaseDate'] as Timestamp).toDate(),
      publishDate: (data['publishDate'] as Timestamp).toDate(),
      duration: Duration(seconds: data['duration'] ?? 0),
      isFree: data['isFree'] ?? false,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      viewCount: data['viewCount'] ?? 0,
      likeCount: data['likeCount'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
      metadata: data['metadata'] != null
          ? Map<String, dynamic>.from(data['metadata'])
          : null,
      isFeatured: data['isFeatured'] ?? false,
      isTrending: data['isTrending'] ?? false,
      isNewRelease: data['isNewRelease'] ?? false,
      director: data['director'],
      languages: _convertToStringList(data['languages']),
      subtitles: _convertToStringList(data['subtitles']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': descriptions,
      'categories': categories,
      'genres': genres,
      'type': type,
      'seasonNumber': seasonNumber,
      'episodeNumber': episodeNumber,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'galleryImages': galleryImages,
      'cast': cast?.map((x) => x.toMap()).toList(),
      'releaseDate': Timestamp.fromDate(releaseDate),
      'publishDate': Timestamp.fromDate(publishDate),
      'duration': duration.inSeconds,
      'isFree': isFree,
      'rating': rating,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'metadata': metadata,
      'isFeatured': isFeatured,
      'isTrending': isTrending,
      'isNewRelease': isNewRelease,
      'director': director,
      'languages': languages,
      'subtitles': subtitles,
    };
  }

  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  String get releaseYear => releaseDate.year.toString();

  bool get isSeries => type == 'series';

  bool get isMovie => type == 'movie';

  MovieModel copyWith({
    String? id,
    String? title,
    Map<String, String>? description,
    //String? description,
    List<String>? categories,
    List<String>? genres,
    String? type,
    int? seasonNumber,
    int? episodeNumber,
    String? thumbnailUrl,
    String? videoUrl,
    List<String>? galleryImages,
    List<CastModel>? cast,
    DateTime? releaseDate,
    DateTime? publishDate,
    Duration? duration,
    bool? isFree,
    double? rating,
    int? viewCount,
    int? likeCount,
    int? commentCount,
    Map<String, dynamic>? metadata,
    bool? isFeatured,
    bool? isTrending,
    bool? isNewRelease,
    String? director,
    List<String>? languages,
    List<String>? subtitles,
    double? watchedProgress,
  }) {
    return MovieModel(
      id: id ?? this.id,
      title: title ?? this.title,
      descriptions: description ??
          this.descriptions?.map(
              (k, v) => MapEntry(k, v)), //description ?? this.description,
      categories: categories ?? this.categories,
      genres: genres ?? this.genres,
      type: type ?? this.type,
      seasonNumber: seasonNumber ?? this.seasonNumber,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      galleryImages: galleryImages ?? this.galleryImages,
      cast: cast ?? this.cast,
      releaseDate: releaseDate ?? this.releaseDate,
      publishDate: publishDate ?? this.publishDate,
      duration: duration ?? this.duration,
      isFree: isFree ?? this.isFree,
      rating: rating ?? this.rating,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      metadata: metadata ?? this.metadata,
      isFeatured: isFeatured ?? this.isFeatured,
      isTrending: isTrending ?? this.isTrending,
      isNewRelease: isNewRelease ?? this.isNewRelease,
      director: director ?? this.director,
      languages: languages ?? this.languages,
      subtitles: subtitles ?? this.subtitles,
      watchedProgress: watchedProgress ?? this.watchedProgress,
    );
  }

  String getDescriptionForLanguage(String languageCode) {
    if (descriptions == null || descriptions!.isEmpty) {
      return '';
    }

    return descriptions![languageCode] ??
        descriptions!['en'] ??
        descriptions!.values.first;
  }
}

class CastModel {
  final String id;
  final String name;
  final String? photoUrl;
  final String role;
  final String? bio;

  CastModel({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.role,
    this.bio,
  });

  // Ajoutez cette méthode
  CastModel copyWith({
    String? id,
    String? name,
    String? photoUrl,
    String? role,
    String? bio,
  }) {
    return CastModel(
      id: id ?? this.id,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      bio: bio ?? this.bio,
    );
  }

  factory CastModel.fromMap(Map<String, dynamic> map) {
    return CastModel(
      id: map['id'],
      name: map['name'],
      photoUrl: map['photoUrl'],
      role: map['role'],
      bio: map['bio'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'photoUrl': photoUrl,
      'role': role,
      'bio': bio,
    };
  }
}

class ImageService {
  static Future<String> getDownloadUrl(String gsUrl) async {
    if (!gsUrl.startsWith('gs://')) return gsUrl;

    try {
      final uri = Uri.parse(gsUrl);
      final path = uri.path.split('/').sublist(2).join('/');
      final ref = FirebaseStorage.instance.ref(path);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error getting download URL: $e');
      return '';
    }
  }
}
