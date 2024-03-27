import 'package:bitpro_hive/home/sales/customer/sideMenuButton.dart';
import 'package:bitpro_hive/services/firestore_api/fb_user_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/firebase_db_service.dart';
import 'package:bitpro_hive/widget/bTextField.dart';
import 'package:bitpro_hive/widget/onpage_button.dart';
import 'package:bitpro_hive/widget/onpage_panel.dart';
import 'package:bitpro_hive/widget/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bitpro_hive/model/user_data.dart';
import 'package:bitpro_hive/model/user_group_data.dart';
import 'package:bitpro_hive/shared/custom_top_nav_bar.dart';
import 'package:bitpro_hive/shared/dialogs/discard_changes_dialog.dart';
import 'package:bitpro_hive/shared/loading.dart';
import '../../shared/global_variables/color.dart';
import '../../shared/global_variables/font_sizes.dart';
import '../../shared/global_variables/static_text_translate.dart';

class CreateEditEmployeesPage extends StatefulWidget {
  final List<UserGroupData> userGroupsDataLst;
  final UserData userData;
  final List<UserData> empLstData;
  final bool edit;
  final UserData? selectedRowData;

  final String newItemId;
  const CreateEditEmployeesPage(
      {Key? key,
      required this.userGroupsDataLst,
      required this.userData,
      this.edit = false,
      this.selectedRowData,
      required this.empLstData,
      required this.newItemId})
      : super(key: key);

  @override
  State<CreateEditEmployeesPage> createState() =>
      _CreateEditEmployeesPageState();
}

