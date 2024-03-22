import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:bitpro_hive/home/employess/employees_list_page.dart';
import 'package:bitpro_hive/home/employess/user_groups/user_group_page.dart';
import 'package:bitpro_hive/model/user_data.dart';
import 'package:bitpro_hive/model/user_group_data.dart';
import '../../shared/global_variables/font_sizes.dart';
import '../../shared/global_variables/static_text_translate.dart';

class EmployeesPage extends StatefulWidget {
  final UserData userData;
  final UserGroupData currentUserRole;
  final List<UserGroupData> userGroupsDataLst;
  const EmployeesPage(
      {Key? key,
      required this.userData,
      required this.currentUserRole,
      required this.userGroupsDataLst})
      : super(key: key);

  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.currentUserRole.employees)
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
            width: 140,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5))),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EmployeesListPage(
                                userData: widget.userData,
                                userGroupsDataLst: widget.userGroupsDataLst,
                              )));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Iconsax.user,
                      size: 20,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(staticTextTranslate('Employees'),
                        style: TextStyle(
                          fontSize: getMediumFontSize,
                        )),
                  ],
                )),
          ),
        const SizedBox(
          width: 15,
        ),
        if (widget.currentUserRole.groups)
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
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5))),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserGroupPage(
                                userData: widget.userData,
                                userGroupsDataLst: widget.userGroupsDataLst,
                              )));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Iconsax.lock_1,
                      size: 20,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(staticTextTranslate('User Groups'),
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
