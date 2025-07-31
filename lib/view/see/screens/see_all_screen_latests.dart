/*import 'package:flutter/material.dart';
import 'package:abbeav/database/movie_data.dart';
import 'package:abbeav/view/home/widgets/movie_card_widget.dart';
import 'package:abbeav/constants/app_spacing.dart';
import 'package:abbeav/style/app_color.dart';

class SeeAllScreenLatests extends StatelessWidget {
  const SeeAllScreenLatests({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'All Latest Movies',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: BackButton(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: GridView.builder(
          itemCount: MovieData.movies.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 22,
            crossAxisSpacing: 18,
            childAspectRatio: 0.62,
          ),
          itemBuilder: (context, i) {
            final movie = MovieData.movies[i];
            return AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              child: MovieCard(
                name: movie.name,
                image: movie.image,
                duration: movie.duration,
                rating: movie.rating,
                onTap: () {
                  // Naviguer vers MovieDetailsScreen
                },
              ),
            );
          },
        ),
      ),
    );
  }
}*/
