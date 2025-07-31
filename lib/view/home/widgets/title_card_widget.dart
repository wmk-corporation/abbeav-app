import 'package:abbeav/app_localizations.dart';
import 'package:abbeav/constants/app_spacing.dart';
import 'package:flutter/material.dart';

class TitleCardWidget extends StatelessWidget {
  const TitleCardWidget({
    super.key,
    required this.title,
    required this.onSeeAll,
  });
  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: Text(
            appLocalizations!.seeAll!,
            //'See All',
            style: TextStyle(color: Colors.grey),
          ),
        )
      ],
    );
  }
}
