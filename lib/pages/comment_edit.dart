import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../arguments.dart';

class EditCommentPage extends StatefulWidget {
  const EditCommentPage({ Key? key }) : super(key: key);

  @override
  _EditCommentPageState createState() => _EditCommentPageState();
}

class _EditCommentPageState extends State<EditCommentPage> {
  final TextEditingController _content = TextEditingController();
  final TextEditingController _author = TextEditingController();
  bool? _incognito;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as EditCommentArguments;
    _author.text = args.comment.author;
    _content.text = args.comment.content;
    (_incognito == null) ? _incognito = args.comment.incognito : _incognito ;


   return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Edit Comment",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25),
          ),
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, args.forumID);
          return false;
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _author,
            ),
            TextField(
              controller: _content,
            ),
            Switch(
              value: _incognito!, 
              onChanged: (value) {
                setState(() {
                  _incognito = value;
                });
              }
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  updateCommentDetail(args.forumID, args.comment.id, _author.text, _content.text, _incognito);
                });
                Navigator.pop(context, args.forumID);
              }, 
              child: const Text('Edit Forum'),
            )
          ],
        ),
      )
    );
  }

  updateCommentDetail(forumID, commentID, author, content, incognito) async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:3000/forums/$forumID/comments/$commentID'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'content': content,
        'author': author,
        'incognito': incognito,
      }),
    );

    if (response.statusCode == 200) {

    }
    else {
      throw Exception(response.statusCode);
    }
  }
}

