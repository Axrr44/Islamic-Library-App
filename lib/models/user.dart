class User {

   String? id;
   String? image;
   String? token;

  User({required this.id,required this.image, required this.token});

  User.fromMap(Map<String, dynamic> data) {
    id = data['id'];
    image = data['image'];
    token = data['token'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image': image,
      'token': token,
    };
  }
}