import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/catalog.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';
import '../profile/profile_pages.dart';

class ShellPage extends StatefulWidget {
  const ShellPage({super.key, this.initialTab = 0});
  final int initialTab;
  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  late int tab = widget.initialTab;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(
      index: tab,
      children: const [
        FeedPage(),
        FeedPage(discover: true),
        FollowingPage(),
        ProfilePage(),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      height: 74,
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: Colors.transparent,
      selectedIndex: tab,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => TextStyle(
          fontFamily: 'Jakarta',
          fontSize: 11,
          color: s.contains(WidgetState.selected)
              ? Palette.purple
              : Palette.muted,
        ),
      ),
      onDestinationSelected: (v) => setState(() => tab = v),
      destinations: [
        for (final item in [
          (Icons.home_outlined, Icons.home_rounded, 'Home'),
          (Icons.explore_outlined, Icons.explore, 'Discover'),
          (Icons.favorite_border, Icons.favorite, 'Favourite'),
          (Icons.person_outline, Icons.person, 'Profile'),
        ])
          NavigationDestination(
            icon: Icon(item.$1, color: Palette.muted),
            selectedIcon: Icon(item.$2, color: Palette.purple),
            label: item.$3,
          ),
      ],
    ),
  );
}

class FeedPage extends StatefulWidget {
  const FeedPage({super.key, this.discover = false});
  final bool discover;
  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  String category = 'Gaming';
  @override
  Widget build(BuildContext context) {
    final streams = Catalog.streams
        .where((s) => s.category == category)
        .toList();
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.discover ? 'Discover' : 'Home',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              IconButton.outlined(
                tooltip: 'Notifications',
                onPressed: () => open(context, '/notifications'),
                icon: const Icon(Icons.notifications_none, size: 23),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Palette.purple,
                  backgroundColor: Palette.purple.withValues(alpha: .07),
                  side: BorderSide(color: Palette.purple.withValues(alpha: .3)),
                  minimumSize: const Size(0, 46),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                onPressed: () => open(context, '/dashboard'),
                icon: const Icon(Icons.sensors, size: 20),
                label: const Text('Go Live', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 28),
          if (widget.discover) ...[
            TextField(
              readOnly: true,
              onTap: () => open(context, '/search'),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search, color: Palette.muted),
                hintText: 'Search...',
              ),
            ),
            const SizedBox(height: 26),
            StreamCard(Catalog.streams[2], compact: true),
            const SectionTitle('Category'),
            CategoryChips(
              selected: category,
              onChanged: (v) => setState(() => category = v),
            ),
            SectionTitle(
              'Recommended $category Streamer',
              onAll: () => open(context, '/streams', category),
            ),
            StreamRail(streams: streams),
            SectionTitle(
              'Most Played Games',
              onAll: () => open(context, '/games'),
            ),
            const GameRail(),
          ] else ...[
            GestureDetector(
              onTap: () => open(context, '/dashboard'),
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Palette.purple,
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Positioned(
                      right: -28,
                      top: -14,
                      child: Transform.rotate(
                        angle: -.22,
                        child: const Icon(
                          Icons.sports_esports_outlined,
                          size: 210,
                          color: Color(0xFF9384FF),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Build Career\nWith a Video',
                            style: TextStyle(
                              fontSize: 19,
                              height: 1.25,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 9),
                          Text(
                            'Become a successful\nlive streamer.',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFFCDC5FF),
                              height: 1.6,
                            ),
                          ),
                          SizedBox(height: 9),
                          Text(
                            'Start Live Streaming',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SectionTitle(
              'Today Top Stream',
              onAll: () => open(context, '/streams'),
            ),
            CategoryChips(
              selected: category,
              onChanged: (v) => setState(() => category = v),
            ),
            const SizedBox(height: 24),
            StreamRail(streams: streams),
            SectionTitle(
              'Popular Streamer',
              onAll: () => open(context, '/streamers'),
            ),
            Wrap(
              spacing: 10,
              runSpacing: 12,
              children: [
                for (final name in Catalog.creators)
                  ActionChip(
                    avatar: Avatar(name, size: 28, live: name == 'Shroud'),
                    label: Text(name, style: const TextStyle(fontSize: 12)),
                    side: BorderSide.none,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.all(10),
                    onPressed: () => open(context, '/streamer', name),
                  ),
              ],
            ),
            SectionTitle(
              'Most Played Games',
              onAll: () => open(context, '/games'),
            ),
            const GameRail(),
          ],
        ],
      ),
    );
  }
}

class GameRail extends StatelessWidget {
  const GameRail({super.key});
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 185,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: Catalog.games.length,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (_, i) {
        final game = Catalog.games[i];
        return InkWell(
          onTap: () => open(context, '/category', game),
          child: SizedBox(
            width: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Picture(game.image, width: 100, height: 130, radius: 16),
                const SizedBox(height: 10),
                Text(
                  game.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '● ${game.viewers}',
                  style: const TextStyle(fontSize: 10, color: Palette.muted),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

class FollowingPage extends StatelessWidget {
  const FollowingPage({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Text(
                'Favourite',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const TabBar(
              labelColor: Palette.purple,
              unselectedLabelColor: Palette.muted,
              indicatorColor: Palette.purple,
              tabs: [
                Tab(text: 'Continue Watching'),
                Tab(text: 'Following'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  PageBody(
                    children: [
                      const SectionTitle('Pick up where you left off'),
                      for (final s in Catalog.streams.take(3)) ...[
                        StreamCard(s),
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
                  PageBody(
                    children: [
                      if (state.following.isEmpty)
                        const EmptyState(
                          'No creators yet',
                          'Find a creator you love and tap Follow.',
                          icon: Icons.favorite_border,
                        ),
                      for (final name in state.following)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: CreatorTile(name),
                        ),
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
}

class CreatorTile extends StatelessWidget {
  const CreatorTile(this.name, {super.key});
  final String name;
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final follows = state.following.contains(name);
    return Row(
      children: [
        InkWell(
          onTap: () => open(context, '/streamer', name),
          child: Avatar(name, size: 48, live: true),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: () => open(context, '/streamer', name),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.titleMedium),
                const Text(
                  '4.4M followers · Gaming',
                  style: TextStyle(color: Palette.muted, fontSize: 10),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(82, 36),
            foregroundColor: Palette.purple,
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          onPressed: () => state.toggleFollow(name),
          child: Text(
            follows ? 'Following' : 'Follow',
            style: const TextStyle(fontSize: 11),
          ),
        ),
      ],
    );
  }
}
