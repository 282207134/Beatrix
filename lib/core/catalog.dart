class Game {
  const Game(this.name, this.image, this.viewers, this.tags);
  final String name, image, viewers;
  final List<String> tags;
}

class Stream {
  const Stream(
    this.title,
    this.creator,
    this.image,
    this.game, {
    this.category = 'Gaming',
    this.views = '2.3K',
  });
  final String title, creator, image, game, category, views;
}

class Gift {
  const Gift(this.name, this.cost);
  final String name;
  final int cost;
}

abstract final class Catalog {
  static const categories = ['Gaming', 'Music', 'Esport', 'Podcast'];
  static const creators = [
    'Shroud',
    'Guerry',
    'Chappy',
    'Bangpen',
    'Ahmeyd',
    'Kaelasy',
  ];
  static const games = [
    Game('Overwatch 2', 'overwatch', '192.9K', ['FPS', 'Shooter', 'Action']),
    Game('Valorant', 'valorant', '81.6K', ['FPS', 'Shooter', 'Action']),
    Game('Genshin Impact', 'genshin', '18.6K', ['RPG', 'Adventure']),
    Game('Dota 2', 'dota', '83.2K', ['MOBA', 'Strategy']),
  ];
  static const streams = [
    Stream(
      'Bronze To Radiant In One Stream!',
      'Shroud',
      'stream-one',
      'Valorant',
    ),
    Stream(
      '#1 Long stream. Let’s play together',
      'Chappy',
      'stream-one',
      'Overwatch 2',
    ),
    Stream(
      'Easy farming at State Of Indonesia Rp',
      'Guerry',
      'valorant-play',
      'Valorant',
    ),
    Stream(
      'Unarchived monday japanese song',
      'Guerry',
      'streamer-cover',
      'Music',
      category: 'Music',
    ),
    Stream(
      'Championship finals · Watch party',
      'Bangpen',
      'overwatch-play',
      'Overwatch 2',
      category: 'Esport',
    ),
    Stream(
      'After hours: life behind the stream',
      'Ahmeyd',
      'profile-cover',
      'Podcast',
      category: 'Podcast',
    ),
  ];
  static const clips = [
    Stream('Lemao momentos', 'Shroud', 'clip', 'Valorant', views: '43.2K'),
    Stream(
      'Trying to play Overwatch 2',
      'Shroud',
      'overwatch-play',
      'Overwatch 2',
      views: '182.7K',
    ),
    Stream(
      'Reyna buffed in v2.32',
      'Chappy',
      'reyna',
      'Valorant',
      views: '22.1K',
    ),
  ];
  static const gifts = [
    Gift('Heart', 10),
    Gift('Rose', 20),
    Gift('Clover', 50),
    Gift('Popcorn', 100),
    Gift('Mega Lion', 150),
    Gift('Cube Robot', 300),
  ];
}
