import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerController extends GetxController {
  Rx<File> image = File("").obs;

  Future pickImage() async {
    try {
      final imagePick =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (imagePick == null) {
        return null;
      }
      final imageTemp = File(imagePick.path);
      image.value = imageTemp;
    } on PlatformException catch (e) {
      return e;
    }
  }

  //
  Rx<String> networkImage = "".obs;

  //upload image onto firebase
  Future<String> uploadImageToFirebase() async {
    String fileName = DateTime.now().microsecondsSinceEpoch.toString();
    try {
      Reference reference =
          FirebaseStorage.instance.ref().child("profile_image/$fileName.png");
      await reference.putFile(image.value);
      String downloadURL = await reference.getDownloadURL();
      networkImage.value = downloadURL;
      return downloadURL;
    } catch (e) {
      return "";
    }
  }
}
