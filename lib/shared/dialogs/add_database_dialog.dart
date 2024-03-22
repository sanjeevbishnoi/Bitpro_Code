import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bitpro_hive/shared/global_variables/static_text_translate.dart';

import '../global_variables/font_sizes.dart';

showAddDatabaseDialog(context) {
  return showDialog(
      context: context,
      builder: (context2) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(width: 0.2, color: Colors.grey)),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Iconsax.danger,
                size: 20,
                color: Color.fromARGB(255, 143, 42, 35),
              ),
              const SizedBox(
                width: 15,
              ),
              Text(
                staticTextTranslate('Discard Changes'),
                style: TextStyle(fontSize: getMediumFontSize + 5),
              ),
            ],
          ),
          content: Text(
              staticTextTranslate(
                  'Are you sure you want to discard all changes?'),
              style: TextStyle(fontSize: getMediumFontSize)),
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
                    Navigator.pop(context2);
                  },
                  child: Text(staticTextTranslate('Cancel'),
                      style: TextStyle(
                          color: Colors.black, fontSize: getMediumFontSize))),
            ),
            SizedBox(
              height: 42,
              width: 173,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    side: const BorderSide(width: 0.1, color: Colors.grey),
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context2);
                  },
                  child: Text(
                    staticTextTranslate('Discard'),
                    style: TextStyle(
                        color: Colors.white, fontSize: getMediumFontSize),
                  )),
            ),
          ],
        );
      });
}
