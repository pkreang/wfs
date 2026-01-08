class Tag {
  String? tagId;
  String? tagName;

  Tag({this.tagId, this.tagName});

  Tag copyWith({String? tagId, String? tagName}) => Tag(tagId: tagId ?? this.tagId, tagName: tagName ?? this.tagName);

  Tag.fromJson(Map<String, dynamic> json) {
    tagId = json['TagID'];
    tagName = json['TagName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tag_id'] = tagId;
    data['tag_name'] = tagName;
    return data;
  }

  static List<Tag> listFromJson(List<dynamic> jsonList) => jsonList.map((e) => Tag.fromJson(e as Map<String, dynamic>)).toList();
}
