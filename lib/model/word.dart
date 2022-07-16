class Word {
  String? uuid;
  String category;
  String eng;
  String exEng;
  String exJap;
  String? exp;
  String id;
  String jap;
  String level;
  String mp3Eng;
  String mp3Ex;
  String mp3Jap;
  String no;
  String? pron;
  String pum;

  Word(
      {this.uuid,
      required this.category,
      required this.eng,
      required this.exEng,
      required this.exJap,
      this.exp,
      required this.id,
      required this.jap,
      required this.level,
      required this.mp3Eng,
      required this.mp3Ex,
      required this.mp3Jap,
      required this.no,
      this.pron,
      required this.pum});

  static Word fromJSON(Map<String, dynamic> json) {
    return Word(
      category: json['category'],
      eng: json['eng'],
      exEng: json['ex_eng'],
      exJap: json['ex_jap'],
      exp: json['exp'] ?? '',
      id: json['id'],
      jap: json['jap'],
      level: json['level'] != '' ? json['level'] : 'Idioms',
      mp3Eng: json['mp3_eng'],
      mp3Ex: json['mp3_ex'],
      mp3Jap: json['mp3_jap'],
      no: json['no'],
      pron: json['pron'] ?? '',
      pum: json['pum'],
    );
  }
}
