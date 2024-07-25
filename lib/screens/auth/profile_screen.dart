
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:letschat/api/apis.dart';
import 'package:letschat/helper/dialogs.dart';
import 'package:letschat/main.dart';
import 'package:letschat/models/chat_user.dart';
import 'package:letschat/screens/auth/login_screen.dart';
// import 'package:letschat/widgets/chat_user_card.dart';
// import 'package:letschat/widgets/chat_user_card.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formkey = GlobalKey<FormState>();
  String? _image;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding Keyboard
      onTap:  FocusScope.of(context).unfocus,
      child: Scaffold(
          // app bar
          appBar: AppBar(
            title: const Text('Profile Screen'),
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton.extended(
                backgroundColor: const Color.fromARGB(255, 205, 79, 104),
                onPressed: () async {
                  Dialogs.showProgressBar(context);
                  await APIs.updateActiveStatus(false);
                  // sign out from app
                  await APIs.auth.signOut().then((value) async {
                    await GoogleSignIn().signOut().then((value) {
                      // for hiding progress dialog
                      Navigator.pop(context);
                      // for moving to home screen
                      Navigator.pop(context);
                      //APIs. = FirebaseAuth.instance;

                      // replacing home screen with login screen
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()));
                    });
                  });
                },
                icon: const Icon(Icons.add_comment_rounded),
                label: const Text('Logout')),
          ),
          //body
          body: Form(
            key: _formkey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // for adding some space
                    SizedBox(width: mq.width, height: mq.height * .03),
                    //user profile picture
                    // leading: const CircleAvatar(child: Icon(CupertinoIcons.person)),
                    Stack(
                      children: [
                        //profile picture
                        _image != null
                            ?
                            // local image
                            ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * .3),
                                child: Image.file(File(_image!),
                                    width: mq.height * .2,
                                    height: mq.height * .2,
                                    fit: BoxFit.cover))
                            : ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * .3),
                                child: CachedNetworkImage(
                                  width: mq.height * .2,
                                  height: mq.height * .2,
                                  fit: BoxFit.cover,
                                  imageUrl: widget.user.image,
                                  errorWidget: (context, url, error) =>
                                      const CircleAvatar(
                                          child: Icon(CupertinoIcons.person)),
                                ),
                              ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: MaterialButton(
                            elevation: 1,
                            onPressed: () {
                              _showBottomSheet();
                            },
                            color: Colors.white,
                            child: const Icon(Icons.edit, color: Colors.blue),
                            shape: const CircleBorder(),
                          ),
                        )
                      ],
                    ),
                    // for adding some space
                    SizedBox(width: mq.width, height: mq.height * .03),
                    Text(widget.user.email,
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 16)),
                    // for adding some space
                    SizedBox(height: mq.height * .03),

                    TextFormField(
                      initialValue: widget.user.name,
                      onSaved: (val) => APIs.me.name = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Kuch to daal de bhai',
                      decoration: InputDecoration(
                        prefixIcon:
                            const Icon(Icons.person, color: Colors.blue),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: 'Aapka naam?🧐',
                        label: const Text('Name'),
                      ),
                    ),

                    // for adding some space
                    SizedBox(height: mq.height * .02),

                    TextFormField(
                      initialValue: widget.user.about,
                      onSaved: (val) => APIs.me.about = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Kuch to daal de bhai',
                      decoration: InputDecoration(
                        prefixIcon:
                            const Icon(Icons.info_outline, color: Colors.blue),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: 'To kaise hai Aap🥱',
                        label: const Text('About'),
                      ),
                    ),

                    // for adding some space
                    SizedBox(height: mq.height * .01),

                    ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            shape: const StadiumBorder(),
                            minimumSize: Size(mq.width * .3, mq.height * .05)),
                        onPressed: () {
                          if (_formkey.currentState!.validate()) {
                            _formkey.currentState!.save();
                            log('inside Validator');
                            APIs.updateUserInfo().then((value) {
                              Dialogs.showSnackbar(
                                  context, 'Profile Updated Successfully!');
                            });
                          }
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('UPDATE',
                            style: TextStyle(fontSize: 16))),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .05),
            children: [
              const Text('Pick Profile Picture',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              // for adding some space
              SizedBox(
                height: mq.height * .02,
              ),
              //buttons
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                // pick from gallery button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                      fixedSize: Size(mq.width * .3, mq.height * .15)),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    // Pick an image.
                    final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery, imageQuality: 80);
                    if (image != null) {
                      log('Image Path: ${image.path} -- MimeType: ${image.mimeType}');
                      setState(() {
                        _image = image.path;
                      });
                      APIs.updateProfilePicture(File(_image!));
                      //for hiding bottom sheet
                      Navigator.pop(context);
                    }
                  },
                  child: Image.asset('assets/upload.png'),
                ),
                //take picture from camera button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                      fixedSize: Size(mq.width * .3, mq.height * .15)),
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    // Pick an image.
                    final XFile? image =
                        await picker.pickImage(source: ImageSource.camera);
                    if (image != null) {
                      log('Image Path: ${image.path}');
                      setState(() {
                        _image = image.path;
                      });
                      APIs.updateProfilePicture(File(_image!));
                      //for hiding bottom sheet
                      Navigator.pop(context);
                    }
                  },
                  child: Image.asset('assets/camera.png'),
                )
              ])
            ],
          );
        });
  }
}
