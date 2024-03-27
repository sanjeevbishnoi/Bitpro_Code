import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:iconsax/iconsax.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:bitpro_hive/shared/loading.dart';
import 'package:bitpro_hive/shared/toast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../shared/global_variables/font_sizes.dart';
import '../../shared/global_variables/static_text_translate.dart';

class BackupAndRestore extends StatefulWidget {
  const BackupAndRestore({Key? key}) : super(key: key);

  @override
  State<BackupAndRestore> createState() => _BackupAndRestoreState();
}

class _BackupAndRestoreState extends State<BackupAndRestore> {
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    if (loading) return showLoading();
    return Wrap(
      runSpacing: 20,
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: const LinearGradient(
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xff092F53),
                    Color(0xff284F70),
                  ],
                  begin: Alignment.topCenter)),
          height: 45,
          width: 160,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5))),
              onPressed: () async {
                setState(() {
                  loading = true;
                });
                String? selectedDirectory =
                    await FilePicker.platform.getDirectoryPath();

                if (selectedDirectory != null) {
                  var p =
                      await getApplicationSupportDirectory(); // C:\Users\team\AppData\Roaming\com.example\bitpro_hive
                  //saving hive file
                  File imgDirectory =
                      File('$selectedDirectory/Bitpro Backup/bitpro_app.hive');

                  try {
                    await imgDirectory.create(recursive: true);
                  } catch (e) {}
                  File file = File('${p.path}/bitpro_app.hive');

                  await file.copy(imgDirectory.path);
                  //saving image

                  await copyFolder('${p.path}/images',
                      '$selectedDirectory/Bitpro Backup/images');

                  showToast(staticTextTranslate("Saved"), context);
                }
                setState(() {
                  loading = false;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(
                    Iconsax.cloud4,
                    size: 20,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(staticTextTranslate('Backup'),
                      style: TextStyle(
                        fontSize: getMediumFontSize,
                      )),
                ],
              )),
        ),
        const SizedBox(
          width: 15,
          height: 20,
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: const LinearGradient(
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xff092F53),
                    Color(0xff284F70),
                  ],
                  begin: Alignment.topCenter)),
          height: 45,
          width: 150,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5))),
              onPressed: () async {
                setState(() {
                  loading = true;
                });

                var p = await getApplicationSupportDirectory();

                launchUrl(p.uri);

                setState(() {
                  loading = false;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(
                    Iconsax.cloud_change,
                    size: 20,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(staticTextTranslate('Restore'),
                      style: TextStyle(
                        fontSize: getMediumFontSize,
                      )),
                ],
              )),
        ),
        const SizedBox(
          width: 15,
          height: 20,
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: const LinearGradient(
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xff092F53),
                    Color(0xff284F70),
                  ],
                  begin: Alignment.topCenter)),
          height: 45,
          width: 190,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5))),
              onPressed: () async {
                showResetApplicationDialog();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(
                    Iconsax.rotate_left,
                    size: 20,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(staticTextTranslate('Reset Application'),
                      style: TextStyle(
                        fontSize: getMediumFontSize,
                      )),
                ],
              )),
        ),
      ],
    );
  }

  Future<void> copyFolder(String from, String to) async {
    if (Directory(from).existsSync()) {
      try {
        await Directory(to).create(recursive: true);
      } catch (e) {}

      await for (final file in Directory(from).list(recursive: true)) {
        final copyTo = p.join(to, p.relative(file.path, from: from));
        if (file is Directory) {
          try {
            await Directory(copyTo).create(recursive: true);
          } catch (e) {}
        } else if (file is File) {
          await File(file.path).copy(copyTo);
        } else if (file is Link) {
          await Link(copyTo).create(await file.target(), recursive: true);
        }
      }
    }
  }

  showResetApplicationDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(staticTextTranslate('Reset Application?'),
                style: TextStyle(
                  fontSize: getMediumFontSize,
                )),
            content: Text(
                staticTextTranslate(
                    'Please backup before, resetting the application.'),
                style: TextStyle(
                  fontSize: getMediumFontSize,
                )),
            actions: [
              SizedBox(
                height: 42,
                width: 175,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                width: 0.5, color: Colors.grey),
                            borderRadius: BorderRadius.circular(5))),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      staticTextTranslate('Cancel'),
                      style: TextStyle(
                          fontSize: getMediumFontSize, color: Colors.black),
                    )),
              ),
              SizedBox(
                height: 42,
                width: 175,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    onPressed: () async {
                      setState(() {
                        loading = true;
                      });
                      Box box = Hive.box('bitpro_app');
                      await box.clear();

                      Navigator.pop(context);
                      setState(() {
                        loading = false;
                      });
                    },
                    child: Text(
                      staticTextTranslate('Reset'),
                      style: TextStyle(
                          fontSize: getMediumFontSize, color: Colors.white),
                    )),
              ),
            ],
          );
        });
  }
}
