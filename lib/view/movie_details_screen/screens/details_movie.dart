import 'package:abbeav/controller/movie_controller.dart';
import 'package:abbeav/firebase_config.dart';
import 'package:abbeav/models/movies_model.dart';
import 'package:abbeav/view/home/widgets/star_rating_widget.dart';
import 'package:flutter/material.dart';

class MovieDetailsScreen extends StatefulWidget {
  final String movieId;

  const MovieDetailsScreen({Key? key, required this.movieId}) : super(key: key);

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final MovieController _movieController =
      MovieController(firestore: FirebaseConfig.firestore);
  late Future<MovieModel> _movieFuture;

  @override
  void initState() {
    super.initState();
    _movieFuture = _movieController.getMovieDetails(widget.movieId);
    _movieController.incrementViewCount(widget.movieId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<MovieModel>(
        future: _movieFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error loading movie details'));
          }

          final movie = snapshot.data!;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      Image.network(
                        movie.thumbnailUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          StarRatingWidget(rating: movie.rating.toString()),
                          const SizedBox(width: 16),
                          Text(movie.releaseYear),
                          const SizedBox(width: 16),
                          Text(movie.formattedDuration),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        children: movie.genres
                            .map((genre) => Chip(label: Text(genre)))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        movie.descriptions?['fr'] ??
                            movie.descriptions?['en'] ??
                            '',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      // Ajoutez ici les sections pour les acteurs, les commentaires, etc.
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
