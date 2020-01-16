import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models.dart';
import 'util.dart';

typedef FetchPostsCallback = Future<void> Function();

class PostList extends StatelessWidget {
  final ScrollController scrollController;
  final List<Post> posts;
  final bool morePosts;
  final FetchPostsCallback fetchPosts;

  const PostList({this.scrollController, this.posts, this.morePosts, this.fetchPosts});

  @override
  Widget build(BuildContext context) {
    return StaggeredGridView.countBuilder(
      primary: false, // TODO Remove this and use aspect ratio in the inner Image
      addAutomaticKeepAlives: false,
      controller: scrollController,
      crossAxisCount: 2,
      itemCount: posts.length + 1,
      staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
      itemBuilder: (BuildContext context, int index) {
        if (index < posts.length) {
          return _Post(posts[index], onTap: () {
              Navigator.of(context).pushNamed(posts[index].route, arguments: posts[index]);
          });
        }

        // TODO handle errors
        if (morePosts) {
          _fetchPosts();
          return Center(child: CircularProgressIndicator());
        } else {
          return Center(child: Container());
        }
      },
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 4.0,
    );
  }

  void _fetchPosts() {
    if (fetchPosts != null) {
      fetchPosts();
    }
  }
}

class _Post extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;

  _Post(this.post, {this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var children = <Widget>[
      Text(post.prettyDay),
      _PostImage(post),
    ];
    if (!post.media.isEmpty) {
      final media = post.media[0];
      children.addAll(<Widget>[
          const Padding(padding: EdgeInsets.only(top: 20.0)),
          Text(media.caption, style: theme.textTheme.caption),
      ]);
    }

    return Padding(
      padding: const EdgeInsets.all(15),
      child: InkWell(
        onTap: onTap,
        child: Card(
          child: Column(children: children),
        ),
      ),
    );
  }
}


class _PostImage extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;

  _PostImage(this.post, {this.onTap});
  
  @override
  Widget build(BuildContext context) {
    if (post.media.isEmpty) {
      return const Text("No media for this post");
    } else {
      final media = post.media[0];
      return Hero(
        tag: post.day.toString(),
        child: Image.network(
          media.src,
          fit: BoxFit.contain,
          cacheWidth: media.width != 0 ? media.width : null,
          cacheHeight: media.height != 0 ? media.height : null,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return CircularProgressIndicator();
          },
        ), // TODO -- move to CachedNetworkImage && fix progress
      );
    }
  }
}


class PostPage extends StatelessWidget {
  final Post post;

  const PostPage({@required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(post.prettyDay)),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              InkWell(
                onTap: () { Navigator.of(context).pop(); },
                child: _PostImage(post),
              ),
              post.media.isEmpty ?
              Container() :
              Text(
                post.media[0].caption,
                style: Theme.of(context).textTheme.display1,
                textAlign: TextAlign.center,
              ),
            ]
          ),
        ),
      ),
    );
  }
}
