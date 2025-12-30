import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Account Settings")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Center(child: CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50))),
          const SizedBox(height: 20),
          ListTile(title: Text(user?.displayName ?? "User"), subtitle: const Text("Edit Name"), onTap: () => _editName(context, auth)),
          SwitchListTile(title: const Text("Dark Mode"), value: auth.isDarkMode, onChanged: (v) => auth.toggleTheme()),
          ListTile(
            leading: const Icon(Icons.security),
            title: const Text("Biometric Lock"),
            onTap: () async {
              bool authenticated = await auth.authenticate();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(authenticated ? "Verified!" : "Failed")));
             
            },
          ),
          ListTile(
            leading: const Icon(Icons.health_and_safety, color: Colors.red),
            title: const Text("Emergency SOS"),
            subtitle: const Text("Call Health Center"),
            onTap: () => launchUrl(Uri.parse('tel:999')),
          ),
          const SizedBox(height: 30),
          ElevatedButton(onPressed: () => auth.logout().then((_) => Navigator.pushReplacementNamed(context, '/login')), child: const Text("Logout")),
        ],
      ),
    );
  }

  void _editName(BuildContext context, AuthService auth) {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (c) => AlertDialog(
      title: const Text("Update Name"),
      content: TextField(controller: ctrl),
      actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text("Cancel")),
                TextButton(onPressed: () { auth.updateName(ctrl.text); Navigator.pop(c); }, child: const Text("Save"))],
    ));
  }
}