import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prashna_pooja_app/widgets/order_item_tile.dart';

class PrashnaListPage extends StatelessWidget {
  const PrashnaListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = List.generate(8, (i) => 'PRASHNA-${1000 + i}');

    const backgroundGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF1a237e), Color(0xFF0d47a1)],
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: backgroundGradient),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              title: Text('Prashna Orders', style: GoogleFonts.poppins()),
              pinned: true,
            ),
            SliverPadding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              sliver: SliverList.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final id = orders[index];
                  return OrderItemTile(
                    icon: Icons.assignment_outlined,
                    title: 'Order $id',
                    subtitle: 'Tap to record and submit audio',
                    onTap: () => context.go('/prashna/$id'),
                  ).animate(delay: (100 * index).ms); // Staggered animation
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
