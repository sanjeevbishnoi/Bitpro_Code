import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bitpro_hive/home/purchase/voucher/voucher_page.dart';
import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:bitpro_hive/model/user_data.dart';
import 'package:bitpro_hive/model/user_group_data.dart';
import '../../shared/global_variables/font_sizes.dart';
import '../../shared/global_variables/static_text_translate.dart';

class PurchasePage extends StatefulWidget {
  final UserData userData;
  final UserGroupData currentUserRole;

  const PurchasePage(
      {Key? key, required this.userData, required this.currentUserRole})
      : super(key: key);

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 15,
      runSpacing: 15,
      children: [
        if (widget.currentUserRole.purchaseVoucher)
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
                        borderRadius: BorderRadius.circular(4))),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              VoucherPage(userData: widget.userData)));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(
                      Iconsax.receipt_2,
                      size: 20,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(staticTextTranslate('Voucher'),
                        style: TextStyle(
                          fontSize: getMediumFontSize,
                        )),
                  ],
                )),
          ),
      ],
    );
  }
}
