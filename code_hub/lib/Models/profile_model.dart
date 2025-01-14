class User {
  String country;
  int lastOnlineTimeSeconds;
  int rating;
  int friendOfCount;
  String titlePhoto;
  String handle;
  String avatar;
  int contribution;
  String organization;
  String rank;
  int maxRating;
  int registrationTimeSeconds;
  String maxRank;

  User({
    required this.country,
    required this.lastOnlineTimeSeconds,
    required this.rating,
    required this.friendOfCount,
    required this.titlePhoto,
    required this.handle,
    required this.avatar,
    required this.contribution,
    required this.organization,
    required this.rank,
    required this.maxRating,
    required this.registrationTimeSeconds,
    required this.maxRank,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      country: json['country'],
      lastOnlineTimeSeconds: json['lastOnlineTimeSeconds'],
      rating: json['rating'],
      friendOfCount: json['friendOfCount'],
      titlePhoto: json['titlePhoto'],
      handle: json['handle'],
      avatar: json['avatar'],
      contribution: json['contribution'],
      organization: json['organization'],
      rank: json['rank'],
      maxRating: json['maxRating'],
      registrationTimeSeconds: json['registrationTimeSeconds'],
      maxRank: json['maxRank'],
    );
  }
}

class Rating {
  int contestId;
  String contestName;
  String handle;
  int rank;
  int ratingUpdateTimeSeconds;
  int oldRating;
  int newRating;

  Rating({
    required this.contestId,
    required this.contestName,
    required this.handle,
    required this.rank,
    required this.ratingUpdateTimeSeconds,
    required this.oldRating,
    required this.newRating,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      contestId: json['contestId'],
      contestName: json['contestName'],
      handle: json['handle'],
      rank: json['rank'],
      ratingUpdateTimeSeconds: json['ratingUpdateTimeSeconds'],
      oldRating: json['oldRating'],
      newRating: json['newRating'],
    );
  }
}

class CodeforcesModel {
  User user;
  List<Rating> ratings;

  CodeforcesModel({
    required this.user,
    required this.ratings,
  });

  factory CodeforcesModel.fromJson(List<dynamic> json) {
    return CodeforcesModel(
      user: User.fromJson(json[0]),
      ratings: (json[1]['ratings'] as List)
          .map((rating) => Rating.fromJson(rating))
          .toList(),
    );
  }
}


class CodechefModel {
  String username;
  String rating;
  int ratingNumber;
  String country;
  String userType;
  String institution;
  String organisation;
  String globalRank;
  String countryRank;
  int maxRank;
  Map<String, dynamic> allRating;

  CodechefModel({
    required this.username,
    required this.rating,
    required this.ratingNumber,
    required this.country,
    required this.userType,
    required this.institution,
    required this.organisation,
    required this.globalRank,
    required this.countryRank,
    required this.maxRank,
    required this.allRating,
  });

  factory CodechefModel.fromJson(Map<String, dynamic> json) {
    return CodechefModel(
      username: json['username'],
      rating: json['rating'],
      ratingNumber: json['rating_number'],
      country: json['country'],
      userType: json['user_type'],
      institution: json['institution'] ?? '',
      organisation: json['organisation'] ?? '',
      globalRank: json['global_rank'],
      countryRank: json['country_rank'],
      maxRank: json['max_rank'],
      allRating: json['all_rating'] ?? {},
    );
  }

  // Method to convert User object to JSON
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'rating': rating,
      'rating_number': ratingNumber,
      'country': country,
      'user_type': userType,
      'institution': institution,
      'organisation': organisation,
      'global_rank': globalRank,
      'country_rank': countryRank,
      'max_rank': maxRank,
      'all_rating': allRating,
    };
  }
}

class LeetcodeModel {
  Data data;

  LeetcodeModel({required this.data});

  factory LeetcodeModel.fromJson(Map<String, dynamic> json) {
    return LeetcodeModel(
      data: Data.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.toJson(),
    };
  }
}

class Data {
  MatchedUser matchedUser;
  UserContestRanking userContestRanking;

