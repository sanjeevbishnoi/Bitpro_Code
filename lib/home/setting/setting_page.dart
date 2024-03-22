import 'dart:convert';
import 'dart:io';
import 'package:bitpro_hive/firebase_backend_setup/workstation_setup.dart';
import 'package:bitpro_hive/services/firestore_api/fb_settings/fb_settings_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_settings/hive_store_db_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:bitpro_hive/home/setting/inventory_tag_size.dart';
import 'package:bitpro_hive/home/setting/tabs/add_edit_store.dart';
import 'package:bitpro_hive/home/setting/tabs/store_tab.dart';
import 'package:bitpro_hive/model/store_data.dart';
import 'package:bitpro_hive/model/user_data.dart';
import 'package:bitpro_hive/services/firestore_api/fb_settings/fb_store_db_service.dart';
import 'package:bitpro_hive/services/hive/hive_settings/hive_settings_db_service.dart';
import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:bitpro_hive/shared/loading.dart';
import 'package:bitpro_hive/shared/toast.dart';
import '../../shared/global_variables/font_sizes.dart';
import '../../shared/global_variables/static_text_translate.dart';

class SettingsPage extends StatefulWidget {
  final UserData? userData;

  const SettingsPage({super.key, required this.userData});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool loading = true;
  int currentTabIndex = 0;
  //tab 1
  String companyName = '';
  String address = '';
  String phone1 = '';
  String phone2 = '';
  String email = '';
  String taxVatNo = '';
  String bankName = '';
  String ibanAccountNumber = '';
  File? productImage;
  //tab 1
  //tab 2
  String receiptTitleEng = '';
  String receiptTitleArb = '';

  String receiptFotterEng = '';
  String receiptFotterArb = '';

  String tagHeight = '1';
  String tagWidth = '2';
  String selectedReceiptTemplate = '80 mm';
  //tab 3
  String taxPercentage = '15';

  ///
  Map? userSettingsData;
  Map? userPrintingData;
  Map? userTaxesData;

  List<Printer> p = [];
  Printer? selectedPrinter;
  var box = Hive.box('bitpro_app');

  String licenseKey = '';
  String licenseAuth = '';
  Map? licenseData;
  bool showLicenseKeyError = false;
  bool showLicenseAuthError = false;
  TextEditingController keyController = TextEditingController();
  TextEditingController authController = TextEditingController();
  DateTime? licenseExpiryDate;
  //store tab fields
  StoreData? selectedStore;
  bool alowDeleteStore = true;
  List<StoreData> storeDataList = [];
  late StoreData defaultSelectedStoreData;
  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    await getPriterLst();
    await getUserData();
    await getLicenseData();

