import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  static Future<String?> uploadProfilePicture(XFile image) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('${user.uid}.jpg');

      await ref.putData(await image.readAsBytes());
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading profile picture: $e');
      return null;
    }
  }

  static Future<void> updateUserProfile(String? photoUrl, String? displayName) async {
    await FirebaseAuth.instance.currentUser?.updateDisplayName(displayName);
    if (photoUrl != null) {
      await FirebaseAuth.instance.currentUser?.updatePhotoURL(photoUrl);
    }
    await FirebaseAuth.instance.currentUser?.reload();
  }
}