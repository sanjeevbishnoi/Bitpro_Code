import 'package:bitpro_hive/services/firestore_api/fb_user_group_db_service.dart';
import 'package:bitpro_hive/services/firestore_api/firebase_db_service.dart';
import 'package:bitpro_hive/services/providers/fetching_data_provider.dart';
import 'package:bitpro_hive/widget/top_bar.dart';
import 'package:bitpro_hive/wrapper.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:iconsax/iconsax.dart';
import 'package:bitpro_hive/home/purchase/purchase_page.dart';
import 'package:bitpro_hive/home/employess/employees_page.dart';
import 'package:bitpro_hive/home/reports/reports_page.dart';
import 'package:bitpro_hive/home/sales/sales_page.dart';
import 'package:bitpro_hive/home/setting/setting_page.dart';
import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:bitpro_hive/shared/loading.dart';
import 'package:provider/provider.dart';
import '../model/user_data.dart';
import '../model/user_group_data.dart';
import '../shared/dialogs/language_select_dialog.dart';
import '../shared/global_variables/font_sizes.dart';
import '../shared/global_variables/static_text_translate.dart';
import 'backup_and_restore/backup_and_restore_page.dart';
import 'merchandise/merchandise_page.dart';

class HomePage extends StatefulWidget {
  final UserData userData;
  const HomePage({Key? key, required this.userData}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedTabIndex = 1;
  UserGroupData? currentUserRole;
  var box = Hive.box('bitpro_app');

  bool isLoading = true;
  List<UserGroupData> userGroupsDataLst = [];
  @override
  void initState() {
    super.initState();
    initData();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setWindowSize();
    });
  }

  initData() async {
    bool showFbDataFetchingDialog =
        //  true;
        await box.get('showFirstFbDataLoadingDialog') ?? false;
    bool showFbDataMergingDialog =
        await box.get('showFirstFbDataMergingDialog') ?? false;

    if (globalIsFbSetupSkipted == false) {
      if (showFbDataMergingDialog) {
        // merging
        showDialogMergingDataFromFirebase();
        await FirebaseService(context: context).mergeHiveDataWithFirebase();
        await box.put('showFirstFbDataMergingDialog', false);
        Navigator.pop(context);
      } else if (showFbDataFetchingDialog) {
        // fetching
        showDialogFetchingDataFromFirebase();
        await FirebaseService(context: context).updateHiveDataWithFirebase();
        await box.put('showFirstFbDataLoadingDialog', false);
        Navigator.pop(context);
      }
    }

    //Fetching & Updating userGroup data if userRole not found
    if (userGroupsDataLst
            .indexWhere((e) => e.name == widget.userData.userRole) ==
        -1) {
      userGroupsDataLst =
          await FbUserGroupDbService(context: context).fetchAllUserGroups();
    }
    //updating loggedIn UserRole info
    int index =
        userGroupsDataLst.indexWhere((e) => e.name == widget.userData.userRole);
    if (index != -1) {
      currentUserRole = userGroupsDataLst.elementAt(index);
    } else {
      print('userrole not found');
    }

    setState(() {
      isLoading = false;
    });
  }

  setWindowSize() async {
    await DesktopWindow.setMinWindowSize(const Size(850, 600));
  }

  showDialogMergingDataFromFirebase() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Column(
            children: [
              Text('Merging Data, Please wait...'),
              SizedBox(
                height: 10,
              ),
              CupertinoActivityIndicator(),
            ],
          ),
        );
      },
    );
  }

  showDialogFetchingDataFromFirebase() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Column(
            children: [
              const Text('Fetching Data, Please wait...'),
              const SizedBox(
                height: 15,
              ),
              LinearProgressIndicator(
                value: context.watch<FetchingDataProvider>().progressValue,
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: showLoading()),
      );
    }

    return Scaffold(
        backgroundColor: homeBgColor,
        body: currentUserRole == null
            ? const Center(
                child: Text(
                  "User Role not found",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
              )
            : Stack(
                children: [
                  SafeArea(
                    child: Column(
                      children: [
                        TopBar(),
                        Expanded(
                          child: Container(
                            color: Colors.grey,
                            child: Row(
                              children: [
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height /
                                        1.05,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            color:
                                                Color.fromARGB(255, 43, 43, 43),
                                            child: Column(
                                              children: [
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                if (currentUserRole == null ||
                                                    !(!currentUserRole!
                                                            .receipt &&
                                                        !currentUserRole!
                                                            .customers &&
                                                        !currentUserRole!
                                                            .registers &&
                                                        !currentUserRole!
                                                            .formerZout))
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        selectedTabIndex = 1;
                                                      });
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color: selectedTabIndex ==
                                                                  1
                                                              ? const Color
                                                                  .fromARGB(255,
                                                                  17, 17, 17)
                                                              : Colors
                                                                  .transparent,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(0)),
                                                      height: 40,
                                                      width: 170,
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Image.asset(
                                                            'assets/icons/sales.png',
                                                            width: 23,
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            staticTextTranslate(
                                                                'Sales'),
                                                            style: TextStyle(
                                                                color: selectedTabIndex ==
                                                                        1
                                                                    ? darkBlueColor
                                                                    : Colors
                                                                        .white,
                                                                fontSize:
                                                                    getMediumFontSize),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                if (currentUserRole == null ||
                                                    currentUserRole!
                                                        .purchaseVoucher)
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        selectedTabIndex = 2;
                                                      });
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color: selectedTabIndex ==
                                                                  2
                                                              ? const Color
                                                                  .fromARGB(255,
                                                                  17, 17, 17)
                                                              : Colors
                                                                  .transparent,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(0)),
                                                      height: 40,
                                                      width: 170,
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Image.asset(
                                                            'assets/icons/purchase.png',
                                                            width: 23,
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            staticTextTranslate(
                                                                'Purchase'),
                                                            style: TextStyle(
                                                                color: selectedTabIndex ==
                                                                        2
                                                                    ? darkBlueColor
                                                                    : Colors
                                                                        .white,
                                                                fontSize:
                                                                    getMediumFontSize),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                if (currentUserRole == null ||
                                                    !(!currentUserRole!.inventory &&
                                                        !currentUserRole!
                                                            .vendors &&
                                                        !currentUserRole!
                                                            .departments &&
                                                        !currentUserRole!
                                                            .adjustment))
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        selectedTabIndex = 3;
                                                      });
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color: selectedTabIndex ==
                                                                  3
                                                              ? const Color
                                                                  .fromARGB(255,
                                                                  17, 17, 17)
                                                              : Colors
                                                                  .transparent,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(0)),
                                                      height: 40,
                                                      width: 170,
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Image.asset(
                                                            'assets/icons/merchandise.png',
                                                            width: 23,
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            staticTextTranslate(
                                                                'Merchandise'),
                                                            style: TextStyle(
                                                                color: selectedTabIndex ==
                                                                        3
                                                                    ? darkBlueColor
                                                                    : Colors
                                                                        .white,
                                                                fontSize:
                                                                    getMediumFontSize),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                                if (currentUserRole == null ||
                                                    currentUserRole!.reports)
                                                  GestureDetector(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      ReportsPage(
                                                                        userData:
                                                                            widget.userData,
                                                                      )));
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color: selectedTabIndex ==
                                                                  4
                                                              ? const Color
                                                                  .fromARGB(255,
                                                                  17, 17, 17)
                                                              : Colors
                                                                  .transparent,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(0)),
                                                      height: 40,
                                                      width: 170,
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Image.asset(
                                                            'assets/icons/report.png',
                                                            width: 23,
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            staticTextTranslate(
                                                                'Reports'),
                                                            style: TextStyle(
                                                                color: selectedTabIndex ==
                                                                        4
                                                                    ? const Color
                                                                        .fromARGB(
                                                                        255,
                                                                        17,
                                                                        17,
                                                                        17)
                                                                    : Colors
                                                                        .white,
                                                                fontSize:
                                                                    getMediumFontSize),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                if (currentUserRole == null ||
                                                    !(!currentUserRole!
                                                            .employees &&
                                                        !currentUserRole!
                                                            .groups))
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        selectedTabIndex = 5;
                                                      });
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color: selectedTabIndex ==
                                                                  5
                                                              ? const Color
                                                                  .fromARGB(255,
                                                                  17, 17, 17)
                                                              : Colors
                                                                  .transparent,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(0)),
                                                      height: 40,
                                                      width: 170,
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Image.asset(
                                                            'assets/icons/employees.png',
                                                            width: 23,
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            staticTextTranslate(
                                                                'Employees'),
                                                            style: TextStyle(
                                                                color: selectedTabIndex ==
                                                                        5
                                                                    ? darkBlueColor
                                                                    : Colors
                                                                        .white,
                                                                fontSize:
                                                                    getMediumFontSize),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                GestureDetector(
                                                  onTap: () {
                                                    showLanguageSelectDialog(
                                                        context);
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Colors.transparent,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(0)),
                                                    height: 40,
                                                    width: 170,
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Image.asset(
                                                          'assets/icons/language.png',
                                                          width: 23,
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                          staticTextTranslate(
                                                              'Language'),
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize:
                                                                  getMediumFontSize),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                if (currentUserRole == null ||
                                                    currentUserRole!.settings)
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        selectedTabIndex = 6;
                                                      });
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color: selectedTabIndex ==
                                                                  6
                                                              ? const Color
                                                                  .fromARGB(255,
                                                                  17, 17, 17)
                                                              : Colors
                                                                  .transparent,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(0)),
                                                      height: 40,
                                                      width: 170,
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Image.asset(
                                                            'assets/icons/settings.png',
                                                            width: 23,
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            staticTextTranslate(
                                                                'Preferences'),
                                                            style: TextStyle(
                                                                color: selectedTabIndex ==
                                                                        6
                                                                    ? darkBlueColor
                                                                    : Colors
                                                                        .white,
                                                                fontSize:
                                                                    getMediumFontSize),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                if (currentUserRole == null ||
                                                    currentUserRole!
                                                        .backupReset)
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        selectedTabIndex = 7;
                                                      });
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color: selectedTabIndex ==
                                                                  7
                                                              ? Color.fromARGB(
                                                                  255,
                                                                  75,
                                                                  75,
                                                                  75)
                                                              : Colors
                                                                  .transparent,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(0)),
                                                      height: 40,
                                                      width: 170,
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Image.asset(
                                                            'assets/icons/backup.png',
                                                            width: 23,
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            staticTextTranslate(
                                                                'Backup & Restore'),
                                                            style: GoogleFonts
                                                                .roboto(
                                                                    fontSize:
                                                                        getMediumFontSize +
                                                                            1,
                                                                    color: Colors
                                                                        .white),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                GestureDetector(
                                                  onTap: () async {
                                                    Box box =
                                                        Hive.box('bitpro_app');
                                                    await box.put(
                                                        'is_user_logged_in',
                                                        false);
                                                    await box
                                                        .delete('user_data');
                                                    setState(() {});
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(0)),
                                                    height: 40,
                                                    width: 170,
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        Image.asset(
                                                          'assets/icons/logout.png',
                                                          width: 23,
                                                        ),
                                                        const SizedBox(
                                                            width: 10),
                                                        Text(
                                                          staticTextTranslate(
                                                              'Logout'),
                                                          style: GoogleFonts.roboto(
                                                              fontSize:
                                                                  getMediumFontSize +
                                                                      1,
                                                              color:
                                                                  Colors.white),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Container(
                                        //   margin: EdgeInsets.only(bottom: 10),
                                        //   padding: EdgeInsets.all(10),
                                        //   height: 170,
                                        //   width: 170,
                                        //   decoration: BoxDecoration(
                                        //     borderRadius: BorderRadius.circular(4),
                                        //     gradient: LinearGradient(
                                        //       begin: Alignment.topLeft,
                                        //       end: Alignment.bottomRight,
                                        //       colors: [
                                        //         Colors.blue,
                                        //         darkBlueColor,
                                        //       ],
                                        //     ),
                                        //   ),
                                        //   child: Column(
                                        //     mainAxisAlignment: MainAxisAlignment.start,
                                        //     crossAxisAlignment: CrossAxisAlignment.start,
                                        //     children: [
                                        //     Text("Bitpro V 1.5.1", style: TextStyle(color: Colors.white),),

                                        //     SizedBox(height: 15,),
                                        //     Center(child: Icon(Icons.add_moderator_outlined, color: Colors.white, size: 74,))
                                        //   ],),
                                        // )
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(5),
                                        height: 23,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            // Text(
                                            //   'Store: Jeddah',
                                            //   style: GoogleFonts.roboto(
                                            //       fontSize: 13),
                                            // ),
                                            // SizedBox(
                                            //   width: 23,
                                            // ),
                                            // Text(
                                            //   'Price Level: Prlvl1',
                                            //   style: GoogleFonts.roboto(
                                            //       fontSize: 13),
                                            // ),
                                            // SizedBox(width: 10,),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          color: Colors.grey[300],
                                          width: double.maxFinite,
                                          child: Card(
                                              shape: RoundedRectangleBorder(
                                                  side: const BorderSide(
                                                      width: 0.5,
                                                      color: Colors.grey),
                                                  borderRadius:
                                                      BorderRadius.circular(0)),
                                              elevation: 0,
                                              child: Container(
                                                color: Colors.grey[300],
                                                child: Padding(
                                                    padding: selectedTabIndex ==
                                                            6
                                                        ? const EdgeInsets.all(
                                                            0)
                                                        : const EdgeInsets.all(
                                                            10.0),
                                                    child: getCurrentPage()),
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
                      ],
                    ),
                  ),
                  //loading data in background
                  loadingInBgWidget()
                ],
              ));
  }

  Widget loadingInBgWidget() {
    //loading data in background
    if (context.watch<FetchingDataProvider>().fetching) {
      return Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          color: Colors.grey.shade300,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Text('${context.watch<FetchingDataProvider>().info}....'),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  getCurrentPage() {
    switch (selectedTabIndex) {
      case 1:
        return SalesPage(
          userData: widget.userData,
          currentUserRole: currentUserRole!,
        );
      case 2:
        return PurchasePage(
          userData: widget.userData,
          currentUserRole: currentUserRole!,
        );
      case 3:
        return MerchandisePage(
          userData: widget.userData,
          currentUserRole: currentUserRole!,
        );
      case 6:
        return SettingsPage(
          userData: widget.userData,
        );
      case 7:
        return const BackupAndRestore();
      default:
        return EmployeesPage(
          userGroupsDataLst: userGroupsDataLst,
          userData: widget.userData,
          currentUserRole: currentUserRole!,
        );
    }
  }
}
