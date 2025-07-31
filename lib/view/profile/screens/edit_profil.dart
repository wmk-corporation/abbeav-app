import 'package:abbeav/view/auth/screens/display.dart';
import 'package:flutter/material.dart';
import 'package:abbeav/constants/app_spacing.dart';
import 'package:abbeav/style/app_color.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  File? _profileImage;
  String? _currentPhotoUrl;
  final ImagePicker _picker = ImagePicker();
  bool _loading = false;

  // Vos variables existantes...
  double _uploadProgress = 0;
  late AnimationController _progressController;
  late Animation<Color?> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _progressAnimation = ColorTween(
      begin: AppColor.primary,
      end: AppColor.secondary,
    ).animate(_progressController);
    _loadUserData();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Widget _buildProfileAvatar() {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey[800],
          backgroundImage: _profileImage != null
              ? FileImage(_profileImage!)
              : (_currentPhotoUrl != null
                  ? NetworkImage(_currentPhotoUrl!)
                  : null) as ImageProvider?,
          child: _profileImage == null && _currentPhotoUrl == null
              ? const Icon(Icons.person, size: 50, color: Colors.white)
              : null,
        ),
        if (_uploadProgress > 0 && _uploadProgress < 1)
          SizedBox(
            width: 104,
            height: 104,
            child: CircularProgressIndicator(
              value: _uploadProgress,
              strokeWidth: 4,
              backgroundColor: Colors.transparent,
              valueColor: _progressAnimation,
            ),
          ),
      ],
    );
  }

  Future<String?> _uploadProfileImage() async {
    if (_profileImage == null) return _currentPhotoUrl;

    try {
      setState(() {
        _uploadProgress = 0;
        _progressController.reset();
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}${path.extension(_profileImage!.path)}';
      final destination = 'profile_images/${user.uid}/$fileName';

      final ref = FirebaseStorage.instance.ref(destination);
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'uploadedBy': user.uid},
      );

      final uploadTask = ref.putFile(_profileImage!, metadata);

      uploadTask.snapshotEvents.listen((taskSnapshot) {
        setState(() {
          _uploadProgress = taskSnapshot.bytesTransferred.toDouble() /
              taskSnapshot.totalBytes.toDouble();
        });
        if (taskSnapshot.state == TaskState.running) {
          _progressController.forward();
        }
      });

      await uploadTask.whenComplete(() {});

      if (uploadTask.snapshot.state == TaskState.success) {
        return await ref.getDownloadURL();
      } else {
        throw Exception('Upload failed');
      }
    } catch (e) {
      //debugPrint('Error uploading image: $e');
      _showAnimatedSnackBar('Failed to upload image', error: true);
      return null;
    } finally {
      setState(() {
        _uploadProgress = 0;
      });
    }
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          _nameController.text = userDoc['fullName'] ?? '';
          _emailController.text = user.email ?? '';
          _phoneController.text = userDoc['phoneNumber'] ?? '';
          _currentPhotoUrl = userDoc['photoUrl'] ?? user.photoURL;
        });
      } else {
        setState(() {
          _nameController.text = user.displayName ?? '';
          _emailController.text = user.email ?? '';
          _phoneController.text = user.phoneNumber ?? '';
          _currentPhotoUrl = user.photoURL;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: ${e.toString()}')),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception('User not logged in');
        }

        // 1. Upload de l'image si elle a été modifiée
        final photoUrl = await _uploadProfileImage();

        // 2. Vérifier si l'email a changé
        final newEmail = _emailController.text.trim();
        final emailChanged = newEmail != user.email;

        // 3. Si email changé, procéder à la mise à jour
        if (emailChanged) {
          await _updateEmailWithReauthentication(newEmail);
          // Ne pas continuer avec les autres mises à jour car l'utilisateur sera déconnecté
          return;
        }

        // 4. Mise à jour dans Firestore
        final userData = {
          'fullName': _nameController.text.trim(),
          'email': newEmail,
          'phoneNumber': _phoneController.text.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        if (photoUrl != null) {
          userData['photoUrl'] = photoUrl;
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update(userData);

        // 5. Mise à jour du nom dans Firebase Auth
        if (_nameController.text.trim() != user.displayName) {
          await user.updateDisplayName(_nameController.text.trim());
        }

        _showAnimatedSnackBar('Profile updated successfully',
            icon: Icons.check_circle_outline);

        // 6. Recharger les données utilisateur
        await _loadUserData();
      } catch (e) {
        //debugPrint('Error updating profile: $e');
        _showAnimatedSnackBar('Failed to update profile: ${e.toString()}',
            icon: Icons.error_outline, error: true);
      } finally {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _updateEmailWithReauthentication(String newEmail) async {
    final user = FirebaseAuth.instance.currentUser!;

    try {
      // 1. Reauthentification nécessaire
      final success = await _reauthenticateUser();
      if (!success) throw Exception('Reauthentication failed');

      // 2. Envoyer l'email de vérification
      await user.verifyBeforeUpdateEmail(newEmail);

      // 3. Mettre à jour Firestore avec le nouvel email immédiatement
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'email': newEmail,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 4. Avertir l'utilisateur
      _showAnimatedSnackBar(
        'Verification email sent to $newEmail. Please confirm the change.',
        icon: Icons.email_outlined,
      );

      // 5. Déconnecter l'utilisateur pour qu'il se reconnecte avec le nouvel email
      await FirebaseAuth.instance.signOut();

      // 6. Rediriger vers l'écran de connexion
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DisplayScreen()),
        );
      }
    } catch (e) {
      ////debugPrint('Email update error: $e');
      rethrow;
    }
  }

  Future<bool> _reauthenticateUser() async {
    final user = FirebaseAuth.instance.currentUser!;

    // 1. Demander les informations d'identification actuelles
    final password = await showDialog<String>(
      context: context,
      builder: (context) {
        final passwordController = TextEditingController();
        return AlertDialog(
          title: Text('Reauthentication required'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(labelText: 'Current Password'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, passwordController.text),
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (password == null || password.isEmpty) return false;

    try {
      // 2. Créer les informations d'identification
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      // 3. Reauthentifier
      await user.reauthenticateWithCredential(credential);
      return true;
    } catch (e) {
      _showAnimatedSnackBar('Reauthentication failed: ${e.toString()}',
          error: true);
      return false;
    }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppSpacing.h30,
              GestureDetector(
                onTap: _pickImage,
                child: _buildProfileAvatar(),
              ),
              AppSpacing.h20,
              Text(
                'Change Profile Photo',
                style: TextStyle(
                  color: AppColor.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              AppSpacing.h30,
              _AnimatedTextField(
                controller: _nameController,
                hint: "Full Name",
                icon: Icons.person_outline_rounded,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Name is required";
                  return null;
                },
                decorationBuilder: _inputDecoration,
              ),
              AppSpacing.h15,
              _AnimatedTextField(
                controller: _emailController,
                hint: "Email Address",
                icon: Icons.email_outlined,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Email is required";
                  if (!v.contains('@')) return "Enter a valid email";
                  return null;
                },
                decorationBuilder: _inputDecoration,
              ),
              AppSpacing.h15,
              _AnimatedTextField(
                controller: _phoneController,
                hint: "Phone Number",
                icon: Icons.phone_outlined,
                validator: (v) {
                  if (v != null && v.isNotEmpty && v.length < 8) {
                    return "Enter a valid phone number";
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
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                          ),
                          onPressed: _saveProfile,
                          child: const Text("SAVE CHANGES"),
                        ),
                      ),
              ),
            ],
          ),
        ),
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
}

// Widgets réutilisés depuis sign_up_screen.dart
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
