import 'package:flutter/material.dart';

import '../core/catalog.dart';
import '../core/theme.dart';

void open(BuildContext context, String route, [Object? arguments]) =>
    Navigator.pushNamed(context, route, arguments: arguments);
void toast(BuildContext context, String message) =>
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));

class Picture extends StatelessWidget {
  const Picture(
    this.name, {
    super.key,
    this.width,
    this.height,
    this.radius = 0,
    this.fit = BoxFit.cover,
  });
  final String name;
  final double? width, height;
  final double radius;
  final BoxFit fit;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: Image.asset(
      'assets/images/$name.png',
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => Container(
        width: width,
        height: height,
        color: Palette.purple.withValues(alpha: .12),
        child: const Icon(Icons.sports_esports_outlined),
      ),
    ),
  );
}

class Avatar extends StatelessWidget {
  const Avatar(this.name, {super.key, this.size = 36, this.live = false});
  final String name;
  final double size;
  final bool live;
  @override
  Widget build(BuildContext context) => Container(
    padding: live ? const EdgeInsets.all(3) : EdgeInsets.zero,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: live ? Border.all(color: Palette.red, width: 1.5) : null,
    ),
    child: ClipOval(
      child: Picture(
        name == 'Guerry' ? 'guerry' : 'shroud',
        width: size,
        height: size,
      ),
    ),
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(
    this.title, {
    super.key,
    this.onAll,
    this.action = 'See All',
  });
  final String title, action;
  final VoidCallback? onAll;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 28, bottom: 18),
    child: Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (onAll != null)
          TextButton(
            onPressed: onAll,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.only(left: 8),
              minimumSize: const Size(44, 32),
            ),
            child: Text(action),
          ),
      ],
    ),
  );
}

class Pill extends StatelessWidget {
  const Pill(
    this.label, {
    super.key,
    this.active = false,
    this.icon,
    this.onTap,
  });
  final String label;
  final bool active;
  final IconData? icon;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: active
        ? Palette.purple
        : Theme.of(context).colorScheme.surfaceContainerHighest,
    borderRadius: BorderRadius.circular(30),
    child: InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: active ? Colors.white : Palette.muted,
              ),
              const SizedBox(width: 5),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: active ? Colors.white : Palette.muted,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class CategoryChips extends StatelessWidget {
  const CategoryChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });
  final String selected;
  final ValueChanged<String> onChanged;
  static const icons = [
    Icons.sports_esports_outlined,
    Icons.music_note_outlined,
    Icons.emoji_events_outlined,
    Icons.mic_none,
  ];
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 38,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: Catalog.categories.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (_, i) => Pill(
        Catalog.categories[i],
        active: selected == Catalog.categories[i],
        icon: icons[i],
        onTap: () => onChanged(Catalog.categories[i]),
      ),
    ),
  );
}

class StreamCard extends StatelessWidget {
  const StreamCard(this.stream, {super.key, this.compact = false});
  final Stream stream;
  final bool compact;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => open(context, '/stream', stream),
    borderRadius: BorderRadius.circular(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1.96,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Picture(stream.image, radius: 16),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Palette.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Live',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.visibility,
                        color: Colors.white,
                        size: 12,
                      ),
                      Text(
                        ' ${stream.views} ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          stream.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (!compact) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 5,
            children: [
              'FPS',
              stream.category,
              'Shooter',
            ].map((e) => Pill(e)).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: () => open(context, '/streamer', stream.creator),
                child: Avatar(stream.creator, size: 27),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  stream.creator,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.verified, color: Palette.purple, size: 14),
              const SizedBox(width: 12),
              Flexible(
                child: Pill(
                  stream.game,
                  active: true,
                  icon: Icons.sports_esports,
                  onTap: () => open(
                    context,
                    '/category',
                    Catalog.games
                            .where((g) => g.name == stream.game)
                            .firstOrNull ??
                        Catalog.games[1],
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}

class StreamRail extends StatelessWidget {
  const StreamRail({super.key, this.streams = Catalog.streams});
  final List<Stream> streams;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 280,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: streams.length,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (_, i) =>
          SizedBox(width: 286, child: StreamCard(streams[i])),
    ),
  );
}

class ClipTile extends StatelessWidget {
  const ClipTile(this.stream, {super.key});
  final Stream stream;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => open(context, '/stream', stream),
    child: Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Stack(
            children: [
              Picture(stream.image, width: 130, height: 96, radius: 16),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '0:23',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stream.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  '${stream.views} views · 2 days ago',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Avatar(stream.creator, size: 20),
                    const SizedBox(width: 6),
                    Text(stream.creator, style: const TextStyle(fontSize: 11)),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, color: Palette.purple, size: 13),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class MenuTile extends StatelessWidget {
  const MenuTile(this.label, this.icon, this.onTap, {super.key, this.trailing});
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(17),
      ),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
        leading: Icon(icon, size: 23),
        title: Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        trailing:
            trailing ?? const Icon(Icons.chevron_right, color: Palette.muted),
        onTap: onTap,
      ),
    ),
  );
}

class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.children, this.padding = 20});
  final List<Widget> children;
  final double padding;
  @override
  Widget build(BuildContext context) =>
      ListView(padding: EdgeInsets.all(padding), children: children);
}

class EmptyState extends StatelessWidget {
  const EmptyState(
    this.title,
    this.subtitle, {
    super.key,
    this.icon = Icons.search_off,
  });
  final String title, subtitle;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
    child: Column(
      children: [
        Icon(icon, size: 48, color: Palette.muted),
        const SizedBox(height: 16),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Palette.muted),
        ),
      ],
    ),
  );
}
