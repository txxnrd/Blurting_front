class home {
  List<dynamic>? mvpData;
  int? arrow;
  int? matchedArrows;
  int? chats;
  int? likes;
  int? milliseconds;

  home({this.arrow, this.chats, this.likes, this.matchedArrows, this.milliseconds, this.mvpData});

  home.fromJson(Map<String, dynamic> json) {
    mvpData = json['answers'];
    arrow = json['arrows'];
    matchedArrows = json['matchedArrows'];
    chats = json['chats'];
    likes = json['likes'];
    milliseconds = json['seconds'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['answers'] = mvpData;
    data['arrow'] = arrow;
    data['matchedArrows'] = matchedArrows;
    data['chats'] = chats;
    data['likes'] = likes;
    
    return data;
  }
}
