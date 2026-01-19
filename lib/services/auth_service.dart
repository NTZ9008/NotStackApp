import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ดู User ปัจจุบัน
  User? get currentUser => _auth.currentUser;

  // Stream คอยฟังสถานะ Login/Logout (ใช้ใน StreamBuilder)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ✅ Login ด้วย Google
  Future<User?> signInWithGoogle() async {
    try {
      // 1. เริ่มกระบวนการ Sign In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // กดยกเลิก

      // 2. ดึง Authentication (Access Token, ID Token)
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. สร้าง Credential สำหรับ Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in เข้า Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print("Error Google Sign In: $e");
      return null;
    }
  }

  // ✅ Logout
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}