enum MusicMood {
  calm,
  uplifting,
  focus,
  sleep,
  nature
}

class MusicTrack {
  final String id;
  final String title;
  final String artist;
  final String url;
  final MusicMood mood;
  final String duration;

  MusicTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.url,
    required this.mood,
    required this.duration,
  });
}
