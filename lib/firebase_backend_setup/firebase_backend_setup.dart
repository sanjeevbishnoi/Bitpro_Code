import 'package:bitpro_hive/services/firestore_api/firebase_db_service.dart';
import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:bitpro_hive/shared/global_variables/font_sizes.dart';
import 'package:bitpro_hive/shared/global_variables/static_text_translate.dart';
import 'package:bitpro_hive/shared/loading.dart';
import 'package:bitpro_hive/widget/onpage_button.dart';
import 'package:bitpro_hive/widget/onpage_panel.dart';
import 'package:bitpro_hive/wrapper.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

class FirebaseBackendSetupPage extends StatefulWidget {
  final bool isChangeDatabase;
  final bool isMergeDatabase;
  const FirebaseBackendSetupPage(
      {super.key, this.isMergeDatabase = false, this.isChangeDatabase = false});

  @override
  State<FirebaseBackendSetupPage> createState() =>
      _FirebaseBackendSetupPageState();
}

class _FirebaseBackendSetupPageState extends State<FirebaseBackendSetupPage> {
  String projectId = '';
  String apiKey = '';
  String databaseName = '(default)';

  bool showProjectIdError = false;
  bool showApiKeyError = false;
  bool showDatabaseError = false;

  bool isLoading = false;
  String errMsg = '';

  @override
  void initState() {
    setWindowSize();
    super.initState();
  }

