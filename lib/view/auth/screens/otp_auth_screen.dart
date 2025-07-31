import 'dart:async';
import 'dart:ui';
import 'package:abbeav/app_localizations.dart';
import 'package:abbeav/constants/app_spacing.dart';
import 'package:abbeav/controller/user_controller.dart';
import 'package:abbeav/style/app_color.dart';
import 'package:abbeav/view/home/screens/landing_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pinput/pinput.dart';

class OtpAuthenticationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  const OtpAuthenticationScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
  });
  @override
  State<OtpAuthenticationScreen> createState() =>
      _OtpAuthenticationScreenState();
}

class _OtpAuthenticationScreenState extends State<OtpAuthenticationScreen>
    with TickerProviderStateMixin {
  final _otpController = TextEditingController();
  final int _otpLength = 5;
  bool _loading = false;
  bool _autoFill = false;
  String? _errorText;
  late AnimationController _fadeAnimCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // Resend logic
  int _resendSeconds = 60;
  Timer? _resendTimer;
  bool _canResend = false;

  // Keyboard state
  bool _keyboardVisible = false;
  late FocusNode _otpFocusNode;

  @override
  void initState() {
    super.initState();
    _otpFocusNode = FocusNode();
    _otpFocusNode.addListener(_handleKeyboardVisibility);

    _fadeAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeAnimCtrl, curve: Curves.easeInOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(_fadeAnim);

    _fadeAnimCtrl.forward();
    _startResendTimer();
  }

  void _handleKeyboardVisibility() {
    setState(() {
      _keyboardVisible = _otpFocusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _fadeAnimCtrl.dispose();
    _otpController.dispose();
    _resendTimer?.cancel();
    _otpFocusNode.removeListener(_handleKeyboardVisibility);
    _otpFocusNode.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendSeconds = 60;
      _canResend = false;
    });
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds == 0) {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      } else {
        setState(() {
          _resendSeconds--;
        });
      }
    });
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.length != 6) {
      setState(() => _errorText = "Please enter 6-digit code");
      return;
    }

    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      final userController = UserController();
      final user = await userController.verifyOTP(
        verificationId: widget.verificationId,
        smsCode: _otpController.text.trim(),
      );

      await _showWelcomeLoader();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LandingScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _errorText = "Invalid OTP. Please try again.";
      });
    }
  }

  /*void _onResend(String msg) {
    if (_canResend) {
      _startResendTimer();
      _showAnimatedSnackBar(
        msg,
        icon: Icons.code,
      );
    }
  }*/

  Future<void> _resendOTP(String msg) async {
    if (!_canResend) return;

    try {
      final userController = UserController();
      final newVerificationId =
          await userController.verifyPhoneNumber(widget.phoneNumber);

      setState(() {
        //_verificationId = newVerificationId;
        _startResendTimer();
      });

      await _showAnimatedSnackBar(
        "New OTP sent to ${widget.phoneNumber}",
        icon: Icons.sms_outlined,
      );
    } catch (e) {
      await _showAnimatedSnackBar(
        "Failed to resend OTP: ${e.toString()}",
        icon: Icons.error_outline,
        error: true,
      );
    }
  }

  Future<void> _handleSuccessfulVerification() async {
    // 1. Fermer le clavier
    _otpFocusNode.unfocus();
    setState(() => _keyboardVisible = false);

    // 2. Attendre que le clavier soit complètement fermé
    await Future.delayed(const Duration(milliseconds: 350));

    // 3. Afficher le loader "Welcome..."
    //await _showWelcomeLoader();
    await _goToOTPScreen(context);

    // 4. Naviguer vers l'écran d'accueil
    if (mounted) {
      await _navigateToLandingScreen();
    }
  }

  Future<void> _showWelcomeLoader() async {
    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      barrierDismissible: false,
      builder: (context) => const _LandingFadeLoader(),
    );
  }

  Future<void> _navigateToLandingScreen() async {
    await Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LandingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fade = CurvedAnimation(
              parent: animation, curve: Curves.easeInOutCubicEmphasized);
          final slide =
              Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                  .animate(fade);

          return FadeTransition(
            opacity: fade,
            child: SlideTransition(position: slide, child: child),
          );
        },
      ),
    );
  }

  Future<void> _onCompleted(String code, String msgError) async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _errorText = null;
    });

    // Simuler la vérification OTP
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    setState(() => _loading = false);

    try {
      await _verifyOTP();
    } catch (e) {
      setState(() {
        _loading = false;
        _errorText = msgError;
      });
    }

    // --- Business logic: check OTP ---
    /*if (code == "12345") {
      await _handleSuccessfulVerification();
    } else {
      setState(() {
        _errorText = msgError;
        //_errorText = "Invalid code. Please try again.";
      });
    }*/
  }

  Future<void> _showAnimatedSnackBar(String msg,
      {IconData? icon, bool error = false}) async {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          bottom: 48,
          left: 24,
          right: 24,
          child: AnimatedSnackBar(
            message: msg,
            icon: icon ??
                (error ? Icons.error_outline : Icons.check_circle_outline),
            error: error,
          ),
        );
      },
    );
    overlay.insert(entry);
    await Future.delayed(const Duration(milliseconds: 2200));
    entry.remove();
  }

  Future<void> _goToOTPScreen(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Lottie.asset(
          'assets/lottie/wait.json',
          width: MediaQuery.of(context).size.width * 0.4,
          height: MediaQuery.of(context).size.width * 0.4,
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              LandingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    final isWide = size.width > 600;

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 6),
          )
        ],
        border: Border.all(
          color: AppColor.primary.withOpacity(0.45),
          width: 2.2,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: Colors.white.withOpacity(0.13),
        border: Border.all(
          color: AppColor.secondary,
          width: 3.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.secondary.withOpacity(0.22),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: Colors.white.withOpacity(0.18),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // --- Gradient + Blur background ---
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F2027),
                  Color(0xFF2C5364),
                  Colors.transparent,
                  Color(0xFF232526),
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Image.asset(
              'assets/images/movie2.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.5),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? size.width * 0.25 : 24,
                vertical: isSmall ? 12 : 36,
              ),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.22),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          width: double.infinity,
                          constraints: BoxConstraints(
                            maxWidth: isWide ? 600 : size.width - 48,
                          ),
                          //color: Colors.white,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/logos/logo.png',
                                    width:
                                        MediaQuery.sizeOf(context).width * .1,
                                  ),
                                  AppSpacing.w20,
                                  Text(
                                    appLocalizations!.verificationCode!,
                                    //"Verification Code",
                                    style: TextStyle(
                                      fontSize: isSmall ? 22 : 28,
                                      fontWeight: FontWeight.bold,
                                      foreground: Paint()
                                        ..shader = const LinearGradient(
                                          colors: [
                                            Color(0xFF3DCBFF),
                                            Color(0xFF7D3CF8)
                                          ],
                                        ).createShader(
                                            const Rect.fromLTWH(0, 0, 400, 70)),
                                      shadows: [
                                        Shadow(
                                          blurRadius: 16,
                                          color: Colors.black.withOpacity(0.45),
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                appLocalizations!.verificationSubTitle!,
                                //"Please enter the verification code sent to",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: isSmall ? 13 : 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.phoneNumber,
                                style: TextStyle(
                                  color:
                                      AppColor.secondary, //Color(0xFF3DCBFF),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 28),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 400),
                                child: Pinput(
                                  key: ValueKey(_autoFill),
                                  controller: _otpController,
                                  length: _otpLength,
                                  focusNode: _otpFocusNode,
                                  autofocus: true,
                                  defaultPinTheme: defaultPinTheme,
                                  focusedPinTheme: focusedPinTheme,
                                  submittedPinTheme: submittedPinTheme,
                                  showCursor: true,
                                  obscureText: false,
                                  animationCurve:
                                      Curves.easeInOutCubicEmphasized,
                                  animationDuration:
                                      const Duration(milliseconds: 420),
                                  onCompleted: (code) {
                                    _onCompleted(_otpController.text,
                                        appLocalizations!.invalidCode!);
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      _errorText = null;
                                    });
                                  },
                                  errorText: _errorText,
                                ),
                              ),
                              if (_errorText != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    _errorText!,
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    appLocalizations!.dontReceiveCode!,
                                    //"Didn't receive code?",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 14,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      if (_canResend == true) {
                                        _resendOTP(
                                            appLocalizations!.resendCode!);
                                      } else {
                                        return;
                                      }
                                    },
                                    child: Text(
                                      _canResend
                                          ? appLocalizations!
                                              .resendCode! //"Resend"
                                          : "${appLocalizations!.resendIn!} $_resendSeconds s",
                                      /*style: TextStyle(
                                        color: _canResend
                                            ? const Color(0xFF3DCBFF)
                                            : Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),*/
                                      style: _canResend
                                          ? TextStyle(
                                              //fontSize: isSmall ? 22 : 28,
                                              fontWeight: FontWeight.bold,
                                              foreground: Paint()
                                                ..shader = const LinearGradient(
                                                  colors: [
                                                    Color(0xFF3DCBFF),
                                                    Color(0xFF7D3CF8)
                                                  ],
                                                ).createShader(
                                                    const Rect.fromLTWH(
                                                        0, 0, 400, 70)),
                                              shadows: [
                                                Shadow(
                                                  blurRadius: 16,
                                                  color: Colors.black
                                                      .withOpacity(0.45),
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            )
                                          : TextStyle(
                                              color: _canResend
                                                  ? const Color(0xFF3DCBFF)
                                                  : Colors.grey,
                                              fontWeight: FontWeight.bold,
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 400),
                                child: _loading
                                    ? const _ModernLoader(color: Colors.white)
                                    : SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColor.primary,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            elevation: 8,
                                            shadowColor: const Color(0xFF7D3CF8)
                                                .withOpacity(0.18),
                                            textStyle: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          child: Text(
                                            appLocalizations!.verifyYourNumber!,
                                          ), //'Verify your number',
                                          onPressed: () {
                                            if (_otpController.text.length ==
                                                _otpLength) {
                                              _onCompleted(
                                                  _otpController.text,
                                                  appLocalizations!
                                                      .invalidCode!);
                                            } else {
                                              setState(() {
                                                _errorText = appLocalizations!
                                                    .enterCode!;
                                                //"Please enter the full code.";
                                              });
                                            }
                                          },
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernLoader extends StatefulWidget {
  final Color color;
  const _ModernLoader({super.key, required this.color});

  @override
  State<_ModernLoader> createState() => _ModernLoaderState();
}

class _ModernLoaderState extends State<_ModernLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Transform.rotate(
          angle: _controller.value * 6.3,
          child: CustomPaint(
            size: const Size(28, 28),
            painter: _ModernLoaderPainter(widget.color),
          ),
        );
      },
    );
  }
}

