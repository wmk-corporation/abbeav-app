import 'dart:async';
import 'dart:ui';
import 'package:abbeav/app_localizations.dart';
import 'package:abbeav/constants/app_spacing.dart';
import 'package:abbeav/controller/user_controller.dart';
import 'package:abbeav/view/auth/screens/otp_auth_screen.dart';
import 'package:abbeav/view/auth/screens/sign_in_screen.dart';
import 'package:abbeav/view/home/screens/landing_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:abbeav/style/app_color.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _showConfirm = false;
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String _countryCode = "+237";

  late AnimationController _formAnimCtrl;
  late Animation<double> _formFade;
  late Animation<Offset> _formSlide;
  late AnimationController _confirmAnimCtrl;
  late Animation<double> _confirmFade;
  late Animation<Offset> _confirmSlide;

  bool _loadingGoogle = false;
  bool _loadingApple = false;

  @override
  void initState() {
    super.initState();
    _formAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _formFade = CurvedAnimation(parent: _formAnimCtrl, curve: Curves.easeInOut);
    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(_formFade);

    _confirmAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _confirmFade =
        CurvedAnimation(parent: _confirmAnimCtrl, curve: Curves.easeInOut);
    _confirmSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(_confirmFade);

    _formAnimCtrl.forward();
    _passwordCtrl.addListener(_onPasswordFilled);
  }

  void _onPasswordFilled() {
    if (_passwordCtrl.text.length >= 6 && !_showConfirm) {
      setState(() => _showConfirm = true);
      _confirmAnimCtrl.forward();
    } else if (_passwordCtrl.text.length < 6 && _showConfirm) {
      setState(() => _showConfirm = false);
      _confirmAnimCtrl.reverse();
    }
  }

  @override
  void dispose() {
    _formAnimCtrl.dispose();
    _confirmAnimCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();

    //FocusScope.of(context).unfocus();
    _formKey.currentState?.dispose();
    super.dispose();
  }

  // Fermer le clavier
  void _closeKeyboard() {
    FocusScope.of(context).unfocus();
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

  Future<void> _onSignUp() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _countryCode + _phoneCtrl.text.trim();
    final password = _passwordCtrl.text;

    _closeKeyboard();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final userController = UserController();
      final user = await userController.createUserWithEmailAndPassword(
        email: email,
        password: password,
        fullName: name,
        phoneNumber: phone,
      );

      await _showAnimatedSnackBar(
        "Account created successfully!",
        icon: Icons.verified_user,
      );

      if (mounted) {
        // Naviguer vers l'écran de vérification OTP ou l'écran d'accueil
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => LandingScreen(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      await _showAnimatedSnackBar(
        e.toString(),
        icon: Icons.error_outline,
        //error: true,
      );
    } catch (e) {
      await _showAnimatedSnackBar(
        "An error occurred. Please try again.",
        icon: Icons.error_outline,
        //error: true,
      );
      //debugPrint('Sign up error: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  /*Future<void> _onSignUp() async {
    final phone = _phoneCtrl.text.trim();
    final password = _passwordCtrl.text;

    _closeKeyboard();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    setState(() => _loading = false);
    await _showAnimatedSnackBar("Account created successfully!",
        icon: Icons.verified_user);
    if (mounted) {
      /*Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (_) => OtpAuthenticationScreen(
                  phoneOrEmail: phone,
                )),
      );*/
    }
    // TODO: Navigate to next screen or home
  }*/

  void _goToSignIn() {
    Navigator.of(context).pushReplacement(_createRouteToSignIn());
  }

  Route _createRouteToSignIn() {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 800),
      pageBuilder: (context, animation, secondaryAnimation) =>
          const SignInScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fade = CurvedAnimation(
            parent: animation, curve: Curves.easeInOutCubicEmphasized);
        final slide = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(fade);
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }

  Future<void> _onGoogleSignUp() async {
    _closeKeyboard();
    setState(() => _loadingGoogle = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    setState(() => _loadingGoogle = false);
    await _showAnimatedSnackBar(
      "Google sign-up coming soon!",
      icon: Icons.g_mobiledata,
    );
  }

  Future<void> _onAppleSignUp() async {
    _closeKeyboard();
    setState(() => _loadingApple = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    setState(() => _loadingApple = false);
    await _showAnimatedSnackBar(
      "Apple sign-up coming soon!",
      icon: Icons.apple,
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isObscure = false,
    VoidCallback? onToggle,
    bool isError = false,
    bool isFocused = false,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.only(left: 8, right: 8),
        child: Icon(icon,
            color: isFocused ? AppColor.secondary : Colors.grey[500], size: 22),
      ),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                isObscure
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: isFocused ? AppColor.secondary : Colors.grey[400],
              ),
              onPressed: onToggle,
            )
          : null,
      filled: true,
      fillColor:
          AppColor.primary.withOpacity(.7), //Colors.white.withOpacity(0.06),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
        borderSide: BorderSide.none,
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          width: 2.5,
          color: isError
              ? Colors.redAccent
              : isFocused
                  ? AppColor.primary
                  : AppColor.primary.withOpacity(0.25),
        ),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          width: 3.5,
          color: AppColor.secondary,
        ),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          width: 2.5,
          color: Colors.redAccent,
        ),
      ),
      hintStyle: TextStyle(
        color: isFocused ? AppColor.secondary : Colors.grey[400],
        fontWeight: FontWeight.w500,
        fontSize: 15.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 700;
    final isWide = size.width > 600;

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
          /*BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
            child: Container(
              color: Colors.black.withOpacity(0.25),
            ),
          ),*/
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? size.width * 0.25 : 24,
                vertical: isSmall ? 12 : 36,
              ),
              child: FadeTransition(
                opacity: _formFade,
                child: SlideTransition(
                  position: _formSlide,
                  child: Form(
                    key: _formKey,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
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
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Image.asset(
                                  'assets/logos/logo.png',
                                  width: MediaQuery.sizeOf(context).width * .1,
                                ),
                                AppSpacing.w20,
                                Text(
                                  appLocalizations!.signupTitle!,
                                  //"Create your account",
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
                            const SizedBox(height: 12),
                            //const SizedBox(height: 8),
                            Text(
                              appLocalizations.signupSubtitle!,
                              //"Sign in to your existing account by entering your details.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: isSmall ? 13 : 15,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _AnimatedTextField(
                              controller: _nameCtrl,
                              hint: appLocalizations.signupFullName!, //"Name",
                              icon: Icons.person_rounded,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return appLocalizations
                                      .errorFullNameRequired!;
                                }
                                if (v.trim().length < 3) {
                                  return appLocalizations.fullName!;
                                }
                                return null;
                              },
                              decorationBuilder: _inputDecoration,
                            ),
                            const SizedBox(height: 14),
                            _AnimatedTextField(
                              controller: _emailCtrl,
                              hint: appLocalizations.signupEmail!, //"Email",
                              icon: Icons.email_rounded,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return appLocalizations
                                      .errorEmailRequired!; //"Email required";
                                }
                                final emailRegex =
                                    RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
                                if (!emailRegex.hasMatch(v.trim())) {
                                  return appLocalizations.invalidEmail!;
                                }
                                return null;
                              },
                              decorationBuilder: _inputDecoration,
                            ),
                            const SizedBox(height: 14),
                            IntlPhoneField(
                              controller: _phoneCtrl,
                              initialCountryCode: 'CM',
                              decoration: _inputDecoration(
                                hint: appLocalizations
                                    .signupPhoneNumber!, //"Phone Number",
                                icon: Icons.phone_rounded,
                                isFocused: false,
                              ),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 15.5),
                              dropdownIcon: Icon(Icons.arrow_drop_down,
                                  color: AppColor.primary),
                              onChanged: (phone) {
                                _countryCode = "+${phone.countryCode}";
                              },
                              validator: (v) {
                                if (v == null || v.number.trim().isEmpty) {
                                  return appLocalizations
                                      .errorPhoneNumberRequired!; //"Phone required";
                                }
                                if (v.number.length < 6) {
                                  return appLocalizations
                                      .invalidPhoneNumber!; //"Invalid phone";
                                }
                                return null;
                              },
                              cursorColor: AppColor.primary,
                            ),
                            const SizedBox(height: 14),
                            _AnimatedTextField(
                              controller: _passwordCtrl,
                              hint: appLocalizations
                                  .signupPassword!, //"Password",
                              icon: Icons.lock_rounded,
                              isPassword: true,
                              obscureText: _obscurePassword,
                              onToggleObscure: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return appLocalizations
                                      .errorPasswordRequired!; //"Password required";
                                }
                                if (v.length < 6) {
                                  return appLocalizations.min6Characters!;
                                }
                                return null;
                              },
                              decorationBuilder: _inputDecoration,
                            ),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOutCubic,
                              child: _showConfirm
                                  ? FadeTransition(
                                      opacity: _confirmFade,
                                      child: SlideTransition(
                                        position: _confirmSlide,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 14),
                                          child: _AnimatedTextField(
                                            controller: _confirmCtrl,
                                            hint: appLocalizations
                                                .signupConfirmPassword!, //"Confirm Password",
                                            icon: Icons.verified_user_rounded,
                                            isPassword: true,
                                            obscureText: _obscureConfirm,
                                            onToggleObscure: () => setState(
                                                () => _obscureConfirm =
                                                    !_obscureConfirm),
                                            validator: (v) {
                                              if (v == null || v.isEmpty) {
                                                return appLocalizations
                                                    .errorConfirmPasswordRequired!; //"Confirm your password";
                                              }
                                              if (v != _passwordCtrl.text) {
                                                return appLocalizations
                                                    .errorNewPasswordMismatch!; //"Passwords do not match";
                                              }
                                              return null;
                                            },
                                            decorationBuilder: _inputDecoration,
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                            const SizedBox(height: 28),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              child: _loading
                                  ? const ModernLoader(color: Colors.white)
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
                                        onPressed: _onSignUp,
                                        child: Text(
                                          appLocalizations.signupTitle!,
                                        ),
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  appLocalizations.signupAlreadyHaveAccount!,
                                  //"Already have an account?",
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.7)),
                                ),
                                TextButton(
                                  onPressed: _goToSignIn,
                                  child: Text(
                                    appLocalizations.signupLogin!,
                                    style: TextStyle(
                                      //fontSize: isSmall ? 22 : 28,
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
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            _buildDividerWithText(
                                appLocalizations.orContinueWith!),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _SocialButton(
                                  asset: 'assets/icons/google.png',
                                  onTap: _onGoogleSignUp,
                                  bgColor: Colors.white,
                                  //iconColor: Colors.black87,
                                  loading: _loadingGoogle,
                                ),
                                const SizedBox(width: 128),
                                _SocialButton(
                                  asset: 'assets/icons/apple.png',
                                  onTap: _onAppleSignUp,
                                  bgColor: Colors.black,
                                  iconColor: Colors.white,
                                  loading: _loadingApple,
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                          ],
                        ),
                      ),
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

Widget _buildDividerWithText(String text) {
  return Row(
    children: [
      const Expanded(
        child: Divider(
          color: Colors.white24,
          thickness: 1.2,
          endIndent: 12,
          indent: 0,
        ),
      ),
      Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.w500,
          fontSize: 13,
          letterSpacing: 0.2,
        ),
      ),
      const Expanded(
        child: Divider(
          color: Colors.white24,
          thickness: 1.2,
          indent: 12,
          endIndent: 0,
        ),
      ),
    ],
  );
}

