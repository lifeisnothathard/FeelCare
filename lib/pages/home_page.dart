import 'package:flutter/material.dart';
import 'package:feelcare/drawer/side_dashboard.dart';
import 'package:feelcare/pages/login.dart';
import 'package:feelcare/themes/theme_provider.dart';


// This is the main entry point for the home page.
class HomePage extends StatelessWidget {
  final ThemeProvider themeProvider; // Receive ThemeProvider instance

  const HomePage ({super.key, required this.themeProvider});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        centerTitle: true, // Center the app bar title
        // No need for a leading icon for the drawer here,
        // Scaffold automatically adds one if a Drawer is present.
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Handle logout logic here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out!')),
              );
              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen(themeProvider: themeProvider)));
            },
            tooltip: 'Logout', // Tooltip for accessibility
          ),
        ],
      ),
      // --- Call Side Dashboard (Drawer) ---
      drawer: const AppDrawer(),
     
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Vertically center content
            crossAxisAlignment: CrossAxisAlignment.center, // Horizontally center content
            children: <Widget>[
              // Welcome Icon
              Icon(
                Icons.check_circle_outline,
                size: 120,
                color: Colors.green[700],
              ),
              const SizedBox(height: 30), // Spacing

              // Welcome Message
              const Text(
                'Welcome Home!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Placeholder for user-specific content or features
              Text(
                'You have successfully logged in. Use the side menu for navigation.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Example of a button to navigate to another feature
              ElevatedButton.icon(
                onPressed: () {
                  // Open the drawer programmatically if needed, or
                  // just show a message.
                  Scaffold.of(context).openDrawer(); // Opens the drawer
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening side menu...')),
                  );
                },
                icon: const Icon(Icons.menu), // Icon for the button
                label: const Text('Open Menu'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.deepPurpleAccent, // Button background color
                  foregroundColor: Colors.white, // Button text color
                  elevation: 5,
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// To integrate this with your login.dart, you would modify the _login function
// in login.dart to navigate to this HomePage upon successful login:

/*
// In login.dart, inside _LoginScreenState's _login method:
void _login() {
  if (_formKey.currentState!.validate()) {
    // Simulate successful login
    debugPrint('Email: ${_emailController.text}');
    debugPrint('Password: ${_passwordController.text}');

    // Navigate to the HomePage and replace the current route,
    // so the user cannot go back to the login page with the back button.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }
}
*/
