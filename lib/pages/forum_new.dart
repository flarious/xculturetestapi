
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class NewForumPage extends StatefulWidget {
  const NewForumPage({ Key? key }) : super(key: key);
  @override
  _NewForumPageState createState() => _NewForumPageState();
}
class _NewForumPageState extends State<NewForumPage> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _subtitle = TextEditingController();
  final TextEditingController _thumbnail = TextEditingController();
  final TextEditingController _content = TextEditingController();
  bool incognito = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            "Post Forum",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 25),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey, 
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(
                    labelText: "Title",
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter forum's title";
                    }
                    else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _subtitle,
                  decoration: const InputDecoration(
                    labelText: "Subtitle",
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter forum's subtitle";
                    }
                    else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _thumbnail,
                  decoration: const InputDecoration(
                    labelText: "Upload Forum Thumbnail",
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter forum's thumbnail url";
                    }
                    else {
                      return null;
                    }
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: const [
                    /* const */ Text("Add Tags"),
                    /* const */ SizedBox(width: 20),
                    /*
                    FindDropdown(
                      items: tags,
                      onChanged: (item) {
                        setState(() {
                          if(!arr.contains(item)){
                            arr.add(item.toString());
                            print(arr);
                          }
                        });
                      },
                      // ignore: deprecated_member_use
                      searchHint: "Search Here",
                      backgroundColor: Colors.white,
                    ),
                    */
                  ],
                ),
                const SizedBox(height: 20),
                /*
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: arr.map((e) => Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Chip(
                      label: Text(e),
                      deleteIcon: const Icon(Icons.clear),
                      onDeleted: () {
                        setState(() {
                          arr.remove(e);
                        });
                      },
                    ),
                  )).toList(),
                ),
                */
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
                      return "Please enter forum's content";
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
                  value: incognito, 
                  onChanged: (selected){
                    setState(() {
                      incognito = !incognito;
                    });
                  }
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(350, 50),
                  ),
                  onPressed: (){
                    if (_formKey.currentState!.validate()) {
                      sendForumDetail(_title.text, _subtitle.text, _thumbnail.text, _content.text, incognito);
                      Fluttertoast.showToast(msg: "Your post have been created.");
                      Future.delayed(const Duration(milliseconds: 1), () {
                        Navigator.pop(context);
                      });
                    }
                  }, 
                  child: const Text("Post Now")
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
  sendForumDetail(String title, String subtitle, String thumbnailUrl, String content, bool isSwitched) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/forums'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'title': title,
        'subtitle': subtitle,
        'thumbnail': thumbnailUrl,
        'content': content,
        'incognito': isSwitched,
      }),
    );
    if (response.statusCode == 201) {
    }
    else {
      throw Exception("Failed to post the forum");
    }
  }
}
