import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/api.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/pages/view_profile_page.dart';
import 'package:chat_app/widgets/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatPage extends StatefulWidget {
  final ChatUser user;
  ChatPage({super.key, required this.user});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  //to store messages
  List<Message> _list = [];
  //for handling messages text changes
  final _textController = TextEditingController();
  //_showEmoji -- for storing value of showing or hiding emoji
  //isUploading  for checking if image is uploading or not
  bool _showEmoji = false, _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //given code hide the text field when we click outside of the keypad
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          //if emojis are shown & back button is pressed then hide emojis
          //or else simple close current screen on back button click
          onWillPop: () {
            if (_showEmoji) {
              setState(() {
                _showEmoji = !_showEmoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            backgroundColor: Color.fromARGB(255, 108, 127, 138),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: APIs.getAllMessages(widget.user),
                    builder: (context, snapshot) {
                      //switch case
                      switch (snapshot.connectionState) {
                        //if data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const Center(
                            child: SizedBox(),
                          );
                        //if same of all data in loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
                          //
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => Message.fromJson(e.data()))
                                  .toList() ??
                              [];

                          if (_list.isNotEmpty) {
                            return ListView.builder(
                              reverse: true,
                              padding: const EdgeInsets.only(top: 5),
                              physics: const BouncingScrollPhysics(),
                              itemCount: _list.length,
                              itemBuilder: (context, index) {
                                return MessageCard(
                                  message: _list[index],
                                );
                              },
                            );
                          } else {
                            return const Center(
                              child: Text(
                                "Say Hi👋🏼 ",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            );
                          }
                      }
                    },
                  ),
                ),
                //progress indicator for showing uploading
                if (_isUploading)
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                _chatInput(),
                //shows emojis on keyboard emoji button click & 5vice versa
                if (_showEmoji)
                  SizedBox(
                    height: 250,
                    child: EmojiPicker(
                      onBackspacePressed: () {},
                      textEditingController: _textController,
                      config: Config(
                        bgColor: Color.fromARGB(255, 31, 132, 186),
                        columns: 7,
                        emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                        verticalSpacing: 0,
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  //
  Widget _appBar() {
    return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ViewProfilePage(user: widget.user)),
          );
        },
        child: StreamBuilder(
            stream: APIs.getUserInfo(widget.user),
            builder: (context, snapshot) {
              //
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

              return Row(
                children: [
                  //back icon
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.blue,
                    ),
                  ),
                  //profile picture
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: CachedNetworkImage(
                      width: 50,
                      height: 50,
                      imageUrl:
                          list.isNotEmpty ? list[0].image : widget.user.image,
                      errorWidget: (context, url, error) => const CircleAvatar(
                        child: Icon(CupertinoIcons.person),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 11,
                  ),
                  //username & last seen time
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //user name
                      Text(
                        list.isNotEmpty ? list[0].name : widget.user.name,
                        style: const TextStyle(
                            fontSize: 17,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      //last seen time of user
                      Text(
                        list.isNotEmpty
                            ? list[0].isOnline
                                ? "Online"
                                : MyDateUtil.getLastsActiveTime(
                                    context: context,
                                    lastActive: list[0].lastActive)
                            : MyDateUtil.getLastsActiveTime(
                                context: context,
                                lastActive: widget.user.lastActive),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      )
                    ],
                  ),
                ],
              );
            }));
  }

//bottom chat input field
  Widget _chatInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  //emoji button
                  IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        _showEmoji = !_showEmoji;
                      });
                    },
                    icon: const Icon(
                      Icons.emoji_emotions,
                      color: Colors.red,
                    ),
                  ),
                  //textfield
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      onTap: () {
                        if (_showEmoji)
                          setState(() {
                            _showEmoji = !_showEmoji;
                          });
                      },
                      maxLength: null,
                      decoration: const InputDecoration(
                          hintText: "Type something..",
                          hintStyle: TextStyle(
                            color: Colors.black45,
                          ),
                          border: InputBorder.none),
                    ),
                  ),

                  //pick image form gallery button
                  IconButton(
                    onPressed: () async {
                      //
                      final ImagePicker picker = ImagePicker();
                      //picking multiple images
                      final List<XFile> images =
                          await picker.pickMultiImage(imageQuality: 60);
                      //uploading & sending image one by one
                      for (var i in images) {
                        print("Image path:${i.path}");
                        setState(
                          () => _isUploading = true,
                        );

                        await APIs.sendChatImage(widget.user, File(i.path));
                        setState(
                          () => _isUploading = false,
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.image,
                      color: Colors.red,
                    ),
                  ),
                  //camera button
                  IconButton(
                    onPressed: () async {
                      //
                      final ImagePicker picker = ImagePicker();
                      //pick an image
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 60);
                      if (image != null) {
                        setState(
                          () => _isUploading = true,
                        );
                        await APIs.sendChatImage(widget.user, File(image.path));
                        setState(
                          () => _isUploading = true,
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(
                    width: 3,
                  ),
                ],
              ),
            ),
          ),
          //button
          MaterialButton(
            minWidth: 0,
            padding:
                const EdgeInsets.only(top: 8, bottom: 8, right: 5, left: 10),
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                if (_list.isEmpty) {
                  //on  first message (add user to new_user collection of chat user)
                  APIs.sendFirstMessage(
                      widget.user, _textController.text, Type.text);
                } else {
                  //simply send message
                  APIs.sendMessage(
                      widget.user, _textController.text, Type.text);
                }
                _textController.text = "";
              }
            },
            color: Colors.black,
            shape: const CircleBorder(),
            child: const Icon(
              Icons.send,
              color: Colors.green,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
