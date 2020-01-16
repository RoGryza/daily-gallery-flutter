import 'package:flutter/material.dart';
import '../models.dart';
import '../service.dart';
import 'posts.dart';
import 'util.dart';

class HomePage extends StatefulWidget {
  final IService service;
  final User user;

  const HomePage({this.service, this.user});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  Future<AppInfo> _infoFuture;
  Future<void> _postsFuture;
  final List<Post> _posts = [];
  bool _morePosts = true;
  bool _fetchingPosts = false;

  @override
  void initState() {
    super.initState();
    _infoFuture = widget.service.appInfo(widget.user.token);
    _postsFuture = _doFetchPosts();
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _infoFuture,
      builder: (context, snapshot)
      {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return _InfoError(_fetchInfo, "Something went wrong");
          case ConnectionState.active:
          case ConnectionState.waiting:
            return _Loading();
          case ConnectionState.done:
            return snapshot.hasError ?
              _InfoError(_fetchInfo, snapshot.error) :
              _LoadedHome(snapshot.data, _posts, _morePosts, _postsFuture, _doFetchPosts);
          }
      },
    );
  }

  Future<AppInfo> _fetchInfo() {
    setState(() { _infoFuture = widget.service.appInfo(widget.user.token); });
  }
  
  Future<void> _fetchPosts() async {
    setState(() { _postsFuture = _doFetchPosts(); });
  }

  Future<void> _doFetchPosts() async {
    if (_fetchingPosts) {
      return _postsFuture;
    }
    _fetchingPosts = true;
    final upto = _posts.length > 0 ? _posts.last.day.subtract(Duration(days: 1)) : null;
    final posts = await widget.service.posts(widget.user.token, upto: upto);
    setState(() {
        _fetchingPosts = false;
        _morePosts = !posts.isEmpty;
        _posts.addAll(posts);
    });
  }
}

class _Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Loading..."),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: CircularProgressIndicator(),
            ),
            Text("Please wait..."),
          ],
        ),
      ),
    );
  }
}

class _InfoError extends StatelessWidget {
  final VoidCallback fetchInfo;
  final Object error;

  const _InfoError(this.fetchInfo, this.error);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Error"),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ErrorText(error),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: RaisedButton(
                onPressed: fetchInfo,
                child: Text('Retry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadedHome extends StatefulWidget {
  final AppInfo info;
  final List<Post> posts;
  final Future<void> postsFuture;
  final bool morePosts;
  final VoidCallback fetchPosts;

  const _LoadedHome(this.info, this.posts, this.morePosts, this.postsFuture, this.fetchPosts);

  @override
  _LoadedHomeState createState() =>_LoadedHomeState();
}

class _LoadedHomeState extends State<_LoadedHome> {
  static double SCROLL_SPEED = 6.0;
  ScrollController _scrollController;
  bool _isOnTop = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollCallback);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollCallback); // TODO does dispose already do this?
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.info.title),
      ),
      body: PostList(
        scrollController: _scrollController,
        posts: widget.posts,
        morePosts: widget.morePosts,
        fetchPosts: widget.fetchPosts,
      ),
      floatingActionButton: _isOnTop ? null : FloatingActionButton(
        child: Icon(Icons.arrow_upward),
        onPressed: () {
          _scrollController.animateTo(
            _scrollController.position.minScrollExtent,
            duration: Duration(milliseconds: _calcScrollDuration()),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }

  void _scrollCallback() {
    setState(() {
        // 1e-9 as a small error margin
        _isOnTop = _scrollController.offset <= SCROLL_SPEED + 1e-9;
    });
  }

  // Calculate time in ms to scroll to top based on offset and an avareage speed
  int _calcScrollDuration() {
    return (_scrollController.offset / SCROLL_SPEED).truncate();
  }
}
