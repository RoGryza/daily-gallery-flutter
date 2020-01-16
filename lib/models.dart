import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import "service.dart";

class User {
  final IToken token;

  const User(this.token);

  String get username => token.username;

  @override
  bool operator==(Object other) =>
    identical(this, other)
    || other is User &&
      runtimeType == other.runtimeType &&
      token == other.token;

  @override
  int get hashCode => token.hashCode;
}

class AppInfo {
  final String title;

  const AppInfo({this.title});

  @override
  bool operator==(Object other) =>
  identical(this, other)
  || other is AppInfo &&
    runtimeType == other.runtimeType &&
    title == other.title;

  @override
  int get hashCode => title.hashCode;
}

class Post {
  static final DATE_FMT = DateFormat("yyyy-MM-dd");
  static final RENDER_FMT = DateFormat("dd/MM/yyyy");
  final DateTime day;
  final List<PostMedia> _media;

  const Post({@required this.day, @required media}): _media = media;

  UnmodifiableListView<PostMedia> get media => UnmodifiableListView(_media);
  String get route => "/posts/" + DATE_FMT.format(day);
  String get prettyDay => RENDER_FMT.format(day);
}

class PostMedia {
  final String caption;
  final String src;
  final int width;
  final int height;

  const PostMedia({
      @required this.caption,
      @required this.src,
      @required this.width,
      @required this.height,
  });

  @override
  bool operator==(Object other) =>
  identical(this, other)
  || other is PostMedia &&
    runtimeType == other.runtimeType &&
    caption == other.caption &&
    src == other.src &&
    width == other.width &&
    height == other.height;

  @override
  int get hashCode {
    int result = 17;
    result = 37 * result + caption.hashCode;
    result = 37 * result + src.hashCode;
    result = 37 * result + width.hashCode;
    result = 37 * result + height.hashCode;
    return result;
  }
}
