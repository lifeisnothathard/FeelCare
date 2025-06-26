import 'package:flutter/material.dart';
import 'package:feelcare/pages/home_page.dart';
import 'package:feelcare/themes/theme_provider.dart';

// This is the main entry point for the login screen.
class LoginScreen extends StatefulWidget {
  final ThemeProvider themeProvider; // Receive ThemeProvider instance

  const LoginScreen ({super.key, required this.themeProvider});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // GlobalKey to uniquely identify the Form widget and enable validation.
  final _formKey = GlobalKey<FormState>();

  // Controllers for text input fields to retrieve user input.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // State variable to show/hide the password.
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    // Dispose controllers to free up resources when the widget is removed.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Function to handle the login logic.
  void _login() {
  if (_formKey.currentState!.validate()) {
    // Simulate successful login
    debugPrint('Email: ${_emailController.text}');
    debugPrint('Password: ${_passwordController.text}');

    // Navigate to the HomePage and replace the current route
    Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(themeProvider: ThemeProvider()))
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView( // Allows scrolling if content overflows
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey, // Assign the form key
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // App Logo or Icon (Optional)
                const Icon(
                  Icons.lock_person,
                  size: 100,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 48),

                // Email Input Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null; // Return null if the input is valid
                  },
                ),
                const SizedBox(height: 20),

                // Password Input Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible, // Toggles password visibility
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        // Update the state to toggle password visibility.
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Login Button
                SizedBox(
                  width: double.infinity, // Makes the button take full width
                  child: ElevatedButton(
                    onPressed: _login, // Call the _login function on press
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.deepPurple, // Button background color
                      foregroundColor: Colors.white, // Button text color
                      elevation: 5, // Shadow effect
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Optional: Forgot Password/Sign Up links
                TextButton(
                  onPressed: () {
                    // Handle forgot password logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Forgot Password pressed!')),
                    );
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        // Handle navigate to sign up screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sign Up pressed!')),
                        );
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(color: Colors.deepPurple),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

