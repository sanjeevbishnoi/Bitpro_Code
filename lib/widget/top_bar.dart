import 'package:bitpro_hive/shared/global_variables/font_sizes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TopBar extends StatelessWidget {
  final String pageName;
  const TopBar({super.key,  this.pageName = ''});

  @override
  Widget build(BuildContext context) {
    return Container(
              height: 50,
              width: double.maxFinite,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(0)),
                  gradient: LinearGradient(
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromARGB(255, 66, 66, 66),
                        Color.fromARGB(255, 0, 0, 0),
                      ],
                      begin: Alignment.topCenter)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 5,
                      ),
                      Image.asset('assets/icons/bitpro.png', width: 23,),
                      const SizedBox(width: 5,),
                      Text(
                                    'BitPro',
                                    style: GoogleFonts.lato(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                      const SizedBox(
                        width: 65,
                      ),
                      Text(
                        pageName,
                        style: GoogleFonts.roboto(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 35,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.white),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ismail Ebrahim',
                              style: GoogleFonts.roboto(
                                  fontSize: getMediumFontSize,
                                  color: Colors.white),
                            ),
                            Text(
                              'Cashier',
                              style: GoogleFonts.roboto(
                                  fontSize: getMediumFontSize - 2,
                                  color: Colors.white),
                            )
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
  }
}