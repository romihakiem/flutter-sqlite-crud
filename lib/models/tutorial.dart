class TutorialModel {
  int? id;
  String? title;
  String? description;

  TutorialModel(this.title, this.description, {this.id});

  TutorialModel.fromJson(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    description = map['description'];
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
    };
  }
}
