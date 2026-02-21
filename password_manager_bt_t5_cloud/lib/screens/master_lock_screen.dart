import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'forgot_password_screen.dart'; // Ensure this file is created
import 'home_screen.dart';

class MasterLockScreen extends StatefulWidget {
  final bool isSetupMode; // true for setting up, false for unlocking

  const MasterLockScreen({super.key, this.isSetupMode = false});

  @override
  State<MasterLockScreen> createState() => _MasterLockScreenState();
}

class _MasterLockScreenState extends State<MasterLockScreen> {
  final _storage = const FlutterSecureStorage();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _obscureText = true;

  // Logic to handle Unlock or Setup
  Future<void> _handleAction() async {
    final pin = _pinController.text.trim();

    if (pin.isEmpty) {
      _showMsg("Please enter a password");
      return;
    }

    if (widget.isSetupMode) {
      // --- SETUP MODE ---
      if (pin != _confirmPinController.text.trim()) {
        _showMsg("Passwords do not match!");
        return;
      }
      await _storage.write(key: 'master_key', value: pin);
      _navigateToHome();
    } else {
      // --- UNLOCK MODE ---
      String? savedKey = await _storage.read(key: 'master_key');
      if (pin == savedKey) {
        _navigateToHome();
      } else {
        _showMsg("Access Denied: Incorrect Password");
      }
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) => const HomeScreen(),
        transitionsBuilder: (context, anim1, anim2, child) =>
            FadeTransition(opacity: anim1, child: child),
      ),
    );
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent.shade700,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface,
              colorScheme.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 1. Security Icon Branding
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primaryContainer.withOpacity(0.3),
                    ),
                    child: Icon(
                      widget.isSetupMode
                          ? Icons.admin_panel_settings
                          : Icons.lock_outline_rounded,
                      size: 64,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 2. Headings
                  Text(
                    widget.isSetupMode ? "Setup Your Vault" : "Vault Protected",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.isSetupMode
                        ? "Set a local master password to encrypt your vault on this device."
                        : "Enter your master key to decrypt and access your passwords.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // 3. Central Input Card
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withOpacity(0.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildPasswordField(
                          _pinController,
                          "MASTER PASSWORD",
                          true,
                        ),
                        if (widget.isSetupMode) ...[
                          const Divider(height: 1),
                          _buildPasswordField(
                            _confirmPinController,
                            "CONFIRM PASSWORD",
                            false,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 4. Primary Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: _handleAction,
                      icon: Icon(
                        widget.isSetupMode
                            ? Icons.cloud_done_rounded
                            : Icons.lock_open_rounded,
                      ),
                      label: Text(
                        widget.isSetupMode
                            ? "INITIALIZE VAULT"
                            : "AUTHENTICATE",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  // 5. Recovery Option
                  if (!widget.isSetupMode)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Forgot Master Password?",
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper to build consistent password fields
  Widget _buildPasswordField(
    TextEditingController controller,
    String hint,
    bool showSuffix,
  ) {
    return TextField(
      controller: controller,
      obscureText: _obscureText,
      textAlign: TextAlign.center,
      onSubmitted: (_) => _handleAction(),
      // Windows Enter-Key Support
      style: const TextStyle(
        fontSize: 18,
        letterSpacing: 2,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          letterSpacing: 1,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        prefixIcon: const Icon(Icons.password_rounded, size: 20),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
        suffixIcon: showSuffix
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : const SizedBox(width: 48), // Keeps the text centered
      ),
    );
  }
}
