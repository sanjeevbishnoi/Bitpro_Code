import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnPagePanel extends StatelessWidget {
  final Widget columnForTextField;
  final String topLabel;
  final Widget rowForButton;

  const OnPagePanel(
      {super.key,
      required this.columnForTextField,
      required this.rowForButton,
      required this.topLabel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 420,
        decoration: BoxDecoration(
            border: Border.all(width: 0.3),
            color: const Color(0xffE2E2E2),
            borderRadius: BorderRadius.circular(3)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 35,
              width: double.maxFinite,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                gradient: LinearGradient(
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromARGB(255, 66, 66, 66),
                      Color.fromARGB(255, 0, 0, 0),
                    ],
                    begin: Alignment.topCenter),
              ),
              child: Row(
                children: [
                  Text(
                    topLabel,
                    style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.white),
                  )
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Container(width: 375, child: columnForTextField),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 60,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(3),
                    bottomRight: Radius.circular(3),
                  ),
                ),
                child: Padding(
                    padding: const EdgeInsets.all(8.0), child: rowForButton),
              ),
            )
          ],
        ),
      ),
    );
  }
}
