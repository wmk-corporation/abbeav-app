import 'package:flutter/material.dart';
import 'package:abbeav/constants/app_spacing.dart';
import 'package:abbeav/view/home/widgets/star_rating_widget.dart';

class SearchMovieCard extends StatelessWidget {
  const SearchMovieCard({
    super.key,
    required this.name,
    required this.image,
    required this.duration,
    required this.rating,
    required this.onTap,
  });
  final String name;
  final String image;
  final String duration;
  final String rating;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            width: 160,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(image), fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(10)),
          ),
          AppSpacing.h10,
          Text(
            name,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white),
          ),
          AppSpacing.h10,
          SizedBox(
            width: 130,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  duration,
                  style: const TextStyle(color: Colors.grey),
                ),
                StarRatingWidget(rating: rating)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
