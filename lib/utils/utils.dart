import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Function to pick an image from the specified source and return it as bytes.
/// Useful for uploading to Supabase or other storage solutions.
Future<Uint8List?> pickImage(ImageSource source) async {
  final ImagePicker imagePicker = ImagePicker();

  // Pick the image from the given source
  XFile? file = await imagePicker.pickImage(source: source);

  if (file != null) {
    return await file.readAsBytes();
  } else {
    debugPrint("No image selected.");
    return null;
  }
}

/// Utility function to show a Snackbar with a specified message in the given context.
void showSnackBar(String content, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(content)),
  );
}
