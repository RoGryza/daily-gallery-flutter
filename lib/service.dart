import 'dart:collection';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'models.dart';

class ServiceException implements Exception {
  final int status;
  final String response;

  ServiceException(this.status, this.response);

  @override
  String toString() => "[${this.status}] ${this.response}";
}

abstract class IToken {
  String get username;
}

abstract class IService {
  Future<IToken> login(String username, String password);
  Future<void> logout(IToken token);
  Future<AppInfo> appInfo(IToken token);
  Future<List<Post>> posts(IToken token, {int limit, DateTime upto});
}

class MockToken implements IToken {
  String _username;

  @override
  String get username => _username;

  @override
  String toString() => _username;
}

class MockService implements IService {
  @override
  Future<IToken> login(String username, String password) async {
    if (username != password) {
      throw ServiceException(401, "Invalid username and/or password");
    }

    var tok = MockToken();
    tok._username = username;
    return tok;
  }

  @override
  Future<void> logout(IToken token) async {
  }

  @override
  Future<AppInfo> appInfo(IToken token) async {
    return AppInfo(
      title: "Mock Gallery",
    );
  }

  @override
  Future<List<Post>> posts(IToken token, {int limit, DateTime upto}) async {
    limit = limit ?? 10;
    upto = upto ?? DateTime.now();
    var day = DateTime(upto.year, upto.month, upto.day);
    final result = <Post>[];
    final fmt = DateFormat("yyyy-MM-ddTHH:mm:ss");
    for (var i = 0; i < limit; i++) {
      result.add(Post(
          day: day,
          media: [PostMedia(
              caption: "Post for ${day}",
              src: "https://picsum.photos/seed/${token}-${fmt.format(day)}/200",
              width: 200,
              height: 200,
          )],
      ));

      day = day.subtract(new Duration(days: 1));
    }
    return result;
  }
}

class DelayedService implements IService {
  final IService _inner;
  final Duration delay;

  DelayedService(this._inner, this.delay);

  @override
  Future<IToken> login(String username, String password) => Future.delayed(delay, () => _inner.login(username, password));

  @override
  Future<void> logout(IToken token) => Future.delayed(delay, () => _inner.logout(token));

  @override
  Future<AppInfo> appInfo(IToken token) => Future.delayed(delay, () => _inner.appInfo(token));

  @override
  Future<List<Post>> posts(IToken token, {int limit, DateTime upto}) => Future.delayed(delay, () => _inner.posts(token, limit: limit, upto: upto));
}

class ApiToken implements IToken {
  final String _username;
  final String _accessToken;

  const ApiToken(this._username, this._accessToken);

  @override
  String get username => _username;

  @override
  String toString() => _accessToken;
}

class ApiService implements IService {
  final String _baseUrl;
  final _client = http.Client();

  ApiService(this._baseUrl);
  
  @override
  Future<IToken> login(String username, String password) async {
    final resp = await _client.post(
      "${_baseUrl}/token",
      body: {
        "username": username,
        "password": password,
      },
    );

    if (resp.statusCode != 200) {
      throw ServiceException(resp.statusCode, resp.body.length > 0 ? resp.body : resp.reasonPhrase);
    }

    final parsed = jsonDecode(resp.body);
    return ApiToken(username, parsed["access_token"]);
  }

  @override
  Future<void> logout(IToken token) async {
  }

  @override
  Future<AppInfo> appInfo(IToken token) async {
    final resp = await _client.get(
      "${_baseUrl}/info",
      headers: {
        "Authorization": "Bearer ${token}",
      },
    );

    if (resp.statusCode != 200) {
      throw ServiceException(resp.statusCode, resp.body.length > 0 ? resp.body : resp.reasonPhrase);
    }

    final parsed = jsonDecode(resp.body);
    return AppInfo(
      title: parsed["title"],
    );
  }

  @override
  Future<List<Post>> posts(IToken token, {int limit, DateTime upto}) async {
    var url = "${_baseUrl}/posts";
    final params = [];
    if (limit != null) {
      params.add("limit=${limit}");
    }
    if (upto != null) {
      final fmt = DateFormat("yyyy-MM-dd");
      params.add("upto=${fmt.format(upto)}");
    }
    if (params.length > 0) {
      url += "?" + params.join("&");
    }
    final resp = await _client.get(
      url,
      headers: {
        "Authorization": "Bearer ${token}",
      },
    );

    if (resp.statusCode != 200) {
      throw ServiceException(resp.statusCode, resp.body.length > 0 ? resp.body : resp.reasonPhrase);
    }

    final parsed = jsonDecode(resp.body);
    final result = <Post>[];
    for (var rawPost in parsed) {
      final medias = <PostMedia>[];
      for (var rawMedia in rawPost["media"]) {
        medias.add(PostMedia(
            caption: rawMedia["caption"],
            src: rawMedia["src"].replaceFirst('http://localhost:8000', _baseUrl),
            width: rawMedia["width"],
            height: rawMedia["height"],
        ));
      }
      result.add(Post(
          day: DateTime.parse(rawPost["date"]),
          media: medias,
      ));
    }
    return result;
  }
}
