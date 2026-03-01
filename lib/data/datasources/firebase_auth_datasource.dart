import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/firebase_constants.dart';
import '../../domain/entities/user_entity.dart';
import '../models/user_model.dart';

/// Firebase Auth and user document datasource.
/// Paste in: lib/data/datasources/firebase_auth_datasource.dart
class FirebaseAuthDatasource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get _usersPath => AppConstants.usersCollection;

  Future<UserEntity?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _firestore.collection(_usersPath).doc(user.uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc.data()!, doc.id);
  }

  Future<UserEntity> signInWithEmailPassword(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final uid = cred.user!.uid;
    final doc = await _firestore.collection(_usersPath).doc(uid).get();
    if (!doc.exists) throw Exception('User document not found');
    return UserModel.fromFirestore(doc.data()!, doc.id);
  }

  Future<UserEntity> createDriverAccount(String email, String password, String name) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final uid = cred.user!.uid;
    await _firestore.collection(_usersPath).doc(uid).set({
      FirebaseConstants.uid: uid,
      FirebaseConstants.email: email,
      FirebaseConstants.role: AppConstants.roleDriver,
      FirebaseConstants.displayName: name.trim().isEmpty ? null : name.trim(),
      FirebaseConstants.isSuspended: false,
      FirebaseConstants.createdAt: FieldValue.serverTimestamp(),
    });
    await _firestore.collection(AppConstants.driversCollection).doc(uid).set({
      'userId': uid,
      FirebaseConstants.name: name.trim().isEmpty ? email.split('@').first : name.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    final user = await getCurrentUser();
    if (user != null) return user;
    return UserModel(uid: uid, email: email, role: AppConstants.roleDriver, displayName: name.trim().isEmpty ? null : name.trim());
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Stream<UserEntity?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      try {
        final doc = await _firestore.collection(_usersPath).doc(user.uid).get();
        if (!doc.exists) return null;
        return UserModel.fromFirestore(doc.data()!, doc.id);
      } on FirebaseException {
        // During sign-out/token transition, this read can fail temporarily.
        // Avoid bubbling stream errors that cause unhandled exceptions in UI.
        return null;
      } catch (_) {
        return null;
      }
    });
  }

  Future<void> updateFcmToken(String uid, String? token) async {
    await _firestore.collection(_usersPath).doc(uid).update({'fcmToken': token});
  }

  Future<void> setSuspended(String uid, bool suspended) async {
    await _firestore.collection(_usersPath).doc(uid).update({FirebaseConstants.isSuspended: suspended});
  }

  Future<List<String>> getAdminFcmTokens() async {
    final snap = await _firestore
        .collection(_usersPath)
        .where(FirebaseConstants.role, isEqualTo: AppConstants.roleAdmin)
        .get();
    final tokens = <String>[];
    for (final doc in snap.docs) {
      final t = doc.data()[FirebaseConstants.fcmToken] as String?;
      if (t != null && t.isNotEmpty) tokens.add(t);
    }
    return tokens;
  }
}
