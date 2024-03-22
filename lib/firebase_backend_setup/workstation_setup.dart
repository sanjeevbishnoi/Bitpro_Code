import 'dart:io';
import 'package:bitpro_hive/model/store_data.dart';
import 'package:bitpro_hive/services/firestore_api/fb_settings/fb_store_db_service.dart';
import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:bitpro_hive/shared/global_variables/font_sizes.dart';
import 'package:bitpro_hive/shared/global_variables/static_text_translate.dart';
import 'package:bitpro_hive/shared/loading.dart';
import 'package:bitpro_hive/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:iconsax/iconsax.dart';

class WorkstationSetupPage extends StatefulWidget {
  final bool isEditing;
  final Map? firebaseBackendData;
  final String? selectedStoreDocId;
  final int? workstationNumber;

  const WorkstationSetupPage(
      {super.key,
      this.isEditing = false,
      this.selectedStoreDocId,
      this.workstationNumber,
      this.firebaseBackendData});

  @override
  State<WorkstationSetupPage> createState() => _WorkstationSetupPageState();
}

class _WorkstationSetupPageState extends State<WorkstationSetupPage> {
  bool showStoreError = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isLoading = true;
  List<StoreData> storeDataLst = [];
  StoreData? selectedStoreData;
  int? newWorkStationNumber;

  @override
  void initState() {
    initData();
    super.initState();
  }

