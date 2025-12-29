import 'package:bytebank_flutter/routes.dart';
import 'package:bytebank_flutter/ui/screens/sign-in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BytebankApp extends StatefulWidget {
  const BytebankApp({super.key});

  @override
  State<BytebankApp> createState() => _BytebankAppState();
}

class _BytebankAppState extends State<BytebankApp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    if (_auth.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Use named route from the root MaterialApp (defined in main.dart)
        Navigator.pushReplacementNamed(context, Routes.signIn);
        return;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Return the app layout; the real MaterialApp lives in main.dart
    return const MainLayout();
  }
}

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFE4EDE3,
      ), // --color-neutral-light from CSS
      body: Column(
        children: [
          // Header equivalent
          const BytebankHeader(),
          // Main content area (Sidebar + Content) - now with scrolling
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  child: MediaQuery.of(context).size.width >= 1024
                      ? _buildDesktopLayout()
                      : _buildMobileLayout(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sidebar
        Container(
          width: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(16),
          child: const SidebarMenu(),
        ),
        const SizedBox(width: 24),
        // Main content
        const Expanded(child: HomePage()),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 32),
          child: const SidebarMenu(),
        ),
        const HomePage(),
      ],
    );
  }
}

// Header component equivalent to Header.tsx
class BytebankHeader extends StatefulWidget {
  const BytebankHeader({super.key});

  @override
  State<BytebankHeader> createState() => _BytebankHeaderState();
}

class _BytebankHeaderState extends State<BytebankHeader> {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final user = _auth.currentUser;
    final String userName = user?.displayName ?? user?.email ?? 'Usuario';

    _signOut() async {
      await _auth.signOut();
      Navigator.pushReplacementNamed(context, Routes.signIn);
      return;
    }

    return Container(
      height: 96,
      width: double.infinity,
      color: const Color(0xFF004D61), // --color-primary
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: const EdgeInsets.symmetric(horizontal: 21),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 40),
              Row(
                children: [
                  // User icon button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFFF5031),
                      ), // --color-accent
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: Color(0xFFFF5031),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Logout button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: IconButton(
                      onPressed: _signOut,
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder for SidebarMenu
class SidebarMenu extends StatelessWidget {
  const SidebarMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Menu',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        _buildMenuItem(Icons.home, 'Home'),
        const SizedBox(height: 8),
        _buildMenuItem(
          Icons.account_balance_wallet,
          'Transactions',
          onTap: () => Navigator.pushNamed(context, Routes.transactions),
        ),
        const SizedBox(height: 8),
        _buildMenuItem(Icons.bar_chart, 'Reports'),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Colors.grey.shade100,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF004D61)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

// HomePage equivalent to your page.tsx
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    if (isDesktop) {
      // Desktop layout: Main content and aside side by side
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main content area
          Expanded(
            child: Column(
              children: [
                const PlaceholderCard(title: 'Balance Card'),
                const SizedBox(height: 24),
                const PlaceholderCard(title: 'Transaction Form'),
                const SizedBox(height: 24),
                const PlaceholderCard(title: 'Home Page Chart'),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Aside (Statement)
          SizedBox(width: 282, child: const RecentTransactions()),
        ],
      );
    } else {
      // Mobile layout: Stacked
      return Column(
        children: [
          const PlaceholderCard(title: 'Balance Card'),
          const SizedBox(height: 24),
          const PlaceholderCard(title: 'Transaction Form'),
          const SizedBox(height: 24),
          const PlaceholderCard(title: 'Home Page Chart'),
          const SizedBox(height: 24),
          const RecentTransactions(),
        ],
      );
    }
  }
}

// Placeholder widget for components we haven't built yet
class PlaceholderCard extends StatelessWidget {
  final String title;

  const PlaceholderCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'This will be replaced with the actual $title component',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class RecentTransactions extends StatelessWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Extrato recente',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, Routes.transactions),
                child: const Text(
                  'Ver todos',
                  style: TextStyle(fontSize: 12, color: Color(0xFF004D61)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (user != null)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('transactions')
                  .where('userId', isEqualTo: user.uid)
                  // .orderBy('date', descending: true)
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Error loading transactions');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Text('Sem transações recentes.');
                }
                return Column(
                  children: docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final value = (data['value'] is num)
                        ? (data['value'] as num).toDouble()
                        : double.tryParse('${data['value']}') ?? 0.0;
                    final typeStr = (data['type'] ?? 'debit')
                        .toString()
                        .toLowerCase();
                    final isCredit = typeStr.contains('credit');

                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black12),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: isCredit
                                ? Colors.green.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                            child: Icon(
                              isCredit
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: isCredit ? Colors.green : Colors.red,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              data['description'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${isCredit ? '+' : '-'} R\$ ${value.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isCredit ? Colors.green : Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          if (user == null)
            const Text('Faça o login para ver suas transações.'),
        ],
      ),
    );
  }
}
