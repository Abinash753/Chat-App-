import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//view profile screen to view profile of user
class ViewProfilePage extends StatefulWidget {
  final ChatUser user;
  const ViewProfilePage({super.key, required this.user});

  @override
  State<ViewProfilePage> createState() => _ViewProfilePageState();
}

class _ViewProfilePageState extends State<ViewProfilePage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //for hinding keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.user.name,
          ),
          backgroundColor: Colors.grey,
        ),
        //logout floating button
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Joined on: ",
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 17),
            ),
            const SizedBox(
              width: 5,
            ),
            //user about
            Text(
              MyDateUtil.getLastMessageTime(
                  context: context,
                  time: widget.user.createdAt,
                  showYear: true),
              style: const TextStyle(color: Colors.black, fontSize: 18),
            ),
          ],
        ),

        //body
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 33,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 40,
                ),
                //user profile picture
                ClipRRect(
                  borderRadius: BorderRadius.circular(72),
                  child: CachedNetworkImage(
                    width: 140,
                    height: 140,
                    fit: BoxFit.fill,
                    imageUrl: widget.user.image,
                    errorWidget: (context, url, error) => const CircleAvatar(
                      child: Icon(CupertinoIcons.person),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                //user email address
                Center(
                  child: Text(
                    widget.user.email,
                    style: const TextStyle(color: Colors.black87, fontSize: 20),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "About: ",
                      style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 17),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    //user about
                    Text(
                      widget.user.about,
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
