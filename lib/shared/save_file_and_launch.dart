import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'global_variables/color.dart';
import 'global_variables/font_sizes.dart';
import 'global_variables/static_text_translate.dart';
import 'loading.dart';

///To save the Excel file in the Mobile and Desktop platforms.
Future<void> saveAndLaunchFile(List<int> bytes, BuildContext context,
    {required String fileExtension}) async {
  String? fileLocation = await showSelectFileLocation(context);
  if (fileLocation != null) {
    final File file = File('$fileLocation.$fileExtension');
    await file.writeAsBytes(bytes, flush: true);
  }
}

Future<String?> showSelectFileLocation(context) async {
  String fileName = '';
  bool dialogLoading = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String? fileLocation;
  await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState2) {
          if (dialogLoading) {
            return Dialog(
                backgroundColor: homeBgColor,
                child: SizedBox(height: 340, width: 500, child: showLoading()));
          }
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(width: 0.2, color: Colors.grey)),
            title: Text(
              staticTextTranslate('Exports'),
              style: TextStyle(fontSize: getMediumFontSize),
            ),
            content: Form(
              key: formKey,
              child: TextFormField(
                autofocus: true,
                decoration: const InputDecoration(hintText: 'File Name'),
                style: const TextStyle(),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter file name'
                    : null,
                onChanged: (val) {
                  fileName = val;
                  setState2(() {});
                },
              ),
            ),
            actions: [
              SizedBox(
                height: 42,
                width: 173,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        side: const BorderSide(width: 0.1, color: Colors.grey),
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4))),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(staticTextTranslate('Cancel'),
                        style: TextStyle(
                            fontSize: getMediumFontSize, color: Colors.black))),
              ),
              SizedBox(
                height: 42,
                width: 173,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      side: const BorderSide(width: 0.1, color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        setState2(() {
                          dialogLoading = true;
                        });
                        fileLocation = await FilePicker.platform
                            .getDirectoryPath(lockParentWindow: true);

                        setState2(() {
                          dialogLoading = false;
                        });
                        if (fileLocation != null) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: Text(
                      staticTextTranslate('Submit'),
                      style: TextStyle(
                        fontSize: getMediumFontSize,
                        color: Colors.white,
                      ),
                    )),
              ),
            ],
          );
        });
      });

  return fileLocation == null ? null : '$fileLocation\\$fileName';
}
