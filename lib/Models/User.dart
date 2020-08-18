//Designed to be light weight and for simple tasks, where all the user data isn't required - Might need a better name
class UserMini {
  final String uid;

  UserMini({this.uid});
}

class User {
  final String uid;
  final String email;
  final String username;
  final String profileImage;
  final int memoryCount;
  final bool showHelp;

  User({this.uid, this.email, this.username, this.profileImage, this.memoryCount, this.showHelp});
}

class UserSettings {

  final String uid;
  final bool notifications;
  final bool lightDarkMode;
  final bool visibility;
  final bool feedback;
  final bool showHelp;

  UserSettings({this.uid, this.notifications, this.lightDarkMode, this.visibility, this.feedback, this.showHelp});
}