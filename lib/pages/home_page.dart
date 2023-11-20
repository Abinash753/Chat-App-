import 'package:chat_app/api/api.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/pages/auth/profile_page.dart';
import 'package:chat_app/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../helper/dialogs.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //stores all the users
  List<ChatUser> _list = [];
  //search list
  final List<ChatUser> _searchList = [];
  //for storing search status
  bool _isSearching = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    APIs.getSelfInfo();
    //for setting user status to active
    APIs.updateActiveStatus(true);

//for updating user cative status according to lifecycle events
//resume  -- active or online
// pause -- inactive or offline
    if (APIs.auth.currentUser != null) {
      SystemChannels.lifecycle.setMessageHandler((message) {
        print("1111111111111111$message");
        if (message.toString().contains("resume")) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains("pause")) {
          APIs.updateActiveStatus(false);
        }
        return Future.value(message);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        //if search is on and  back button is pressed on screen
        // or else simple close current screen on back button click
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: const Icon(
              CupertinoIcons.home,
              color: Colors.black,
            ),
            title: _isSearching
                ? TextField(
                    autofocus: true,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search Email/name",
                    ),
                    style: const TextStyle(fontSize: 18, letterSpacing: 1.2),
                    //when search text changes then updated search list
                    onChanged: (value) {
                      //search logic
                      _searchList.clear();
                      for (var i in _list) {
                        if (i.name
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            i.email
                                .toLowerCase()
                                .contains(value.toLowerCase())) {
                          _searchList.add(i);
                        }
                        setState(() {
                          _searchList;
                        });
                      }
                    },
                  )
                : const Text(
                    "Let's chat",
                  ),
            actions: [
              //search  user icon
              IconButton(
                onPressed: () {
                  setState(() {
                    _isSearching = !_isSearching;
                  });
                },
                icon: Icon(
                  _isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search,
                  color: Colors.black,
                  size: 30,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              //proflie button
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfilePage(
                        user: APIs.me,
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  CupertinoIcons.person,
                  color: Colors.black,
                  size: 30,
                ),
              ),
            ],
            backgroundColor: Colors.grey,
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 25, right: 10),
            child: FloatingActionButton(
              onPressed: () async {
                _addCharUserDialog();
              },
              child: const Icon(Icons.add_comment_sharp),
            ),
          ),
          //body
          body: StreamBuilder(
            stream: APIs.getMyUsersId(),
            builder: (context, snapshot) {
              //switch case
              switch (snapshot.connectionState) {
                //if data is loading
                case ConnectionState.waiting:
                case ConnectionState.none:
                // return const Center(
                //   child: CircularProgressIndicator(),
                // );
                //if same of all data in loaded then show it
                case ConnectionState.active:
                case ConnectionState.done:
                  return StreamBuilder(
                    stream: APIs.getAllUsers(
                        snapshot.data?.docs.map((e) => e.id).toList() ?? []),
                    //get only those users, who's ids are provided
                    builder: (context, snapshot) {
                      //switch case
                      switch (snapshot.connectionState) {
                        //if data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        //if same of all data in loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => ChatUser.fromJson(e.data()))
                                  .toList() ??
                              [];
                          if (_list.isNotEmpty) {
                            return ListView.builder(
                              padding: const EdgeInsets.only(top: 5),
                              physics: const BouncingScrollPhysics(),
                              itemCount: _isSearching
                                  ? _searchList.length
                                  : _list.length,
                              itemBuilder: (context, index) {
                                return ChatUserCart(
                                    user: _isSearching
                                        ? _searchList[index]
                                        : _list[index]);
                              },
                            );
                          } else {
                            return const Center(
                              child: Text(
                                "No connection found",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            );
                          }
                      }
                    },
                  );
              }
            },
          ),
        ),
      ),
    );
  }

  //for adding new chat user
  void _addCharUserDialog() {
    String email = "";
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 25, right: 25, top: 20, bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              //title of the dialogbox
              title: const Row(
                children: [
                  Icon(
                    Icons.person_add,
                    color: Colors.red,
                    size: 30,
                  ),
                  Text("  Add New User"),
                ],
              ),
              //content of the dialog box
              content: TextFormField(
                keyboardType: TextInputType.emailAddress,
                maxLines: null,
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.email,
                    color: Colors.black,
                  ),
                  hintText: "Email",
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
                //add new user button
                MaterialButton(
                  onPressed: () async {
                    //hide alert dialog
                    Navigator.pop(context);
                    if (email.isNotEmpty) {
                      await APIs.addChatUser(email).then((value) {
                        if (value) {
                          Dialogs.showSnackbar(
                              context, "New User Added successfully !!");
                        } else if (!value) {
                          Dialogs.showSnackbar(context, "User does not exists");
                        }
                      });
                    }
                  },
                  child: const Text(
                    "Add User",
                    style: TextStyle(color: Colors.green, fontSize: 17),
                  ),
                ),
              ],
            ));
  }
}
