class TutorialModel {
  int? id;
  String? title;
  String? description;

  TutorialModel({this.id, this.title, this.description});

  TutorialModel.fromJson(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    description = map['description'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
    };
  }
}
