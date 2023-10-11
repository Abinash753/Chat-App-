import 'package:chat_app/models/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class APIs {
  //this line is used for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;
  //for accessing cloud firebae database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  //to return current user
  static User? get user => auth.currentUser;
  //for  storing self information
  static late ChatUser me;

//for checking if user exists or not
  static Future<bool> userExists() async {
    return (await firestore
            .collection("users")
            .doc(auth.currentUser!.uid)
            .get())
        .exists;
  }

  //for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection("users").doc(user!.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  //for creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
        image: user!.photoURL.toString(),
        name: user!.displayName.toString(),
        about: "I am using chat app",
        createdAt: time,
        id: user!.uid,
        lastActive: time,
        isOnline: false,
        pushToken: "",
        email: user!.email.toString());
    return await firestore
        .collection("users")
        .doc(user!.uid)
        .set(chatUser.toJson());
  }

//for getting all the users form firebase database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection("users")
        .where("id", isNotEqualTo: user!.uid)
        .snapshots();
  }

  //for updating userinformation
  static Future<void> updateUserInfo() async {
    await firestore.collection("users").doc(user!.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }
}
//video 25 9 mit