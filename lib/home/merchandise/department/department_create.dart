import 'package:bitpro_hive/home/sales/customer/sideMenuButton.dart';
import 'package:bitpro_hive/services/firestore_api/fb_merchandise/fb_department_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/firebase_db_service.dart';
import 'package:bitpro_hive/widget/bTextField.dart';
import 'package:bitpro_hive/widget/onpage_button.dart';
import 'package:bitpro_hive/widget/onpage_panel.dart';
import 'package:bitpro_hive/widget/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:bitpro_hive/model/department_data.dart';
import 'package:bitpro_hive/model/user_data.dart';
import 'package:bitpro_hive/shared/loading.dart';
import '../../../shared/custom_top_nav_bar.dart';
import '../../../shared/dialogs/discard_changes_dialog.dart';
import '../../../shared/global_variables/font_sizes.dart';
import '../../../shared/global_variables/static_text_translate.dart';

class DepartmentCreatePage extends StatefulWidget {
  final UserData userData;
  final bool edit;
  final List<DepartmentData> allDepartmentDataLst;
  final DepartmentData? selectedRowData;
  final String newDepartmentId;
  const DepartmentCreatePage({
    Key? key,
    required this.userData,
    this.edit = false,
    this.selectedRowData,
    required this.allDepartmentDataLst,
    required this.newDepartmentId,
  }) : super(key: key);

  @override
  State<DepartmentCreatePage> createState() => _DepartmentCreatePageState();
}

class _DepartmentCreatePageState extends State<DepartmentCreatePage> {
  String? departmentId;
  String? departmentName;

  var formKey = GlobalKey<FormState>();
  bool loading = false;

  @override
  void initState() {
    if (widget.edit && widget.selectedRowData != null) {
      departmentId = widget.selectedRowData!.departmentId;
      departmentName = widget.selectedRowData!.departmentName;
    } else {
      departmentId = widget.newDepartmentId;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return customTopNavBar(
      Scaffold(
        backgroundColor: homeBgColor,
        body: SafeArea(
          child: Container(
            color: homeBgColor,
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  TopBar(pageName: 'Department'),
                  Expanded(
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
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 0,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 380,
                                width: 430,
                                child: loading
                                    ? showLoading()
                                    : OnPagePanel(
                                        columnForTextField: Column(
                                          children: [
                                            BTextField(
                                              label: 'Department Id',
                                              enabled: false,
                                              initialValue: departmentId,
                                              validator: ((value) {
                                                if (value!.isEmpty) {
                                                  return staticTextTranslate(
                                                      'Enter department id');
                                                } else if ((widget.edit &&
                                                        widget.selectedRowData!
                                                                .departmentId !=
                                                            value) ||
                                                    !widget.edit) {
                                                  if (widget
                                                      .allDepartmentDataLst
                                                      .where((e) =>
                                                          e.departmentId ==
                                                          value)
                                                      .isNotEmpty) {
                                                    return staticTextTranslate(
                                                        'ID is already in use');
                                                  }
                                                }
                                                return null;
                                              }),
                                              autovalidateMode: AutovalidateMode
                                                  .onUserInteraction,
                                              onChanged: (val) {},
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            BTextField(
                                              label: 'Department Name',
                                              initialValue: departmentName,
                                              validator: ((value) {
                                                if (value!.isEmpty) {
                                                  return staticTextTranslate(
                                                      'Enter department name');
                                                }
                                                return null;
                                              }),
                                              onChanged: (val) => setState(() {
                                                departmentName = val;
                                              }),
                                            ),
                                          ],
                                        ),
                                        rowForButton: Row(
                                          children: [
                                            OnPageButton(
                                                label: 'Back',
                                                onPressed: () {
                                                  showDiscardChangesDialog(
                                                      context);
                                                },
                                                icon: Iconsax.redo),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            OnPageButton(
                                                label: 'Save',
                                                onPressed: () async {
                                                  if (formKey.currentState!
                                                      .validate()) {
                                                    setState(() {
                                                      loading = true;
                                                    });

                                                    await FbDepartmentDbService(
                                                            context: context)
                                                        .addUpdateDepartmentData([
                                                      DepartmentData(
                                                        docId: widget.edit &&
                                                                widget.selectedRowData !=
                                                                    null
                                                            ? widget
                                                                .selectedRowData!
                                                                .docId
                                                            : getRandomString(
                                                                20),
                                                        departmentName:
                                                            departmentName!,
                                                        departmentId:
                                                            departmentId!,
                                                        createdDate: widget
                                                                    .edit &&
                                                                widget.selectedRowData !=
                                                                    null
                                                            ? widget
                                                                .selectedRowData!
                                                                .createdDate
                                                            : DateTime.now(),
                                                        createdBy: widget
                                                                    .edit &&
                                                                widget.selectedRowData !=
                                                                    null
                                                            ? widget
                                                                .selectedRowData!
                                                                .createdBy
                                                            : widget.userData
                                                                .username,
                                                      )
                                                    ]);

                                                    Navigator.pop(
                                                        context, true);

                                                    setState(() {
                                                      loading = false;
                                                    });
                                                  }
                                                },
                                                icon: Iconsax.archive),
                                          ],
                                        ),
                                        topLabel: 'Department Details'),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
