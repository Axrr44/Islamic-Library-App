class Favorite {
  final String type;
  final String title;
  final String content;

  Favorite({required this.type, required this.title, required this.content});

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'title': title,
      'content': content,
    };
  }

  factory Favorite.fromMap(Map<String, dynamic> map) {
    return Favorite(
      type: map['type'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
    );
  }
}