import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/catalog.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';
import '../home/shell_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final input = TextEditingController();
  String query = '';
  bool submitted = false;
  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  void search(String value) {
    input.text = value;
    setState(() {
      query = value.trim();
      submitted = true;
    });
    AppScope.of(context).search(value);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context), term = query.toLowerCase();
    final streams = Catalog.streams
        .where(
          (s) => '${s.title} ${s.creator} ${s.game} ${s.category}'
              .toLowerCase()
              .contains(term),
        )
        .toList();
    final creators = Catalog.creators
        .where((n) => n.toLowerCase().contains(term))
        .toList();
    final games = Catalog.games
        .where((g) => g.name.toLowerCase().contains(term))
        .toList();
    Widget results(String kind) => PageBody(
      children: [
        if ((kind == 'Top' || kind == 'Channels') && creators.isNotEmpty) ...[
          const SectionTitle('Channels'),
          for (final name in creators)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: CreatorTile(name),
            ),
        ],
        if ((kind == 'Top' || kind == 'Categories') && games.isNotEmpty) ...[
          const SectionTitle('Categories'),
          for (final game in games) GameTile(game),
        ],
        if ((kind == 'Top' || kind == 'Videos') && streams.isNotEmpty) ...[
          const SectionTitle('Videos'),
          for (final stream in streams) ...[
            StreamCard(stream),
            const SizedBox(height: 24),
          ],
        ],
        if ((kind == 'Top' &&
                creators.isEmpty &&
                games.isEmpty &&
                streams.isEmpty) ||
            (kind == 'Channels' && creators.isEmpty) ||
            (kind == 'Categories' && games.isEmpty) ||
            (kind == 'Videos' && streams.isEmpty))
          const EmptyState(
            'No results found',
            'Try a game, creator or stream title.',
          ),
      ],
    );
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: TextField(
              key: const ValueKey('search-input'),
              controller: input,
              textInputAction: TextInputAction.search,
              onChanged: (v) => setState(() {
                query = v;
                submitted = false;
              }),
              onSubmitted: search,
              decoration: InputDecoration(
                hintText: 'Search...',
                contentPadding: const EdgeInsets.all(12),
                prefixIcon: const Icon(Icons.search, color: Palette.muted),
                suffixIcon: IconButton(
                  tooltip: 'Clear search',
                  onPressed: () {
                    input.clear();
                    setState(() {
                      query = '';
                      submitted = false;
                    });
                  },
                  icon: const Icon(Icons.close, size: 18),
                ),
              ),
            ),
          ),
          bottom: submitted && query.isNotEmpty
              ? const TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: [
                    Tab(text: 'Top'),
                    Tab(text: 'Channels'),
                    Tab(text: 'Categories'),
                    Tab(text: 'Videos'),
                  ],
                )
              : null,
        ),
        body: submitted && query.isNotEmpty
            ? TabBarView(
                children: [
                  'Top',
                  'Channels',
                  'Categories',
                  'Videos',
                ].map(results).toList(),
              )
            : PageBody(
                children: [
                  SectionTitle(
                    query.isEmpty ? 'Recent Searches' : 'Suggested',
                    action: 'Clear All',
                    onAll: () => state.clearSearches(),
                  ),
                  for (final value
                      in (query.isEmpty
                          ? state.searches
                          : [
                              ...Catalog.creators,
                              ...Catalog.games.map((g) => g.name),
                            ].where((v) => v.toLowerCase().contains(term))))
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        query.isEmpty ? Icons.history : Icons.search,
                        color: Palette.muted,
                      ),
                      title: Text(value),
                      trailing: const Icon(
                        Icons.north_west,
                        size: 16,
                        color: Palette.muted,
                      ),
                      onTap: () => search(value),
                    ),
                  if (query.isNotEmpty)
                    TextButton(
                      onPressed: () => search(query),
                      child: Text('Search for “$query”'),
                    ),
                ],
              ),
      ),
    );
  }
}

