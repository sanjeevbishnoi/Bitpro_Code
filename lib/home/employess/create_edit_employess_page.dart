import 'package:bitpro_hive/services/firestore_api/fb_user_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/firebase_db_service.dart';
import 'package:flutter/material.dart';
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
          child: Container(
            color: homeBgColor,
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 2),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 0,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blue,
                            darkBlueColor,
                          ],
                        ),
                      ),
                      margin: const EdgeInsets.only(left: 0),
                      padding: const EdgeInsets.all(0),
                      width: 170,
                      height: 45,
                      child: const Center(
                        child: Text(
                          'BitPro',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    SizedBox(
                      height: 40,
                      width: 170,
                      child: TextButton(
                        style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(
                              size: 19,
                              Iconsax.back_square,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(staticTextTranslate('Back'),
                                style: TextStyle(
                                    fontSize: getMediumFontSize,
                                    color: Colors.grey[800])),
                          ],
                        ),
                        onPressed: () {
                          showDiscardChangesDialog(context);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  width: 0,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 0,
                      ),
                      SizedBox(
                        height: 35,
                        width: 370,
                        child: Row(children: [
                          const SizedBox(width: 10),
                          const Icon(
                            size: 17,
                            Iconsax.user,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            staticTextTranslate('Employees'),
                            style: TextStyle(
                              fontSize: getMediumFontSize,
                              color: const Color.fromARGB(255, 0, 0, 0),
                            ),
                          )
                        ]),
                      ),
                      const SizedBox(
                        height: 0,
                      ),
                      Expanded(
                        child: SizedBox(
                          width: double.maxFinite,
                          height: 120,
                          child: Card(
                              shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      width: 0.5, color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4)),
                              elevation: 0,
                              color: Colors.white,
                              child: loading
                                  ? showLoading()
                                  : Column(
                                      children: [
                                        Expanded(
                                          child: SingleChildScrollView(
                                            child: Form(
                                              key: formKey,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(22.0),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        staticTextTranslate(
                                                            'Employee Details'),
                                                        style: TextStyle(
                                                          fontSize:
                                                              getMediumFontSize,
                                                        )),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          height: 5,
                                                          width: 112,
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  darkBlueColor,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8)),
                                                        ),
                                                        Flexible(
                                                          child: Container(
                                                            height: 1,
                                                            width: double
                                                                .maxFinite,
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .grey[300],
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8)),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    ButtonBar(
                                                      alignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(
                                                          width: 280,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                  staticTextTranslate(
                                                                      'First Name'),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        getMediumFontSize -
                                                                            1,
                                                                  )),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              TextFormField(
                                                                initialValue:
                                                                    firstName,
                                                                validator:
                                                                    ((value) {
                                                                  if (value!
                                                                      .isEmpty) {
                                                                    return staticTextTranslate(
                                                                        'Enter your name');
                                                                  }
                                                                  return null;
                                                                }),
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                                decoration: const InputDecoration(
                                                                    isDense:
                                                                        true,
                                                                    contentPadding: EdgeInsets.symmetric(
                                                                        vertical:
                                                                            10,
                                                                        horizontal:
                                                                            15),
                                                                    border:
                                                                        OutlineInputBorder()),
                                                                onChanged:
                                                                    (val) =>
                                                                        setState(
                                                                            () {
                                                                  firstName =
                                                                      val;
                                                                }),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 20,
                                                          width: 30,
                                                        ),
                                                        SizedBox(
                                                          width: 280,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                  staticTextTranslate(
                                                                      'Username'),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        getMediumFontSize -
                                                                            1,
                                                                  )),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              TextFormField(
                                                                initialValue:
                                                                    userName,
                                                                autovalidateMode:
                                                                    AutovalidateMode
                                                                        .onUserInteraction,
                                                                enabled: !widget
                                                                    .edit,
                                                                validator:
                                                                    ((value) {
                                                                  if (value!
                                                                      .isEmpty) {
                                                                    return staticTextTranslate(
                                                                        'Enter your username');
                                                                  } else if ((widget
                                                                              .edit &&
                                                                          widget.selectedRowData!.username !=
                                                                              value) ||
                                                                      !widget
                                                                          .edit) {
                                                                    if (widget
                                                                        .empLstData
                                                                        .where((e) =>
                                                                            e.username ==
                                                                            value)
                                                                        .isNotEmpty) {
                                                                      return staticTextTranslate(
                                                                          'Username is already in use');
                                                                    }
                                                                  }
                                                                  return null;
                                                                }),
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: widget.edit
                                                                        ? Colors
                                                                            .grey
                                                                        : Colors
                                                                            .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                                decoration: const InputDecoration(
                                                                    isDense:
                                                                        true,
                                                                    contentPadding: EdgeInsets.symmetric(
                                                                        vertical:
                                                                            10,
                                                                        horizontal:
                                                                            15),
                                                                    border:
                                                                        OutlineInputBorder()),
                                                                onChanged:
                                                                    (val) =>
                                                                        setState(
                                                                            () {
                                                                  userName =
                                                                      val;
                                                                }),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    ButtonBar(
                                                      alignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(
                                                          width: 280,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                      staticTextTranslate(
                                                                          'Last Name '),
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            getMediumFontSize -
                                                                                1,
                                                                      )),
                                                                  Text(
                                                                    staticTextTranslate(
                                                                        '(optional)'),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            getSmallFontSize,
                                                                        color: Colors
                                                                            .grey),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              TextFormField(
                                                                initialValue:
                                                                    lastName,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                                decoration: const InputDecoration(
                                                                    isDense:
                                                                        true,
                                                                    contentPadding: EdgeInsets.symmetric(
                                                                        vertical:
                                                                            10,
                                                                        horizontal:
                                                                            15),
                                                                    border:
                                                                        OutlineInputBorder()),
                                                                onChanged:
                                                                    (val) =>
                                                                        setState(
                                                                            () {
                                                                  lastName =
                                                                      val;
                                                                }),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 20,
                                                          width: 30,
                                                        ),
                                                        SizedBox(
                                                          width: 280,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                  staticTextTranslate(
                                                                      'Password'),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        getMediumFontSize -
                                                                            1,
                                                                  )),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              TextFormField(
                                                                initialValue:
                                                                    password,
                                                                validator:
                                                                    ((value) {
                                                                  if (value!
                                                                      .isEmpty) {
                                                                    return staticTextTranslate(
                                                                        'Enter your password');
                                                                  }
                                                                  return null;
                                                                }),
                                                                obscureText:
                                                                    true,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                                decoration: const InputDecoration(
                                                                    isDense:
                                                                        true,
                                                                    contentPadding: EdgeInsets.symmetric(
                                                                        vertical:
                                                                            10,
                                                                        horizontal:
                                                                            15),
                                                                    border:
                                                                        OutlineInputBorder()),
                                                                onChanged:
                                                                    (val) =>
                                                                        setState(
                                                                            () {
                                                                  password =
                                                                      val;
                                                                }),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    ButtonBar(
                                                      alignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(
                                                          width: 280,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                  staticTextTranslate(
                                                                      'Employee Id'),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        getMediumFontSize -
                                                                            1,
                                                                  )),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              TextFormField(
                                                                initialValue:
                                                                    employeeId,
                                                                enabled: false,
                                                                // employeeId,
                                                                autovalidateMode:
                                                                    AutovalidateMode
                                                                        .onUserInteraction,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                                validator:
                                                                    ((value) {
                                                                  if (value!
                                                                      .isEmpty) {
                                                                    return staticTextTranslate(
                                                                        'Enter employee id');
                                                                  } else if ((widget
                                                                              .edit &&
                                                                          widget.selectedRowData!.employeeId !=
                                                                              value) ||
                                                                      !widget
                                                                          .edit) {
                                                                    if (widget
                                                                        .empLstData
                                                                        .where((e) =>
                                                                            e.employeeId ==
                                                                            value)
                                                                        .isNotEmpty) {
                                                                      return staticTextTranslate(
                                                                          'ID is already in use');
                                                                    }
                                                                  }
                                                                  return null;
                                                                }),
                                                                decoration: const InputDecoration(
                                                                    isDense:
                                                                        true,
                                                                    contentPadding: EdgeInsets.symmetric(
                                                                        vertical:
                                                                            10,
                                                                        horizontal:
                                                                            15),
                                                                    border:
                                                                        OutlineInputBorder()),
                                                                // onChanged:
                                                                //     (val) =>
                                                                //         setState(
                                                                //             () {
                                                                //   employeeId =
                                                                //       val;
                                                                // }),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 20,
                                                          width: 30,
                                                        ),
                                                        SizedBox(
                                                          width: 280,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                  staticTextTranslate(
                                                                      'Confirm Password'),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        getMediumFontSize -
                                                                            1,
                                                                  )),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              TextFormField(
                                                                initialValue:
                                                                    confirmPassword,
                                                                validator:
                                                                    ((value) {
                                                                  if (value!
                                                                      .isEmpty) {
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
                                                                obscureText:
                                                                    true,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                                decoration: const InputDecoration(
                                                                    isDense:
                                                                        true,
                                                                    contentPadding: EdgeInsets.symmetric(
                                                                        vertical:
                                                                            10,
                                                                        horizontal:
                                                                            15),
                                                                    border:
                                                                        OutlineInputBorder()),
                                                                onChanged:
                                                                    (val) =>
                                                                        setState(
                                                                            () {
                                                                  confirmPassword =
                                                                      val;
                                                                }),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    ButtonBar(
                                                      alignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        SizedBox(
                                                          width: 280,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                  staticTextTranslate(
                                                                      'User Role'),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        getMediumFontSize -
                                                                            1,
                                                                  )),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(5),
                                                                height: 35,
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    border: Border.all(
                                                                        color: Colors
                                                                            .grey),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            5)),
                                                                child:
                                                                    DropdownButton<
                                                                        String>(
                                                                  underline:
                                                                      const SizedBox(),
                                                                  isExpanded:
                                                                      true,
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
                                                                  value:
                                                                      userRole,
                                                                  items: widget
                                                                      .userGroupsDataLst
                                                                      .map((UserGroupData
                                                                          value) {
                                                                    return DropdownMenuItem<
                                                                        String>(
                                                                      value: value
                                                                          .name,
                                                                      child:
                                                                          Text(
                                                                        value
                                                                            .name,
                                                                        style: TextStyle(
                                                                            fontSize: getMediumFontSize +
                                                                                2,
                                                                            fontWeight:
                                                                                FontWeight.w400),
                                                                      ),
                                                                    );
                                                                  }).toList(),
                                                                  onChanged:
                                                                      (val) {
                                                                    setState(
                                                                        () {
                                                                      showDropDownError =
                                                                          false;
                                                                      userRole =
                                                                          val;
                                                                    });
                                                                  },
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              if (showDropDownError)
                                                                Text(
                                                                  staticTextTranslate(
                                                                      'Select a role'),
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          getSmallFontSize,
                                                                      color: Colors
                                                                              .red[
                                                                          800]),
                                                                )
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 20,
                                                          width: 30,
                                                        ),
                                                        SizedBox(
                                                          width: 280,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                      staticTextTranslate(
                                                                          'Max Discount % '),
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            getMediumFontSize -
                                                                                1,
                                                                      )),
                                                                  Text(
                                                                    staticTextTranslate(
                                                                        '(optional)'),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            getSmallFontSize,
                                                                        color: Colors
                                                                            .grey),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                height: 5,
                                                              ),
                                                              TextFormField(
                                                                maxLength: 3,
                                                                initialValue:
                                                                    maxDiscount,
                                                                maxLines: 1,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                                decoration: const InputDecoration(
                                                                    isDense:
                                                                        true,
                                                                    contentPadding: EdgeInsets.symmetric(
                                                                        vertical:
                                                                            10,
                                                                        horizontal:
                                                                            15),
                                                                    border:
                                                                        OutlineInputBorder()),
                                                                autovalidateMode:
                                                                    AutovalidateMode
                                                                        .onUserInteraction,
                                                                validator:
                                                                    (val) {
                                                                  if (double.tryParse(
                                                                          val!) ==
                                                                      null) {
                                                                    return staticTextTranslate(
                                                                        'Enter a valid number');
                                                                  } else if (double.parse(
                                                                              val) <
                                                                          0 ||
                                                                      double.parse(
                                                                              val) >
                                                                          110) {
                                                                    return staticTextTranslate(
                                                                        'Enter a value between 0 - 100%');
                                                                  }
                                                                  return null;
                                                                },
                                                                onChanged:
                                                                    (val) =>
                                                                        setState(
                                                                            () {
                                                                  maxDiscount =
                                                                      val;
                                                                }),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            height: 62,
                                            width: double.maxFinite,
                                            color: const Color(0xffdddfe8),
                                            child: Row(
                                              children: [
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                SizedBox(
                                                  height: 42,
                                                  width: 173,
                                                  child: ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.white,
                                                          shape: RoundedRectangleBorder(
                                                              side: const BorderSide(
                                                                  width: 0.5,
                                                                  color: Colors
                                                                      .grey),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          3))),
                                                      onPressed: () {
                                                        showDiscardChangesDialog(
                                                            context);
                                                      },
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Image.asset(
                                                            'assets/icons/cross-circle.png',
                                                            height: 20,
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            staticTextTranslate(
                                                                'Cancel'),
                                                            style: TextStyle(
                                                                fontSize:
                                                                    getMediumFontSize,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ],
                                                      )),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                SizedBox(
                                                  height: 42,
                                                  width: 173,
                                                  child: ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              darkBlueColor,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          3))),
                                                      onPressed: () async {
                                                        if (userRole == null) {
                                                          setState(() {
                                                            showDropDownError =
                                                                true;
                                                          });
                                                        } else if (formKey
                                                            .currentState!
                                                            .validate()) {
                                                          setState(() {
                                                            loading = true;
                                                          });

                                                          //adding data
                                                          UserData ud = UserData(
                                                              openRegister: widget.edit
                                                                  ? widget.userData
                                                                      .openRegister
                                                                  : null,
                                                              createdDate: widget.edit
                                                                  ? widget
                                                                      .selectedRowData!
                                                                      .createdDate
                                                                  : DateTime
                                                                      .now(),
                                                              createdBy: widget.edit
                                                                  ? widget
                                                                      .selectedRowData!
                                                                      .createdBy
                                                                  : widget
                                                                      .userData
                                                                      .username,
                                                              docId: widget.edit
                                                                  ? widget
                                                                      .selectedRowData!
                                                                      .docId
                                                                  : getRandomString(
                                                                      20),
                                                              firstName:
                                                                  firstName!,
                                                              lastName: lastName ??
                                                                  '',
                                                              username:
                                                                  userName!,
                                                              employeeId:
                                                                  employeeId!,
                                                              password:
                                                                  password!,
                                                              userRole:
                                                                  userRole!,
                                                              maxDiscount:
                                                                  maxDiscount ?? '0');

                                                          await FbUserDbService(
                                                                  context:
                                                                      context)
                                                              .addUpdateUser(
                                                                  [ud]);

                                                          Navigator.pop(
                                                              context, true);
                                                        }
                                                      },
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Icon(
                                                            Iconsax.archive,
                                                            size: 20,
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                              staticTextTranslate(
                                                                  'Save'),
                                                              style: TextStyle(
                                                                fontSize:
                                                                    getMediumFontSize,
                                                              )),
                                                        ],
                                                      )),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    )),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
