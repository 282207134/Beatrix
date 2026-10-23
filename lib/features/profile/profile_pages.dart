import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/catalog.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';
import '../live/live_pages.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        SizedBox(
          height: 164,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const Picture('profile-cover'),
              Positioned(
                left: 20,
                bottom: 26,
                child: Text(
                  'My Profile',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Avatar('Guerry', size: 72),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.nickname,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Text(
                          '8K followers',
                          style: TextStyle(color: Palette.muted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(80, 34),
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                    ),
                    onPressed: () => open(context, '/edit-profile'),
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
              const SectionTitle('Account Settings'),
              MenuTile(
                'Account Settings',
                Icons.person_outline,
                () => open(context, '/settings'),
              ),
              MenuTile(
                'My Videos',
                Icons.videocam_outlined,
                () => open(context, '/videos'),
              ),
              MenuTile(
                'My Wallet',
                Icons.account_balance_wallet_outlined,
                () => open(context, '/wallet'),
                trailing: Text(
                  '◆ ${state.balance}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SectionTitle('Streaming Centre'),
              MenuTile(
                'Streaming Channel',
                Icons.videocam_outlined,
                () => open(context, '/dashboard'),
              ),
              MenuTile(
                'Gift Centre',
                Icons.card_giftcard,
                () => open(context, '/gifts'),
              ),
              const SectionTitle('Other Menu'),
              MenuTile(
                'Help & Feedback',
                Icons.help_outline,
                () => open(context, '/help'),
              ),
              MenuTile(
                'Customer Service',
                Icons.support_agent,
                () => open(context, '/support'),
              ),
              MenuTile(
                'About Us',
                Icons.people_outline,
                () => open(context, '/about'),
              ),
              MenuTile('Log Out', Icons.logout, () => confirmLogout(context)),
            ],
          ),
        ),
      ],
    );
  }
}

