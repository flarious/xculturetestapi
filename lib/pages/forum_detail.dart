import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../arguments.dart';
import '../data.dart';

class ForumDetailPage extends StatefulWidget {
  const ForumDetailPage({Key? key}) : super(key: key);

  @override
  _ForumDetailPageState createState() => _ForumDetailPageState();
}

class _ForumDetailPageState extends State<ForumDetailPage> {
  Future<Forum>? fullDetail;

  final TextEditingController _authorComment = TextEditingController();
  final TextEditingController _contentComment = TextEditingController();
  final List<TextEditingController> _authorReplies = [];
  final List<TextEditingController> _contentReplies = [];
  final List<bool> isSwitchedReplies = [];
  bool isSwitchedComment = false;
  bool isSwitchedReply = false;
  
  @override
  Widget build(BuildContext context) {
    final forumDetail = ModalRoute.of(context)!.settings.arguments as Forum;
    fullDetail = getFullDetail(forumDetail.id);

    setState(() {
      forumViewed(forumDetail.id);
    });

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: double.maxFinite,
          width: double.maxFinite,
          child: FutureBuilder<Forum>(
            future: fullDetail,
            builder: (BuildContext context, AsyncSnapshot<Forum> snapshot) {
              if (snapshot.hasData) {
                var dt = DateTime.parse(snapshot.data!.updateDate).toLocal();
                String formattedDate = DateFormat('dd/MM/yyyy – HH:mm a').format(dt);
                
                if (_authorReplies.isEmpty){
                  for (var comment in snapshot.data!.comments) {
                    final TextEditingController _authorReply = TextEditingController();
                    final TextEditingController _contentReply = TextEditingController();

                    _authorReplies.add(_authorReply);
                    _contentReplies.add(_contentReply);
                    isSwitchedReplies.add(isSwitchedReply);
                  }
                }

                return Stack(
                  children: [
                    Positioned(
                      right: 0,
                      left: 0,
                      child: Container(
                        height: 300,
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(snapshot.data!.thumbnail),
                            fit: BoxFit.cover
                          )
                        ),
                      )
                    ),
                    Positioned(
                      top: 40,
                      left: 20,
                      child: Row(
                        children: [
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.arrow_back))
                        ],
                      )
                    ),
                    Positioned(
                      top: 280,
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, top: 20),
                        width: MediaQuery.of(context).size.width,
                        height: 1200,
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            )),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(snapshot.data!.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 23)
                            ),
                            const SizedBox(height: 10),
                            Text(snapshot.data!.subtitle,
                                style: const TextStyle(fontSize: 15)),
                            const SizedBox(height: 10),
                            const Text("Tags Area"),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.account_circle),
                                const SizedBox(width: 5),
                                (snapshot.data!.incognito == false) ? Text(snapshot.data!.author) : const Text("Author")
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Text(formattedDate),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Container(
                              height: 1.0,
                              width: 400,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 10),
                            const Text("Description",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            Text(snapshot.data!.content),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      forumFavorited(snapshot.data!.id);
                                    });
                                  }, 
                                  child: const Text("Favorite")
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      forumUnfavorited(snapshot.data!.id);
                                    });
                                  }, 
                                  child: const Text("Unfavorite")
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, 'editForumPage', arguments: snapshot.data).then(refreshPage);
                                  }, 
                                  child: const Text("Edit forum")
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            const Text("Comments",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold)
                            ),
                            TextField(
                              controller: _authorComment,
                              decoration: const InputDecoration(hintText: "Author"),
                            ),
                            TextField(
                              controller: _contentComment,
                              decoration: const InputDecoration(hintText: "Content"),
                            ),
                            Row(
                              children: [
                                Switch(
                                  value: isSwitchedComment, 
                                  onChanged: (value) {
                                    setState(() {
                                      isSwitchedComment = value;
                                    });
                                  }
                                ),
                                const Spacer(),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      sendCommentDetail(snapshot.data!.id, _authorComment.text, _contentComment.text, isSwitchedComment);
                                      refreshPage(snapshot.data!.id);
                                    });
                                  }, 
                                  child: const Text("Post Comment")
                                ),
                              ],
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: snapshot.data!.comments.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      Card(
                                        elevation: 5,
                                        child: ListTile(
                                          title: (snapshot.data!.comments[index].incognito == false) ? Text(snapshot.data!.comments[index].author) : const Text("Author"),
                                          subtitle: Text(snapshot.data!.comments[index].content),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    commentFavorited(snapshot.data!.id, snapshot.data!.comments[index].id);
                                                  });
                                                }, 
                                                icon: const Icon(Icons.favorite),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    commentUnfavorited(snapshot.data!.id, snapshot.data!.comments[index].id);
                                                  });
                                                }, 
                                                icon: const Icon(Icons.favorite_border),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    Navigator.pushNamed(context, 'editCommentPage', 
                                                    arguments: EditCommentArguments(
                                                      forumID: snapshot.data!.id, 
                                                      comment: snapshot.data!.comments[index]
                                                    )).then(refreshPage);
                                                  });
                                                }, 
                                                icon: const Icon(Icons.edit),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      TextField(
                                        controller: _authorReplies[index],
                                        decoration: const InputDecoration(hintText: "Author"),
                                      ),
                                      TextField(
                                        controller: _contentReplies[index],
                                        decoration: const InputDecoration(hintText: "Content"),
                                      ),
                                      Row(
                                        children: [
                                          Switch(
                                            value: isSwitchedReplies[index], 
                                            onChanged: (value) {
                                              setState(() {
                                                isSwitchedReplies[index] = value;
                                              });
                                            }
                                          ),
                                          const Spacer(),
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                sendReplyDetail(snapshot.data!.id, snapshot.data!.comments[index].id, _authorReplies[index].text, _contentReplies[index].text, isSwitchedReplies[index]);
                                                refreshPage(snapshot.data!.id);
                                              });
                                            }, 
                                            child: const Text("Post Reply")
                                          ),
                                        ],
                                      ),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: const ScrollPhysics(),
                                        itemCount: snapshot.data!.comments[index].replies.length,
                                        itemBuilder: (context, index2) {
                                          return Column(
                                            children: [
                                              Card(
                                                elevation: 5,
                                                margin: const EdgeInsets.fromLTRB(30.0, 0.0, 4.0, 4.0),
                                                child: ListTile(
                                                  title: (snapshot.data!.comments[index].replies[index2].incognito == false) ? Text(snapshot.data!.comments[index].replies[index2].author) : const Text("Author"),
                                                  subtitle: Text(snapshot.data!.comments[index].replies[index2].content),
                                                  trailing: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            replyFavorited(snapshot.data!.id, snapshot.data!.comments[index].id, snapshot.data!.comments[index].replies[index2].id);
                                                          });
                                                        }, 
                                                        icon: const Icon(Icons.favorite),
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            replyUnfavorited(snapshot.data!.id, snapshot.data!.comments[index].id, snapshot.data!.comments[index].replies[index2].id);
                                                          });
                                                        }, 
                                                        icon: const Icon(Icons.favorite_border),
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            Navigator.pushNamed(context, 'editReplyPage', 
                                                            arguments: EditReplyArguments(
                                                              forumID: snapshot.data!.id, 
                                                              commentID: snapshot.data!.comments[index].id,
                                                              reply: snapshot.data!.comments[index].replies[index2]
                                                            )).then(refreshPage);
                                                          });
                                                        }, 
                                                        icon: const Icon(Icons.edit),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                      )
                                    ],
                                  );
                                }
                              )
                            )
                          ],
                        ),
                      )
                    )
                  ],
                );
              } else {
                return const CircularProgressIndicator();
              }
            }
          )
        ),
      ),
    );
  }

  FutureOr refreshPage(forumID) {
    setState(() {
      fullDetail = getFullDetail(forumID);
    });
  }

  Future<Forum> getFullDetail(forumID) async {
    final response =
        await http.get(Uri.parse('http://10.0.2.2:3000/forums/$forumID'));

    if (response.statusCode == 200) {
      return Forum.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Error");
    }
  }
  
  forumViewed(forumID) async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:3000/forums/$forumID/viewed'));
  
    if (response.statusCode == 200) {
    }
    else {
      throw Exception("Error");
    }
  }

  forumFavorited(forumID) async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:3000/forums/$forumID/favorite')
    );

    if (response.statusCode == 200) {

    }
    else {
      throw Exception("Error");
    }
  }

  forumUnfavorited(forumID) async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:3000/forums/$forumID/unfavorite')
    );

    if (response.statusCode == 200) {

    }
    else {
      throw Exception("Error");
    }
  }

  sendCommentDetail(forumID, author, content, incognito) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/forums/$forumID/comments'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'author': author,
        'content': content,
        'incognito': incognito,
      }),
    );

    if (response.statusCode == 201) {

    }
    else {
      throw Exception(response.statusCode);
    }
  }

  commentFavorited(forumID, commentID) async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:3000/forums/$forumID/comments/$commentID/favorite')
    );

    if (response.statusCode == 200) {

    }
    else {
      throw Exception(response.statusCode);
    }
  }

  commentUnfavorited(forumID, commentID) async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:3000/forums/$forumID/comments/$commentID/unfavorite')
    );

    if (response.statusCode == 200) {

    }
    else {
      throw Exception(response.statusCode);
    }
  }

  sendReplyDetail(forumID, commentID, author, content, incognito) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/forums/$forumID/comments/$commentID/replies'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'author': author,
        'content': content,
        'incognito': incognito,
      }),
    );

    if (response.statusCode == 201) {

    }
    else {
      throw Exception(response.statusCode);
    }
  }

  replyFavorited(forumID, commentID, replyID) async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:3000/forums/$forumID/comments/$commentID/replies/$replyID/favorite')
    );

    if (response.statusCode == 200) {

    }
    else {
      throw Exception(response.statusCode);
    }
  }

  replyUnfavorited(forumID, commentID, replyID) async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:3000/forums/$forumID/comments/$commentID/replies/$replyID/unfavorite')
    );

    if (response.statusCode == 200) {

    }
    else {
      throw Exception(response.statusCode);
    }
  }
}
