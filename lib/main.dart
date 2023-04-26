import 'dart:convert';
import 'dart:html';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:github_api/repo.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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

void _redirectToLink(String link) async {
  if (await canLaunchUrl(Uri.parse(link))) {
    await launchUrl(Uri.parse(link));
  } else {
    throw 'Could not launch $link';
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
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("GitHub API $width"),
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
                  for (int j = 0; j < wantRepo.length; j++) {
                    if (wantRepo[j] == snapshot.data!.allRepos[i].name) {
                      repoList.add(Repo(
                        snapshot.data!.allRepos[i].name,
                        snapshot.data!.allRepos[i].description,
                        snapshot.data!.allRepos[i].url,
                      ));
                    }
                  }
                }
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: width > 1093 ? 4 : 3,
                  ),
                  // itemCount: snapshot.data!.allRepos.length,
                  itemCount: repoList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return AspectRatio(
                      aspectRatio: 1,
                      child: GestureDetector(
                        onTap: () => _redirectToLink(repoList[index].url),
                        child: Container(
                          margin: const EdgeInsets.only(right: 20, bottom: 20),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          color: const Color.fromARGB(255, 2, 20, 30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                repoList[index].name,
                                style: const TextStyle(
                                  fontSize: 22,
                                ),
                              ),
                              Text(
                                repoList[index].description.toString(),
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(
                                height: 50.0,
                              ),
                              // Text(repoList[index].url),
                              const Spacer(),
                              IconButton(
                                  onPressed: () {
                                    _redirectToLink(repoList[index].url);
                                  },
                                  icon:
                                      const Icon(Icons.question_mark_outlined))
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
                // ListView(
                //   children: repoList
                //       .map(
                //         (r) => Card(
                //           color: Colors.blue[300],
                //           child: Padding(
                //             padding: const EdgeInsets.all(8.0),
                //             child: Column(
                //               mainAxisAlignment: MainAxisAlignment.start,
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: [
                //                 Row(
                //                   mainAxisAlignment:
                //                       MainAxisAlignment.spaceBetween,
                //                   children: [
                //                     Text(
                //                       r.name,
                //                       style: const TextStyle(fontSize: 30.0),
                //                     ),
                //                   ],
                //                 ),
                //                 Text(
                //                   r.description.toString(),
                //                   style: const TextStyle(fontSize: 23.0),
                //                 ),
                //                 Text(r.url),
                //               ],
                //             ),
                //           ),
                //         ),
                //       )
                //       .toList(),
                // );
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
