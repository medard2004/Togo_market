import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifs = true;
  bool _location = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Paramètres'),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _SettingsTile(
              icon: Icons.person_outline,
              label: 'Modifier le profil',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.lock_outline,
              label: 'Confidentialité',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              trailing: Transform.scale(
                scale: 0.7,
                alignment: Alignment.centerRight,
                child: CupertinoSwitch(
                  value: _notifs,
                  activeTrackColor: AppTheme.primary,
                  inactiveTrackColor: const Color(0xFFEEEEEE),
                  onChanged: (v) => setState(() => _notifs = v),
                ),
              ),
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.location_on_outlined,
              label: 'Localisation',
              trailing: Transform.scale(
                scale: 0.7,
                alignment: Alignment.centerRight,
                child: CupertinoSwitch(
                  value: _location,
                  activeTrackColor: AppTheme.primary,
                  inactiveTrackColor: const Color(0xFFEEEEEE),
                  onChanged: (v) => setState(() => _location = v),
                ),
              ),
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.language,
              label: 'Langue',
              subtitle: 'Français',
              onTap: () {},
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Get.offAllNamed('/auth'),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.destructive.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: AppTheme.destructive.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.destructive.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.logout,
                          color: AppTheme.destructive, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Text('Se déconnecter',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.destructive)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_city_rounded, size: 14, color: AppTheme.mutedForeground),
                const SizedBox(width: 4),
                const Text('Togo_Market v1.0.0 — Fait au Togo',
                    style:
                        TextStyle(fontSize: 12, color: AppTheme.mutedForeground)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.shadowCard,
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: AppTheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    if (subtitle != null)
                      Text(subtitle!,
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.mutedForeground)),
                  ],
                ),
              ),
              trailing ??
                  const Icon(Icons.chevron_right,
                      color: AppTheme.mutedForeground),
            ],
          ),
        ),
      );
}
