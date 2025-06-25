import 'package:feelcare/pages/login.dart';
import 'package:flutter/material.dart';

// You might need to import your login.dart file if you want to navigate back to it.
// import 'package:your_project_name/login.dart'; // Adjust import path as needed

// This is the main entry point for the home page.
class HomePage extends StatelessWidget {
  // Constructor for HomePage, with an optional key.
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        centerTitle: true, // Center the app bar title
        // Optional: Add actions like a logout button here
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                 context,
                 MaterialPageRoute(builder: (context) => const LoginScreen()),
               );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out!')),
              );
              Navigator.pop(LoginScreen() as BuildContext); // Goes back to the previous screen (e.g., LoginScreen)
            },
            tooltip: 'Logout', // Tooltip for accessibility
          ),
        ],
      ),
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
                'You have successfully logged in. This is your personal dashboard.',
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
                  // Implement navigation to another screen or feature
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Exploring features...')),
                  );
                },
                icon: const Icon(Icons.dashboard), // Icon for the button
                label: const Text('Go to Dashboard'),
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