Future<void> confirmLogout(BuildContext context) async {
  final state = AppScope.of(context);
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Log out?'),
      content: const Text(
        'Your local profile and preferences will be kept on this device.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Log Out'),
        ),
      ],
    ),
  );
  if (confirm == true) {
    await state.logout();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/onboarding', (_) => false);
    }
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Account Settings')),
      body: PageBody(
        children: [
          const SectionTitle('Account'),
          MenuTile(
            'Edit Account',
            Icons.manage_accounts_outlined,
            () => open(context, '/account'),
          ),
          MenuTile(
            'Edit Profile',
            Icons.person_outline,
            () => open(context, '/edit-profile'),
          ),
          const SectionTitle('Preferences'),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Dark Mode'),
            subtitle: const Text(
              'Switch between the two Pixso themes',
              style: TextStyle(color: Palette.muted, fontSize: 11),
            ),
            value: state.dark,
            onChanged: state.setDark,
          ),
          const SizedBox(height: 20),
          MenuTile(
            'Privacy & Terms',
            Icons.shield_outlined,
            () => open(context, '/privacy'),
          ),
          const SectionTitle('Session'),
          MenuTile('Log Out', Icons.logout, () => confirmLogout(context)),
          const SizedBox(height: 24),
          const Text(
            'Beatrix 1.0.0 · Local demo',
            textAlign: TextAlign.center,
            style: TextStyle(color: Palette.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, this.account = false});
  final bool account;
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final form = GlobalKey<FormState>();
  late final TextEditingController name, bio, email;

  bool initialized = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialized) {
      final state = AppScope.of(context);
      name = TextEditingController(text: state.nickname);
      bio = TextEditingController(text: state.bio);
      email = TextEditingController(text: state.email);
      initialized = true;
    }
  }

  @override
  void dispose() {
    name.dispose();
    bio.dispose();
    email.dispose();
    super.dispose();
  }

  Widget field(
    String label,
    TextEditingController controller, {
    int lines = 1,
    bool isEmail = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          maxLines: lines,
          maxLength: isEmail
              ? 100
              : lines > 1
              ? 250
              : 30,
          keyboardType: isEmail
              ? TextInputType.emailAddress
              : TextInputType.text,
          decoration: const InputDecoration(counterText: ''),
          validator: (v) => v == null || v.trim().isEmpty
              ? 'This field is required'
              : isEmail && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)
              ? 'Enter a valid email'
              : null,
        ),
      ],
    ),
  );
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account ? 'Edit Account' : 'Edit Profile'),
      ),
      body: Form(
        key: form,
        child: PageBody(
          children: [
            if (!widget.account) ...[
              const Picture('profile-cover', height: 125, radius: 18),
              const SizedBox(height: 16),
              const Center(child: Avatar('Guerry', size: 72)),
              const SectionTitle('Display Information'),
              field('Nickname', name),
              field('Bio', bio, lines: 3),
            ],
            if (widget.account) ...[
              const SectionTitle('Account Information'),
              field('Display Name', name),
              field('Email', email, isEmail: true),
              const SectionTitle('Security'),
              const Text(
                'This demo does not store passwords or connect to an identity provider.',
                style: TextStyle(color: Palette.muted),
              ),
              const SizedBox(height: 24),
              MenuTile(
                'Password & Sign-in Help',
                Icons.lock_outline,
                () => open(context, '/help'),
              ),
            ],
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () async {
                if (!form.currentState!.validate()) {
                  return;
                }
                await state.saveProfile(name.text, bio.text);
                if (widget.account) {
                  await state.saveEmail(email.text);
                }
                if (context.mounted) {
                  Navigator.pop(context);
                  toast(context, 'Changes saved');
                }
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('My Wallet')),
      body: PageBody(
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Palette.purple,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Demo diamond balance',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Text(
                  '◆ ${state.balance}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Use diamonds to support your favourite creators.',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          const SectionTitle('Gift Activity'),
          if (state.giftHistory.isEmpty)
            const EmptyState(
              'No gifts sent yet',
              'Open a stream and choose a gift to get started.',
              icon: Icons.card_giftcard,
            ),
          for (final gift in state.giftHistory)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.diamond_outlined,
                color: Palette.purple,
              ),
              title: Text(gift),
            ),
          const Text(
            'Demo balance only. No purchases or real payments.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Palette.muted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class GiftCentrePage extends StatelessWidget {
  const GiftCentrePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Gift Centre')),
    body: const SingleChildScrollView(child: GiftPanel()),
  );
}

class InfoPage extends StatelessWidget {
  const InfoPage({super.key, required this.kind});
  final String kind;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(switch (kind) {
        'help' => 'Help & Feedback',
        'support' => 'Customer Service',
        'privacy' => 'Privacy & Terms',
        'notifications' => 'Notifications',
        _ => 'About Beatrix',
      }),
    ),
    body: PageBody(
      children: [
        if (kind == 'help' || kind == 'support') ...[
          const SectionTitle('How can we help?'),
          for (final item in [
            (
              'How do I log in?',
              'Use any username and a password with at least 6 characters. This is a local demonstration; no remote account is created.',
            ),
            (
              'How do I follow a creator?',
              'Open a stream or creator profile, then tap Follow. Find saved creators in Favourite → Following.',
            ),
            (
              'How do gifts work?',
              'Choose the gift icon in a stream. Gifts deduct demo diamonds and appear in My Wallet. No real payments are made.',
            ),
            (
              'Can I broadcast or watch live video?',
              'This build shows original design preview images. A streaming service is needed for live video, camera capture and chat delivery.',
            ),
            (
              'Where is my data saved?',
              'Your profile, follows, theme, search history and gift balance are saved locally on this device.',
            ),
          ])
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(
                item.$1,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(item.$2),
                ),
              ],
            ),
          if (kind == 'support')
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Text(
                'This offline build has no connected customer service. No messages are sent externally.',
                style: TextStyle(color: Palette.muted),
              ),
            ),
        ] else if (kind == 'privacy') ...[
          const SectionTitle('Your data stays on this device'),
          const Text(
            'This demonstration stores profile details, preferences, follows, searches and a virtual gift ledger in local app preferences. Passwords are never saved. Uninstalling the app or clearing app data removes this information.',
          ),
          const SectionTitle('Demo terms'),
          const Text(
            'All viewer counts, streams, creator profiles, events and diamonds are sample content. No real account, purchase, broadcast or external message is created.',
          ),
        ] else if (kind == 'notifications') ...[
          const SectionTitle('Latest Activity'),
          for (final name in ['Shroud', 'Guerry', 'Chappy'])
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Avatar(name),
              title: Text('$name is live'),
              subtitle: const Text('Sample notification · Gaming'),
              onTap: () => open(
                context,
                '/stream',
                Catalog.streams.firstWhere((s) => s.creator == name),
              ),
            ),
        ] else ...[
          const SizedBox(height: 44),
          const Icon(Icons.sensors, color: Palette.purple, size: 72),
          const SizedBox(height: 20),
          Text(
            'Beatrix',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Your people. Your game. Your stream.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Palette.muted),
          ),
          const SectionTitle('Built for the community'),
          const Text(
            'A Flutter interpretation of the Pixso “Beatrix - Live Streaming App” design. Explore creators, follow favourites and try the streaming dashboard.',
          ),
          const SizedBox(height: 24),
          const Text(
            'Version 1.0.0 · Flutter · Local demo',
            style: TextStyle(color: Palette.muted),
          ),
        ],
      ],
    ),
  );
}

class VideosPage extends StatelessWidget {
  const VideosPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('My Videos')),
    body: PageBody(
      children: [
        const SectionTitle('Recent Uploads'),
        ...Catalog.clips.map(ClipTile.new),
        const SizedBox(height: 16),
        const Text(
          'Sample videos from the design reference.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Palette.muted, fontSize: 11),
        ),
      ],
    ),
  );
}
