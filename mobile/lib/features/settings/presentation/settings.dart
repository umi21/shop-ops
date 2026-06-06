import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _lowStockAlerts = true;
  bool _dailySalesSummary = true;
  bool _savePressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 60),

          const Text(
            'Settings',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          // Profile card
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, AppRoutes.profileRoute),
            child: _SettingsCard(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: Color(0xFFC6A77D),
                        child: Icon(Icons.person, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Shop-Ops Manager',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'owner@shop-ops.com',
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          const _SectionTitle('APP PREFERENCES'),
          _SettingsCard(
            children: [
              _IconTile(
                iconColor: const Color(0xFF5856D6),
                icon: Icons.dark_mode,
                title: 'Appearance',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('System Default', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
              const _Divider(),
              _IconTile(
                iconColor: const Color(0xFF34AADC),
                icon: Icons.language,
                title: 'Language',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('English (US)', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          const _SectionTitle('NOTIFICATION SETTINGS'),
          _SettingsCard(
            children: [
              _IconTile(
                iconColor: const Color(0xFFFF9500),
                icon: Icons.inventory,
                title: 'Low Stock Alerts',
                subtitle: 'Notify when stock hits 10%',
                trailing: Switch(
                  value: _lowStockAlerts,
                  onChanged: (v) => setState(() => _lowStockAlerts = v),
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xFF1E5EFE),
                ),
              ),
              const _Divider(),
              _IconTile(
                iconColor: const Color(0xFF1E5EFE),
                icon: Icons.bar_chart,
                title: 'Daily Sales Summary',
                subtitle: 'Receive EOD report at 9:00 PM',
                trailing: Switch(
                  value: _dailySalesSummary,
                  onChanged: (v) => setState(() => _dailySalesSummary = v),
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xFF1E5EFE),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          const _SectionTitle('DATA MANAGEMENT'),
          _SettingsCard(
            children: [
              _IconTile(
                iconColor: const Color(0xFF1765FF),
                icon: Icons.cloud_upload,
                title: 'Backup to Cloud',
                subtitle: 'Last synced: Today, 10:42 AM',
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              ),
              const _Divider(),
              _IconTile(
                iconColor: const Color(0xFF1765FF),
                icon: Icons.download,
                title: 'Export CSV Report',
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              ),
              const _Divider(),
              _IconTile(
                iconColor: Colors.red,
                icon: Icons.delete,
                title: 'Clear Local Data',
                titleColor: Colors.red,
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Center(
            child: Text(
              'Clearing data will remove all locally stored inventory and sales history that isn\'t synced to the cloud.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          ),

          const SizedBox(height: 28),

          // Save Settings button
          GestureDetector(
            onTapDown: (_) => setState(() => _savePressed = true),
            onTapUp: (_) => setState(() => _savePressed = false),
            onTapCancel: () => setState(() => _savePressed = false),
            child: AnimatedScale(
              scale: _savePressed ? 0.97 : 1.0,
              duration: const Duration(milliseconds: 80),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 80),
                height: 54,
                decoration: BoxDecoration(
                  color: _savePressed
                      ? const Color(0xFF0D4FCC)
                      : const Color(0xFF1765FF),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: _savePressed
                      ? []
                      : [
                          BoxShadow(
                            color: const Color(0xFF1765FF).withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Save Settings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: children),
    );
  }
}

class _IconTile extends StatelessWidget {
  final Color iconColor;
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Color? titleColor;

  const _IconTile({
    required this.iconColor,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: titleColor ?? Colors.black,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, indent: 62, endIndent: 0, color: Colors.grey.shade200);
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}