import 'package:flutter/material.dart';

class MovieModel {
  final String id;
  final String image;
  final String name;
  final String duration;
  final String rating;
  final double downloadProgress;
  final String downloadStatus;
  final String downloadSize;
  final String downloadTime;
  final String? watchProgress;
  final String? lastWatched;

  MovieModel(
    this.image, {
    required this.name,
    required this.duration,
    required this.rating,
    String? id,
    this.downloadProgress = 1.0,
    this.downloadStatus = 'Downloaded',
    this.downloadSize = '1.5GB',
    this.downloadTime = '1h ago',
    this.watchProgress,
    this.lastWatched,
  }) : id = (id == null || id.isEmpty) ? UniqueKey().toString() : id;

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      json['image'] as String,
      name: json['name'] as String,
      duration: json['duration'] as String,
      rating: json['rating'] as String,
      downloadProgress: (json['downloadProgress'] as num).toDouble(),
      downloadStatus: json['downloadStatus'] as String,
      downloadSize: json['downloadSize'] as String,
      downloadTime: json['downloadTime'] as String,
      // Assuming watchProgress and lastWatched are optional
      watchProgress: json['watchProgress'] as String?,
      lastWatched: json['lastWatched'] as String?,
      // other fields,
      //watchProgress: json['watchProgress'] as String?,
      //lastWatched: json['lastWatched'] as String?,
    );
  }
}

/*class MovieModel {
  final String name;
  final String image;
  final String duration;
  final String rating;
  final String? watchProgress;
  final String? lastWatched;

  MovieModel(
    this.image, {
    required this.name,
    required this.duration,
    required this.rating,
    this.watchProgress,
    this.lastWatched,
  });

  // If you use fromJson or similar, update those as well:
  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      json['image'] as String,
      name: json['name'] as String,
      duration: json['duration'] as String,
      rating: json['rating'] as String,
      // Assuming watchProgress and lastWatched are optional
      watchProgress: json['watchProgress'] as String?,
      lastWatched: json['lastWatched'] as String?,
      // other fields,
      watchProgress: json['watchProgress'] as String?,
      lastWatched: json['lastWatched'] as String?,
    );
  }
}*/