class _ModernLoaderPainter extends CustomPainter {
  final Color color;
  _ModernLoaderPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.92)
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromLTWH(2, 2, size.width - 4, size.height - 4),
      0,
      4.2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LandingFadeLoader extends StatefulWidget {
  const _LandingFadeLoader({super.key});

  @override
  State<_LandingFadeLoader> createState() => _LandingFadeLoaderState();
}

class _LandingFadeLoaderState extends State<_LandingFadeLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeCtrl,
      curve: Curves.easeInOutCubicEmphasized,
    );
    _fadeCtrl.forward();

    // Ferme le dialog après 1.1s
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.primary, //Colors.transparent,
      body: Container(
        color: Colors.black.withOpacity(0.85),
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LottieBuilder.asset(
                  'assets/lottie/wait.json',
                  width: MediaQuery.of(context).size.width * 0.5,
                  repeat: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Animated Snackbar ---
class AnimatedSnackBar extends StatefulWidget {
  final String message;
  final IconData icon;
  final bool error;
  const AnimatedSnackBar({
    super.key,
    required this.message,
    required this.icon,
    this.error = false,
  });

  @override
  State<AnimatedSnackBar> createState() => _AnimatedSnackBarState();
}

class _AnimatedSnackBarState extends State<AnimatedSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(_fade);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: widget.error
                  ? Colors.redAccent.withOpacity(0.93)
                  : Colors.black.withOpacity(0.93),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    widget.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
