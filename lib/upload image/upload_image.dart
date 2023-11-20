// import 'dart:io';

// import 'package:chat_app/upload%20image/image_picker_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class UploadImage extends StatefulWidget {
//   const UploadImage({super.key});

//   @override
//   State<UploadImage> createState() => _UploadImageState();
// }

// class _UploadImageState extends State<UploadImage> {
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(ImagePickerController());
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Upload Image"),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Center(
//               child: ElevatedButton(
//                 onPressed: () {
//                   controller.pickImage();
//                 },
//                 child: const Text('Pick your image'),
//               ),
//             ),
//             //
//             Obx(() {
//               return Container(
//                 child: controller.image.value.path == ""
//                     ? Icon(
//                         Icons.camera,
//                         size: 60,
//                       )
//                     : Image.file(File(controller.image.value.path)),
//               );
//             }),
//             //upload  onto firebase button
//             ElevatedButton(
//               onPressed: () {
//                 controller.uploadImageToFirebase();
//               },
//               child: const Text("Upload to Firebase"),
//             ),
//             //display image
//             Obx(() {
//               final imageUrl = controller.networkImage.value.toString();
//               if (Uri.parse(imageUrl).isAbsolute) {
//                 return Container(
//                     height: 100, width: 100, child: Image.network(imageUrl));
//               } else {
//                 // Handle invalid or local URIs
//                 return Text('Invalid or local URI: $imageUrl');
//               }
//             }),

//             // Obx(() {
//             //   return Image.network(controller.networkImage.value.toString());
//             // }),
//           ],
//         ),
//       ),
//     );
//   }
// }
