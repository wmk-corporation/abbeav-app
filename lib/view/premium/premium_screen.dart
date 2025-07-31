import 'package:abbeav/app_localizations.dart';
import 'package:abbeav/style/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    ThemeData theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: double.infinity),
                Text(
                  appLocalizations!.premiumSubscription!,
                  //'Abonnement Premium',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: AppColor.secondary, //const Color(0xFF3DCBFF),
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  appLocalizations!.bodyPremium2!,
                  //'Profitez de films Full-HD sans aucune restriction et sans publicité.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.90),
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 32),
                PremiumItemCard(
                  subscriptionPrice: '5 000',
                  subscriptionTime: appLocalizations!.month!, //'mois',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PremiumItemCard extends StatelessWidget {
  final String subscriptionPrice;
  final String subscriptionTime;

  const PremiumItemCard({
    super.key,
    required this.subscriptionPrice,
    required this.subscriptionTime,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    ThemeData theme = Theme.of(context);
    final features = [
      appLocalizations!.fullHD!,
      appLocalizations!.noAds!,
      appLocalizations!.unlimitedAccess!,
      appLocalizations!.previews!,
      //"Films en Full-HD",
      //"Sans publicité",
      //"Accès illimité",
      //"Nouveautés en avant-première",
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColor.primary,
        //color: Colors.blueGrey,
        border: Border.all(
          color: const Color(0xFF3DCBFF).withOpacity(0.2),
          width: 1,
        ),
        /*gradient: const LinearGradient(
          colors: [Color(0xFF3DCBFF), Color(0xFF7D3CF8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),*/
        borderRadius: BorderRadius.circular(24),
        /*boxShadow: [
          BoxShadow(
            color: const Color(0xFF3DCBFF).withOpacity(0.13),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],*/
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          children: [
            SvgPicture.asset(
              'assets/images/icon_premium.svg',
              width: 52,
              height: 52,
              color: const Color(0xFF3DCBFF),
            ),
            const SizedBox(height: 18),
            RichText(
              text: TextSpan(
                text: '$subscriptionPrice FCFA',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  letterSpacing: 0.2,
                ),
                children: [
                  const WidgetSpan(child: SizedBox(width: 8)),
                  TextSpan(
                    text: '/$subscriptionTime',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Divider(
              color: Colors.white.withOpacity(0.12),
              thickness: 1,
              height: 1,
            ),
            const SizedBox(height: 18),
            Column(
              children: features
                  .map(
                    (feature) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/images/icon_done.svg',
                            width: 22,
                            height: 22,
                            color: const Color(0xFF3DCBFF),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            feature,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.92),
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            AnimatedGradientButton(
              onPressed: () {
                // TODO: Action d'achat premium
              },
              text: appLocalizations!.subscribeNow!,
              //text: "S'abonner maintenant",
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedGradientButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;

  const AnimatedGradientButton({
    Key? key,
    required this.onPressed,
    required this.text,
  }) : super(key: key);

  @override
  State<AnimatedGradientButton> createState() => _AnimatedGradientButtonState();
}

class _AnimatedGradientButtonState extends State<AnimatedGradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _gradientAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _gradientAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _gradientAnim,
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.onPressed,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: const [Color(0xFF3DCBFF), Color(0xFF7D3CF8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [
                  _gradientAnim.value * 0.5,
                  1 - _gradientAnim.value * 0.5
                ],
                transform: GradientRotation(_gradientAnim.value * 3.14),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3DCBFF).withOpacity(0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
