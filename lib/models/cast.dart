class Cast {
  int castId;
  String character;
  String creditId;
  int gender;
  int id;
  String name;
  int order;
  String profilePath;

  Cast({
    this.castId,
    this.character,
    this.creditId,
    this.gender,
    this.id,
    this.name,
    this.order,
    this.profilePath,
  });

  factory Cast.fromJson(Map<String, dynamic> json) => new Cast(
        castId: json["cast_id"],
        character: json["character"],
        creditId: json["credit_id"],
        gender: json["gender"],
        id: json["id"],
        name: json["name"],
        order: json["order"],
        profilePath: json["profile_path"],
      );

  Map<String, dynamic> toJson() => {
        "cast_id": castId,
        "character": character,
        "credit_id": creditId,
        "gender": gender,
        "id": id,
        "name": name,
        "order": order,
        "profile_path": profilePath,
      };
}
