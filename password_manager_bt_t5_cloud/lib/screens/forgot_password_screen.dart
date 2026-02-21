import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  final _storage = const FlutterSecureStorage();

  Future<void> _resetVault(BuildContext context) async {
    // 1. Clear the local master key
    await _storage.delete(key: 'master_key');

    // 2. Sign out of Firebase to ensure full re-authentication
    await AuthService().signOut();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Local Vault Reset. Please Login again.")),
      );
      // 3. Go back to the very beginning (AuthWrapper will handle the rest)
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 80,
              color: Colors.orange.shade700,
            ),
            const SizedBox(height: 24),
            const Text(
              "Reset Master Password",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "For security, Master Passwords cannot be recovered. To set a new one, we must reset your local vault session.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              "Your cloud data will remain safe. You will just need to log in again and set a new Master Key.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 40),

            // The Action Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => _resetVault(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red.shade900,
                  side: BorderSide(color: Colors.red.shade100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text("I UNDERSTAND, RESET LOCAL VAULT"),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Go Back"),
            ),
          ],
        ),
      ),
    );
  }
}
