// takes only name, description and url from allRepo
class Repo {
  String name;
  String description;
  String url;

  Repo(this.name, this.description, this.url);

  factory Repo.fromJson(Map<String, dynamic> json) {
    return Repo(
      json['name'],
      json['description'],
      json["html_url"],
    );
  }
}

// takes all the repos and passes each repo to Repo with parameters name, discription and URL
class AllRepo {
  List<Repo> allRepos;

  AllRepo(this.allRepos);

  factory AllRepo.fromJson(List<dynamic> json) {
    // allRepos is the List which containes key:value of all the repositories
    List<Repo> allRepos;
    allRepos = json.map((e) => Repo.fromJson(e)).toList();
    return AllRepo(allRepos);
  }
}
