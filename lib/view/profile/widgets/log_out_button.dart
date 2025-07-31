import 'package:abbeav/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:abbeav/constants/app_spacing.dart';
import 'package:abbeav/style/app_color.dart';

class LogOutButton extends StatelessWidget {
  const LogOutButton({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            color: AppColor.primary, borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.logout,
                  color: Colors.redAccent,
                ),
                AppSpacing.w10,
                Text(
                  appLocalizations!.logout!,
                  //'Logout',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: Colors.redAccent,
            )
          ],
        ),
      ),
    );
  }
}
