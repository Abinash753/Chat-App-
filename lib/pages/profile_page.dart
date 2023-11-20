import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/api.dart';
import 'package:chat_app/helper/dialogs.dart';
import 'package:chat_app/models/chat_user.dart';
import 'package:chat_app/pages/auth/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

//profile screen to show signed in user  information
class ProfilePage extends StatefulWidget {
  final ChatUser user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //for form validation
  final _formKey = GlobalKey<FormState>();
  //for store the image url
  String? _image;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //for hinding keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Profile Page",
          ),
          backgroundColor: Colors.grey,
        ),
        //logout floating button
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 25, right: 10),
          child: FloatingActionButton.extended(
            onPressed: () async {
              Dialogs.showProgressBar(context);
              await APIs.updateActiveStatus(false);

              await APIs.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  //to hide progress dialog
                  Navigator.pop(context);
                  //to moving to home screen

                  Navigator.pop(context);
                  APIs.auth = FirebaseAuth.instance;
                  //replacing home screen with login screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginPage(),
                    ),
                  );
                });
              });
            },
            label: const Text("Logout"),
            icon: const Icon(Icons.logout),
          ),
        ),
        //body
        body: Form(
          key: _formKey,
          child: Padding(
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
                  Stack(
                    children: [
                      //profile picture
                      _image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(72),
                              child: Image.file(
                                File(_image!),
                                width: 140,
                                height: 140,
                                fit: BoxFit.cover,
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(72),
                              child: CachedNetworkImage(
                                width: 140,
                                height: 140,
                                fit: BoxFit.fill,
                                imageUrl: widget.user.image,
                                errorWidget: (context, url, error) =>
                                    const CircleAvatar(
                                  child: Icon(CupertinoIcons.person),
                                ),
                              ),
                            ),
                      //profile image edit icon
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          child: const Icon(Icons.edit),
                          onPressed: () {
                            _showBottonSheet();
                          },
                          shape: const CircleBorder(),
                          elevation: 1,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  //user email address
                  Center(
                    child: Text(
                      widget.user.email,
                      style: const TextStyle(color: Colors.black, fontSize: 20),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  //textform field
                  TextFormField(
                    onSaved: (value) => APIs.me.name = value ?? "",
                    validator: (value) => value != null && value.isNotEmpty
                        ? null
                        : "Required Field",
                    initialValue: widget.user.name,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Colors.orange,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        hintText: "Eg. Abinash Upreti",
                        label: const Text(
                          "Enter Name",
                          style: TextStyle(color: Colors.black),
                        )),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  //textform about
                  TextFormField(
                    onSaved: (value) => APIs.me.about = value ?? "",
                    validator: (value) => value != null && value.isNotEmpty
                        ? null
                        : "Required Field",
                    initialValue: widget.user.about,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.info_outline_rounded,
                          color: Colors.orange,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        hintText: "Eg. Feeling awesome",
                        label: const Text(
                          "About",
                          style: TextStyle(color: Colors.black),
                        )),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  //update button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        minimumSize: const Size(120, 50)),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        APIs.updateUserInfo().then((value) {
                          Dialogs.showSnackbar(
                              context, "Profile Updated successfully");
                        });
                      }
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text("Update"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //bottom sheet for picking a profile picture for user
  void _showBottonSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                const EdgeInsets.only(top: 20, right: 10, left: 10, bottom: 30),
            children: [
              const Text(
                "Pick Profile Picture",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    letterSpacing: 1.3,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //capture image  button
                  ElevatedButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      //pick an image here
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 80);
                      if (image != null) {
                        print("image path : ${image.path} ");
                        setState(() {
                          _image = image.path;
                        });
                        //calling function to upload user image
                        APIs.updateProfilePicture(File(_image!));
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: const CircleBorder(),
                        fixedSize: const Size(100, 100)),
                    child: Image.asset("images/camera_icon.png"),
                  ),
                  //take picture from camera button
                  ElevatedButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      //pick an image
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery, imageQuality: 80);
                      if (image != null) {
                        print("image path:${image.path}");
                        setState(
                          () {
                            _image = image.path;
                          },
                        );
                        //calling function to upload user image
                        APIs.updateProfilePicture(File(_image!));
                        //for hiding botton sheet
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: const CircleBorder(),
                        fixedSize: const Size(100, 100)),
                    child: Image.asset("images/gallery.png"),
                  ),
                ],
              )
            ],
          );
        });
  }
}
