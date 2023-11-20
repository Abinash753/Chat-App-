import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/api.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/widgets/Dialogs/profile_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/message.dart';

//card to represent a single user in home screen
class ChatUserCart extends StatefulWidget {
  final ChatUser user;
  const ChatUserCart({super.key, required this.user});

  @override
  State<ChatUserCart> createState() => _ChatUserCartState();
}

class _ChatUserCartState extends State<ChatUserCart> {
  //last message info (if null --> no message)
  Message? _message;
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
        onTap: () {
          //
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatPage(
                user: widget.user,
              ),
            ),
          );
        },
        child: StreamBuilder(
          stream: APIs.getLastMessage(widget.user),
          builder: (context, snapshot) {
            //
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
            if (list.isNotEmpty) {
              _message = list[0];
            }
            return ListTile(
              //user profile screen
              leading: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => ProfileDialog(
                      user: widget.user,
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: CachedNetworkImage(
                    width: 55,
                    height: 55,
                    imageUrl: Uri.encodeFull(widget.user.image),
                    // imageUrl: widget.user.image,
                    errorWidget: (context, url, error) => const CircleAvatar(
                      child: Icon(CupertinoIcons.person),
                    ),
                  ),
                ),
              ),

              //username
              title: Text(widget.user.name),
              //last message of the conversation
              subtitle: Text(
                _message != null
                    ? _message!.type == Type.image
                        ? "Image"
                        : _message!.msg
                    : widget.user.about,
                maxLines: 1,
              ),
              //last message time
              trailing: _message == null
                  ? null //show nothing when no message is sent
                  : _message!.read.isEmpty && _message!.fromId != APIs.user!.uid
                      ?
                      //show for unread message
                      Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                              color: Colors.greenAccent.shade400,
                              borderRadius: BorderRadius.circular(10)),
                        )
                      //message sent time
                      : Text(
                          MyDateUtil.getLastMessageTime(
                              context: context, time: _message!.sent),
                          style: const TextStyle(color: Colors.black54),
                        ),
              // Text(
              //   widget.user.lastActive,
              //   style: const TextStyle(color: Colors.black54),
              //   maxLines: 1,
              // ),
            );
          },
        ),
      ),
    );
  }
}

//22 video dekhi baki