class GameTile extends StatelessWidget {
  const GameTile(this.game, {super.key});
  final Game game;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => open(context, '/category', game),
    child: Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Picture(game.image, width: 80, height: 100, radius: 16),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(game.name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  '● ${game.viewers} viewers',
                  style: const TextStyle(fontSize: 11, color: Palette.muted),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: game.tags.map((s) => Pill(s)).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key, required this.kind, this.category});
  final String kind;
  final String? category;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        kind == 'games'
            ? 'Most Played Games'
            : kind == 'streamers'
            ? 'Popular Streamer'
            : 'Today Top Stream',
      ),
    ),
    body: PageBody(
      children: [
        if (kind == 'games')
          for (final game in Catalog.games) GameTile(game),
        if (kind == 'streamers')
          for (final name in Catalog.creators)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: CreatorTile(name),
            ),
        if (kind == 'streams')
          for (final s in Catalog.streams.where(
            (s) => category == null || s.category == category,
          )) ...[StreamCard(s), const SizedBox(height: 28)],
      ],
    ),
  );
}

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key, required this.game});
  final Game game;
  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  int tab = 0;
  bool popular = true;
  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    var streams = Catalog.streams.where((s) => s.game == game.name).toList();
    if (!popular) {
      streams = streams.reversed.toList();
    }
    return Scaffold(
      body: SafeArea(
        top: false,
        child: ListView(
          children: [
            SizedBox(
              height: 264,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Picture(
                    game.name == 'Valorant' ? 'valorant-banner' : game.image,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black12, Colors.black87],
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.paddingOf(context).top + 8,
                    left: 8,
                    child: BackButton(color: Colors.white),
                  ),
                  Positioned(
                    top: MediaQuery.paddingOf(context).top + 8,
                    right: 8,
                    child: IconButton(
                      tooltip: 'Sort streams',
                      onPressed: () => showModalBottomSheet<void>(
                        context: context,
                        showDragHandle: true,
                        builder: (context) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const ListTile(title: Text('Sort streams')),
                              for (final v in [true, false])
                                ListTile(
                                  title: Text(
                                    v ? 'Most popular' : 'Recently added',
                                  ),
                                  trailing: popular == v
                                      ? const Icon(
                                          Icons.check,
                                          color: Palette.purple,
                                        )
                                      : null,
                                  onTap: () {
                                    setState(() => popular = v);
                                    Navigator.pop(context);
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                      icon: const Icon(
                        Icons.filter_alt_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          game.name,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${game.name} brings players and creators together. Watch the best moments, live.',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            height: 1.7,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '◉  ${game.viewers}    ·    ◉  2.83M',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          children: game.tags.map((s) => Pill(s)).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: SegmentedTabs(
                labels: const ['Live', 'Videos', 'Clips', 'Events'],
                selected: tab,
                onChanged: (v) => setState(() => tab = v),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (tab == 0) ...[
                    SectionTitle(
                      'Live Now',
                      onAll: () => open(context, '/streams'),
                    ),
                    if (streams.isNotEmpty)
                      StreamRail(streams: streams)
                    else
                      const EmptyState(
                        'No live streams',
                        'Check back soon or explore the clips below.',
                      ),
                    const SectionTitle('Most Viewed Clips'),
                    ...Catalog.clips.map(ClipTile.new),
                  ],
                  if (tab == 1) ...[
                    const SectionTitle('Recent Videos'),
                    ...Catalog.clips.map(ClipTile.new),
                    const SectionTitle('Popular Videos'),
                    ...Catalog.clips.reversed.map(ClipTile.new),
                  ],
                  if (tab == 2) ...[
                    const SectionTitle('Most Viewed Clips'),
                    ...Catalog.clips.map(ClipTile.new),
                  ],
                  if (tab == 3) ...[
                    const SectionTitle('Upcoming Events'),
                    const EventCard(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (int i = 0; i < labels.length; i++)
        Expanded(
          child: InkWell(
            onTap: () => onChanged(i),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: selected == i ? Palette.purple : Colors.transparent,
                  ),
                ),
              ),
              child: Text(
                labels[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: selected == i ? Palette.purple : Palette.muted,
                ),
              ),
            ),
          ),
        ),
    ],
  );
}

class StreamerPage extends StatefulWidget {
  const StreamerPage({super.key, required this.name});
  final String name;
  @override
  State<StreamerPage> createState() => _StreamerPageState();
}

class _StreamerPageState extends State<StreamerPage> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final name = widget.name;
    return Scaffold(
      body: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 150,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const Picture('streamer-cover'),
                  Positioned(
                    top: MediaQuery.paddingOf(context).top,
                    left: 8,
                    child: const BackButton(color: Colors.white),
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
                      Avatar(name, size: 64, live: true),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const Text(
                              '4.4M followers',
                              style: TextStyle(
                                fontSize: 11,
                                color: Palette.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Palette.purple,
                          minimumSize: const Size(90, 36),
                        ),
                        onPressed: () => state.toggleFollow(name),
                        child: Text(
                          state.following.contains(name)
                              ? 'Following'
                              : 'Follow',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Sentinel content creator, btw I’m back baby!'),
                  const SizedBox(height: 16),
                  const Divider(),
                  SegmentedTabs(
                    labels: const ['Broadcast', 'Clips', 'About'],
                    selected: tab,
                    onChanged: (v) => setState(() => tab = v),
                  ),
                  if (tab == 0) ...[
                    const SectionTitle('Ongoing Stream'),
                    StreamCard(
                      Catalog.streams.firstWhere(
                        (s) => s.creator == name,
                        orElse: () => Catalog.streams[0],
                      ),
                    ),
                    const SectionTitle('Yesterday Stream'),
                    const StreamRail(),
                  ],
                  if (tab == 1) ...[
                    const SectionTitle('Recently Clips'),
                    ...Catalog.clips.map(ClipTile.new),
                  ],
                  if (tab == 2) ...[
                    SectionTitle('About $name'),
                    Text(
                      'Hi my name is $name, I’m a professional gamer and content creator. Join me for ranked games, good music and a great community.',
                    ),
                    const SectionTitle('Recently Categories'),
                    ...Catalog.games.take(3).map(GameTile.new),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  const EventCard({super.key, this.openDetails = true});
  final bool openDetails;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: openDetails ? () => open(context, '/event') : null,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Picture(
          'streamer-cover',
          width: double.infinity,
          height: 175,
          radius: 16,
        ),
        const SizedBox(height: 14),
        const Pill('COMMUNITY EVENT', active: true),
        const SizedBox(height: 12),
        Text(
          'Valorant Community Night',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const Text(
          'Friday · 20:00 JST · Hosted by Shroud',
          style: TextStyle(color: Palette.muted),
        ),
      ],
    ),
  );
}

class EventPage extends StatefulWidget {
  const EventPage({super.key});
  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  bool joined = false;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Event Details')),
    body: PageBody(
      children: [
        const EventCard(openDetails: false),
        const SectionTitle('About the event'),
        const Text(
          'A night of friendly matches, exciting plays and community conversations. All skill levels are welcome. Bring your team and enjoy the stream.',
        ),
        const SectionTitle('Your host'),
        const CreatorTile('Shroud'),
        const SizedBox(height: 32),
        FilledButton(
          onPressed: () => setState(() => joined = !joined),
          child: Text(joined ? 'You’re on the list ✓' : 'Join Event'),
        ),
        const SizedBox(height: 12),
        const Text(
          'Demo RSVP · saved for this visit only',
          textAlign: TextAlign.center,
          style: TextStyle(color: Palette.muted, fontSize: 11),
        ),
      ],
    ),
  );
}
