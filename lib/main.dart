import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'quiz.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.white),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Quiz quiz;
  List<Results> results;

  Future<void> fetchQuestions() async {
    var res = await http.get("https://opentdb.com/api.php?amount=20");
    var decRes = jsonDecode(res.body);
    quiz = Quiz.fromJson(decRes);
    results = quiz.results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz App"),
        elevation: 0.0,
      ),
      body: RefreshIndicator(
        onRefresh: fetchQuestions,
        child: FutureBuilder(
          future: fetchQuestions(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Text("Press button to start.");

              case ConnectionState.active:

              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(),
                );

              case ConnectionState.done:
                if (snapshot.hasError) {
                  return errorData(snapshot);
                }
                return questionsList();
            }
            return null;
          },
        ),
      ),
    );
  }

  Padding errorData(AsyncSnapshot snapshot) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("Error: ${snapshot.error}"),
          SizedBox(
            height: 15,
          ),
          RaisedButton(
            onPressed: () {
              fetchQuestions();
              setState(() {});
            },
            child: Text("Try Again"),
          )
        ],
      ),
    );
  }

  ListView questionsList() {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return Card(
          color: Colors.white,
          elevation: 0.0,
          child: ExpansionTile(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  results[index].question,
                  style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                ),
                FittedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      FilterChip(
                          backgroundColor: Colors.grey[100],
                          label: Text(results[index].category),
                          onSelected: (b) {}),
                      SizedBox(
                        width: 8,
                      ),
                      FilterChip(
                          backgroundColor: Colors.grey[100],
                          label: Text(results[index].difficulty),
                          onSelected: (b) {})
                    ],
                  ),
                )
              ],
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.grey[100],
              child: Text(results[index].type.startsWith("m") ? "M" : "B"),
            ),
            children: results[index]
                .allAnswers
                .map((m) => AnswerWidget(results, index, m))
                .toList(),
          ),
        );
      },
    );
  }
}

class AnswerWidget extends StatefulWidget {
  final List<Results> results;
  final int index;
  final String m;

  AnswerWidget(this.results, this.index, this.m);

  @override
  _AnswerWidgetState createState() => _AnswerWidgetState();
}

class _AnswerWidgetState extends State<AnswerWidget> {
  Color c = Colors.black;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        if (this.widget.m == widget.results[widget.index].correctAnswer) {
          c = Colors.green;
        } else {
          c = Colors.red;
        }
        setState(() {});
      },
      title: Text(
        widget.m,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13, color: c, fontWeight: FontWeight.bold),
      ),
    );
  }
}
