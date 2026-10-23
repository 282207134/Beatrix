import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_state.dart';
import '../../core/catalog.dart';
import '../../core/theme.dart';
import '../../widgets/common.dart';

class StreamPage extends StatefulWidget {
  const StreamPage({super.key, required this.stream});
  final Stream stream;
  @override
  State<StreamPage> createState() => _StreamPageState();
}

class _StreamPageState extends State<StreamPage> {
  final message = TextEditingController();
  final chatScroll = ScrollController();
  @override
  void dispose() {
    message.dispose();
    chatScroll.dispose();
    super.dispose();
  }

  void send() {
    final text = message.text;
    AppScope.of(context).sendMessage(text);
    message.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (chatScroll.hasClients) {
        chatScroll.animateTo(
          chatScroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final stream = widget.stream, state = AppScope.of(context);
    final typing = MediaQuery.viewInsetsOf(context).bottom > 0;
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            SizedBox(
              height: typing ? 130 : 240,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Picture(
                    stream.image == 'stream-one'
                        ? 'valorant-play'
                        : stream.image,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black45,
                          Colors.transparent,
                          Colors.black54,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.paddingOf(context).top + 4,
                    left: 6,
                    right: 6,
                    child: Row(
                      children: [
                        const BackButton(color: Colors.white),
                        const Spacer(),
                        IconButton(
                          tooltip: 'Leaderboard',
                          onPressed: () => open(context, '/leaderboard'),
                          icon: const Icon(
                            Icons.leaderboard_outlined,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Streamer profile',
                          onPressed: () =>
                              open(context, '/streamer', stream.creator),
                          icon: const Icon(
                            Icons.forum_outlined,
                            color: Colors.white,
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_horiz,
                            color: Colors.white,
                          ),
                          onSelected: (v) {
                            if (v == 'profile') {
                              open(context, '/streamer', stream.creator);
                            }
                            if (v == 'info') {
                              toast(
                                context,
                                'Demo stream preview · live playback is not connected.',
                              );
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'profile',
                              child: Text('View creator'),
                            ),
                            PopupMenuItem(
                              value: 'info',
                              child: Text('Stream information'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 20,
                    right: 12,
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 7, color: Palette.red),
                        const Text(
                          ' 08:23:21',
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                        const Spacer(),
                        Text(
                          '◉ ${stream.views}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Fullscreen',
                          onPressed: () => open(context, '/fullscreen', stream),
                          icon: const Icon(
                            Icons.fullscreen,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Positioned(
                    left: 20,
                    top: 95,
                    child: Text(
                      'DEMO PREVIEW',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (!typing)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Pill(
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
                    const SizedBox(height: 10),
                    Text(
                      stream.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Wrap(
                      spacing: 5,
                      children: [Pill('FPS'), Pill('Gaming'), Pill('Shooter')],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        InkWell(
                          onTap: () =>
                              open(context, '/streamer', stream.creator),
                          child: Avatar(stream.creator),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: () =>
                                open(context, '/streamer', stream.creator),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      stream.creator,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    const Icon(
                                      Icons.verified,
                                      size: 14,
                                      color: Palette.purple,
                                    ),
                                  ],
                                ),
                                const Text(
                                  '4.4M followers',
                                  style: TextStyle(
                                    color: Palette.muted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        FilledButton(
                          key: const ValueKey('stream-follow'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(94, 34),
                          ),
                          onPressed: () => state.toggleFollow(stream.creator),
                          child: Text(
                            state.following.contains(stream.creator)
                                ? 'Following'
                                : 'Follow',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: ListView.builder(
                  key: const ValueKey('chat-list'),
                  controller: chatScroll,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  itemCount: state.messages.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 82,
                          child: Text(
                            state.messages[i].$1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Palette.muted,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            state.messages[i].$2,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const ValueKey('chat-input'),
                      controller: message,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => send(),
                      decoration: InputDecoration(
                        hintText: 'Send a message',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        suffixIcon: IconButton(
                          tooltip: 'Send message',
                          onPressed: send,
                          icon: const Icon(Icons.send_outlined),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filledTonal(
                    tooltip: 'Send gift',
                    onPressed: () => showModalBottomSheet<void>(
                      context: context,
                      showDragHandle: true,
                      isScrollControlled: true,
                      builder: (_) => GiftPanel(creator: stream.creator),
                    ),
                    icon: const Icon(
                      Icons.card_giftcard,
                      color: Palette.purple,
                    ),
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

class GiftPanel extends StatelessWidget {
  const GiftPanel({super.key, this.creator = 'Shroud'});
  final String creator;
  static const icons = [
    Icons.favorite,
    Icons.local_florist,
    Icons.eco,
    Icons.local_movies,
    Icons.pets,
    Icons.smart_toy,
  ];
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Send a gift',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                Text(
                  '◆ ${state.balance}',
                  key: const ValueKey('gift-balance'),
                  style: const TextStyle(
                    color: Palette.purple,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Support $creator · Demo diamonds',
              style: const TextStyle(color: Palette.muted, fontSize: 11),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: Catalog.gifts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: .95,
              ),
              itemBuilder: (_, i) {
                final gift = Catalog.gifts[i];
                return OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () async {
                    final sent = await state.sendGift(gift, creator);
                    if (context.mounted) {
                      toast(
                        context,
                        sent
                            ? '${gift.name} sent to $creator!'
                            : 'Not enough demo diamonds.',
                      );
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icons[i],
                        color: i < 2 ? Palette.red : Palette.purple,
                        size: 32,
                      ),
                      const SizedBox(height: 10),
                      Text(gift.name, style: const TextStyle(fontSize: 11)),
                      Text(
                        '◆ ${gift.cost}',
                        style: const TextStyle(
                          color: Palette.muted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});
  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 3,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        bottom: const TabBar(
          tabs: [
            Tab(text: 'Today'),
            Tab(text: 'This Week'),
            Tab(text: 'All Time'),
          ],
        ),
      ),
      body: TabBarView(
        children: [
          for (int period = 0; period < 3; period++)
            PageBody(
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final rank in [2, 1, 3])
                      Column(
                        children: [
                          Icon(
                            Icons.emoji_events,
                            size: rank == 1 ? 36 : 25,
                            color: rank == 1
                                ? const Color(0xFFE9B34C)
                                : Palette.muted,
                          ),
                          const SizedBox(height: 10),
                          Avatar(
                            Catalog.creators[rank - 1],
                            size: rank == 1 ? 66 : 50,
                            live: rank == 1,
                          ),
                          const SizedBox(height: 8),
                          Text(Catalog.creators[rank - 1]),
                          Text(
                            '◆ ${(4000 - rank * 700) * (period + 1)}',
                            style: const TextStyle(
                              color: Palette.purple,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SectionTitle('Top Supporters'),
                for (int i = 0; i < 6; i++)
                  ListTile(
                    leading: Text(
                      '${i + 4}',
                      style: const TextStyle(color: Palette.muted),
                    ),
                    title: Row(
                      children: [
                        Avatar(Catalog.creators[i], size: 32),
                        const SizedBox(width: 10),
                        Text(Catalog.creators[i]),
                      ],
                    ),
                    trailing: Text(
                      '◆ ${(950 - i * 120) * (period + 1)}',
                      style: const TextStyle(
                        color: Palette.purple,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    ),
  );
}

class FullscreenPage extends StatefulWidget {
  const FullscreenPage({super.key, required this.stream});
  final Stream stream;
  @override
  State<FullscreenPage> createState() => _FullscreenPageState();
}

class _FullscreenPageState extends State<FullscreenPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: SafeArea(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Picture(
            widget.stream.image == 'stream-one'
                ? 'valorant-play'
                : widget.stream.image,
            fit: BoxFit.contain,
          ),
          Positioned(
            top: 8,
            left: 8,
            child: const BackButton(color: Colors.white),
          ),
          Positioned(
            top: 20,
            left: 70,
            child: Text(
              widget.stream.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Positioned(
            left: 24,
            bottom: 24,
            child: Text(
              '● DEMO PREVIEW     08:23:21',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );
}
