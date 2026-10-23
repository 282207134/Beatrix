import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/catalog.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Streaming Dashboard')),
      body: PageBody(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                for (final item in [
                  (state.streaming ? 'Demo Live' : 'Offline', 'Stream'),
                  (state.streaming ? '0' : '—', 'Viewers'),
                  ('2,932', 'Diamonds'),
                  ('183', 'Followers'),
                ])
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          item.$1,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.$2,
                          style: const TextStyle(
                            color: Palette.muted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            child: Text(
              'The numbers on the dashboard are obtained by your previous stream.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Palette.muted),
            ),
          ),
          const Divider(),
          const SizedBox(height: 12),
          Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: state.streaming ? Palette.purple : const Color(0xFF99999F),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    state.streaming ? Icons.sensors : Icons.videocam_outlined,
                    size: 32,
                    color: Colors.white70,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.streaming ? 'DEMO STREAM ACTIVE' : 'STARTING SOON',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            key: const ValueKey('start-stream'),
            onPressed: () {
              state.toggleStreaming();
              toast(
                context,
                state.streaming
                    ? 'Demo started. No camera or live broadcast is connected.'
                    : 'Demo stream ended.',
              );
            },
            child: Text(
              state.streaming ? 'End Demo Stream' : 'Start Streaming',
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () => open(context, '/edit-live'),
            child: const Text('Edit Stream Preferences'),
          ),
          const SectionTitle('Streaming Activity'),
          for (final item in [
            ('Guerry', 'Started following you'),
            ('Shroud', 'Gave you ◆ ×2'),
            ('Chappy', 'Gave you ◆ ×283'),
            ('Bangpen', 'Mentioned you in their stream'),
          ])
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Avatar(item.$1, size: 44),
              title: Text(
                item.$1,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                item.$2,
                style: const TextStyle(color: Palette.muted, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }
}

class EditLivePage extends StatefulWidget {
  const EditLivePage({super.key});
  @override
  State<EditLivePage> createState() => _EditLivePageState();
}

class _EditLivePageState extends State<EditLivePage> {
  final form = GlobalKey<FormState>();
  TextEditingController? title;
  String category = 'Gaming', game = 'Valorant', language = 'English';
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (title == null) {
      final state = AppScope.of(context);
      title = TextEditingController(text: state.streamTitle);
      category = state.streamCategory;
      game = state.streamGame;
      language = state.streamLanguage;
    }
  }

  @override
  void dispose() {
    title?.dispose();
    super.dispose();
  }

  Widget dropdown(
    String label,
    String value,
    List<String> values,
    ValueChanged<String> update,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: const InputDecoration(),
          items: values
              .map(
                (v) => DropdownMenuItem(
                  value: v,
                  child: Text(v, style: const TextStyle(fontSize: 13)),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => update(v!)),
        ),
      ],
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Edit Live Streaming')),
    body: Form(
      key: form,
      child: PageBody(
        children: [
          const Picture('streamer-cover', height: 160, radius: 18),
          const SectionTitle('Stream Information'),
          const Text(
            'Stream Title',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: title,
            maxLength: 100,
            decoration: const InputDecoration(
              hintText: 'Give your stream a title',
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Please enter a title' : null,
          ),
          const SizedBox(height: 20),
          dropdown(
            'Category',
            category,
            Catalog.categories,
            (v) => category = v,
          ),
          dropdown(
            'Game',
            game,
            Catalog.games.map((g) => g.name).toList(),
            (v) => game = v,
          ),
          dropdown('Language', language, [
            'English',
            '日本語',
            '中文',
          ], (v) => language = v),
          FilledButton(
            onPressed: () async {
              if (!form.currentState!.validate()) {
                return;
              }
              await AppScope.of(context)
                  .saveStreamPreferences(title!.text, category, game, language);
              if (context.mounted) {
                Navigator.pop(context);
                toast(context, 'Stream preferences saved.');
              }
            },
            child: const Text('Save Preferences'),
          ),
        ],
      ),
    ),
  );
}
