import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/home_cards.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // A beautiful gradient for the background
    const backgroundGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF1a237e), // Deep Indigo
        Color(0xFF0d47a1), // Deep Blue
      ],
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: backgroundGradient),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              expandedHeight: 180.0,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                centerTitle: false,
                title: Text(
                  'Dashboard',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF283593), // Lighter Indigo
                        Color(0xFF1565c0), // Lighter Blue
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
                child: Text(
                  'Select a service to continue',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    HomeTile(
                      icon: Icons.record_voice_over,
                      title: 'Prashna',
                      subtitle: 'View orders and record audio answers',
                      onTap: () => context.go('/prashna'),
                      gradientColors: const [
                        Color(0xFFff7e5f),
                        Color(0xFFfeb47b)
                      ],
                    ),
                    const SizedBox(height: 16),
                    HomeTile(
                      icon: Icons.local_fire_department_outlined,
                      title: 'Pooja',
                      subtitle: 'View orders and record video updates',
                      onTap: () => context.go('/pooja'),
                      gradientColors: const [
                        Color(0xFF8e2de2),
                        Color(0xFF4a00e0)
                      ],
                    ),
                    // Add more cards here if needed
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms); // Fade in the whole page
  }
}
