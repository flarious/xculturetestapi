class Forum {
  final int id;
  final String title;
  final String subtitle;
  final String content;
  final String thumbnail;
  final String author;
  final bool incognito;
  final int viewed;
  final int favorited;
  final String date;
  final String updateDate;

  Forum({
    required this.id, 
    required this.title,
    required this.subtitle,
    required this.content,
    required this.thumbnail, 
    required this.author,
    required this.incognito,
    required this.viewed,
    required this.favorited,
    required this.date,
    required this.updateDate
  });

  factory Forum.fromJson(Map<String, dynamic> json) {
    return Forum(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      content: json['content'],
      thumbnail: json['thumbnail'],
      author: json['author'],
      incognito: json['incognito'],
      viewed: json['viewed'],
      favorited: json['favorite_amount'],
      date: json['date'],
      updateDate: json['update_date'],
    );
  }
}