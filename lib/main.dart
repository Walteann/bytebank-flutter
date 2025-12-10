import 'package:flutter/material.dart';

void main() {
  runApp(const BytebankApp());
}

class BytebankApp extends StatelessWidget {
  const BytebankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bytebank',
      theme: ThemeData(
        // Custom color scheme based on your CSS variables
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF004D61), // --color-primary
          primary: const Color(0xFF004D61),
          secondary: const Color(0xFF47A138), // --color-success
          surface: const Color(0xFFF8F8F8), // --color-neutral-100
          error: const Color(0xFFFF5031), // --color-accent
        ),
        // Removed fontFamily for now - you can add Inter later if needed
        useMaterial3: true,
      ),
      home: const MainLayout(),
    );
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
class BytebankHeader extends StatelessWidget {
  const BytebankHeader({super.key});

  @override
  Widget build(BuildContext context) {
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
              const Text(
                'Usuario', // You'll replace this with actual user name from state
                style: TextStyle(
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
                      onPressed: () {
                        // Handle logout - you'll implement this
                        print('Logout pressed');
                      },
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
        _buildMenuItem(Icons.account_balance_wallet, 'Transactions'),
        const SizedBox(height: 8),
        _buildMenuItem(Icons.bar_chart, 'Reports'),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return Container(
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
          SizedBox(
            width: 282,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const PlaceholderCard(title: 'Statement'),
            ),
          ),
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
          const PlaceholderCard(title: 'Statement'),
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
