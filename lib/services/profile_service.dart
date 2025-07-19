import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data'; // Import for Uint8List

class ProfileService {
  static Future<String?> uploadProfilePicture(XFile image) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('ProfileService: No user logged in. Cannot upload picture.');
        return null;
      }

      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('${user.uid}.jpg');

      print('ProfileService: Starting image upload for user ${user.uid}...');

      // Read image bytes
      Uint8List imageData = await image.readAsBytes();
      print('ProfileService: Image bytes read. Size: ${imageData.length} bytes');

      // Upload data
      UploadTask uploadTask = ref.putData(imageData);
      await uploadTask.whenComplete(() => null); // Wait for upload to complete
      print('ProfileService: Image upload completed.');

      // Get download URL
      final downloadUrl = await ref.getDownloadURL();
      print('ProfileService: Download URL obtained: $downloadUrl');
      return downloadUrl;
    } on FirebaseException catch (e) {
      // Catch specific Firebase Storage errors
      print('ProfileService: Firebase Storage Error uploading profile picture: ${e.code} - ${e.message}');
      return null;
    } catch (e) {
      // Catch any other general errors
      print('ProfileService: Generic Error uploading profile picture: $e');
      return null;
    }
  }

  static Future<void> updateUserProfile(String? photoUrl, String? displayName) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('ProfileService: No user logged in. Cannot update profile.');
        return;
      }

      if (displayName != null) {
        await user.updateDisplayName(displayName);
        print('ProfileService: Display name updated to $displayName');
      }
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
        print('ProfileService: Photo URL updated to $photoUrl');
      }
      
      // Reload the user to ensure the latest data is available across the app
      await user.reload();
      print('ProfileService: User reloaded after profile update.');

    } on FirebaseAuthException catch (e) {
      print('ProfileService: Firebase Auth Error updating user profile: ${e.code} - ${e.message}');
    } catch (e) {
      print('ProfileService: Generic Error updating user profile: $e');
    }
  }
}
