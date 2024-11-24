import 'dart:typed_data'; // Import Uint8List from the correct library
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta_supabase/utils/global_variables.dart';
import '../resources/auth_methods.dart';
import '../responsive/mobile_screen_layout.dart';
import '../responsive/responsive_layout_screen.dart';
import '../responsive/web_screen_layout.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';
import '../widgets/text_field_input.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passController.dispose();
    _bioController.dispose();
  }

  void selectImage() async {
    Uint8List? im = await pickImage(ImageSource.gallery);
    if (im != null) {
      setState(() {
        _image = im;
      });
    } else {
      showSnackBar("No image selected.", context);
    }
  }

  void signUpUser() async {
    setState(() {
      _isLoading = true;
    });

    String res = await AuthMethods().signupUser(
        email: _emailController.text,
        pass: _passController.text,
        username: _usernameController.text,
        bio: _bioController.text,
        file: _image ?? Uint8List(0));

    setState(() {
      _isLoading = false;
    });

    if (res == "Success") {
      print("Navigating to ResponsiveLayout is about to occur");
      showSnackBar(res, context);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const ResponsiveLayout(
                  webScreenLayout: WebScreenLayout(),
                  mobileScreenLayout: MobileScreenLayout())));
    } else {
      print("Signup failed with message: $res");
      showSnackBar(res, context);
      _emailController.clear();
      _passController.clear();
      _bioController.clear();
      _usernameController.clear();
    }
  }

  void navigateToLogin() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView( // Ensure this wraps the entire content
          child: Column(
            children: [
              Container(
                padding: MediaQuery.of(context).size.width > webScreenSize ? EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width / 3) :
                const EdgeInsets.symmetric(horizontal: 32),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16), // Adjust spacing as needed
                    SvgPicture.asset(
                      "assets/images/instagram.svg",
                      color: primaryColor,
                      height: 64,
                    ),
                    const SizedBox(height: 64),
                    Stack(
                      children: [
                        _image != null
                            ? CircleAvatar(
                          radius: 64,
                          backgroundImage: MemoryImage(_image!),
                        )
                            : const CircleAvatar(
                          radius: 64,
                          backgroundImage: NetworkImage(
                              "https://static.vecteezy.com/system/resources/thumbnails/009/734/564/small/default-avatar-profile-icon-of-social-media-user-vector.jpg"),
                        ),
                        Positioned(
                            bottom: -10,
                            left: 80,
                            child: IconButton(
                                onPressed: selectImage,
                                icon: const Icon(Icons.add_a_photo)))
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextFieldInput(
                      textEditingController: _usernameController,
                      hintText: "Enter Your Username",
                      textInputType: TextInputType.text,
                    ),
                    const SizedBox(height: 24),
                    TextFieldInput(
                      textEditingController: _emailController,
                      hintText: "Enter Your Email",
                      textInputType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 24),
                    TextFieldInput(
                      textEditingController: _passController,
                      hintText: "Enter Your Password",
                      textInputType: TextInputType.text,
                      isPass: true,
                    ),
                    const SizedBox(height: 24),
                    TextFieldInput(
                      textEditingController: _bioController,
                      hintText: "Enter Your Bio",
                      textInputType: TextInputType.text,
                    ),
                    const SizedBox(height: 54),
                    InkWell(
                      onTap: signUpUser,
                      child: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: const ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          color: blueColor,
                        ),
                        child: _isLoading
                            ? const Center(
                          child: CircularProgressIndicator(
                            color: primaryColor,
                          ),
                        )
                            : const Text("Sign up"),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: const Text("Already have an Account? "),
                        ),
                        GestureDetector(
                          onTap: navigateToLogin,
                          child: Container(
                            child: const Text(
                              "Log In",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
