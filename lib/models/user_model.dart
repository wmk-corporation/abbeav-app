import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String uid;
  final String? email;
  final String? phoneNumber;
  final String? fullName;
  final String? photoUrl;
  final String? provider;
  final String? languagePreference;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final SubscriptionModel? subscription;
  final List<String>? favoriteMovies;
  final List<String>? likedMovies;
  final List<String>? downloadedMovies;
  final Map<String, double>? watchingProgress;
  final bool? notificationsEnabled;
  final List<PaymentMethodModel>? paymentMethods;

  UserModel({
    required this.uid,
    this.email,
    this.phoneNumber,
    this.fullName,
    this.photoUrl,
    this.provider,
    this.languagePreference = 'fr',
    required this.createdAt,
    this.updatedAt,
    this.subscription,
    this.favoriteMovies,
    this.likedMovies,
    this.downloadedMovies,
    this.watchingProgress,
    this.notificationsEnabled = true,
    this.paymentMethods,
  });

  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      phoneNumber: user.phoneNumber,
      photoUrl: user.photoURL,
      createdAt: DateTime.now(),
      languagePreference: 'fr',
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'],
      phoneNumber: data['phoneNumber'],
      fullName: data['fullName'],
      photoUrl: data['photoUrl'],
      provider: data['provider'],
      languagePreference: data['languagePreference'] ?? 'fr',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      subscription: data['subscription'] != null
          ? SubscriptionModel.fromMap(data['subscription'])
          : null,
      favoriteMovies: List<String>.from(data['favoriteMovies'] ?? []),
      likedMovies: List<String>.from(data['likedMovies'] ?? []),
      downloadedMovies: List<String>.from(data['downloadedMovies'] ?? []),
      watchingProgress: Map<String, double>.from(
          data['watchingProgress']?.map((k, v) => MapEntry(k, v.toDouble())) ??
              {}),
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      paymentMethods: data['paymentMethods'] != null
          ? List<PaymentMethodModel>.from(
              data['paymentMethods'].map((x) => PaymentMethodModel.fromMap(x)))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'phoneNumber': phoneNumber,
      'fullName': fullName,
      'photoUrl': photoUrl,
      'provider': provider,
      'languagePreference': languagePreference,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'subscription': subscription?.toMap(),
      'favoriteMovies': favoriteMovies,
      'likedMovies': likedMovies,
      'downloadedMovies': downloadedMovies,
      'watchingProgress': watchingProgress,
      'notificationsEnabled': notificationsEnabled,
      'paymentMethods': paymentMethods?.map((x) => x.toMap()).toList(),
    };
  }

  UserModel copyWith({
    String? email,
    String? phoneNumber,
    String? fullName,
    String? photoUrl,
    String? provider,
    String? languagePreference,
    DateTime? createdAt,
    DateTime? updatedAt,
    SubscriptionModel? subscription,
    List<String>? favoriteMovies,
    List<String>? likedMovies,
    List<String>? downloadedMovies,
    Map<String, double>? watchingProgress,
    bool? notificationsEnabled,
    List<PaymentMethodModel>? paymentMethods,
  }) {
    return UserModel(
      uid: uid,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      photoUrl: photoUrl ?? this.photoUrl,
      provider: provider ?? this.provider,
      languagePreference: languagePreference ?? this.languagePreference,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      subscription: subscription ?? this.subscription,
      favoriteMovies: favoriteMovies ?? this.favoriteMovies,
      likedMovies: likedMovies ?? this.likedMovies,
      downloadedMovies: downloadedMovies ?? this.downloadedMovies,
      watchingProgress: watchingProgress ?? this.watchingProgress,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      paymentMethods: paymentMethods ?? this.paymentMethods,
    );
  }
}

class SubscriptionModel {
  final String plan; // 'basic', 'premium'
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'active', 'expired', 'cancelled'
  final String? paymentMethod;
  final double price;

  SubscriptionModel({
    required this.plan,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.paymentMethod,
    required this.price,
  });

  factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionModel(
      plan: map['plan'],
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      status: map['status'],
      paymentMethod: map['paymentMethod'],
      price: map['price']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plan': plan,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'status': status,
      'paymentMethod': paymentMethod,
      'price': price,
    };
  }

  bool get isActive => status == 'active' && endDate.isAfter(DateTime.now());
}

class PaymentMethodModel {
  final String type; // 'momo', 'om', 'paypal', 'card'
  final String? cardLast4;
  final String? cardBrand;
  final String? phoneNumber; // Pour MoMo/OM
  final bool isDefault;

  PaymentMethodModel({
    required this.type,
    this.cardLast4,
    this.cardBrand,
    this.phoneNumber,
    this.isDefault = false,
  });

  factory PaymentMethodModel.fromMap(Map<String, dynamic> map) {
    return PaymentMethodModel(
      type: map['type'],
      cardLast4: map['cardLast4'],
      cardBrand: map['cardBrand'],
      phoneNumber: map['phoneNumber'],
      isDefault: map['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'cardLast4': cardLast4,
      'cardBrand': cardBrand,
      'phoneNumber': phoneNumber,
      'isDefault': isDefault,
    };
  }
}