// --- Animated TextField Widget ---
class _AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final InputDecoration Function({
    required String hint,
    required IconData icon,
    bool isPassword,
    bool isObscure,
    VoidCallback? onToggle,
    bool isError,
    bool isFocused,
  }) decorationBuilder;

  const _AnimatedTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.obscureText = false,
    this.onToggleObscure,
    this.validator,
    this.keyboardType,
    required this.decorationBuilder,
  });

  @override
  State<_AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<_AnimatedTextField> {
  bool _focused = false;
  bool _error = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: Builder(
        builder: (context) => TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword ? widget.obscureText : false,
          keyboardType: widget.keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 15.5),
          cursorColor: AppColor.primary,
          validator: (v) {
            final res = widget.validator?.call(v);
            setState(() => _error = res != null);
            return res;
          },
          decoration: widget.decorationBuilder(
            hint: widget.hint,
            icon: widget.icon,
            isPassword: widget.isPassword,
            isObscure: widget.obscureText,
            onToggle: widget.onToggleObscure,
            isError: _error,
            isFocused: _focused,
          ),
        ),
      ),
    );
  }
}

// --- Modern Loader ---
class ModernLoader extends StatefulWidget {
  final Color color;
  const ModernLoader({super.key, required this.color});

  @override
  State<ModernLoader> createState() => _ModernLoaderState();
}

class _ModernLoaderState extends State<ModernLoader>
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

class _SocialButton extends StatelessWidget {
  final String asset;
  final VoidCallback onTap;
  final Color bgColor;
  Color? iconColor;
  final bool loading;

  _SocialButton({
    required this.asset,
    required this.onTap,
    required this.bgColor,
    this.iconColor,
    this.loading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutExpo,
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 18,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.13),
            width: 1.2,
          ),
        ),
        child: Center(
          child: loading
              ? ModernLoader(color: iconColor ?? AppColor.primary)
              : Image.asset(
                  asset,
                  width: 28,
                  height: 28,
                  color: iconColor,
                ),
        ),
      ),
    );
  }
}
