import 'package:bitpro_hive/shared/constant_data.dart';
import 'package:bitpro_hive/shared/global_variables/static_text_translate.dart';
import 'package:bitpro_hive/widget/bTextField.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<String?> showTendorAmountDialog(context,
    {required String paymentMathodKey, required String previousAmt}) async {
  TextEditingController amountTextController =
      TextEditingController(text: previousAmt);
  amountTextController.selection = TextSelection(
      baseOffset: 0, extentOffset: amountTextController.value.text.length);
  await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context2, setState2) {
            return Dialog(
              child: SizedBox(
                width: 350,
                height: paymentMathodKey == PaymentMethodKey().cash ? 250 : 200,
                child: Column(
                  children: [
                    if (paymentMathodKey == PaymentMethodKey().cash)
                      const SizedBox(
                        height: 10,
                      )
                    else
                      const Expanded(
                        child: SizedBox(
                          height: 10,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: BTextField(
                        autoFoucs: true,
                        label: 'Amount',
                        controller: amountTextController,
                        validator: ((value) {
                          if (value!.isEmpty) {
                            return staticTextTranslate('Enter valid number');
                          }
                          return null;
                        }),
                        onChanged: (val) => setState2(() {}),
                      ),
                    ),
                    const Expanded(
                      child: SizedBox(
                        height: 10,
                      ),
                    ),
                    if (paymentMathodKey == PaymentMethodKey().cash)
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 200,
                          child: Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [5, 10, 50, 100, 200, 500]
                                  .map(
                                    (e) => Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(width: 1),
                                        borderRadius: BorderRadius.circular(4),
                                        gradient: const LinearGradient(
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Color(0xff092F53),
                                              Color(0xff284F70),
                                            ],
                                            begin: Alignment.topCenter),
                                      ),
                                      height: 40,
                                      width: 60,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.transparent),
                                        onPressed: () {
                                          amountTextController
                                              .text = ((double.tryParse(
                                                          amountTextController
                                                              .text) ??
                                                      0) +
                                                  e)
                                              .toString();
                                          setState2(() {});
                                        },
                                        child: Text(e.toString()),
                                      ),
                                    ),
                                  )
                                  .toList()),
                        ),
                      ),
                    const Expanded(
                      child: SizedBox(
                        height: 10,
                      ),
                    ),
                    Container(
                      height: 60,
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(5),
                              bottomRight: Radius.circular(5))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tendor $paymentMathodKey',
                            style: GoogleFonts.roboto(fontSize: 18),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(width: 1),
                              borderRadius: BorderRadius.circular(4),
                              gradient: const LinearGradient(
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xff092F53),
                                    Color(0xff284F70),
                                  ],
                                  begin: Alignment.topCenter),
                            ),
                            height: 40,
                            width: 100,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Ok',
                                style: GoogleFonts.roboto(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          }));
  return amountTextController.text;
}
