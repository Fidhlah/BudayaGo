class KaryaItem {
  final String id;
  final String name;
  final String creatorId;
  final String creatorName;
  final String tag;
  final String umkm;
  final String? description;
  final String? imageUrl;
  final int color;
  final double height;
  final int iconCodePoint;
  final DateTime createdAt;
  final int likes;
  final int views;

  KaryaItem({
    required this.id,
    required this.name,
    required this.creatorId,
    required this.creatorName,
    required this.tag,
    required this.umkm,
    this.description,
    this.imageUrl,
    required this.color,
    required this.height,
    required this.iconCodePoint,
    required this.createdAt,
    this.likes = 0,
    this.views = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'creator_id': creatorId,
      'creator_name': creatorName,
      'tag': tag,
      'umkm': umkm,
      'description': description,
      'image_url': imageUrl,
      'color': color,
      'height': height,
      'icon_code_point': iconCodePoint,
      'created_at': createdAt.toIso8601String(),
      'likes': likes,
      'views': views,
    };
  }

  factory KaryaItem.fromJson(Map<String, dynamic> json) {
    return KaryaItem(
      id: json['id'] as String,
      name: json['name'] as String,
      creatorId: json['creator_id'] as String,
      creatorName: json['creator_name'] as String,
      tag: json['tag'] as String,
      umkm: json['umkm'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      color: json['color'] as int,
      height: (json['height'] as num).toDouble(),
      iconCodePoint: json['icon_code_point'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      likes: json['likes'] as int? ?? 0,
      views: json['views'] as int? ?? 0,
    );
  }

  KaryaItem copyWith({
    String? id,
    String? name,
    String? creatorId,
    String? creatorName,
    String? tag,
    String? umkm,
    String? description,
    String? imageUrl,
    int? color,
    double? height,
    int? iconCodePoint,
    DateTime? createdAt,
    int? likes,
    int? views,
  }) {
    return KaryaItem(
      id: id ?? this.id,
      name: name ?? this.name,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      tag: tag ?? this.tag,
      umkm: umkm ?? this.umkm,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      color: color ?? this.color,
      height: height ?? this.height,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      views: views ?? this.views,
    );
  }
}
