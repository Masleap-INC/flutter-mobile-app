import 'story_model.dart';
import 'user_model.dart';

class StoryResponseModel {
  List<StoryResponse>? response;

  StoryResponseModel({this.response});

  StoryResponseModel.fromJson(Map<String, dynamic> json) {
    if (json['response'] != null) {
      response = <StoryResponse>[];
      json['response'].forEach((v) {
        response!.add(StoryResponse.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (response != null) {
      data['response'] = response!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class StoryResponse {
  String? id;
  UserModel? user;
  List<Stories>? stories;

  StoryResponse({this.id, this.user, this.stories});

  StoryResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['data'] != null ? UserModel.fromJson(json['data']) : null;
    if (json['stories'] != null) {
      stories = <Stories>[];
      json['stories'].forEach((v) {
        stories!.add(Stories.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (user != null) {
      data['data'] = user!.toJson();
    }
    if (stories != null) {
      data['stories'] = stories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}



class Stories {
  String? id;
  StoryModel? story;

  Stories({this.id, this.story});

  Stories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    story = json['data'] != null ? StoryModel.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (story != null) {
      data['data'] = story!.toJson();
    }
    return data;
  }
}

