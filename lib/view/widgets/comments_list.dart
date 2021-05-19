import 'package:flutter/material.dart';
import 'package:inproduce/model/comment_model.dart';
import 'package:inproduce/view/widgets/inherited_widgets/inherited_post_model.dart';
import 'package:inproduce/view/widgets/user_details_with_follow.dart';
import 'package:inproduce/helper/demo_values.dart';
import 'package:inproduce/model/user_model.dart';
import 'package:intl/intl.dart';

class CommentsListKeyPrefix {
  static final String singleComment = "Comment";
  static final String commentUser = "Comment User";
  static final String commentText = "Comment Text";
  static final String commentDivider = "Comment Divider";
}

class CommentsList extends StatelessWidget {
  final dynamic params;
  const CommentsList({Key key,@required this.params}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<dynamic> comments = this.params;
        //InheritedPostModel.of(context).postData.comments;

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: ExpansionTile(
        leading: Icon(Icons.comment),
        trailing: Text(comments.length.toString()),
        title: Text("Коммертарии"),
        children: List<Widget>.generate(
          comments.length,
          (int index) => _SingleComment(
            key: ValueKey("${CommentsListKeyPrefix.singleComment} $index"),
            index: index,
            commentData: this.params[index]
          ),
        ),
      ),
    );
  }
}

class _SingleComment extends StatelessWidget {
  final int index;
  final commentData;

  const _SingleComment({Key key, @required this.index,  @required this.commentData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final CommentModel commentData = params[index];
        //InheritedPostModel.of(context).postData.comments[index];
    var date = new DateFormat('dd.MM.yy HH:mm');
    UserModel user = new UserModel(id: '1', name: commentData['user_name'], time: date.format(DateFormat('yyyy-MM-dd HH:mm').parse(commentData['time_comment'])),email: '', image: '', followers: null, joined: null, posts: null);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          UserDetailsWithFollow(
            key: ValueKey("${CommentsListKeyPrefix.commentUser} $index"),
            userData: user
          ),
          Container(
            //padding: new EdgeInsets.only(left: 0.0, bottom: 0, top: 10.0),
              margin: new EdgeInsets.only(left: 45.0, bottom: 0, top: 10.0, right: 15.0),

              child: Text(
                commentData['comment'],
                key: ValueKey("${CommentsListKeyPrefix.commentText} $index"),
                textAlign: TextAlign.left,
              )
          ),

//          Text(
//            commentData['time_comment'],
//            key: ValueKey("${CommentsListKeyPrefix.commentText} $index"),
//            textAlign: TextAlign.left,
//          ),


          Divider(
            key: ValueKey("${CommentsListKeyPrefix.commentDivider} $index"),
            color: Colors.black45,
          ),
        ],
      ),
    );
  }
}
