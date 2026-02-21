import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/password_entry.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/entry_dialog.dart';
import '../widgets/password_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _dbService = DatabaseService();
  String _searchQuery = "";

  void _showDialog({PasswordEntry? entry}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => EntryDialog(
        existingEntry: entry,
        onSave: (newEntry) => _dbService.saveEntry(newEntry),
      ),
    );
  }

  void _delete(String id) {
    _dbService.deleteEntry(id);
  }

  // Get current user details from Firebase
  User? get _currentUser => FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // 1. Premium Layered Header with Profile Identity
          SliverAppBar(
            expandedHeight: 230.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: colorScheme.surface,

            // --- USER PROFILE ICON (Left Side) ---
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  _currentUser?.email != null
                      ? _currentUser!.email![0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Custom Title when the user scrolls up (Collapsed state)
            title: _searchQuery.isEmpty
                ? const Text(
                    "T5 Vault",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                : const Text("Searching..."),

            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // The Background Gradient
                  Container(
                    width: double.infinity,
                    height: 210,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF004D40), // Deep Teal
                          colorScheme.primary,
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                  ),

                  // Header Branding & User Email Chip
                  Positioned(
                    top: 95,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        const Text(
                          "T5 PASSWORD MANAGER CLOUD",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // --- LOGGED IN USER CHIP ---
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.cloud_done_rounded,
                                color: Colors.tealAccent,
                                size: 12,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _currentUser?.email ?? "Cloud User",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. Centered Floating Search Bar
                  Positioned(
                    bottom: 0,
                    left: 24,
                    right: 24,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: TextField(
                        textAlign: TextAlign.center,
                        onChanged: (val) =>
                            setState(() => _searchQuery = val.toLowerCase()),
                        decoration: InputDecoration(
                          hintText: "SEARCH IN YOUR VAULT",
                          hintStyle: TextStyle(
                            color: colorScheme.onSurfaceVariant.withOpacity(
                              0.5,
                            ),
                            letterSpacing: 1.5,
                            fontSize: 11,
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Icon(
                              Icons.search,
                              color: colorScheme.primary,
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- LOGOUT BUTTON (Right Side) ---
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                tooltip: "Logout",
                onPressed: () => AuthService().signOut(),
              ),
            ],
          ),

          // 3. Password List with Spacing
          StreamBuilder<List<PasswordEntry>>(
            stream: _dbService.getPasswordsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_open_rounded,
                          size: 64,
                          color: colorScheme.outlineVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Your vault is currently empty.",
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final filteredData = snapshot.data!
                  .where((e) => e.siteName.toLowerCase().contains(_searchQuery))
                  .toList();

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 35, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final entry = filteredData[index];
                    return PasswordCard(
                      entry: entry,
                      onEdit: () => _showDialog(entry: entry),
                      onDelete: () => _delete(entry.id),
                    );
                  }, childCount: filteredData.length),
                ),
              );
            },
          ),
        ],
      ),

      // Custom Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDialog(),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.security_rounded),
        label: const Text("ENTER NEW DATA"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
