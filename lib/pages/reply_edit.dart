import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
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
  bool? incognito;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as EditReplyArguments;
    _content.text = args.reply.content;
    (incognito == null) ? incognito = args.reply.incognito : incognito ;


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
              validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter comment's reply";
                    }
                    else {
                      return null;
                    }
                  },
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
                if(_formKey.currentState!.validate()) {
                  updateReplyDetail(args.forumID, args.commentID, args.reply.id, _content.text, incognito);
                  Fluttertoast.showToast(msg: "Your reply has been updated");
                  Navigator.pop(context, args.forumID);
                }
              }, 
              child: const Text('Edit Forum'),
            )
          ],
        ),
      )
    );
  }

  updateReplyDetail(forumID, commentID, replyID, content, incognito) async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:3000/forums/$forumID/comments/$commentID/replies/$replyID'),
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