  setWindowSize() async {
    await DesktopWindow.setMinWindowSize(const Size(550, 650));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: homeBgColor,
        body: isLoading
            ? showLoading()
            : SafeArea(
                child: Container(
                    height: 400,
                    child: Center(
                      child: SizedBox(
                        height:
                            widget.isMergeDatabase || widget.isChangeDatabase
                                ? 800
                                : 400,
                        child: OnPagePanel(
                            columnForTextField: Column(
                              children: [
                                SizedBox(
                                  height: 40,
                                  child: TextFormField(
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color.fromARGB(
                                                    255, 13, 82, 139))),
                                        contentPadding:
                                            EdgeInsets.symmetric(
                                                vertical: 5, horizontal: 8),
                                        fillColor: Colors.white,
                                        filled: true,
                                        alignLabelWithHint: true,
                                        labelText: 'Project Id',
                                        border: OutlineInputBorder(
                                            borderSide:
                                                BorderSide(width: 0.3))),
                                    initialValue: projectId,
                                    onChanged: (val) {
                                      setState(() {
                                        projectId = val.trim();
                                        if (showProjectIdError) {
                                          showProjectIdError = false;
                                        }
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                if (showProjectIdError)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Please enter a project id',
                                      style: TextStyle(
                                          fontSize: getSmallFontSize,
                                          color: Colors.red[800]),
                                    ),
                                  ),
                                const SizedBox(
                                  height: 15,
                                ),
                                SizedBox(
                                  height: 40,
                                  child: TextFormField(
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color.fromARGB(
                                                    255, 13, 82, 139))),
                                        contentPadding:
                                            EdgeInsets.symmetric(
                                                vertical: 5, horizontal: 8),
                                        fillColor: Colors.white,
                                        filled: true,
                                        alignLabelWithHint: true,
                                        labelText: 'Api Key',
                                        border: OutlineInputBorder()),
                                    initialValue: apiKey,
                                    onChanged: (val) {
                                      setState(() {
                                        apiKey = val.trim();
                                        if (showApiKeyError) {
                                          showApiKeyError = false;
                                        }
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                if (showApiKeyError)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Please enter a api key',
                                      style: TextStyle(
                                          fontSize: getSmallFontSize,
                                          color: Colors.red[800]),
                                    ),
                                  ),
                                const SizedBox(
                                  height: 15,
                                ),
                                SizedBox(
                                  height: 40,
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Color.fromARGB(
                                                    255, 13, 82, 139))),
                                        contentPadding:
                                            EdgeInsets.symmetric(
                                                vertical: 5, horizontal: 8),
                                        fillColor: Colors.white,
                                        filled: true,
                                        alignLabelWithHint: true,
                                        labelText: 'Database Name',
                                        border: OutlineInputBorder()),
                                    initialValue: databaseName,
                                    onChanged: (val) {
                                      setState(() {
                                        databaseName = val;
                                        if (showDatabaseError) {
                                          showDatabaseError = false;
                                        }
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                if (showDatabaseError)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Please enter database name',
                                      style: TextStyle(
                                          fontSize: getSmallFontSize,
                                          color: Colors.red[800]),
                                    ),
                                  ),
                                const SizedBox(
                                  height: 10,
                                ),
                                SizedBox(height: 5,),
                                Text(
                                        errMsg,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.red.shade800,
                                            fontSize: 16),
                                      )
                              ],
                            ),
                            rowForButton: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(4),
                                      gradient: const LinearGradient(
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Color(0xff092F53),
                                            Color(0xff284F70),
                                          ],
                                          begin: Alignment.topCenter)),
                                  height: 45,
                                  width: 163,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                    ),
                                      onPressed: () async {
                                        if (widget.isMergeDatabase ||
                                            widget.isChangeDatabase) {
                                          Navigator.pop(context);
                                        } else {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          var box = Hive.box('bitpro_app');
                        
                                          await box.put(
                                              'firebase_backend_data', {
                                            'setupSkipped': true,
                                            'workstationSetupDone': false,
                                            'projectId': projectId,
                                            'apiKey': apiKey,
                                            'databaseName': databaseName
                                          });
                                          // setState(() {
                                          //   isLoading = false;
                                          // });
                                        }
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            widget.isMergeDatabase ||
                                                    widget.isChangeDatabase
                                                ? Icons
                                                    .navigate_before_outlined
                                                : Icons
                                                    .navigate_next_outlined,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                              staticTextTranslate(widget
                                                          .isMergeDatabase ||
                                                      widget
                                                          .isChangeDatabase
                                                  ? 'Back'
                                                  : 'Skip'),
                                              style: TextStyle(
                                                fontSize: getMediumFontSize,
                                              )),
                                        ],
                                      )),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(4),
                                      gradient: const LinearGradient(
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Color(0xff092F53),
                                            Color(0xff284F70),
                                          ],
                                          begin: Alignment.topCenter)),
                                  height: 45,
                                  width: 165,
                                  child: ElevatedButton(
                                      onPressed: () async {
                                        bool canCallApi = true;
                                        if (projectId.isEmpty) {
                                          showProjectIdError = true;
                                          canCallApi = false;
                                        }
                        
                                        if (apiKey.isEmpty) {
                                          showApiKeyError = true;
                                          canCallApi = false;
                                        }
                                        if (databaseName.isEmpty) {
                                          showDatabaseError = true;
                                          canCallApi = false;
                                        }
                        
                                        if (canCallApi) {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          String? resMsg =
                                              await FirebaseService(
                                                      context: context)
                                                  .checkApiKeyAuthIsCorrect(
                                                      ischangeDatabase: widget
                                                          .isChangeDatabase,
                                                      ismergeDatabase: widget
                                                          .isMergeDatabase,
                                                      apiKey: apiKey,
                                                      projectId: projectId,
                                                      databaseName:
                                                          databaseName);
                                          if (resMsg != null) {
                                            errMsg = resMsg;
                                            setState(() {
                                              isLoading = false;
                                            });
                                          }
                                        } else {
                                          setState(() {});
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: projectId.isEmpty
                                              ? Colors.grey[400]
                                              : Colors.transparent),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.done),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text('Submit',
                                              style: TextStyle(
                                                fontSize: getMediumFontSize,
                                              )),
                                        ],
                                      )),
                                ),
                              ],
                            ),
                            topLabel: "Birpro FireBase Setup"),
                      ),
                    ))));
  }
}
