class TafseerResponse {
  final int tafseerId;
  final String tafseerName;
  final String ayahUrl;
  final int ayahNumber;
  final String text;

  TafseerResponse({
    required this.tafseerId,
    required this.tafseerName,
    required this.ayahUrl,
    required this.ayahNumber,
    required this.text,
  });

  factory TafseerResponse.fromJson(Map<String, dynamic> json) {
    return TafseerResponse(
      tafseerId: json['tafseer_id'],
      tafseerName: json['tafseer_name'],
      ayahUrl: json['ayah_url'],
      ayahNumber: json['ayah_number'],
      text: json['text'],
    );
  }
}
