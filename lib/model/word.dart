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
}
