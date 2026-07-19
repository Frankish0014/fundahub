import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/fh_primary_button.dart';

abstract final class NotificationPrefKeys {
  static const matches = 'notif_matches';
  static const deadlines = 'notif_deadlines';
  static const community = 'notif_community';
  static const programmes = 'notif_programmes';
  static const push = 'notif_push';
  static const email = 'notif_email';
  static const sms = 'notif_sms';
}

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool matches = true;
  bool deadlines = true;
  bool community = false;
  bool programmes = true;
  bool push = true;
  bool email = false;
  bool sms = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      matches = p.getBool(NotificationPrefKeys.matches) ?? true;
      deadlines = p.getBool(NotificationPrefKeys.deadlines) ?? true;
      community = p.getBool(NotificationPrefKeys.community) ?? false;
      programmes = p.getBool(NotificationPrefKeys.programmes) ?? true;
      push = p.getBool(NotificationPrefKeys.push) ?? true;
      email = p.getBool(NotificationPrefKeys.email) ?? false;
      sms = p.getBool(NotificationPrefKeys.sms) ?? false;
      loading = false;
    });
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(NotificationPrefKeys.matches, matches);
    await p.setBool(NotificationPrefKeys.deadlines, deadlines);
    await p.setBool(NotificationPrefKeys.community, community);
    await p.setBool(NotificationPrefKeys.programmes, programmes);
    await p.setBool(NotificationPrefKeys.push, push);
    await p.setBool(NotificationPrefKeys.email, email);
    await p.setBool(NotificationPrefKeys.sms, sms);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Preferences saved')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Notification Settings'),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preferences',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Stay updated with what matters most to your business.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onPrimary.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _PrefCard(
                  icon: Icons.handshake_outlined,
                  iconBg: AppColors.mintSoft,
                  title: 'New Matches',
                  body:
                      'Get notified when a new grant or investment opportunity matches your profile criteria.',
                  value: matches,
                  onChanged: (v) => setState(() => matches = v),
                ),
                _PrefCard(
                  icon: Icons.calendar_month_outlined,
                  iconBg: AppColors.deadlineBg,
                  title: 'Deadline Reminders',
                  body:
                      'Receive alerts for upcoming submission deadlines on your saved programmes.',
                  value: deadlines,
                  onChanged: (v) => setState(() => deadlines = v),
                ),
                _PrefCard(
                  icon: Icons.groups_outlined,
                  iconBg: const Color(0xFFE8EEF2),
                  title: 'Community Updates',
                  body:
                      'Stay informed about forum discussions, expert webinars, and entrepreneurial network news.',
                  value: community,
                  onChanged: (v) => setState(() => community = v),
                ),
                _PrefCard(
                  icon: Icons.campaign_outlined,
                  iconBg: AppColors.mint,
                  title: 'Programme Alerts',
                  body:
                      'Direct updates from programme administrators regarding your active applications.',
                  value: programmes,
                  onChanged: (v) => setState(() => programmes = v),
                ),
                const SizedBox(height: 12),
                Text(
                  'DELIVERY CHANNELS',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Push Notifications'),
                        subtitle: const Text('Recommended for instant updates'),
                        value: push,
                        activeThumbColor: AppColors.onPrimary,
                        activeTrackColor: AppColors.primary,
                        onChanged: (v) => setState(() => push = v),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: const Text('Email Summaries'),
                        subtitle: const Text('Weekly digest of opportunities'),
                        value: email,
                        activeThumbColor: AppColors.onPrimary,
                        activeTrackColor: AppColors.primary,
                        onChanged: (v) => setState(() => email = v),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        title: const Text('SMS Alerts'),
                        subtitle: const Text('Critical deadline alerts only'),
                        value: sms,
                        activeThumbColor: AppColors.onPrimary,
                        activeTrackColor: AppColors.primary,
                        onChanged: (v) => setState(() => sms = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                FhPrimaryButton(label: 'Save Preferences', onPressed: _save),
                const SizedBox(height: 12),
                Text(
                  'Changes may take up to 24 hours to sync across all devices.',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
    );
  }
}

class _PrefCard extends StatelessWidget {
  const _PrefCard({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.body,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconBg;
  final String title;
  final String body;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.onPrimary,
            activeTrackColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
