import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/api.dart';
import 'package:chat_app/helper/dialogs.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';

import '../models/message.dart';

//for showing single message details
class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});
  final Message message;

  @override
  State<MessageCard> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user?.uid == widget.message.fromId;
    return InkWell(
      onLongPress: () {
        _showBottonSheet(isMe);
      },
      child: isMe ? _greenMessage() : _blueMessage(),
    );
  }

  //sender or another user message
  Widget _blueMessage() {
// update last read message if sender and receiver are different
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image ? 5 : 7),
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 108, 113, 108),
              //making borders curved
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              border: Border.all(color: const Color.fromARGB(255, 54, 203, 59)),
            ),
            //show text
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: const TextStyle(color: Colors.white),
                  )
                :
                //show image
                ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      width: 14,
                      height: 15,
                      imageUrl: widget.message.msg,
                      placeholder: ((context, url) => const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                            ),
                          )),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.image, size: 70),
                    ),
                  ),
          ),
        ),
        //message time
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text(
            MyDateUtil.getFormattedTime(
                context: context, time: widget.message.sent),
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        ),
      ],
    );
  }

  //our or user message
  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //message time
        Row(
          children: [
            const SizedBox(
              width: 9,
            ),
            //double tick blue icon for message read
            if (widget.message.read.isNotEmpty)
              const Icon(
                Icons.done_all_rounded,
                color: Colors.blue,
                size: 22,
              ),

            //for adding some space
            const SizedBox(
              width: 2,
            ),

            //sent time
            Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          ],
        ),
        //message content
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
            padding: EdgeInsets.all(widget.message.type == Type.image ? 3 : 5),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
              border: Border.all(color: Colors.black),
            ),
            child: //show text
                widget.message.type == Type.text
                    ? Text(
                        widget.message.msg,
                        style: const TextStyle(color: Colors.white),
                      )
                    :
                    //show image
                    ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          placeholder: (context, url) => const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                            ),
                          ),
                          imageUrl: widget.message.msg,
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.image, size: 70),
                        ),
                      ),
          ),
        ),
      ],
    );
  }

//bottom sheet for modifying message details
  void _showBottonSheet(bool isMe) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              //
              Container(
                height: 6,
                margin:
                    const EdgeInsets.symmetric(horizontal: 90, vertical: 15),
                decoration: BoxDecoration(
                    color: Colors.grey, borderRadius: BorderRadius.circular(8)),
              ),
              widget.message.type == Type.text
                  ? _OptionItem(
                      //copy option
                      icon: const Icon(
                        Icons.copy_all_rounded,
                        color: Colors.green,
                        size: 25,
                      ),
                      name: "Copy Text",
                      onTap: () async {
                        await Clipboard.setData(
                                ClipboardData(text: widget.message.msg))
                            .then((value) {
                          //for hiding buttonsheet
                          Navigator.pop(context);
                          Dialogs.showSnackbar(context, "Text Copied");
                        });
                      })
                  : _OptionItem(
                      //save option
                      icon: const Icon(
                        Icons.download_done,
                        color: Colors.green,
                        size: 25,
                      ),
                      name: "Save Image",
                      onTap: () async {
                        try {
                          await GallerySaver.saveImage(widget.message.msg,
                                  albumName: "Chat App Images")
                              .then((success) {
                            //for hiding buttonsheet
                            Navigator.pop(context);
                            if (success != null && success) {
                              Dialogs.showSnackbar(
                                  context, "Image Saved to Gallery");
                            }
                          });
                        } catch (e) {
                          print("Error while saving image $e");
                        }
                      }),
              //separator or divider
              if (isMe)
                const Divider(
                  color: Colors.black45,
                  endIndent: 15,
                  indent: 10,
                ),

              //edit option
              if (widget.message.type == Type.text && isMe)
                _OptionItem(
                    icon: const Icon(
                      Icons.edit,
                      size: 25,
                      color: Colors.green,
                    ),
                    name: "Edit Message",
                    onTap: () {
                      //for hiding buttonsheet
                      Navigator.pop(context);
                      _showMessageUpdateDialog();
                    }),
              //delete option
              if (isMe)
                _OptionItem(
                    icon: const Icon(
                      Icons.delete_forever,
                      color: Colors.red,
                      size: 25,
                    ),
                    name: "Delete Message",
                    onTap: () {
                      APIs.deleteMessage(widget.message).then((value) {
                        ///for hiding bottom sheet
                        Navigator.pop(context);
                      });
                    }),
              //separator or divider
              const Divider(
                color: Colors.black45,
                endIndent: 15,
                indent: 10,
              ),
              //sent time
              _OptionItem(
                  icon: const Icon(
                    Icons.remove_red_eye,
                    color: Colors.blue,
                    size: 26,
                  ),
                  name:
                      "Sent At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}",
                  onTap: () {}),
              //read time
              _OptionItem(
                  icon: const Icon(
                    Icons.remove_red_eye,
                    color: Colors.red,
                  ),
                  name: widget.message.read.isEmpty
                      ? "Read At: Not Seen yet"
                      : "Reat At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}",
                  onTap: () {}),
            ],
          );
        });
  }

  //dialog for updating message
  void _showMessageUpdateDialog() {
    String updatedMsg = widget.message.msg;
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 25, right: 25, top: 20, bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              //title of the dialogbox
              title: Row(
                children: [
                  Icon(
                    Icons.message,
                    color: Colors.red,
                    size: 30,
                  ),
                  const Text("  Update Message"),
                ],
              ),
              //content of the dialog box
              content: TextFormField(
                initialValue: updatedMsg,
                maxLines: null,
                onChanged: (value) => updatedMsg = value,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
              ),

              actions: [
                //cancle button
                MaterialButton(
                  onPressed: () {
                    //hide alert dialog
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Cancle",
                    style: TextStyle(color: Colors.red, fontSize: 17),
                  ),
                ),
                //update button
                MaterialButton(
                  onPressed: () {
                    //hide alert dialog
                    Navigator.pop(context);
                    APIs.updateMessage(widget.message, updatedMsg);
                  },
                  child: const Text(
                    "Update",
                    style: TextStyle(color: Colors.green, fontSize: 17),
                  ),
                ),
              ],
            ));
  }
}

// custom operation card (for copy, edit, delete .....)
class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  const _OptionItem({
    required this.icon,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 20,
          top: 5,
          bottom: 10,
        ),
        child: Row(
          children: [
            icon,
            Flexible(
              child: Text(
                "$name",
                style: const TextStyle(
                    fontSize: 16, color: Colors.black87, letterSpacing: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
