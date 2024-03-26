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
          return Dialog(
            backgroundColor: homeBgColor,
            // title: Text(
            //   staticTextTranslate('Change Language'),
            //   style: TextStyle(fontSize: getMediumFontSize + 5),
            // ),
            // content:
            child: SizedBox(
              height: 250,
              width: 400,
              child: Column(
                children: [
                  Container(
                    // height: 55,
                    width: double.maxFinite,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4)),
                        gradient: LinearGradient(
                            end: Alignment.bottomCenter,
                            colors: [
                              Color.fromARGB(255, 66, 66, 66),
                              Color.fromARGB(255, 0, 0, 0),
                            ],
                            begin: Alignment.topCenter)),
                    child: Text(
                      staticTextTranslate('Change Language'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: getMediumFontSize + 5,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          staticTextTranslate(
                              'Please select a language to use'),
                          style: TextStyle(fontSize: getMediumFontSize - 1),
                        ),
                        const SizedBox(
                          height: 0,
                        ),
                        Container(
                            width: 360,
                            height: 30,
                            margin: const EdgeInsets.only(top: 5, bottom: 0),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.grey, width: 0.5),
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
                              items: <String>['English', 'Arabic']
                                  .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value != 'English' ? 'عربي' : 'English',
                                    style: TextStyle(
                                        fontSize: getMediumFontSize + 2),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                language = val ?? "English";

                                setState(() {});
                              },
                            )),
                      ],
                    ),
                  ),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                          width: 550,
                          height: 60,
                          decoration: const BoxDecoration(
                              color: Color(0xffdddfe8),
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(6),
                                  bottomRight: Radius.circular(6))),
                          // padding: const EdgeInsets.symmetric(
                          //     horizontal: 10, vertical: 10),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  height: 42,
                                  width: 173,
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                              255, 255, 255, 255),
                                          shape: RoundedRectangleBorder(
                                              side: const BorderSide(
                                                  width: 0.5,
                                                  color: Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(4))),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        staticTextTranslate('Cancel'),
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: getMediumFontSize),
                                      )),
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
                                  height: 42,
                                  width: 173,
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                              side: const BorderSide(
                                                  width: 0.5,
                                                  color: Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(4))),
                                      onPressed: () {
                                        box.put('Selected Language', language);
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const MyApp()));
                                      },
                                      child: Text(
                                        staticTextTranslate('Save'),
                                        style: TextStyle(
                                            fontSize: getMediumFontSize),
                                      )),
                                ),
                              ])))
                ],
              ),
            ),
            // actions: [

            // ],
          );
        });
      });
}
