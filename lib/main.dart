import 'dart:convert';
import 'dart:html';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:github_api/repo.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GitHub API',
      theme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
      home: const HomePage(),
    );
  }
}

// getting the data from the API of github
Future<AllRepo> getRepos() async {
  const String githubUrl = "https://api.github.com/users/laksh29/repos";
  final response = await http.get(Uri.parse(githubUrl));
  if (response.statusCode == 200) {
    // print(response.body);
    return AllRepo.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Failed to fetch repos from GitHub!");
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // use it in Future Builder which has the value of getRepos()
  late Future<AllRepo> futureRepos;

  @override
  void initState() {
    super.initState();
    futureRepos = getRepos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("GitHub API"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder(
            future: futureRepos,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Repo> repoList = [];
                for (int i = 0; i < snapshot.data!.allRepos.length; i++) {
                  repoList.add(Repo(
                    snapshot.data!.allRepos[i].name,
                    snapshot.data!.allRepos[i].description,
                    snapshot.data!.allRepos[i].url,
                  ));
                }
                return ListView(
                  children: repoList
                      .map(
                        (r) => Card(
                          color: Colors.blue[300],
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      r.name,
                                      style: const TextStyle(fontSize: 30.0),
                                    ),
                                  ],
                                ),
                                Text(
                                  r.description,
                                  style: const TextStyle(fontSize: 23.0),
                                ),
                                Text(r.url),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    snapshot.toString(),
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }),
      ),
    );
  }
}
