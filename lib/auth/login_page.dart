import 'dart:io';
import 'package:bitpro_hive/services/firestore_api/fb_user_db_service.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../shared/global_variables/font_sizes.dart';
import '../shared/loading.dart';
import '../shared/global_variables/static_text_translate.dart';
import '../shared/toast.dart';

class LoginPage extends StatefulWidget {
  final DateTime licenseExpiryDate;
  const LoginPage({Key? key, required this.licenseExpiryDate})
      : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? username;
  String? password;
  var formKey = GlobalKey<FormState>();
  bool loading = false;
  bool obscurePassword = true;

  bool backendSetupSkipped = false;
  @override
  void initState() {
    setWindowSize();
    super.initState();
  }

  setWindowSize() async {
    await DesktopWindow.setMinWindowSize(const Size(550, 650));
    var box = Hive.box('bitpro_app');
    Map? firebaseBackendData = box.get('firebase_backend_data');
    if (firebaseBackendData != null) {
      backendSetupSkipped = firebaseBackendData['setupSkipped'];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.enter):
            const LoginCallbackShortcutsIntent(name: 'onEnter'),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          LoginCallbackShortcutsIntent:
              CallbackAction<LoginCallbackShortcutsIntent>(
                  onInvoke: (LoginCallbackShortcutsIntent intent) =>
                      onEnterLogin()),
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: loading
                ? showLoading()
                : Stack(alignment: Alignment.center, children: [
                    Container(
                      width: double.infinity,
                      foregroundDecoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/bcc.jpg'),
                            fit: BoxFit.fill,
                            opacity: 50),
                      ),
                      color: const Color.fromARGB(255, 201, 201, 201),
                    ),
                    Container(
                      width: 400,
                      height: 480,
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color.fromARGB(255, 223, 223, 223)
                            .withOpacity(0.85),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 15, 15, 15)
                                .withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(
                                0, 6), // changes position of shadow
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: 300,
                        child: Form(
                          key: formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                staticTextTranslate('Login to Bitpro'),
                                style: TextStyle(
                                    fontSize: getExtraLargeFontSize + 6,
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Column(
                                children: [
                                  TextFormField(
                                    validator: (value) => value!.isEmpty
                                        ? staticTextTranslate(
                                            'Please enter your username')
                                        : null,
                                    decoration: InputDecoration(
                                        hintText:
                                            staticTextTranslate('Username'),
                                        border: const OutlineInputBorder()),
                                    onChanged: (val) {
                                      setState(() {
                                        username = val;
                                      });
                                    },
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  TextFormField(
                                    obscureText: obscurePassword,
                                    validator: (value) => value!.isEmpty
                                        ? staticTextTranslate(
                                            'Please enter your password')
                                        : null,
                                    decoration: InputDecoration(
                                        suffixIcon: IconButton(
                                            splashRadius: 1,
                                            onPressed: () {
                                              setState(() {
                                                obscurePassword =
                                                    !obscurePassword;
                                              });
                                            },
                                            icon: SvgPicture.asset(
                                              obscurePassword
                                                  ? 'assets/icons/password-show.svg'
                                                  : 'assets/icons/password-hide.svg',
                                              width: 20,
                                              color: Colors.grey[700],
                                            )),
                                        hintText:
                                            staticTextTranslate('Password'),
                                        border: const OutlineInputBorder()),
                                    onChanged: (val) {
                                      setState(() {
                                        password = val;
                                      });
                                    },
                                  ),
                                  const SizedBox(
                                    height: 20,
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
                                                    staticTextTranslate(
                                                        'Cancel'),
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
                                              onEnterLogin();
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.login),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                    staticTextTranslate(
                                                        'Login'),
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
                                  Text(
                                    staticTextTranslate(
                                        """Bitpro is a trademark of Bitpro\nInternational, www.bitproglobal.com"""),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: getMediumFontSize,
                                        color: const Color.fromARGB(
                                            255, 83, 83, 83)),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    staticTextTranslate('Version 1.0.0'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: getMediumFontSize,
                                        color: const Color.fromARGB(
                                            255, 43, 42, 42)),
                                  ),
                                  const SizedBox(
                                    height: 2,
                                  ),
                                  Text(
                                    staticTextTranslate(
                                        'Licensed Up to: ${DateFormat('MM-dd-yyyy').format(widget.licenseExpiryDate)}'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: getMediumFontSize,
                                        color: const Color.fromARGB(
                                            255, 27, 27, 27)),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]),
          ),
        ),
      ),
    );
  }

  onEnterLogin() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        loading = true;
      });
      var userData = await FbUserDbService(context: context)
          .loginUser(username!, password!);
      if (userData != null) {
        var box = Hive.box('bitpro_app');
        await box.put('user_data', userData.toMap());
        box.put('is_user_logged_in', true);
      } else {
        showToast(
            staticTextTranslate('Enter the correct username and password.'),
            context);
        setState(() {
          loading = false;
        });
      }
    }
  }
}

class LoginCallbackShortcutsIntent extends Intent {
  const LoginCallbackShortcutsIntent({required this.name});

  final String name;
}
