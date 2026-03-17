import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _lowStockAlerts = true;
  bool _dailySalesSummary = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, size: 14, color: Color(0xFF1765FF)),
          label: const Text('Dashboard', style: TextStyle(color: Color(0xFF1765FF))),
        ),
        leadingWidth: 130,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Done', style: TextStyle(color: Color(0xFF1765FF), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 8),

          const Text(
            'Settings',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          // Profile card
          _SettingsCard(
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
                            'Shemsu Shop',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'owner@shemsusuq.com',
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

          const SizedBox(height: 28),

          // App Preferences
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

          // Notification Settings
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
                  activeTrackColor: const Color(0xFF34C759),
                ),
              ),
              const _Divider(),
              _IconTile(
                iconColor: const Color(0xFF4CD964),
                icon: Icons.bar_chart,
                title: 'Daily Sales Summary',
                subtitle: 'Receive EOD report at 9:00 PM',
                trailing: Switch(
                  value: _dailySalesSummary,
                  onChanged: (v) => setState(() => _dailySalesSummary = v),
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xFF34C759),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Data Management
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

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// Groups tiles into a white rounded card
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
      child: Column(
        children: children,
      ),
    );
  }
}

// A single tile with a colored icon container
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

// Thin divider indented to align with tile text
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