// payment_controller.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
//import '../models/payment_model.dart';

class PaymentController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Payer un abonnement
  Future<void> subscribe({
    required String plan,
    required PaymentMethod paymentMethod,
    required double amount,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in');

    // Enregistrer le paiement
    final paymentRef = await _firestore.collection('payments').add({
      'userId': userId,
      'amount': amount,
      'currency': 'XAF',
      'paymentMethod': paymentMethod.type,
      'status': 'completed',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Mettre à jour l'abonnement de l'utilisateur
    final now = DateTime.now();
    await _firestore.collection('users').doc(userId).update({
      'subscription': {
        'plan': plan,
        'startDate': now,
        'endDate': now.add(Duration(days: 30)), // 1 mois
        'status': 'active',
        'paymentMethod': paymentMethod.type,
        'paymentId': paymentRef.id,
      },
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Obtenir les méthodes de paiement de l'utilisateur
  Future<List<PaymentMethod>> getPaymentMethods(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    final data = doc.data() as Map<String, dynamic>;
    final methods = data['paymentMethods'] as List<dynamic>? ?? [];

    return methods.map((method) => PaymentMethod.fromMap(method)).toList();
  }

  // Ajouter une méthode de paiement
  Future<void> addPaymentMethod({
    required String userId,
    required PaymentMethod method,
  }) async {
    await _firestore.collection('users').doc(userId).update({
      'paymentMethods': FieldValue.arrayUnion([method.toMap()]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Supprimer une méthode de paiement
  Future<void> removePaymentMethod({
    required String userId,
    required PaymentMethod method,
  }) async {
    await _firestore.collection('users').doc(userId).update({
      'paymentMethods': FieldValue.arrayRemove([method.toMap()]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Vérifier le statut de l'abonnement
  Future<SubscriptionStatus> getSubscriptionStatus(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    final subscription = doc['subscription'] as Map<String, dynamic>?;

    if (subscription == null) return SubscriptionStatus.none;

    final endDate = (subscription['endDate'] as Timestamp).toDate();
    if (endDate.isBefore(DateTime.now())) {
      return SubscriptionStatus.expired;
    }

    return SubscriptionStatus.active;
  }

  // Obtenir l'historique des paiements
  Stream<List<PaymentHistory>> getPaymentHistory(String userId) {
    return _firestore
        .collection('payments')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PaymentHistory.fromFirestore(doc))
            .toList());
  }
}

enum SubscriptionStatus {
  none,
  active,
  expired,
}

class PaymentMethod {
  final String type; // 'momo', 'om', 'card', 'paypal'
  final String? last4;
  final String? brand;
  final String? phoneNumber;

  PaymentMethod({
    required this.type,
    this.last4,
    this.brand,
    this.phoneNumber,
  });

  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      type: map['type'],
      last4: map['last4'],
      brand: map['brand'],
      phoneNumber: map['phoneNumber'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'last4': last4,
      'brand': brand,
      'phoneNumber': phoneNumber,
    };
  }
}

class PaymentHistory {
  final String id;
  final double amount;
  final String currency;
  final String status;
  final DateTime createdAt;

  PaymentHistory({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
  });

  factory PaymentHistory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentHistory(
      id: doc.id,
      amount: data['amount']?.toDouble() ?? 0.0,
      currency: data['currency'] ?? 'XAF',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
