// lib/pages/profile_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/profile_service.dart';
import '../themes/theme_provider.dart';
import 'package:feelcare/themes/colors.dart'; // Import AppColors

class ProfileScreen extends StatefulWidget {
  final ThemeProvider themeProvider;

  const ProfileScreen({super.key, required this.themeProvider});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameController.text = user?.displayName ?? '';
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _isLoading = true); // Show loading indicator

      try {
        final photoUrl = await ProfileService.uploadProfilePicture(image);
        if (photoUrl != null) {
          await ProfileService.updateUserProfile(
              photoUrl, null); // Update photo URL in Firebase Auth

          // IMPORTANT FIX: Reload the current user to get the updated photoURL
          await FirebaseAuth.instance.currentUser?.reload();
          // After reloading, get the refreshed user object for the UI to pick it up.
          // This will trigger a rebuild when _isLoading becomes false.
          // You don't necessarily need to explicitly re-fetch `user = FirebaseAuth.instance.currentUser;`
          // here if your `build` method relies on `FirebaseAuth.instance.currentUser` directly.

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Profile picture updated successfully')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading picture: $e')),
          );
        }
      } finally {
        if (mounted) {
          // Hide loading indicator and trigger a UI rebuild to show updated image
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      await ProfileService.updateUserProfile(
        null, // Photo is handled by _pickImage separately
        _nameController.text, // Update display name from text field
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface, // Use theme background color
      appBar: AppBar(
        title: Text('Profile',
            style: textTheme.headlineSmall
                ?.copyWith(color: colorScheme.onPrimary)),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Profile Picture with Camera Icon - Integrated from previous example
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60, // Larger avatar
                        backgroundColor: colorScheme
                            .secondary, // Background for default icon
                        backgroundImage: user?.photoURL != null
                            ? NetworkImage(user!.photoURL!)
                            : null,
                        child: user?.photoURL == null
                            ? Icon(Icons.person,
                                size: 60, color: colorScheme.onSecondary)
                            : null,
                      ),
                      GestureDetector(
                        onTap: _pickImage, // Call existing pick image function
                        child: Container(
                          padding: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: Colors
                                .white, // White background for the camera icon
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.grey[300]!), // Light grey border
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size:
                                20.0, // Adjusted size for better fit on 60 radius avatar
                            color: Colors.black54, // Darker color for the icon
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Hi, ${user?.displayName ?? 'User'}!',
                    style: const TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Display Name Text Field (original)
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Display Name',
                      hintText: 'Enter your display name',
                      prefixIcon: Icon(Icons.person_outline,
                          color: colorScheme.primary),
                      border: OutlineInputBorder(
                        // Added border for clarity
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: colorScheme.primary, width: 2),
                      ),
                    ),
                    style: textTheme.bodyMedium
                        ?.copyWith(color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () {
                            // Handle add account (e.g., navigate to login/signup)
                          },
                          icon: const Icon(Icons.add, color: Colors.black54),
                          label: const Text(
                            'Add account',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () async {
                            // Handle sign out
                            await FirebaseAuth.instance.signOut();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Signed out successfully')),
                              );
                              // You might want to navigate to the login screen after sign out
                              // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
                            }
                          },
                          icon: const Icon(Icons.logout, color: Colors.black54),
                          label: const Text(
                            'Sign out',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  const Divider(height: 1, thickness: 1),
                  const SizedBox(height: 16.0),

                  // Save Profile Button (original)
                  ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Save Profile', style: textTheme.titleMedium),
                  ),
                ],
              ),
            ),
    );
  }
}
