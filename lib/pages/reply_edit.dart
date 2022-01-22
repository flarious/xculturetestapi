import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../arguments.dart';

class EditReplyPage extends StatefulWidget {
  const EditReplyPage({ Key? key }) : super(key: key);

  @override
  _EditReplyPageState createState() => _EditReplyPageState();
}

class _EditReplyPageState extends State<EditReplyPage> {
  final TextEditingController _content = TextEditingController();
  final TextEditingController _author = TextEditingController();
  bool? _incognito;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as EditReplyArguments;
    _author.text = args.reply.author;
    _content.text = args.reply.content;
    (_incognito == null) ? _incognito = args.reply.incognito : _incognito ;


   return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Edit Reply",
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
                  updateReplyDetail(args.forumID, args.commentID, args.reply.id, _author.text, _content.text, _incognito);
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

  updateReplyDetail(forumID, commentID, replyID, author, content, incognito) async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:3000/forums/$forumID/comments/$commentID/replies/$replyID'),
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