class _CreateEditEmployeesPageState extends State<CreateEditEmployeesPage> {
  String? firstName;
  String? userName;
  String? lastName;
  String? password;
  String? employeeId;
  String? confirmPassword;
  String? userRole;
  String? maxDiscount = '0';
  var formKey = GlobalKey<FormState>();
  bool loading = false;
  bool showDropDownError = false;
  @override
  void initState() {
    super.initState();
    if (widget.edit && widget.selectedRowData != null) {
      firstName = widget.selectedRowData!.firstName;
      userName = widget.selectedRowData!.username;
      lastName = widget.selectedRowData!.lastName;
      password = widget.selectedRowData!.password;
      confirmPassword = widget.selectedRowData!.password;
      employeeId = widget.selectedRowData!.employeeId;
      userRole = widget.selectedRowData!.userRole;
      maxDiscount = widget.selectedRowData!.maxDiscount;
    } else {
      employeeId = widget.newItemId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return customTopNavBar(
      Scaffold(
        backgroundColor: homeBgColor,
        body: SafeArea(
          child: Column(
            children: [
              const TopBar(pageName: 'Employee'),
              Expanded(
                child: Container(
                  color: homeBgColor,
                  child: Row(
                    children: [
                      Container(
                        color: const Color.fromARGB(255, 43, 43, 43),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SideMenuButton(
                              label: 'Back',
                              iconPath: 'assets/icons/back.png',
                              buttonFunction: () {
                                showDiscardChangesDialog(context);
                              },
                            ),
                            SideMenuButton(
                                label: 'Save',
                                iconPath: 'assets/icons/save.png',
                                buttonFunction: () => onTapSaveButton())
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 0,
                      ),
                      Expanded(
                        child: loading
                            ? showLoading()
                            : Form(
                                key: formKey,
                                child: Row(
                                  children: [
                                    OnPagePanel(
                                        widht: 450,
                                        columnForTextField: Column(
                                          children: [
                                            BTextField(
                                              textFieldReadOnly: true,
                                              label: 'Employee Id',
                                              initialValue: employeeId,
                                              validator: ((value) {
                                                if (value!.isEmpty) {
                                                  return staticTextTranslate(
                                                      'Enter employee id');
                                                } else if ((widget.edit &&
                                                        widget.selectedRowData!
                                                                .employeeId !=
                                                            value) ||
                                                    !widget.edit) {
                                                  if (widget.empLstData
                                                      .where((e) =>
                                                          e.employeeId == value)
                                                      .isNotEmpty) {
                                                    return staticTextTranslate(
                                                        'ID is already in use');
                                                  }
                                                }
                                                return null;
                                              }),
                                              onChanged: (val) =>
                                                  setState(() {}),
                                              autovalidateMode: AutovalidateMode
                                                  .onUserInteraction,
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            BTextField(
                                              textFieldReadOnly: false,
                                              label: 'Username',
                                              initialValue: userName,
                                              validator: ((value) {
                                                if (value!.isEmpty) {
                                                  return staticTextTranslate(
                                                      'Enter your username');
                                                } else if ((widget.edit &&
                                                        widget.selectedRowData!
                                                                .username !=
                                                            value) ||
                                                    !widget.edit) {
                                                  if (widget.empLstData
                                                      .where((e) =>
                                                          e.username == value)
                                                      .isNotEmpty) {
                                                    return staticTextTranslate(
                                                        'Username is already in use');
                                                  }
                                                }
                                                return null;
                                              }),
                                              onChanged: (val) => setState(() {
                                                userName = val;
                                              }),
                                              autovalidateMode: AutovalidateMode
                                                  .onUserInteraction,
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            BTextField(
                                              textFieldReadOnly: false,
                                              label: 'First Name',
                                              initialValue: firstName,
                                              validator: ((value) {
                                                if (value!.isEmpty) {
                                                  return staticTextTranslate(
                                                      'Enter your name');
                                                }
                                                return null;
                                              }),
                                              onChanged: (val) => setState(() {
                                                firstName = val;
                                              }),
                                              autovalidateMode: AutovalidateMode
                                                  .onUserInteraction,
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            BTextField(
                                              textFieldReadOnly: false,
                                              label: 'Last Name',
                                              initialValue: lastName,
                                              onChanged: (val) => setState(() {
                                                lastName = val;
                                              }),
                                              autovalidateMode: AutovalidateMode
                                                  .onUserInteraction,
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            BTextField(
                                              textFieldReadOnly: false,
                                              label: 'Password',
                                              initialValue: password,
                                              validator: ((value) {
                                                if (value!.isEmpty) {
                                                  return staticTextTranslate(
                                                      'Enter your password');
                                                }
                                                return null;
                                              }),
                                              onChanged: (val) => setState(() {
                                                password = val;
                                              }),
                                              autovalidateMode: AutovalidateMode
                                                  .onUserInteraction,
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            BTextField(
                                              textFieldReadOnly: false,
                                              label: 'Confirm Password',
                                              initialValue: confirmPassword,
                                              validator: ((value) {
                                                if (value!.isEmpty) {
                                                  return staticTextTranslate(
                                                      'Re enter your password');
                                                }
                                                if (password !=
                                                    confirmPassword) {
                                                  return staticTextTranslate(
                                                      'Please make sure your passwords match.');
                                                }
                                                return null;
                                              }),
                                              obscureText: true,
                                              onChanged: (val) => setState(() {
                                                confirmPassword = val;
                                              }),
                                              autovalidateMode: AutovalidateMode
                                                  .onUserInteraction,
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8.0),
                                                  child: Text(
                                                    staticTextTranslate(
                                                        'User Role'),
                                                    style: GoogleFonts.roboto(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: 240,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 43, 43, 43),
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4)),
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 5),
                                                  child: DropdownButton<String>(
                                                    underline: const SizedBox(),
                                                    isExpanded: true,
                                                    padding: EdgeInsets.zero,
                                                    hint: Text(
                                                      staticTextTranslate(
                                                          'Select Role'),
                                                      style: TextStyle(
                                                          fontSize:
                                                              getMediumFontSize +
                                                                  2,
                                                          fontWeight:
                                                              FontWeight.w400),
                                                    ),
                                                    value: userRole,
                                                    items: widget
                                                        .userGroupsDataLst
                                                        .map((UserGroupData
                                                            value) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: value.name,
                                                        child: Text(
                                                          value.name,
                                                          style: TextStyle(
                                                              fontSize:
                                                                  getMediumFontSize +
                                                                      2,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                      );
                                                    }).toList(),
                                                    onChanged: (val) {
                                                      setState(() {
                                                        showDropDownError =
                                                            false;
                                                        userRole = val;
                                                      });
                                                    },
                                                  ),
                                                )
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            if (showDropDownError)
                                              Text(
                                                staticTextTranslate(
                                                    'Select a role'),
                                                style: TextStyle(
                                                    fontSize: getSmallFontSize,
                                                    color: Colors.red[800]),
                                              ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            BTextField(
                                              textFieldReadOnly: false,
                                              label: 'Max Discount %',
                                              initialValue: maxDiscount,
                                              validator: ((val) {
                                                if (double.tryParse(val!) ==
                                                    null) {
                                                  return staticTextTranslate(
                                                      'Enter a valid number');
                                                } else if (double.parse(val) <
                                                        0 ||
                                                    double.parse(val) > 110) {
                                                  return staticTextTranslate(
                                                      'Enter a value between 0 - 100%');
                                                }
                                                return null;
                                              }),
                                              onChanged: (val) => setState(() {
                                                maxDiscount = val;
                                              }),
                                              autovalidateMode: AutovalidateMode
                                                  .onUserInteraction,
                                            ),
                                          ],
                                        ),
                                        rowForButton: Row(
                                          children: [
                                            OnPageButton(
                                              icon: Iconsax.archive,
                                              label: 'Save',
                                              onPressed: onTapSaveButton,
                                            ),
                                          ],
                                        ),
                                        topLabel: 'Employee Details'),
                                  ],
                                ),
                              ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  onTapSaveButton() async {
    if (userRole == null) {
      setState(() {
        showDropDownError = true;
      });
    } else if (formKey.currentState!.validate()) {
      setState(() {
        loading = true;
      });

      //adding data
      UserData ud = UserData(
          openRegister: widget.edit ? widget.userData.openRegister : null,
          createdDate: widget.edit
              ? widget.selectedRowData!.createdDate
              : DateTime.now(),
          createdBy: widget.edit
              ? widget.selectedRowData!.createdBy
              : widget.userData.username,
          docId:
              widget.edit ? widget.selectedRowData!.docId : getRandomString(20),
          firstName: firstName!,
          lastName: lastName ?? '',
          username: userName!,
          employeeId: employeeId!,
          password: password!,
          userRole: userRole!,
          maxDiscount: maxDiscount ?? '0');

      await FbUserDbService(context: context).addUpdateUser([ud]);

      Navigator.pop(context, true);
    }
  }
}