    setState(() {
      loading = false;
    });
  }

  getLicenseData() async {
    licenseData = box.get('license_data');
    if (licenseData != null) {
      licenseKey = licenseData!['key'];
      licenseAuth = licenseData!['auth'];
      licenseExpiryDate = DateTime.parse(licenseData!['expiry_date']);
      keyController.text = licenseKey;
      authController.text = licenseAuth;
    }
  }

  getPriterLst() async {
    p = await Printing.listPrinters();

    var activePrinter = box.get('active_printer');
    if (activePrinter != null) {
      if (Printer.fromMap(activePrinter).name ==
          'Select Printer While Printing') {
        selectedPrinter = const Printer(
            url: 'Select Printer While Printing',
            name: 'Select Printer While Printing');
      } else {
        for (var t in p) {
          if (t.name == Printer.fromMap(activePrinter).name) {
            selectedPrinter = t;
          }
        }
      }
    }
  }

  getCompanyDetailsPageData() async {
    userSettingsData = await box.get('user_settings_data');
    if (userSettingsData != null) {
      companyName = userSettingsData!['companyName'];
      storeDataList = await HiveStoreDbService().fetchAllStoresData();
      defaultSelectedStoreData =
          await HiveStoreDbService().getSelectedStoreData();
    }
  }

  getUserData() async {
    userPrintingData = await box.get('user_printing_settings');
    userTaxesData = await box.get('user_taxes_settings');
    await getCompanyDetailsPageData();
    if (userPrintingData != null) {
      receiptTitleEng = userPrintingData!['receiptTitleEng'];
      receiptTitleArb = userPrintingData!['receiptTitleArb'];

      receiptFotterEng = userPrintingData!['receiptFotterEng'];
      receiptFotterArb = userPrintingData!['receiptFotterArb'];
      tagHeight =
          // (double.parse(
          userPrintingData!['tagHeight'];
      // ) * 25.4).toString();
      tagWidth =
          // (double.parse(
          userPrintingData!['tagWidth'];
      // ) * 25.4).toString();

      selectedReceiptTemplate = userPrintingData!['selectedReceiptTemplate'];
    }
    if (userTaxesData != null) {
      taxPercentage = userTaxesData!['taxPercentage'].toString();
    }
  }

  fbStoreDataUpdate() async {
    setState(() {
      loading = true;
    });
    storeDataList =
        await FbStoreDbService(context: context).fetchAllStoresData();

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return showLoading();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 35,
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromARGB(255, 66, 66, 66),
                        Color.fromARGB(255, 0, 0, 0),
                      ],
                      begin: Alignment.topCenter)),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.6),
                          borderRadius: BorderRadius.circular(0),
                          gradient: const LinearGradient(
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xff092F53),
                                Color(0xff284F70),
                              ],
                              begin: Alignment.topCenter)),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          currentTabIndex = 0;
                        });
                      },
                      child: Text(
                        staticTextTranslate('Company Details'),
                        style: GoogleFonts.roboto(
                            fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                 
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.6)
                    ),
                    height: 35,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          currentTabIndex = 1;
                        });
                      },
                      child: Text(
                        staticTextTranslate('Printing'),
                        style:
                            GoogleFonts.roboto(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.6)
                    ),
                    height: 35,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          currentTabIndex = 2;
                        });
                      },
                      child: Text(
                        staticTextTranslate('Taxes'),
                        style:
                            GoogleFonts.roboto(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.6)
                    ),
                    height: 35,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          currentTabIndex = 3;
                        });
                      },
                      child: Center(
                        child: Text(
                          staticTextTranslate('License'),
                          style:
                              GoogleFonts.roboto(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.6)
                    ),
                    height: 35,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          currentTabIndex = 4;
                          selectedStore = null;
                        });
                      },
                      child: Text(
                        staticTextTranslate('Store'),
                        style:
                            GoogleFonts.roboto(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                if (currentTabIndex != 0)
                  Container(
                    height: 1,
                    width: currentTabIndex == 1
                        ? engSelectedLanguage
                            ? 142
                            : 100
                        : currentTabIndex == 2
                            ? engSelectedLanguage
                                ? 226
                                : 165
                            : currentTabIndex == 3
                                ? engSelectedLanguage
                                    ? 316
                                    : 165
                                : engSelectedLanguage
                                    ? 399
                                    : 165,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8)),
                  ),
                Container(
                  height: 5,
                  width: currentTabIndex == 0
                      ? engSelectedLanguage
                          ? 120
                          : 70
                      : currentTabIndex == 1
                          ? engSelectedLanguage
                              ? 70
                              : 40
                          : currentTabIndex == 2
                              ? engSelectedLanguage
                                  ? 60
                                  : 50
                              : currentTabIndex == 3
                                  ? engSelectedLanguage
                                      ? 70
                                      : 70
                                  : engSelectedLanguage
                                      ? 50
                                      : 70,
                  decoration: BoxDecoration(
                      color: darkBlueColor,
                      borderRadius: BorderRadius.circular(8)),
                ),
                Flexible(
                  child: Container(
                    height: 1,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
        ),
        Expanded(
          child: Padding(
              padding: const EdgeInsets.only(top: 18, left: 18, right: 18),
              child: currentTabIndex == 0
                  ? companyDetailsPage()
                  : currentTabIndex == 1
                      ? printingSettings()
                      : currentTabIndex == 2
                          ? texsSettings()
                          : currentTabIndex == 3
                              ? licenseSettings()
                              : SettingStoreTab(
                                  storeDataList: storeDataList,
                                  selectStore: (selectedStoreData) {
                                    selectedStore = selectedStoreData;
                                    setState(() {});
                                  },
                                )),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 62,
            width: double.maxFinite,
            color: Colors.grey,
            child: currentTabIndex == 4
                ? storeTabButtons()
                : Row(
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
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
                        height: 42,
                        width: 173,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4))),
                            onPressed: () async {
                              setState(() {
                                loading = true;
                              });
                              if (currentTabIndex == 0 ||
                                  currentTabIndex == 2) {
                                await FbSettingsDbService(context: context)
                                    .addUpdateSettingsData(
                                        companyName: companyName,
                                        taxPercentage: taxPercentage);
                                showToast(
                                    staticTextTranslate(
                                        'Settings saved, successfully'),
                                    context);
                              } else if (currentTabIndex == 1) {
                                await HiveSettingsDbService()
                                    .addUpdateTab2SettingsData(
                                        receiptTitleEng: receiptTitleEng,
                                        receiptTitleArb: receiptTitleArb,
                                        receiptFotterEng: receiptFotterEng,
                                        receiptFotterArb: receiptFotterArb,
                                        tagHeight: tagHeight,
                                        tagWidth: tagWidth,
                                        selectedReceiptTemplate:
                                            selectedReceiptTemplate);
                                showToast(
                                    staticTextTranslate(
                                        'Settings saved, successfully'),
                                    context);
                              } else if (currentTabIndex == 3) {
                                Codec<String, String> stringToBase64 =
                                    utf8.fuse(base64);
                                bool callApi = true;
                                int? noOfDays;
                                if (licenseAuth.isEmpty) {
                                  showLicenseKeyError = true;
                                  callApi = false;
                                } else {
                                  //key
                                  try {
                                    DeviceInfoPlugin deviceInfo =
                                        DeviceInfoPlugin();
                                    WindowsDeviceInfo win =
                                        await deviceInfo.windowsInfo;

                                    String keysDecoded = stringToBase64
                                        .decode(licenseKey); //MzY1

                                    if (win.productId != keysDecoded) {
                                      showLicenseKeyError = true;
                                      callApi = false;
                                    }
                                  } catch (e) {
                                    showLicenseKeyError = true;
                                    callApi = false;
                                  }
                                }

                                if (licenseKey.isEmpty) {
                                  showLicenseAuthError = true;
                                  callApi = false;
                                } else {
                                  //auth
                                  try {
                                    String decoded =
                                        stringToBase64.decode(licenseAuth);

                                    noOfDays = int.tryParse(decoded);

                                    if (noOfDays == null) {
                                      showLicenseAuthError = true;
                                      callApi = false;
                                    }
                                  } catch (e) {
                                    showLicenseAuthError = true;
                                    callApi = false;
                                  }
                                }

                                if (callApi && noOfDays != null) {
                                  DateTime d = DateTime.now();
                                  var box = Hive.box('bitpro_app');

                                  box.put('license_data', {
                                    "key": licenseKey,
                                    "auth": licenseAuth,
                                    "expiry_date": d
                                        .add(Duration(days: noOfDays))
                                        .toString()
                                  });
                                  showToast(
                                      staticTextTranslate(
                                          'Settings saved, successfully'),
                                      context);
                                }
                              }
                              // userData =
                              //     await UserDbService().fetchUserData(userData.docId);

                              setState(() {
                                loading = false;
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Iconsax.archive,
                                  size: 20,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  staticTextTranslate('Save'),
                                  style: TextStyle(
                                    fontSize: getMediumFontSize,
                                  ),
                                ),
                              ],
                            )),
                      ),
                    ],
                  ),
          ),
        )
      ],
    );
  }

  storeTabButtons() {
    return Row(
      children: [
        const SizedBox(
          width: 10,
        ),
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
            width: 40,
            height: 40,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.transparent,
                ),
                onPressed: () {
                  fbStoreDataUpdate();
                },
                child: const Center(
                  child: Icon(
                    Icons.refresh,
                  ),
                ))),
        const SizedBox(
          width: 10,
        ),
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
          height: 42,
          width: 173,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4))),
              onPressed: () async {
                bool res = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AddEditStore(storeDataLst: storeDataList)));

                if (res) {
                  await fbStoreDataUpdate();
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Iconsax.add,
                    size: 20,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    staticTextTranslate('Add Store'),
                    style: TextStyle(
                      fontSize: getMediumFontSize,
                    ),
                  ),
                ],
              )),
        ),
        const SizedBox(
          width: 10,
        ),
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

          height: 42,
          width: 173,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                  disabledBackgroundColor:Colors.grey[300] ,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4))),
              onPressed: selectedStore == null
                  ? null
                  : () async {
                      bool res = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddEditStore(
                                    storeDataLst: storeDataList,
                                    editData: true,
                                    storeData: selectedStore,
                                  )));

                      if (res) {
                        await fbStoreDataUpdate();
                      }
                    },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Iconsax.edit,
                    size: 20,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    staticTextTranslate('Edit Store'),
                    style: TextStyle(
                      fontSize: getMediumFontSize,
                    ),
                  ),
                ],
              )),
        ),
      ],
    );
  }

  licenseSettings() {
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (licenseExpiryDate != null)
          Text(
            staticTextTranslate(
                'Licensed Up to: ${DateFormat('MM-dd-yyyy').format(licenseExpiryDate!)}'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: getMediumFontSize, color: Colors.grey),
          ),
        const SizedBox(
          height: 15,
        ),
        Text(
          staticTextTranslate('Key'),
          style: GoogleFonts.roboto(fontSize: 14),
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          children: [
            SizedBox(
              height: 32,
              width: 330,
              child: TextFormField(
                obscureText: true,
                controller: keyController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                 style: GoogleFonts.roboto(fontSize: 14, height: 2.3),
                decoration: const InputDecoration(
                   enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 0.3)),
                  fillColor: Colors.white,
                  filled: true,
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                    border: OutlineInputBorder(
                      
                    )),
                    
                onChanged: (val) => setState(() {
                  licenseKey = val;
                  if (showLicenseKeyError) showLicenseKeyError = false;
                }),
              ),
            ),
            if (licenseData != null && licenseData!['key'] != licenseKey)
              IconButton(
                onPressed: () {
                  licenseKey = licenseData!['key'];
                  keyController.text = licenseKey;
                  setState(() {});
                },
                splashRadius: 2,
                tooltip: staticTextTranslate('Reset key'),
                icon: const Icon(
                  Icons.restore,
                  color: Colors.grey,
                ),
              )
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        if (showLicenseKeyError)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              staticTextTranslate('Please enter a valid license key'),
              style:
                  TextStyle(fontSize: getSmallFontSize, color: Colors.red[800]),
            ),
          ),
        const SizedBox(
          height: 15,
        ),
        Text(
          staticTextTranslate('Auth'),
          style: GoogleFonts.roboto(fontSize: 14),
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          children: [
            SizedBox(
              height: 32,
              width: 330,
              child: TextFormField(
                obscureText: true,
                controller: authController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                
                    style: GoogleFonts.roboto(fontSize: 14, height: 2.3),
                decoration: const InputDecoration(
                   enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 0.3)),
                  fillColor: Colors.white,
                  filled: true,
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 5, horizontal: 5 ),
                    border: OutlineInputBorder()),
                onChanged: (val) => setState(() {
                  licenseAuth = val;
                  if (showLicenseAuthError) showLicenseAuthError = false;
                }),
              ),
            ),
            if (licenseData != null && licenseData!['auth'] != licenseAuth)
              IconButton(
                onPressed: () {
                  licenseAuth = licenseData!['auth'];
                  authController.text = licenseAuth;
                  setState(() {});
                },
                splashRadius: 2,
                tooltip: staticTextTranslate('Reset auth'),
                icon: const Icon(
                  Icons.restore,
                  color: Colors.grey,
                ),
              )
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        if (showLicenseAuthError)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              staticTextTranslate('Please enter a valid license auth'),
              style:
                  TextStyle(fontSize: getSmallFontSize, color: Colors.red[800]),
            ),
          ),
        const SizedBox(
          height: 5,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
              onPressed: () async {
                DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                WindowsDeviceInfo win = await deviceInfo.windowsInfo;
                await Clipboard.setData(ClipboardData(text: win.productId));
                showToast(staticTextTranslate('Copied!'), context);
              },
              child: Text(
                staticTextTranslate('Copy Device Id'),
               style: GoogleFonts.roboto(fontSize: 14),
              )),
        ),
      ],
    ));
  }

  texsSettings() {
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          staticTextTranslate('Tax Percentage'),
          style: GoogleFonts.roboto(fontSize: 14),),
        const SizedBox(
          height: 5,
        ),
        SizedBox(
          width: 250,
          height: 32,
          child: TextFormField(
            initialValue: taxPercentage,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (double.tryParse(value ?? '') == null) {
                return staticTextTranslate('Enter a valid number');
              }
              return null;
            },
           style: GoogleFonts.roboto(fontSize: 14),
            decoration: const InputDecoration(
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 0.3)),
              fillColor: Colors.white,
              filled: true,
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                border: OutlineInputBorder()),
            onChanged: (val) => setState(() {
              if (double.tryParse(val) != null) {
                taxPercentage = val;
              }
            }),
          ),
        ),
      ],
    ));
  }

  printingSettings() {
    return SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(staticTextTranslate('Receipt Printer'),
          style: GoogleFonts.roboto(fontSize: 14)),
      const SizedBox(
        height: 5,
      ),
      Container(
        height: 32,
        width: 500,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(width: 0.3),
            borderRadius: BorderRadius.circular(4)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            hint: Text(staticTextTranslate('Select Printer'),
                style: GoogleFonts.roboto(fontSize: 15, color: Colors.black)),
            items: p.map((Printer value) {
                  return DropdownMenuItem<String>(
                    value: value.name,
                    child: Text(
                      value.name,
                      style: TextStyle(fontSize: getMediumFontSize),
                    ),
                  );
                }).toList() +
                [
                  DropdownMenuItem<String>(
                    value: 'Select Printer While Printing',
                    child: Text(
                      staticTextTranslate('Select Printer While Printing'),
                      style: TextStyle(fontSize: getMediumFontSize),
                    ),
                  )
                ],
            value: selectedPrinter == null ? null : selectedPrinter!.name,
            onChanged: (value) {
              var box = Hive.box('bitpro_app');
              if (value == 'Select Printer While Printing') {
                selectedPrinter = const Printer(
                    url: 'Select Printer While Printing',
                    name: 'Select Printer While Printing');
                box.put('active_printer', selectedPrinter!.toMap());
              } else {
                selectedPrinter =
                    p.firstWhere((element) => element.name == value);
                if (selectedPrinter != null) {
                  box.put('active_printer', selectedPrinter!.toMap());
                }
              }
              setState(() {});
            },
          ),
        ),
      ),
      const SizedBox(
        height: 20,
      ),
      Text(staticTextTranslate('Default Receipt Template'),
          style: GoogleFonts.roboto(fontSize: 14)),
      const SizedBox(
        height: 5,
      ),
      Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(width: 0.3),
            borderRadius: BorderRadius.circular(4)),
        width: 500,
        height: 32,
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: selectedReceiptTemplate,
            items: <String>[
              'DES0001-A4',
              'DES0002-A4',
              'DES0003-A4',
              'DES0004-A4',
              '80 mm',
              '80 mm No Vat',
              'ECS-POS-80mm'
            ].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value,
                    style:
                        GoogleFonts.roboto(fontSize: 14, color: Colors.black)),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                selectedReceiptTemplate = val ?? '80 mm';
              });
            },
          ),
        ),
      ),
      const SizedBox(
        height: 20,
      ),
      SizedBox(
        width: 500,
        child: Row(
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(staticTextTranslate('Receipt Title (English)'),
                      style: GoogleFonts.roboto(fontSize: 14)),
                  const SizedBox(
                    height: 5,
                  ),
                  TextFormField(
                    initialValue: receiptTitleEng,
                    style: GoogleFonts.roboto(fontSize: 14, height: 1.4),
                    decoration: const InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 0.3)),
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        border: OutlineInputBorder()),
                    onChanged: (val) => setState(() {
                      receiptTitleEng = val;
                    }),
                  )
                ],
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(staticTextTranslate('Receipt Title (Arabic)'),
                      style: GoogleFonts.roboto(fontSize: 14)),
                  const SizedBox(
                    height: 5,
                  ),
                  TextFormField(
                    initialValue: receiptTitleArb,
                    // validator:
                    //     ((value) {
                    //   if (value!
                    //       .isEmpty)
                    //     return 'Enter email';
                    // }),
                    style: GoogleFonts.roboto(fontSize: 14, height: 1.4),
                    decoration: const InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 0.3)),
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        border: OutlineInputBorder()),
                    onChanged: (val) => setState(() {
                      receiptTitleArb = val;
                    }),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                width: 240,
                height: 20,
              ),
              Text(
                staticTextTranslate('Receipt Footer (English)'),
                style: GoogleFonts.roboto(fontSize: 14, height: 1.4),
              ),
              const SizedBox(
                height: 5,
              ),
              SizedBox(
                width: 240,
                child: TextFormField(
                  initialValue: receiptFotterEng,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w400),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 0.3)),
                      fillColor: Colors.white,
                      filled: true,
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                      border: OutlineInputBorder()),
                  onChanged: (val) => setState(() {
                    receiptFotterEng = val;
                  }),
                ),
              ),
            ],
          ),
          SizedBox(width: 20,),
          Column(
             crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
                width: 240,
              ),
              Text(
                staticTextTranslate('Receipt Footer (Arabic)'),
                style: TextStyle(fontSize: getMediumFontSize - 1),
              ),
              const SizedBox(
                height: 5,
              ),
              SizedBox(
                width: 240,
                child: TextFormField(
                  initialValue: receiptFotterArb,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w400),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 0.3)),
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                      border: OutlineInputBorder()),
                      
                  onChanged: (val) => setState(() {
                    receiptFotterArb = val;
                  }),
                ),
              ),
            ],
          )
        ],
      ),
      const SizedBox(
        height: 20,
      ),
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
          height: 42,
          width: 173,
          child: ElevatedButton.icon(
              icon: const Icon(Iconsax.scan),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4))),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => InventoryTagSize()));
              },
              label: Text(
                staticTextTranslate('Barcode Settings'),
                style: GoogleFonts.roboto(fontSize: 14)
              ))),
      const SizedBox(
        height: 10,
      ),
      const SizedBox(
        height: 20,
      ),
    ]));
  }

  companyDetailsPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          staticTextTranslate('Company name'),
          style: GoogleFonts.roboto(fontSize: 14),
        ),
        const SizedBox(
          height: 5,
        ),
        SizedBox(
          width: 350,
          child: TextFormField(
            initialValue: companyName,
            style: GoogleFonts.roboto(fontSize: 15, height: 1.5),
            decoration: const InputDecoration(
                fillColor: Colors.white,
                filled: true,
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                border: OutlineInputBorder(
                  borderSide: BorderSide(width: 0.3),
                ),
                enabledBorder:
                    OutlineInputBorder(borderSide: BorderSide(width: 0.3))),
            onChanged: (val) => setState(() {
              companyName = val;
            }),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(width: 0.3),
            color: Color.fromARGB(255, 236, 248, 250),
          ),
          height: 140,
          child: Row(
            children: [
              Container(
                child: Icon(
                  Icons.store,
                  size: 40,
                  color: Color.fromARGB(255, 131, 148, 153),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 230,
                    child: Text(
                      staticTextTranslate(
                          userSettingsData!['workstationNumber'] == null
                              ? 'Selected store'
                              : 'Store & Workstation Details'),
                      style: GoogleFonts.roboto(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Container(
                      width: 233,
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(width: 0.4))),
                    ),
                  ),
                  SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Store Name : ',
                          style: GoogleFonts.roboto(fontSize: 16),
                        ),
                        Text(defaultSelectedStoreData.storeName,
                            style: GoogleFonts.roboto(fontSize: 16)),
                      ],
                    ),
                  ),
                  if (userSettingsData!['workstationNumber'] != null)
                    SizedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Workstation : ',
                              style: GoogleFonts.roboto(fontSize: 16)),
                          Text(
                              userSettingsData!['workstationNumber'].toString(),
                              style: GoogleFonts.roboto(fontSize: 16)),
                        ],
                      ),
                    ),
                  SizedBox(
                    child: Align(
                      child: TextButton(
                          onPressed: () async {
                            bool res = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WorkstationSetupPage(
                                        isEditing: true,
                                        selectedStoreDocId:
                                            defaultSelectedStoreData.docId,
                                        workstationNumber: userSettingsData![
                                            'workstationNumber'])));
                            if (res) {
                              setState(() {
                                loading = true;
                              });
                              await getCompanyDetailsPageData();
                              setState(() {
                                loading = false;
                              });
                            }
                          },
                          child: Text(
                            'Change store',
                            style: GoogleFonts.roboto(fontSize: 14),
                          )),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
