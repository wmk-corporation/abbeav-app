import 'package:abbeav/app_localizations.dart';
import 'package:abbeav/config/global/constants/image_routes.dart';
import 'package:abbeav/controller/user_controller.dart';
import 'package:abbeav/main.dart';
import 'package:abbeav/models/user_model.dart';
import 'package:abbeav/view/profile/widgets/premium_card.dart';
import 'package:abbeav/view/profile/widgets/user_avatar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:abbeav/constants/app_spacing.dart';
import 'package:abbeav/style/app_color.dart';
import 'package:abbeav/view/profile/widgets/log_out_button.dart';
import 'package:abbeav/view/profile/widgets/profile_tile_widget.dart';
import 'package:abbeav/view/profile/screens/edit_profil.dart';
import 'package:abbeav/view/profile/screens/change_password.dart';
import 'package:abbeav/view/auth/screens/sign_in_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:animations/animations.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userController = Provider.of<UserController>(context, listen: false);
    final user = await userController.getCurrentUser();
    if (user != null) {
      setState(() {
        _currentUser = user;
        _notificationsEnabled = user.notificationsEnabled ?? true;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final File imageFile = File(image.path);

        // Vérifier si le fichier existe
        if (!await imageFile.exists()) {
          throw Exception('Image file not found');
        }

        setState(() => _profileImage = imageFile);

        final userController =
            Provider.of<UserController>(context, listen: false);
        final user = await userController.getCurrentUser();
        if (user != null) {
          // Upload vers Firebase Storage
          final storageRef = FirebaseStorage.instance.ref(
              'profile_images/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');

          // Ajouter des métadonnées
          final metadata = SettableMetadata(
            contentType: 'image/jpeg',
            customMetadata: {'uploadedBy': user.uid},
          );

          // Upload avec suivi de progression
          final uploadTask = storageRef.putFile(_profileImage!, metadata);
          final taskSnapshot = await uploadTask.whenComplete(() {});

          if (taskSnapshot.state == TaskState.success) {
            final photoUrl = await storageRef.getDownloadURL();

            // Mise à jour du profil
            await userController.updateProfile(
              userId: user.uid,
              photoUrl: photoUrl,
            );

            setState(() {
              _currentUser = _currentUser?.copyWith(photoUrl: photoUrl);
              _profileImage = null; // Réinitialiser après upload réussi
            });

            _showAnimatedSnackBar('Profile picture updated successfully');
          } else {
            throw Exception('Upload failed');
          }
        }
      }
    } catch (e) {
      setState(() => _profileImage = null);
      _showAnimatedSnackBar('Failed to update profile picture: ${e.toString()}',
          error: true);
      //debugPrint('Error updating profile picture: $e');
    }
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute;
    } catch (e) {
      return false;
    }
  }

  ImageProvider? getProfileImage() {
    if (_profileImage != null) {
      return FileImage(_profileImage!);
    } else if (_currentUser?.photoUrl != null &&
        _currentUser!.photoUrl!.isNotEmpty &&
        _isValidUrl(_currentUser!.photoUrl!)) {
      return NetworkImage(_currentUser!.photoUrl!);
    }
    return const AssetImage('assets/logos/logo.png');
  }

  /*Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _profileImage = File(image.path));
        
        final userController = Provider.of<UserController>(context, listen: false);
        final user = await userController.getCurrentUser();
        if (user != null) {
          // Upload de l'image vers Firebase Storage
          final storageRef = FirebaseStorage.instance
              .ref('profile_images/${user.uid}/${path.basename(image.path)}');
          await storageRef.putFile(_profileImage!);
          final photoUrl = await storageRef.getDownloadURL();
          
          // Mise à jour du profil
          await userController.updateProfile(
            userId: user.uid,
            photoUrl: photoUrl,
          );
          
          setState(() => _currentUser = _currentUser?.copyWith(photoUrl: photoUrl));
        }
        
        _showAnimatedSnackBar('Profile picture updated successfully');
      }
    } catch (e) {
      _showAnimatedSnackBar('Failed to update profile picture', error: true);
      debugPrint('Error updating profile picture: $e');
    }
  }*/

  Future<void> _toggleNotifications(bool value) async {
    try {
      final userController =
          Provider.of<UserController>(context, listen: false);
      final user = await userController.getCurrentUser();

      if (user != null) {
        await userController.toggleNotifications(user.uid, value);
        setState(() => _notificationsEnabled = value);

        final appLocalizations = AppLocalizations.of(context);
        _showAnimatedSnackBar(
          value
              ? appLocalizations!.enableNotifications!
              : appLocalizations!.disableNotifications!,
          icon: value ? Icons.notifications_active : Icons.notifications_off,
        );
      }
    } catch (e) {
      _showAnimatedSnackBar('Failed to update notifications', error: true);
      //debugPrint('Error toggling notifications: $e');
      setState(() => _notificationsEnabled = !value); // Revert the change
    }
  }

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final appLocalizations = AppLocalizations.of(context);
    final userController = Provider.of<UserController>(context, listen: false);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(appLocalizations!.confirmLogout!),
        content: Text(appLocalizations.logoutMessage!),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(appLocalizations.cancel!),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(appLocalizations.logout!),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );

        await userController.signOut();

        // Navigate to login screen
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => SignInScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop(); // Remove loading indicator
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('logoutError: $e')),
          );
        }
      }
    }
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

  /*@override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    final languageProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      OpenContainer(
                        closedShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(56),
                        ),
                        closedColor: Colors.transparent,
                        //clipBehavior: Clip.antiAlias,
                        transitionDuration: const Duration(milliseconds: 700),
                        transitionType: ContainerTransitionType.fadeThrough,
                        closedBuilder: (context, action) => UserAvatar(
                          image: _profileImage != null
                              ? _profileImage!.path
                              : 'assets/logos/logo.png',
                          onTap: action,
                        ),
                        openBuilder: (context, action) => Scaffold(
                          appBar: AppBar(
                              title: Text(
                            appLocalizations!.editProfile!,
                          ) //const Text('Edit Profile Picture'),
                              ),
                          body: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColor.primary,
                                  radius: 80,
                                  backgroundImage: _profileImage != null
                                      ? FileImage(_profileImage!)
                                      : null,
                                  child: _profileImage == null
                                      ? const Icon(
                                          Icons.person,
                                          size: 80,
                                          color: AppColor.secondary,
                                        )
                                      : null,
                                ),
                                const SizedBox(height: 30),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FloatingActionButton(
                                      backgroundColor: AppColor.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      heroTag: 'camera',
                                      onPressed: () async {
                                        final XFile? image =
                                            await _picker.pickImage(
                                                source: ImageSource.camera);
                                        if (image != null) {
                                          setState(() {
                                            _profileImage = File(image.path);
                                          });
                                          Navigator.pop(context);
                                          _showAnimatedSnackBar(
                                              'Profile picture updated successfully');
                                        }
                                      },
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    FloatingActionButton(
                                      backgroundColor: AppColor.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      heroTag: 'gallery',
                                      onPressed: () async {
                                        await _pickImage();
                                        Navigator.pop(context);
                                      },
                                      child: const Icon(
                                        Icons.photo_library,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      AppSpacing.h15,
                      const Text(
                        'VACHALA TERI Armand',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSpacing.h15,
                      Text(
                        'daad.devanios@gmail.com',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.h10,
                PremiumCard(),
                AppSpacing.h10,
                Text(
                  appLocalizations!.account!,
                  //'Account',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                ProfileTileWidget(
                  title: appLocalizations.editProfile!, //'Edit Profile',
                  icon: AppImagesRoute.iconProfile,
                  trailing: '>',
                  isBackButtonEnable: true,
                  onTap: () => _navigateToEditProfile(context),
                ),
                ProfileTileWidget(
                    title: appLocalizations.language!, //'Language',
                    icon: AppImagesRoute.iconLanguage,
                    trailing:
                        appLocalizations.changeLanguage!, //'English (US)',
                    isBackButtonEnable: false,
                    onTap: () {
                      final newLocale =
                          languageProvider.locale.languageCode == 'fr'
                              ? const Locale('en')
                              : const Locale('fr');
                      languageProvider.setLocale(newLocale);
                      _showAnimatedSnackBar(
                          '${appLocalizations.languageChangeTo} ${appLocalizations.changeLanguage!}');
                    } //=> _showLanguageSelection(context),
                    ),
                ProfileTileWidget(
                  title: appLocalizations.changePassword!, //'Change Password',
                  icon: AppImagesRoute.iconEye,
                  trailing: '>',
                  isBackButtonEnable: true,
                  onTap: () => _navigateToChangePassword(context),
                ),
                AppSpacing.h20,
                _buildNotificationSwitch(
                  appLocalizations.enableNotifications!,
                  appLocalizations.disableNotifications!,
                ),
                AppSpacing.h30,
                LogOutButton(
                  onTap: () => _showLogoutConfirmation(
                    context,
                  ),
                ),
                AppSpacing.h10,
              ],
            ),
          ),
        ),
      ),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      OpenContainer(
                        closedShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(56),
                        ),
                        closedColor: Colors.transparent,
                        transitionDuration: const Duration(milliseconds: 700),
                        transitionType: ContainerTransitionType.fadeThrough,
                        closedBuilder: (context, action) => UserAvatar(
                          image: _profileImage != null
                              ? _profileImage!.path
                              : _currentUser?.photoUrl ??
                                  'assets/logos/logo.png',
                          onTap: action,
                        ),
                        openBuilder: (context, action) => Scaffold(
                          appBar: AppBar(
                            title: Text(appLocalizations!.editProfile!),
                          ),
                          body: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColor.primary,
                                  radius: 80,
                                  backgroundImage: getProfileImage(),
                                  /*backgroundImage: _profileImage != null
                                      ? FileImage(_profileImage!)
                                      : (_currentUser?.photoUrl != null
                                          ? NetworkImage(
                                              _currentUser!.photoUrl!)
                                          : null) as ImageProvider?,
                                  child: _profileImage == null &&
                                          _currentUser?.photoUrl == null
                                      ? const Icon(
                                          Icons.person,
                                          size: 80,
                                          color: AppColor.secondary,
                                        )
                                      : null,*/
                                ),
                                const SizedBox(height: 30),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FloatingActionButton(
                                      backgroundColor: AppColor.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      heroTag: 'camera',
                                      onPressed: () async {
                                        final XFile? image =
                                            await _picker.pickImage(
                                                source: ImageSource.camera);
                                        if (image != null) {
                                          setState(() =>
                                              _profileImage = File(image.path));
                                          Navigator.pop(context);

                                          final userController =
                                              Provider.of<UserController>(
                                                  context,
                                                  listen: false);
                                          final user = await userController
                                              .getCurrentUser();
                                          if (user != null) {
                                            // Upload de l'image
                                            final storageRef =
                                                FirebaseStorage.instance.ref(
                                                    'profile_images/${user.uid}/${path.basename(image.path)}');
                                            await storageRef
                                                .putFile(_profileImage!);
                                            final photoUrl = await storageRef
                                                .getDownloadURL();

                                            // Mise à jour du profil
                                            await userController.updateProfile(
                                              userId: user.uid,
                                              photoUrl: photoUrl,
                                            );

                                            setState(() => _currentUser =
                                                _currentUser?.copyWith(
                                                    photoUrl: photoUrl));
                                          }

                                          _showAnimatedSnackBar(
                                              'Profile picture updated successfully');
                                        }
                                      },
                                      child: const Icon(Icons.camera_alt,
                                          color: Colors.white),
                                    ),
                                    const SizedBox(width: 20),
                                    FloatingActionButton(
                                      backgroundColor: AppColor.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      heroTag: 'gallery',
                                      onPressed: () async {
                                        await _pickImage();
                                        Navigator.pop(context);
                                      },
                                      child: const Icon(Icons.photo_library,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      AppSpacing.h15,
                      Text(
                        _currentUser?.fullName ?? 'Chargement...',
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppSpacing.h15,
                      Text(
                        _currentUser?.email ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.h10,
                const PremiumCard(),
                AppSpacing.h10,
                Text(
                  appLocalizations!.account!,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                ProfileTileWidget(
                  title: appLocalizations.editProfile!,
                  icon: AppImagesRoute.iconProfile,
                  trailing: '>',
                  isBackButtonEnable: true,
                  onTap: () => _navigateToEditProfile(context),
                ),
                ProfileTileWidget(
                  title: appLocalizations.language!,
                  icon: AppImagesRoute.iconLanguage,
                  trailing: appLocalizations.changeLanguage!,
                  isBackButtonEnable: false,
                  onTap: () {
                    final newLocale =
                        languageProvider.locale.languageCode == 'fr'
                            ? const Locale('en')
                            : const Locale('fr');
                    languageProvider.setLocale(newLocale);

                    final userController =
                        Provider.of<UserController>(context, listen: false);
                    if (_currentUser != null) {
                      userController.updateLanguagePreference(
                          _currentUser!.uid, newLocale.languageCode);
                    }

                    _showAnimatedSnackBar(
                        '${appLocalizations.languageChangeTo} ${newLocale.languageCode == 'fr' ? 'Français' : 'English'}');
                  },
                ),
                ProfileTileWidget(
                  title: appLocalizations.changePassword!,
                  icon: AppImagesRoute.iconEye,
                  trailing: '>',
                  isBackButtonEnable: true,
                  onTap: () => _navigateToChangePassword(context),
                ),
                AppSpacing.h20,
                _buildNotificationSwitch(
                  appLocalizations.enableNotifications!,
                  appLocalizations.disableNotifications!,
                ),
                AppSpacing.h30,
                LogOutButton(
                  onTap: () => _showLogoutConfirmation(context),
                ),
                AppSpacing.h10,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationSwitch(String enabled, String desabled) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Notifications',
          style: TextStyle(
              fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        Transform.scale(
          scale: 0.9,
          child: Switch.adaptive(
            value: _notificationsEnabled,
            onChanged: _toggleNotifications,
            /*onChanged: (value) async {
              setState(() {
                _notificationsEnabled = value;
              });
              await Future.delayed(const Duration(milliseconds: 300));
              _showAnimatedSnackBar(
                value
                    ? enabled
                    : desabled, //'Notifications enabled' : 'Notifications disabled',
                icon: value
                    ? Icons.notifications_active
                    : Icons.notifications_off,
              );
            },*/
            activeColor: AppColor.secondary,
            activeTrackColor: AppColor.secondary.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EditProfileScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutQuart;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  void _navigateToChangePassword(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ChangePasswordScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.elasticOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }
}

class ElasticInOutPopup extends StatelessWidget {
  final Widget child;

  const ElasticInOutPopup({required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }
}

class ElasticInPopup extends StatelessWidget {
  final Widget child;

  const ElasticInPopup({required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInSine,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
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
