import 'dart:math'; // For password generation

import 'package:flutter/material.dart';

import '../models/password_entry.dart';

class EntryDialog extends StatefulWidget {
  final PasswordEntry? existingEntry;
  final Function(PasswordEntry) onSave;

  const EntryDialog({super.key, this.existingEntry, required this.onSave});

  @override
  State<EntryDialog> createState() => _EntryDialogState();
}

class _EntryDialogState extends State<EntryDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _siteNameCtrl;
  late TextEditingController _siteAddrCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _numberCtrl;
  late TextEditingController _nickNameCtrl;
  late TextEditingController _passCtrl;
  late TextEditingController _detailsCtrl;

  bool _isOtpEnabled = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final e = widget.existingEntry;
    _siteNameCtrl = TextEditingController(text: e?.siteName ?? '');
    _siteAddrCtrl = TextEditingController(text: e?.siteAddress ?? '');
    _emailCtrl = TextEditingController(text: e?.email ?? '');
    _numberCtrl = TextEditingController(
      text: e?.number.replaceAll('+91 ', '') ?? '',
    );
    _nickNameCtrl = TextEditingController(text: e?.nickName ?? '');
    _passCtrl = TextEditingController(text: e?.password ?? '');
    _detailsCtrl = TextEditingController(text: e?.additionalDetails ?? '');
    _isOtpEnabled = e?.isOtpEnabled ?? false;
  }

  // --- Pro Feature: Password Generator ---
  void _generatePassword() {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*()';
    final random = Random();
    final newPass = List.generate(
      16,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
    setState(() => _passCtrl.text = newPass);
  }

  @override
  void dispose() {
    for (var controller in [
      _siteNameCtrl,
      _siteAddrCtrl,
      _emailCtrl,
      _numberCtrl,
      _nickNameCtrl,
      _passCtrl,
      _detailsCtrl,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newEntry = PasswordEntry(
        id:
            widget.existingEntry?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        siteName: _siteNameCtrl.text.trim(),
        siteAddress: _siteAddrCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        number: _numberCtrl.text.isNotEmpty
            ? '+91 ${_numberCtrl.text.trim()}'
            : '',
        nickName: _nickNameCtrl.text.trim(),
        password: _passCtrl.text,
        isOtpEnabled: _isOtpEnabled,
        additionalDetails: _detailsCtrl.text.trim(),
      );

      widget.onSave(newEntry);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Header with Gradient
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.secondary],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.existingEntry == null
                        ? Icons.add_moderator
                        : Icons.edit_note,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.existingEntry == null
                        ? 'Add to Vault'
                        : 'Secure Edit',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // 2. Form Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildInput(
                        _siteNameCtrl,
                        'Site / App Name',
                        Icons.apps,
                        true,
                      ),
                      const SizedBox(height: 16),
                      _buildInput(
                        _siteAddrCtrl,
                        'URL (Optional)',
                        Icons.language,
                        false,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInput(
                              _emailCtrl,
                              'Email',
                              Icons.alternate_email,
                              true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // NEW: Phone Number Field
                      _buildInput(
                        _numberCtrl,
                        'Phone (Optional)',
                        Icons.phone,
                        false,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),

                      _buildInput(
                        _nickNameCtrl,
                        'Username / Nickname',
                        Icons.badge_outlined,
                        false,
                      ),
                      const SizedBox(height: 16),

                      // 3. Password Box with Generator
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorScheme.primary.withOpacity(0.2),
                          ),
                        ),
                        child: TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.password),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.auto_fix_high,
                                    color: Colors.orange,
                                  ),
                                  onPressed: _generatePassword,
                                  tooltip: 'Generate Strong Password',
                                ),
                              ],
                            ),
                          ),
                          validator: (val) =>
                              val!.isEmpty ? 'Password is required' : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // NEW: Additional Notes Field
                      _buildInput(
                        _detailsCtrl,
                        'Additional Notes',
                        Icons.notes,
                        false,
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),

                      SwitchListTile(
                        title: const Text(
                          '2FA / OTP Required',
                          style: TextStyle(fontSize: 14),
                        ),
                        subtitle: const Text(
                          'Toggle for high-security accounts',
                          style: TextStyle(fontSize: 11),
                        ),
                        value: _isOtpEnabled,
                        onChanged: (val) => setState(() => _isOtpEnabled = val),
                        secondary: const Icon(Icons.verified_user_outlined),
                        activeColor: Colors.teal,
                        contentPadding:
                            EdgeInsets.zero, // Aligns nicely with other fields
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 4. Action Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'LOCK IN VAULT',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modified helper function to support keyboard types and multiple lines
  Widget _buildInput(
    TextEditingController ctrl,
    String lbl,
    IconData icon,
    bool required, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: lbl,
        alignLabelWithHint: maxLines > 1,
        // Ensures label stays at the top for tall boxes
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      validator: (val) =>
          (required && val!.isEmpty) ? '$lbl is required' : null,
    );
  }
}
