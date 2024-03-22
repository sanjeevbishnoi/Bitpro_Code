import 'dart:convert';
import 'dart:io';
import 'package:desktop_window/desktop_window.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:bitpro_hive/shared/global_variables/color.dart';
import 'package:bitpro_hive/shared/global_variables/font_sizes.dart';
import 'package:bitpro_hive/shared/loading.dart';
import '../../shared/global_variables/static_text_translate.dart';
import '../../shared/toast.dart';

class LicenseModule extends StatefulWidget {
  final DateTime? licenseExpiredDate;
  const LicenseModule({Key? key, this.licenseExpiredDate}) : super(key: key);

  @override
  State<LicenseModule> createState() => _LicenseModuleState();
}

// const String key1 = 'mxuTkzdFyY4O3HcHyDNI'; // - for 30 days
// const String key2 = 'YdoYt2AQD01D0gqJEqkW'; // - for 365 days

class _LicenseModuleState extends State<LicenseModule> {
  String licenseKey = '';
  String licenseAuth = '';

  bool showLicenseKeyError = false;
  bool showLicenseAuthError = false;

  bool isLoading = false;
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
    if (isLoading) return showLoading();
    return Scaffold(
        backgroundColor: homeBgColor,
        body: SafeArea(
            child: Container(
                  // decoration: const BoxDecoration(
                  //       image: DecorationImage(
                  //           image: AssetImage('assets/bcc.jpg'),
                  //           fit: BoxFit.fill,
                  //           opacity: 50),
                  //     ),
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
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Bitpro License',
                                  style: TextStyle(
                                      fontSize: getExtraLargeFontSize + 6,
                                      fontWeight: FontWeight.w400),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                TextFormField(
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                      hintText: 'Key',
                                      border: OutlineInputBorder()),
                                  initialValue: licenseKey,
                                  onChanged: (val) {
                                    setState(() {
                                      licenseKey = val;
                                      if (showLicenseKeyError) {
                                        showLicenseKeyError = false;
                                      }
                                    });
                                  },
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                if (showLicenseKeyError)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Please enter a valid license key',
                                      style: TextStyle(
                                          fontSize: getSmallFontSize,
                                          color: Colors.red[800]),
                                    ),
                                  ),
                                const SizedBox(
                                  height: 15,
                                ),
                                TextFormField(
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                      hintText: 'Auth',
                                      border: OutlineInputBorder()),
                                  initialValue: licenseAuth,
                                  onChanged: (val) {
                                    setState(() {
                                      licenseAuth = val;
                                      if (showLicenseAuthError) {
                                        showLicenseAuthError = false;
                                      }
                                    });
                                  },
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                if (showLicenseAuthError)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Please enter a valid license auth',
                                      style: TextStyle(
                                          fontSize: getSmallFontSize,
                                          color: Colors.red[800]),
                                    ),
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
                                          onPressed: () {
                                            exit(0);
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.cancel,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                  staticTextTranslate('Cancel'),
                                                  style: TextStyle(
                                                    fontSize: getMediumFontSize,
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
                                            Codec<String, String>
                                                stringToBase64 =
                                                utf8.fuse(base64);
                                            bool callApi = true;
                                            int? noOfDays;
                                            if (licenseKey.isEmpty) {
                                              showLicenseKeyError = true;
                                              callApi = false;
                                            } else {
                                              //key
                                              try {
                                                DeviceInfoPlugin deviceInfo =
                                                    DeviceInfoPlugin();
                                                WindowsDeviceInfo win =
                                                    await deviceInfo
                                                        .windowsInfo;

                                                String keysDecoded =
                                                    stringToBase64.decode(
                                                        licenseKey); //MzY1

                                                if (win.productId !=
                                                    keysDecoded) {
                                                  showLicenseKeyError = true;
                                                  callApi = false;
                                                }
                                              } catch (e) {
                                                showLicenseKeyError = true;
                                                callApi = false;
                                              }
                                            }

                                            if (licenseAuth.isEmpty) {
                                              showLicenseAuthError = true;
                                              callApi = false;
                                            } else {
                                              //auth
                                              try {
                                                String decoded = stringToBase64
                                                    .decode(licenseAuth);

                                                noOfDays =
                                                    int.tryParse(decoded);

                                                if (noOfDays == null) {
                                                  showLicenseAuthError = true;
                                                  callApi = false;
                                                }
                                              } catch (e) {
                                                showLicenseAuthError = true;
                                                callApi = false;
                                              }
                                            }

                                            // print(encoded);
                                            // print(decoded);
                                            if (callApi && noOfDays != null) {
                                              DateTime d = DateTime.now();
                                              var box = Hive.box('bitpro_app');

                                              box.put('license_data', {
                                                "key": licenseKey,
                                                "auth": licenseAuth,
                                                "expiry_date": d
                                                    .add(Duration(
                                                        days: noOfDays))
                                                    .toString()
                                              });
                                            }
                                            setState(() {
                                              isLoading = false;
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  licenseKey.isEmpty
                                                      ? Colors.grey[400]
                                                      : Colors.blue),
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
                                const SizedBox(
                                  height: 30,
                                ),
                                if (widget.licenseExpiredDate != null)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Your Bitpro License key is expired on ${DateFormat('MM-dd-yyyy').format(widget.licenseExpiredDate!)}. Please renew your license.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: getSmallFontSize,
                                          color: Colors.red[800]),
                                    ),
                                  ),
                                TextButton(
                                    onPressed: () async {
                                      DeviceInfoPlugin deviceInfo =
                                          DeviceInfoPlugin();
                                      WindowsDeviceInfo win =
                                          await deviceInfo.windowsInfo;
                                      await Clipboard.setData(
                                          ClipboardData(text: win.productId));
                                      showToast(staticTextTranslate('Copied!'),
                                          context);
                                    },
                                    child: Text(
                                      staticTextTranslate('Copy Device Id'),
                                      style: TextStyle(
                                          fontSize: getMediumFontSize,
                                          color: Colors.grey),
                                    )),
                              ]),
                        )),
                  ),
                ))));
  }
}
