import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prashna_pooja_app/widgets/order_item_tile.dart';

class PoojaListPage extends StatelessWidget {
  const PoojaListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = List.generate(8, (i) => 'POOJA-${2000 + i}');

    // Consistent background gradient
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
              title: Text('Pooja Orders', style: GoogleFonts.poppins()),
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
                    icon: Icons.local_fire_department_outlined,
                    title: 'Order $id',
                    subtitle: 'Tap to record/pick video and submit',
                    onTap: () => context.go('/pooja/$id'),
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
