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
  bool? incognito;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as EditCommentArguments;
    _content.text = args.comment.content;
    (incognito == null) ? incognito = args.comment.incognito : incognito ;


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
            const SizedBox(height: 20),
            TextFormField(
              maxLines: 10,
              keyboardType: TextInputType.multiline,
              controller: _content,
              decoration: const InputDecoration(
                hintText: "Enter Your Content Here",
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text("Incognito"),
              activeColor: Theme.of(context).primaryColor,
              subtitle: const Text("If incognito is on this post will hide author/owner username."),
              value: incognito!, 
              onChanged: (selected){
                setState(() {
                  incognito = !incognito!;
                });
              }
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  updateCommentDetail(args.forumID, args.comment.id, _content.text, incognito);
                });
                Navigator.pop(context, args.forumID);
              }, 
              child: const Text('Edit Comment'),
            )
          ],
        ),
      )
    );
  }

  updateCommentDetail(forumID, commentID, content, incognito) async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:3000/forums/$forumID/comments/$commentID'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'content': content,
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

