import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:bitpro_hive/shared/global_variables/static_text_translate.dart';
import '../../main.dart';
import '../global_variables/font_sizes.dart';

showLanguageSelectDialog(context) {
  var box = Hive.box('bitpro_app');
  String language = box.get('Selected Language') ?? 'English';

  return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(
              staticTextTranslate('Change Language'),
              style: TextStyle(fontSize: getMediumFontSize + 5),
            ),
            content: SizedBox(
              height: 53,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    staticTextTranslate('Please select a language to use'),
                    style: TextStyle(fontSize: getMediumFontSize - 1),
                  ),
                  const SizedBox(
                    height: 0,
                  ),
                  Container(
                      width: 320,
                      height: 30,
                      margin: const EdgeInsets.only(top: 5, bottom: 0),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 0.5),
                          color: const Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(4)),
                      padding: const EdgeInsets.only(right: 5, left: 5
                          // top: 3,
                          // bottom: 3
                          ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: language,
                        underline: const SizedBox(),
                        items:
                            <String>['English', 'Arabic'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value != 'English' ? 'عربي' : 'English',
                              style: TextStyle(fontSize: getMediumFontSize + 2),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          language = val ?? "English";

                          setState(() {});
                        },
                      ))
                ],
              ),
            ),
            actions: [
              SizedBox(
                height: 42,
                width: 173,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                width: 0.5, color: Colors.grey),
                            borderRadius: BorderRadius.circular(4))),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      staticTextTranslate('Cancel'),
                      style: TextStyle(
                          color: Colors.black, fontSize: getMediumFontSize),
                    )),
              ),
              SizedBox(
                height: 42,
                width: 173,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: darkBlueColor,
                        shape: RoundedRectangleBorder(
                            side: const BorderSide(
                                width: 0.5, color: Colors.grey),
                            borderRadius: BorderRadius.circular(4))),
                    onPressed: () {
                      box.put('Selected Language', language);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MyApp()));
                    },
                    child: Text(
                      staticTextTranslate('Save'),
                      style: TextStyle(fontSize: getMediumFontSize),
                    )),
              ),
            ],
          );
        });
      });
}
