/*import 'package:flutter/material.dart';
import 'package:abbeav/database/movie_data.dart';
import 'package:abbeav/view/search/widgets/actors_card.dart';
import 'package:abbeav/constants/app_spacing.dart';
import 'package:abbeav/style/app_color.dart';

class SeeAllScreenActors extends StatelessWidget {
  const SeeAllScreenActors({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'All Popular Actors',
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
          itemCount: MovieData.actors.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 22,
            crossAxisSpacing: 18,
            childAspectRatio: 0.7,
          ),
          itemBuilder: (context, i) {
            final actor = MovieData.actors[i];
            return AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              child: ActorsCard(
                image: actor.image,
                name: actor.name,
                onTap: () {
                  // Naviguer vers ActorDetailsScreen
                },
              ),
            );
          },
        ),
      ),
    );
  }
}*/