  Data({required this.matchedUser, required this.userContestRanking});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      matchedUser: MatchedUser.fromJson(json['matchedUser']),
      userContestRanking: UserContestRanking.fromJson(json['userContestRanking']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matchedUser': matchedUser.toJson(),
      'userContestRanking': userContestRanking.toJson(),
    };
  }
}

class MatchedUser {
  String username;
  Profile profile;
  List<LanguageProblemCount> languageProblemCount;
  SubmitStats submitStats;
  List<dynamic> badges;
  UserCalendar userCalendar;

  MatchedUser({
    required this.username,
    required this.profile,
    required this.languageProblemCount,
    required this.submitStats,
    required this.badges,
    required this.userCalendar,
  });

  factory MatchedUser.fromJson(Map<String, dynamic> json) {
    return MatchedUser(
      username: json['username'],
      profile: Profile.fromJson(json['profile']),
      languageProblemCount: (json['languageProblemCount'] as List)
          .map((e) => LanguageProblemCount.fromJson(e))
          .toList(),
      submitStats: SubmitStats.fromJson(json['submitStats']),
      badges: json['badges'] ?? [],
      userCalendar: UserCalendar.fromJson(json['userCalendar']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'profile': profile.toJson(),
      'languageProblemCount': languageProblemCount.map((e) => e.toJson()).toList(),
      'submitStats': submitStats.toJson(),
      'badges': badges,
      'userCalendar': userCalendar.toJson(),
    };
  }
}

class Profile {
  String userAvatar;

  Profile({required this.userAvatar});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      userAvatar: json['userAvatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userAvatar': userAvatar,
    };
  }
}

class LanguageProblemCount {
  String languageName;
  int problemsSolved;

  LanguageProblemCount({required this.languageName, required this.problemsSolved});

  factory LanguageProblemCount.fromJson(Map<String, dynamic> json) {
    return LanguageProblemCount(
      languageName: json['languageName'],
      problemsSolved: json['problemsSolved'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'languageName': languageName,
      'problemsSolved': problemsSolved,
    };
  }
}

class SubmitStats {
  List<AcSubmissionNum> acSubmissionNum;

  SubmitStats({required this.acSubmissionNum});

  factory SubmitStats.fromJson(Map<String, dynamic> json) {
    return SubmitStats(
      acSubmissionNum: (json['acSubmissionNum'] as List)
          .map((e) => AcSubmissionNum.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'acSubmissionNum': acSubmissionNum.map((e) => e.toJson()).toList(),
    };
  }
}

class AcSubmissionNum {
  String difficulty;
  int count;
  int submissions;

  AcSubmissionNum({required this.difficulty, required this.count, required this.submissions});

  factory AcSubmissionNum.fromJson(Map<String, dynamic> json) {
    return AcSubmissionNum(
      difficulty: json['difficulty'],
      count: json['count'],
      submissions: json['submissions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'difficulty': difficulty,
      'count': count,
      'submissions': submissions,
    };
  }
}

class UserCalendar {
  int streak;
  int totalActiveDays;

  UserCalendar({required this.streak, required this.totalActiveDays});

  factory UserCalendar.fromJson(Map<String, dynamic> json) {
    return UserCalendar(
      streak: json['streak'],
      totalActiveDays: json['totalActiveDays'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'streak': streak,
      'totalActiveDays': totalActiveDays,
    };
  }
}

class UserContestRanking {
  int attendedContestsCount;
  int globalRanking;
  double rating;
  double topPercentage;
  int totalParticipants;

  UserContestRanking({
    required this.attendedContestsCount,
    required this.globalRanking,
    required this.rating,
    required this.topPercentage,
    required this.totalParticipants,
  });

  factory UserContestRanking.fromJson(Map<String, dynamic> json) {
    return UserContestRanking(
      attendedContestsCount: json['attendedContestsCount'],
      globalRanking: json['globalRanking'],
      rating: json['rating'],
      topPercentage: json['topPercentage'],
      totalParticipants: json['totalParticipants'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendedContestsCount': attendedContestsCount,
      'globalRanking': globalRanking,
      'rating': rating,
      'topPercentage': topPercentage,
      'totalParticipants': totalParticipants,
    };
  }
}

