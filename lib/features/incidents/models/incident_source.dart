class IncidentNewsArticle {
  const IncidentNewsArticle({
    required this.headline,
    this.url,
    this.thumbnailUrl,
    this.publishedAt,
    this.source,
  });

  final String headline;
  final String? url;
  final String? thumbnailUrl;
  final String? publishedAt;
  final String? source;
}

class IncidentWeatherSnapshot {
  const IncidentWeatherSnapshot({
    this.tempC,
    this.humidity,
    this.windKph,
    this.condition,
    this.day1Condition,
    this.day1PrecipMm,
    this.day1RainChance,
  });

  final double? tempC;
  final int? humidity;
  final double? windKph;
  final String? condition;
  final String? day1Condition;
  final double? day1PrecipMm;
  final int? day1RainChance;
}

class IncidentSourceTrail {
  const IncidentSourceTrail({
    required this.type,
    this.newsArticles = const <IncidentNewsArticle>[],
    this.weather,
  });

  final String type;
  final List<IncidentNewsArticle> newsArticles;
  final IncidentWeatherSnapshot? weather;

  bool get isNews => type == 'news' && newsArticles.isNotEmpty;
  bool get isWeather => type == 'weather' && weather != null;
}
