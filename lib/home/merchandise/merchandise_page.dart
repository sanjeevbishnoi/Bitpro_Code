import 'package:bitpro_hive/services/firestore_api/fb_user_group_db_service.dart';
import 'package:bitpro_hive/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:bitpro_hive/home/merchandise/department/department_page.dart';
import 'package:bitpro_hive/home/merchandise/inventory/inventory_page.dart';
import 'package:bitpro_hive/home/merchandise/vendor/vendor_page.dart';
import 'package:bitpro_hive/model/user_data.dart';
import 'package:bitpro_hive/model/user_group_data.dart';
import '../../shared/global_variables/font_sizes.dart';
import '../../shared/global_variables/static_text_translate.dart';

class MerchandisePage extends StatefulWidget {
  final UserData userData;
  final UserGroupData currentUserRole;
  const MerchandisePage(
      {Key? key, required this.userData, required this.currentUserRole})
      : super(key: key);

  @override
  State<MerchandisePage> createState() => _MerchandisePageState();
}

class _MerchandisePageState extends State<MerchandisePage> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 15,
      runSpacing: 15,
      children: [
        if (widget.currentUserRole.inventory)
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
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              InventoryPage(userData: widget.userData)));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(
                      Iconsax.d_square,
                      size: 20,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(staticTextTranslate('Inventory'),
                        style: TextStyle(
                          fontSize: getMediumFontSize,
                        )),
                  ],
                )),
          ),
        if (widget.currentUserRole.vendors)
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
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => VendorPage(
                                userData: widget.userData,
                              )));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(
                      Iconsax.building,
                      size: 20,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(staticTextTranslate('Vendors'),
                        style: TextStyle(
                          fontSize: getMediumFontSize,
                        )),
                  ],
                )),
          ),
        if (widget.currentUserRole.departments)
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
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DepartmentPage(
                                userData: widget.userData,
                              )));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(
                      Iconsax.layer,
                      size: 20,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(staticTextTranslate('Department'),
                        style: TextStyle(
                          fontSize: getMediumFontSize,
                        )),
                  ],
                )),
          ),
        if (widget.currentUserRole.adjustment)
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
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(
                      Iconsax.pen_tool,
                      size: 20,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(staticTextTranslate('Adjustment'),
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
