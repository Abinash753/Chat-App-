import 'dart:convert';
import 'dart:io';

import 'package:chat_app/models/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';

import '../models/message.dart';

class APIs {
  //this line is used for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;
  //for accessing cloud firebae database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  //for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  //for accessing firebase messaging (Push notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;
  //for getting firebase messaging token
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((token) {
      if (token != null) {
        me.pushToken = token;
        print("push token $token");
      }
    });
    //for handing foreground messages
    //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //     print('Got a message whilst in the foreground!');
    //     print('Message data: ${message.data}');

    //     if (message.notification != null) {
    //       print('Message also contained a notification: ${message.notification}');
    //     }
    //   });
  }

  //for sending push notification
  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": chatUser.name,
          "body": msg,
          "android_channel_id": "chats",
        },
        "data": {
          "some_data": "User Id: ${me.id}",
        },
      };
      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            HttpHeaders.authorizationHeader:
                "key=AAAA-BAQBWw:APA91bEZhwGW8HXzKB04dP8VfBRGbFb22cQuHNKAQDzM5VOU8FWQd7ckskJ-Ja-oBrF22QHdfedpD5cIMQPT2T8x_SntGEQY8I1Dtb9F7SClqGGfIgMx4p3KNI_-_TkQ0G36WLReAII9"
          },
          body: jsonEncode(body));
      var url = Uri.https('example.com', 'whatsit/create');

      print('Response status: ${res.statusCode}');
      print('Response body: ${res.body}');
    } catch (e) {
      print("\nsendPushNotification: $e");
    }
  }

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

  //for adding an chat user for our conversition
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection("users")
        .where("email", isEqualTo: email)
        .get();
    if (data.docs.isNotEmpty && data.docs.first.id != user!.uid) {
      //user exists
      print("User exits-------${data.docs.first.id}");
      firestore
          .collection("users")
          .doc(user!.uid)
          .collection("new_users")
          .doc(data.docs.first.id)
          .set({});
      return true;
    } else {
      //user doesnot exist
      return false;
    }
  }

  //for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection("users").doc(user!.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();
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

  //for getting id's of known users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection("users")
        .doc(user!.uid)
        .collection("new_users")
        .snapshots();
  }

//for getting all the users form firebase database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    print(userIds);
    return firestore
        .collection("users")
        .where("id", whereIn: userIds)
        .snapshots();
  }

  //for adding an user to my user when first message is sent
  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection("users")
        .doc(chatUser.id)
        .collection("new_users")
        .doc(user!.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }

  //for updating userinformation
  static Future<void> updateUserInfo() async {
    await firestore.collection("users").doc(user!.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  //update profile picture of user
  static Future<void> updateProfilePicture(File file) async {
    //getting image file extension
    final ext = file.path.split(".").last;
    final ref = storage.ref().child("profile_pictures/${user?.uid}.$ext");
    //uploading image
    await ref
        .putFile(
      file,
      SettableMetadata(contentType: 'image/$ext'),
    )
        .then((p0) {
      print("Data transferred:${p0.bytesTransferred / 1000} kb");
    });
    // updating image in firestore database
    me.image = await ref.getDownloadURL();
    await firestore.collection("users").doc(user!.uid).update({
      'image': me.name,
    });
  }

// for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection("users")
        .where("id", isEqualTo: chatUser.id)
        .snapshots();
  }

// update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnlne) async {
    firestore.collection("users").doc(user!.uid).update({
      "is_online": isOnlne,
      "last_active": DateTime.now().millisecondsSinceEpoch.toString(),
      "push_token": me.pushToken,
    });
  }

  /// ********************** Chat screen related APIs ***************

  //useful for getting conversation id
  static String getConversationId(String id) =>
      user!.uid.hashCode <= id.hashCode
          ? "${user!.uid}_$id"
          : "${id}_${user!.uid}";

  //for getting all the users form firebase database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection("chats/${getConversationId(user.id)}/messages/")
        .orderBy("sent", descending: true)
        .snapshots();
  }

  //for sending message
  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    //message sending time (also used as id)
    final time = DateTime.now().microsecondsSinceEpoch.toString();

    //message to send
    final Message message = Message(
        msg: msg,
        toId: chatUser.id,
        read: "",
        type: type,
        sent: time,
        fromId: user!.uid);

    final ref = firestore
        .collection("chats/${getConversationId(chatUser.id)}/messages/");
    await ref.doc(time).set(message.toJson()).then(
          (value) =>
              sendPushNotification(chatUser, type == Type.text ? msg : "image"),
        );
  }

  //update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationId(message.fromId)}/messages/')
        .doc(message.sent)
        .update({"read": DateTime.now().microsecondsSinceEpoch.toString()});
  }

  //get only last message of ta specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection("chats/${getConversationId(user.id)}/messages/")
        .orderBy("sent", descending: true)
        .limit(1)
        .snapshots();
  }

  //send chat image
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    //getting image file extension
    final ext = file.path.split(".").last;
    //storage file ref with path
    final ref = storage.ref().child(
        "images/${getConversationId(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext");

    //uploading image
    await ref
        .putFile(
      file,
      SettableMetadata(contentType: 'image/$ext'),
    )
        .then((p0) {
      print("Data transferred:${p0.bytesTransferred / 1000} kb");
    });
    // updating image in firestore database
    final imageUrl = me.image = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  //delete message
  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection("chats/${getConversationId(message.toId)}/messages/")
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.sent).delete();
    }
  }

  //update message
  static Future<void> updateMessage(Message message, String updatedMsg) async {
    await firestore
        .collection("chats/${getConversationId(message.toId)}/messages/")
        .doc(message.sent)
        .update({"msg": updatedMsg});
  }
}