  initData() async {
    storeDataLst =
        await FbStoreDbService(context: context).fetchAllStoresData();
    if (storeDataLst.isEmpty) {
      noStoreFoundError();
    } else if (widget.isEditing) {
      int i = storeDataLst
          .indexWhere((element) => element.docId == widget.selectedStoreDocId);
      if (i != -1) {
        selectedStoreData = storeDataLst.elementAt(i);
      }
      newWorkStationNumber = widget.workstationNumber;
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: homeBgColor,
        body: SafeArea(
            child: Stack(
          children: [
            Container(
                padding: const EdgeInsets.fromLTRB(10, 30, 10, 20),
                child: Center(
                  child: SizedBox(
                    width: 400,
                    height: 520,
                    child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        elevation: 5,
                        color: Colors.white,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          child: storeDataLst.isEmpty
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'No store data found in the Backend!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.red.shade800,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                          height: 45,
                                          width: 163,
                                          child: ElevatedButton(
                                              onPressed: () async {
                                                if (widget.isEditing) {
                                                  Navigator.pop(context);
                                                } else {
                                                  setState(() {
                                                    isLoading = true;
                                                  });

                                                  var box =
                                                      Hive.box('bitpro_app');

                                                  await box.put(
                                                      'firebase_backend_data',
                                                      null);
                                                }
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.navigate_before,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                      staticTextTranslate(
                                                          'Back'),
                                                      style: TextStyle(
                                                        fontSize:
                                                            getMediumFontSize,
                                                      )),
                                                ],
                                              )),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        SizedBox(
                                          height: 45,
                                          width: 165,
                                          child: ElevatedButton(
                                              onPressed: () async {
                                                setState(() {
                                                  isLoading = true;
                                                });

                                                initData();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.blue),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(Icons.refresh),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text('Refresh',
                                                      style: TextStyle(
                                                        fontSize:
                                                            getMediumFontSize,
                                                      )),
                                                ],
                                              )),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : Form(
                                  key: _formKey,
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Bitpro Workstation Setup',
                                            style: TextStyle(
                                                fontSize:
                                                    getExtraLargeFontSize + 6,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        const Text('Stores'),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(4)),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: DropdownButton<StoreData>(
                                            isExpanded: true,
                                            padding: EdgeInsets.zero,
                                            value: selectedStoreData,
                                            underline: const SizedBox(),
                                            hint: Text(
                                              staticTextTranslate(
                                                  'Select store'),
                                              style: TextStyle(
                                                fontSize: getMediumFontSize + 2,
                                              ),
                                            ),
                                            items: storeDataLst
                                                .map((StoreData storeData) {
                                              return DropdownMenuItem<
                                                  StoreData>(
                                                value: storeData,
                                                child: Text(
                                                  storeData.storeName,
                                                  style: TextStyle(
                                                    fontSize:
                                                        getMediumFontSize + 2,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (val) {
                                              setState(() {
                                                selectedStoreData = val;
                                              });
                                            },
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        if (showStoreError)
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Please selct a store',
                                              style: TextStyle(
                                                  fontSize: getSmallFontSize,
                                                  color: Colors.red[800]),
                                            ),
                                          ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        TextFormField(
                                          initialValue: newWorkStationNumber ==
                                                  null
                                              ? ''
                                              : newWorkStationNumber.toString(),
                                          decoration: const InputDecoration(
                                              alignLabelWithHint: true,
                                              labelText: 'Workstation Number',
                                              border: OutlineInputBorder()),
                                          validator: (val) {
                                            if (val == null ||
                                                int.tryParse(val) == null) {
                                              return 'Enter a valid number';
                                            } else if (val.isEmpty) {
                                              return 'Please enter a workstation number';
                                            }
                                          },
                                          onChanged: (val) {
                                            if (int.tryParse(val) != null) {
                                              newWorkStationNumber =
                                                  int.parse(val);

                                              setState(() {});
                                            }
                                          },
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            SizedBox(
                                              height: 45,
                                              width: 163,
                                              child: ElevatedButton(
                                                  onPressed: () {
                                                    if (widget.isEditing) {
                                                      Navigator.pop(context);
                                                    } else {
                                                      exit(0);
                                                    }
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Icon(
                                                        Icons.cancel,
                                                        color: Colors.white,
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Text(
                                                          staticTextTranslate(
                                                              widget.isEditing
                                                                  ? 'Back'
                                                                  : 'Exit'),
                                                          style: TextStyle(
                                                            fontSize:
                                                                getMediumFontSize,
                                                          )),
                                                    ],
                                                  )),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            SizedBox(
                                              height: 45,
                                              width: 165,
                                              child: ElevatedButton(
                                                  onPressed: () async {
                                                    setState(() {
                                                      isLoading = true;
                                                    });

                                                    bool canCallApi = true;
                                                    if (selectedStoreData ==
                                                        null) {
                                                      showStoreError = true;
                                                      canCallApi = false;
                                                    }

                                                    if (canCallApi &&
                                                        _formKey.currentState!
                                                            .validate()) {
                                                      //show dialog if workstation id already exist
                                                      bool callOnTap = true;

                                                      for (var w
                                                          in selectedStoreData!
                                                              .workstationInfo) {
                                                        if (w.toString() ==
                                                            newWorkStationNumber
                                                                .toString()) {
                                                          callOnTap = false;
                                                          await showWorkstationAlredyExistDialog();
                                                          break;
                                                        }
                                                      }

                                                      if (callOnTap) {
                                                        await onTapSaveButton();
                                                      }
                                                    } else {
                                                      setState(() {
                                                        isLoading = false;
                                                      });
                                                    }
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          selectedStoreData ==
                                                                      null ||
                                                                  showStoreError ==
                                                                      true
                                                              ? Colors.grey[400]
                                                              : Colors.blue),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Icon(Icons.done),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Text('Submit',
                                                          style: TextStyle(
                                                            fontSize:
                                                                getMediumFontSize,
                                                          )),
                                                    ],
                                                  )),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 30,
                                        ),
                                      ]),
                                ),
                        )),
                  ),
                )),
            if (isLoading)
              Container(
                  color: Colors.white,
                  child: Center(
                    child: showLoading(),
                  ))
          ],
        )));
  }

  noStoreFoundError() {
    var box = Hive.box('bitpro_app');
    var d = box.get('firebase_backend_data');
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context2) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(width: 0.2, color: Colors.grey)),
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Iconsax.danger,
                  size: 20,
                  color: Color.fromARGB(255, 143, 42, 35),
                ),
                const SizedBox(
                  width: 15,
                ),
                Text(
                  staticTextTranslate('Stores not found'),
                  style: TextStyle(fontSize: getMediumFontSize + 5),
                ),
              ],
            ),
            content: Text(
                staticTextTranslate(
                    'Stores not found on Project : ${d['projectId']} & Database : ${d['databaseName']}'),
                style: TextStyle(fontSize: getMediumFontSize)),
            actions: [
              SizedBox(
                height: 42,
                width: 173,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        side: const BorderSide(width: 0.1, color: Colors.grey),
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4))),
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        isLoading = true;
                      });
                      initData();
                    },
                    child: Text(staticTextTranslate('Refresh'),
                        style: TextStyle(
                            color: Colors.black, fontSize: getMediumFontSize))),
              ),
              SizedBox(
                height: 42,
                width: 173,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      side: const BorderSide(width: 0.1, color: Colors.grey),
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      setState(() {
                        isLoading = true;
                      });
                      await box.delete('firebase_backend_data');

                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Wrapper()));
                    },
                    child: Text(
                      staticTextTranslate('Reset Database'),
                      style: TextStyle(
                          color: Colors.white, fontSize: getMediumFontSize),
                    )),
              ),
            ],
          );
        });
  }

  onTapSaveButton({bool addWorkstationInFb = true}) async {
    //
    var box = Hive.box('bitpro_app');
    var resData = await box.get('firebase_backend_data');

    resData['workstationSetupDone'] = true;
    //updating default store id in hive
    await box.put('user_settings_data', {
      'companyName': '',
      'selectedStoreCode': int.parse(selectedStoreData!.storeCode),
      'workstationNumber': newWorkStationNumber
    });
    await box.put('showFirstFbDataLoadingDialog', true);

    //if worksation number already exist in fb then, don't need to update
    if (addWorkstationInFb) {
      StoreData temp = selectedStoreData!;
      print(temp.workstationInfo);
      if (temp.workstationInfo.contains(newWorkStationNumber) == false) {
        temp.workstationInfo.add(newWorkStationNumber);
      }
      print(temp.workstationInfo);
      await FbStoreDbService(context: context).addStoreData([temp]);
    }

    await box.put('firebase_backend_data', resData);
    if (widget.isEditing) {
      Navigator.pop(context, true);
    }
  }

  showWorkstationAlredyExistDialog() {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context2) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(width: 0.2, color: Colors.grey)),
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Iconsax.danger,
                  size: 20,
                  color: Color.fromARGB(255, 143, 42, 35),
                ),
                const SizedBox(
                  width: 15,
                ),
                Text(
                  staticTextTranslate(
                      'Workstation $newWorkStationNumber already exist'),
                  style: TextStyle(fontSize: getMediumFontSize + 5),
                ),
              ],
            ),
            content: Text(
                staticTextTranslate(
                    'Are you sure you want Workstation $newWorkStationNumber because it\'s already in use for Store ${selectedStoreData!.storeName}'),
                style: TextStyle(fontSize: getMediumFontSize)),
            actions: [
              SizedBox(
                height: 42,
                width: 173,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        side: const BorderSide(width: 0.1, color: Colors.grey),
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4))),
                    onPressed: () {
                      onTapSaveButton(addWorkstationInFb: false);
                      Navigator.pop(context);
                    },
                    child: Text(staticTextTranslate('Yes'),
                        style: TextStyle(
                            color: Colors.black, fontSize: getMediumFontSize))),
              ),
              SizedBox(
                height: 42,
                width: 173,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      side: const BorderSide(width: 0.1, color: Colors.grey),
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        isLoading = false;
                      });

                      Navigator.pop(context);
                    },
                    child: Text(
                      staticTextTranslate('No'),
                      style: TextStyle(
                          color: Colors.white, fontSize: getMediumFontSize),
                    )),
              ),
            ],
          );
        });
  }
}
