// lib/pages/profile_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/profile_service.dart'; // Ensure ProfileService handles Firebase Storage and Auth updates
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
	_initializeProfileData();
  }

  void _initializeProfileData() {
	final user = FirebaseAuth.instance.currentUser;
	_nameController.text = user?.displayName ?? '';
  }

  Future<void> _pickImage() async {
	final ImagePicker picker = ImagePicker();
	XFile? image; // Declare image here

	print('ProfileScreen: Attempting to pick image from gallery...');
	try {
	  image = await picker.pickImage(source: ImageSource.gallery);
	  print('ProfileScreen: ImagePicker returned.'); // Debug print after picker call
	} catch (e) {
	  print('ProfileScreen: Error during image picking: $e'); // Catch errors from picker itself
	  if (mounted) {
		ScaffoldMessenger.of(context).showSnackBar(
		  SnackBar(content: Text('Error accessing gallery: $e')),
		);
	  }
	  setState(() => _isLoading = false); // Ensure loading is off if picker fails
	  return; // Exit if image picking fails
	}

	if (image != null) {
	  setState(() => _isLoading = true); // Show loading indicator
	  print('ProfileScreen: Image selected: ${image.path}'); // Debug print

	  try {
		final photoUrl = await ProfileService.uploadProfilePicture(image);
		print('ProfileScreen: Uploaded photo URL from service: $photoUrl'); // Debug print

		if (photoUrl != null) {
		  await ProfileService.updateUserProfile(
			  photoUrl, null); // Update photo URL in Firebase Auth

		  // IMPORTANT: Reload the current user to get the updated photoURL
		  // This ensures FirebaseAuth.instance.currentUser reflects the latest data.
		  await FirebaseAuth.instance.currentUser?.reload();
		  final updatedUser = FirebaseAuth.instance.currentUser; // Get the reloaded user
		  print('ProfileScreen: User photoURL after reload: ${updatedUser?.photoURL}'); // Debug print

		  if (mounted) {
			ScaffoldMessenger.of(context).showSnackBar(
			  const SnackBar(
				  content: Text('Profile picture updated successfully')),
			);
		  }
		} else {
		  if (mounted) {
			ScaffoldMessenger.of(context).showSnackBar(
			  const SnackBar(
				  content: Text('Failed to get photo URL after upload.')),
			);
		  }
		}
	  } catch (e) {
		if (mounted) {
		  ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(content: Text('Error uploading picture: $e')),
		  );
		}
		print('ProfileScreen: Error during image pick/upload: $e'); // Debug print
	  } finally {
		if (mounted) {
		  // Hide loading indicator and trigger a UI rebuild to show updated image
		  setState(() => _isLoading = false);
		}
	  }
	} else {
	  print('ProfileScreen: Image picking cancelled.'); // Debug print
	  setState(() => _isLoading = false); // Ensure loading is off if cancelled
	}
  }

  Future<void> _updateProfile() async {
	setState(() => _isLoading = true);
	try {
	  await ProfileService.updateUserProfile(
		null, // Photo is handled by _pickImage separately
		_nameController.text, // Update display name from text field
	  );
	  // IMPORTANT: Reload the current user to get the updated display name
	  await FirebaseAuth.instance.currentUser?.reload();
	  final updatedUser = FirebaseAuth.instance.currentUser; // Get the reloaded user
	  print('ProfileScreen: User display name after reload: ${updatedUser?.displayName}'); // Debug print

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
	  print('ProfileScreen: Error during profile update: $e'); // Debug print
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
	// Get the latest user object every time build is called
	final user = FirebaseAuth.instance.currentUser;
	final colorScheme = Theme.of(context).colorScheme;
	final textTheme = Theme.of(context).textTheme;

	// Add this debug print to see the photoURL being used by CircleAvatar
	print('ProfileScreen Build: Current user photoURL: ${user?.photoURL}');

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
					style: TextStyle( // Use theme's text style
					  fontSize: 22.0,
					  fontWeight: FontWeight.bold,
					  color: colorScheme.onSurface,
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

				  // --- START: ADDED BIOMETRIC SETTINGS BUTTON ---
				  ListTile(
					leading: Icon(Icons.fingerprint, color: colorScheme.primary),
					title: const Text('Manage Biometric Login'),
					subtitle: const Text('Enable Face ID or Fingerprint for quick sign-in.'),
					trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.onSurface.withOpacity(0.5)),
					onTap: () {
					  // Navigate to the new biometric settings page
					  Navigator.pushNamed(context, '/biometric_settings');
					},
				  ),
				  const Divider(height: 1, thickness: 1), // Separator for settings
				  const SizedBox(height: 24.0),
				  // --- END: ADDED BIOMETRIC SETTINGS BUTTON ---

				  Row(
					children: [
					  Expanded( // Keep this expanded if you want the Sign out button to take full width
						child: TextButton.icon(
						  onPressed: () async {
							// Handle sign out
							await FirebaseAuth.instance.signOut();
							if (mounted) {
							  ScaffoldMessenger.of(context).showSnackBar(
								const SnackBar(
									content: Text('Signed out successfully')),
							  );
							  // Navigate to the login screen after sign out
							  Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
							}
						  },
						  icon: Icon(Icons.logout, color: colorScheme.error), // Use error color for logout
						  label: Text(
							'Sign out',
							style: textTheme.bodyMedium?.copyWith(color: colorScheme.error), // Use error color for text
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
					onPressed: _isLoading ? null : _updateProfile, // Disable button while loading
					style: ElevatedButton.styleFrom(
					  backgroundColor: colorScheme.primary,
					  foregroundColor: colorScheme.onPrimary,
					  padding: const EdgeInsets.symmetric(
						  horizontal: 40, vertical: 12),
					  shape: RoundedRectangleBorder(
						borderRadius: BorderRadius.circular(8),
					  ),
					),
					child: _isLoading
						? CircularProgressIndicator(color: colorScheme.onPrimary) // Show loading on button
						: Text('Save Profile', style: textTheme.titleMedium),
				  ),
				],
			  ),
			),
	);
  }
}