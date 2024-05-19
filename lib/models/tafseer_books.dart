class Tafseer {
  final int id;
  final String name;
  final String language;
  final String author;
  final String bookName;

  Tafseer({
    required this.id,
    required this.name,
    required this.language,
    required this.author,
    required this.bookName,
  });

  factory Tafseer.fromJson(Map<String, dynamic> json) {
    return Tafseer(
      id: json['id'],
      name: json['name'],
      language: json['language'],
      author: json['author'],
      bookName: json['book_name'],
    );
  }

   Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'language': language,
      'author': author,
      'book_name': bookName,
    };
  }

  static Tafseer empty()
  {
    return Tafseer(id: 1, name: "", language: "", author: "", bookName: "");
  }

}