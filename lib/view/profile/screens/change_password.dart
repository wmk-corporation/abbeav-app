import 'dart:io';

import 'package:abbeav/app_localizations.dart';
import 'package:abbeav/controller/user_controller.dart';
import 'package:abbeav/upload_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:abbeav/constants/app_spacing.dart';
import 'package:abbeav/style/app_color.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart' show basename;

import 'package:path/path.dart' as path;

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  bool _success = false;

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
      fillColor: AppColor.primary.withOpacity(.7),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appLocalizations!.changePassword!,
        ), //const Text('Change Password'),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _AnimatedTextField(
                    controller: _currentPasswordController,
                    hint: "Current Password",
                    icon: Icons.lock_rounded,
                    isPassword: true,
                    obscureText: _obscureCurrent,
                    onToggleObscure: () =>
                        setState(() => _obscureCurrent = !_obscureCurrent),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return appLocalizations.errorCurrentPasswordRequired!;
                      }
                      //"Current password required";
                      if (v.length < 6) {
                        return appLocalizations
                            .min6Characters!; //"Minimum 6 characters";
                      }
                      return null;
                    },
                    decorationBuilder: _inputDecoration,
                  ),
                  AppSpacing.h15,
                  _AnimatedTextField(
                    controller: _newPasswordController,
                    hint: appLocalizations.newPassword!, //"New Password",
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                    obscureText: _obscureNew,
                    onToggleObscure: () =>
                        setState(() => _obscureNew = !_obscureNew),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return appLocalizations
                            .errorNewPasswordRequired!; //"New password required";
                      }
                      if (v.length < 6) {
                        return appLocalizations
                            .min6Characters!; //"Minimum 8 characters";
                      }
                      return null;
                    },
                    decorationBuilder: _inputDecoration,
                  ),
                  AppSpacing.h15,
                  _AnimatedTextField(
                    controller: _confirmPasswordController,
                    hint: appLocalizations
                        .confirmNewPassword!, //"Confirm New Password",
                    icon: Icons.lock_reset_rounded,
                    isPassword: true,
                    obscureText: _obscureConfirm,
                    onToggleObscure: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return appLocalizations
                            .confirmNewPassword!; //"Please confirm password";
                      }
                      if (v != _newPasswordController.text) {
                        return appLocalizations
                            .errorNewPasswordMismatch!; //"Passwords don't match";
                      }
                      return null;
                    },
                    decorationBuilder: _inputDecoration,
                  ),
                  AppSpacing.h30,
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 8,
                                shadowColor:
                                    const Color(0xFF7D3CF8).withOpacity(0.18),
                              ),
                              onPressed: _changePassword,
                              child: Text(appLocalizations
                                  .updatePassword!), //const Text("UPDATE PASSWORD"),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          if (_success)
            SuccessOverlay(
              onDismiss: () {
                setState(() => _success = false);
                Navigator.pop(context);
              },
            ),
        ],
      ),
    );
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

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);

      try {
        final userController = UserController();
        await userController.changePassword(
          currentPassword: _currentPasswordController.text.trim(),
          newPassword: _newPasswordController.text.trim(),
        );

        setState(() {
          _loading = false;
          _success = true;
        });

        // Réinitialiser les champs après succès
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      } on FirebaseAuthException catch (e) {
        setState(() => _loading = false);

        String errorMessage;
        switch (e.code) {
          case 'wrong-password':
            errorMessage = 'Le mot de passe actuel est incorrect';
            break;
          case 'weak-password':
            errorMessage = 'Le nouveau mot de passe est trop faible';
            break;
          case 'requires-recent-login':
            errorMessage =
                'Veuillez vous reconnecter avant de changer votre mot de passe';
            break;
          default:
            errorMessage = 'Une erreur est survenue: ${e.message}';
        }

        _showAnimatedSnackBar(errorMessage, error: true);
      } catch (e) {
        setState(() => _loading = false);
        _showAnimatedSnackBar('Une erreur inattendue est survenue',
            error: true);
        //debugPrint('Error changing password: $e');
      }
    }
  }
}

class SuccessOverlay extends StatelessWidget {
  final VoidCallback onDismiss;

  const SuccessOverlay({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lottie/success.json',
              width: 200,
              height: 200,
              repeat: false,
            ),
            const SizedBox(height: 20),
            Text(
              'Password Changed Successfully!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onDismiss,
              child: const Text('DONE'),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedSnackBar extends StatelessWidget {
  final String message;
  final IconData icon;
  final bool error;

  const AnimatedSnackBar({
    required this.message,
    required this.icon,
    this.error = false,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        color: Colors.black
            .withOpacity(0.93), //error ? Colors.red[800] : Colors.green[800],
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final String? Function(String?)? validator;
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
