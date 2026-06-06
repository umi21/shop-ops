import 'package:flutter/material.dart';
import 'package:mobile/core/routes/app_routes.dart';
import 'package:mobile/injection_container.dart' as di;
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:mobile/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:mobile/features/auth/domain/usecases/logout_usecase.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const primary = Color(0xFF1765FF);

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _businessController = TextEditingController();
  final _locationController = TextEditingController();

  bool _faceIdEnabled = true;
  bool _largeExpenseAlerts = false;
  bool _isLoading = true;
  String? _userId;

  bool _savePressed = false;
  bool _logoutPressed = false;
  bool _cameraPressed = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final getCurrentUser = di.sl<GetCurrentUserUseCase>();
    final result = await getCurrentUser(const NoParams());

    result.fold(
      (failure) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading profile: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      (user) {
        if (mounted) {
          setState(() {
            _userId = user.id;
            _nameController.text = user.name;
            _emailController.text = user.email;
            _phoneController.text = user.phone;
            _isLoading = false;
          });
        }
      },
    );
  }

  Future<void> _saveProfile() async {
    if (_userId == null) return;

    final updateProfile = di.sl<UpdateProfileUseCase>();
    final result = await updateProfile(
      UpdateProfileParams(
        userId: _userId!,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
      ),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: ${failure.message}'),
            backgroundColor: Colors.red,
          ),
        );
      },
      (user) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      },
    );
  }

  Future<void> _logout() async {
    final logout = di.sl<LogoutUseCase>();
    final result = await logout(const NoParams());

    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: ${failure.message}'),
            backgroundColor: Colors.red,
          ),
        );
      },
      (_) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.loginRoute,
          (route) => false,
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _businessController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile Settings',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 20),

          // Avatar + name
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade200,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        backgroundColor: const Color(0xFFC6A77D),
                        child: Text(
                          _nameController.text.isNotEmpty
                              ? _nameController.text[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTapDown: (_) => setState(() => _cameraPressed = true),
                        onTapUp: (_) => setState(() => _cameraPressed = false),
                        onTapCancel: () =>
                            setState(() => _cameraPressed = false),
                        child: AnimatedScale(
                          scale: _cameraPressed ? 0.88 : 1.0,
                          duration: const Duration(milliseconds: 100),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: _cameraPressed
                                  ? const Color(0xFF0D4FCC)
                                  : primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _nameController.text.isNotEmpty
                      ? _nameController.text
                      : 'User',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _phoneController.text.isNotEmpty ? _phoneController.text : '',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Personal Details
          const _SectionTitle('PERSONAL DETAILS'),
          _SettingsCard(
            children: [
              _EditableTile(label: 'FULL NAME', controller: _nameController),
              const _Divider(),
              _EditableTile(
                label: 'EMAIL ADDRESS',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const _Divider(),
              _EditableTile(
                label: 'PHONE NUMBER',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Business Details
          const _SectionTitle('BUSINESS DETAILS'),
          _SettingsCard(
            children: [
              _EditableTile(
                label: 'BUSINESS NAME',
                controller: _businessController,
              ),
              const _Divider(),
              _EditableTile(label: 'LOCATION', controller: _locationController),
              const _Divider(),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CURRENCY',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: primary,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'USD — US Dollar',
                                style: TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Security
          const _SectionTitle('SECURITY'),
          _SettingsCard(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                  child: _IconTile(
                    iconColor: const Color(0xFF5856D6),
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const _Divider(),
              _IconTile(
                iconColor: const Color(0xFF34AADC),
                icon: Icons.fingerprint,
                title: 'Enable Face ID',
                trailing: Switch(
                  value: _faceIdEnabled,
                  onChanged: (v) => setState(() => _faceIdEnabled = v),
                  activeColor: Colors.white,
                  activeTrackColor: primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Account Alerts
          const _SectionTitle('ACCOUNT ALERTS'),
          _SettingsCard(
            children: [
              _IconTile(
                iconColor: const Color(0xFFFF3B30),
                icon: Icons.account_balance_wallet_outlined,
                title: 'Large Expense Alerts',
                subtitle: 'Notify for any expense over \$500',
                trailing: Switch(
                  value: _largeExpenseAlerts,
                  onChanged: (v) => setState(() => _largeExpenseAlerts = v),
                  activeColor: Colors.white,
                  activeTrackColor: primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Save Changes button with press animation
          GestureDetector(
            onTapDown: (_) => setState(() => _savePressed = true),
            onTapUp: (_) {
              setState(() => _savePressed = false);
              _saveProfile();
            },
            onTapCancel: () => setState(() => _savePressed = false),
            child: AnimatedScale(
              scale: _savePressed ? 0.97 : 1.0,
              duration: const Duration(milliseconds: 80),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 80),
                height: 54,
                decoration: BoxDecoration(
                  color: _savePressed ? const Color(0xFF0D4FCC) : primary,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: _savePressed
                      ? []
                      : [
                          BoxShadow(
                            color: primary.withOpacity(0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Logout button with press animation
          _SettingsCard(
            children: [
              GestureDetector(
                onTapDown: (_) => setState(() => _logoutPressed = true),
                onTapUp: (_) {
                  setState(() => _logoutPressed = false);
                  _showLogoutConfirmation();
                },
                onTapCancel: () => setState(() => _logoutPressed = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 80),
                  height: 52,
                  decoration: BoxDecoration(
                    color: _logoutPressed ? Colors.red.shade50 : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      color: _logoutPressed ? Colors.red.shade700 : Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Footer links
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _FooterLink(label: 'Privacy Policy', onTap: () {}),
              Text('·', style: TextStyle(color: Colors.grey[400])),
              _FooterLink(label: 'Terms of Use', onTap: () {}),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Footer link with underline on press
class _FooterLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _FooterLink({required this.label, required this.onTap});

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          widget.label,
          style: TextStyle(
            color: _pressed ? Colors.grey[700] : Colors.grey[500],
            fontSize: 12,
            decoration: _pressed
                ? TextDecoration.underline
                : TextDecoration.none,
          ),
        ),
      ),
    );
  }
}

class _EditableTile extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const _EditableTile({
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1765FF),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 15),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
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

  const _IconTile({
    required this.iconColor,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
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
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
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
    return Divider(
      height: 1,
      indent: 62,
      endIndent: 0,
      color: Colors.grey.shade200,
    );
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
