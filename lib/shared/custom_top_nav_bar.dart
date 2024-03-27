import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:bitpro_hive/shared/global_variables/static_text_translate.dart';

import 'global_variables/font_sizes.dart';

customTopNavBar(child) {
  return Material(
    child: WindowBorder(
      width: 1,
      color: homeBgColor, //background color
      child: Column(
        children: [
          WindowTitleBarBox(
            child: Container(
              color: homeBgColor, //background color
              child: Row(
                children: [
                  Expanded(child: MoveWindow()),
                  const WindowButtons()
                ],
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    ),
  );
}

final buttonColors = WindowButtonColors(
    iconNormal: Colors.black,
    mouseOver: Colors.grey[200],
    mouseDown: Colors.grey[200],
    iconMouseOver: const Color(0xFF805306),
    iconMouseDown: const Color(0xFFFFD500));

final closeButtonColors = WindowButtonColors(
    mouseOver: const Color(0xFFD32F2F),
    mouseDown: const Color(0xFFB71C1C),
    iconNormal: Colors.black,
    iconMouseOver: Colors.white);

class WindowButtons extends StatefulWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  _WindowButtonsState createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons> {
  void maximizeOrRestore() {
    setState(() {
      appWindow.maximizeOrRestore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        appWindow.isMaximized
            ? RestoreWindowButton(
                colors: buttonColors,
                onPressed: maximizeOrRestore,
              )
            : MaximizeWindowButton(
                colors: buttonColors,
                onPressed: maximizeOrRestore,
              ),
        CloseWindowButton(
          colors: closeButtonColors,
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      elevation: 5,
                      title: Text(
                        staticTextTranslate('Exit'),
                        style: TextStyle(fontSize: getMediumFontSize + 5),
                      ),
                      content: Text(
                        staticTextTranslate('Do you really want to exit?'),
                        style: TextStyle(fontSize: getMediumFontSize - 1),
                      ),
                      actions: [
                        SizedBox(
                          height: 45,
                          width: 150,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xffdddfe8),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4))),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                staticTextTranslate('No'),
                                style: TextStyle(
                                    fontSize: getMediumFontSize,
                                    color: Colors.black),
                              )),
                        ),
                        SizedBox(
                          height: 45,
                          width: 150,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: darkBlueColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4))),
                              onPressed: () {
                                appWindow.close();
                              },
                              child: Text(
                                staticTextTranslate('Yes'),
                                style: TextStyle(fontSize: getMediumFontSize),
                              )),
                        ),
                      ],
                    ));
          },
        ),
      ],
    );
  }
}
