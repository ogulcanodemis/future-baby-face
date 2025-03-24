class UserImage {
  final String path;
  final bool isParent1;

  UserImage({required this.path, required this.isParent1});

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'isParent1': isParent1,
    };
  }

  factory UserImage.fromJson(Map<String, dynamic> json) {
    return UserImage(
      path: json['path'],
      isParent1: json['isParent1'],
    );
  }
} 