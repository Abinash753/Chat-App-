import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//card to represent a single user in home screen
class ChatUserCart extends StatefulWidget {
  final ChatUser user;
  const ChatUserCart({super.key, required this.user});

  @override
  State<ChatUserCart> createState() => _ChatUserCartState();
}

class _ChatUserCartState extends State<ChatUserCart> {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.white,
      elevation: 0.9,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: InkWell(
        onTap: () {},
        child: ListTile(
            //user profile screen
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: CachedNetworkImage(
                width: 55,
                height: 55,
                imageUrl: widget.user.image,
                errorWidget: (context, url, error) => const CircleAvatar(
                  child: Icon(CupertinoIcons.person),
                ),
              ),
            ),

            //username
            title: Text(widget.user.name),
            //last message of the conversation
            subtitle: Text(
              widget.user.about,
              maxLines: 1,
            ),
            //last message time
            trailing: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                  color: Colors.greenAccent.shade400,
                  borderRadius: BorderRadius.circular(10)),
            )
            // Text(
            //   widget.user.lastActive,
            //   style: const TextStyle(color: Colors.black54),
            //   maxLines: 1,
            // ),
            ),
      ),
    );
  }
}

//22 video dekhi baki