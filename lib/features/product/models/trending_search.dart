enum TrendingTimeframe {
  recent,
  daily,
  monthly;

  String get label {
    switch (this) {
      case TrendingTimeframe.recent:
        return 'Recent';
      case TrendingTimeframe.daily:
        return 'Today';
      case TrendingTimeframe.monthly:
        return 'This Month';
    }
  }

  String get apiValue => name;
}

class TrendingItem {
  final String query;
  final int rank;
  final bool isHot;
  final String? tag;
  final String? category;
  final int? searchCount;

  const TrendingItem({
    required this.query,
    required this.rank,
    this.isHot = false,
    this.tag,
    this.category,
    this.searchCount,
  });

  Map<String, dynamic> toJson() => {
    'query': query,
    'rank': rank,
    'isHot': isHot,
    if (tag != null) 'tag': tag,
    if (category != null) 'category': category,
    if (searchCount != null) 'searchCount': searchCount,
  };

  factory TrendingItem.fromJson(Map<String, dynamic> j) {
    return TrendingItem(
      query: j['query'] as String? ?? '',
      rank: (j['rank'] as num?)?.toInt() ?? 1,
      isHot: j['isHot'] as bool? ?? false,
      tag: j['tag'] as String?,
      category: j['category'] as String?,
      searchCount: (j['searchCount'] as num?)?.toInt(),
    );
  }
}
