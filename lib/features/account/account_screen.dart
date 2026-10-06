import 'package:cartiva/features/auth/sign_in_screen.dart';
import 'package:cartiva/features/account/my_orders_screen.dart';
import 'package:cartiva/features/notifications/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignIn()),
      (route) => false,
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red, width: 4),
                ),
                child: const Center(
                  child: Text(
                    '!',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Logout?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to logout?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Yes, Logout'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFDDDDDD)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('No, Cancel'),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (shouldLogout == true && context.mounted) {
      await _signOut(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Account',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
          ),
        ],
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        children: [
          const Divider(height: 1, indent: 24, endIndent: 24),
          AccountSection(
            tiles: [
              AccountTile(
                icon: Icons.inventory_2_outlined,
                title: 'My Orders',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MyOrdersScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SectionGap(),
          AccountSection(
            tiles: [
              const AccountTile(
                icon: Icons.contact_page_outlined,
                title: 'My Details',
              ),
              const AccountTile(
                icon: Icons.home_outlined,
                title: 'Address Book',
              ),
              const AccountTile(
                icon: Icons.credit_card_outlined,
                title: 'Payment Methods',
              ),
              AccountTile(
                icon: Icons.notifications_none,
                title: 'Notifications',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SectionGap(),
          const AccountSection(
            tiles: [
              AccountTile(icon: Icons.help_outline, title: 'FAQs'),
              AccountTile(icon: Icons.headset_mic_outlined, title: 'Help Center'),
            ],
          ),
          const SectionGap(),
          AccountTile(
            icon: Icons.logout,
            title: 'Logout',
            color: Colors.red,
            showArrow: false,
            onTap: () => _confirmLogout(context),
          ),
        ],
      ),
    );
  }
}

class AccountTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final bool showArrow;
  final VoidCallback? onTap;

  const AccountTile({
    super.key,
    required this.icon,
    required this.title,
    this.color = Colors.black,
    this.showArrow = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      minLeadingWidth: 24,
      horizontalTitleGap: 16,
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(fontSize: 16, color: color)),
      trailing: showArrow
          ? const Icon(Icons.chevron_right, color: Colors.grey)
          : null,
    );
  }
}

class AccountSection extends StatelessWidget {
  final List<Widget> tiles;

  const AccountSection({super.key, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int index = 0; index < tiles.length; index++) ...[
          tiles[index],
          if (index < tiles.length - 1)
            const Divider(height: 1, indent: 64, endIndent: 24),
        ],
      ],
    );
  }
}

class SectionGap extends StatelessWidget {
  const SectionGap({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(height: 8, color: const Color(0xFFEFEFEF));
  }
}