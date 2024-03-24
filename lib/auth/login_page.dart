import 'dart:io';
import 'dart:ui';
import 'package:bitpro_hive/services/firestore_api/fb_user_db_service.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:iconsax/iconsax.dart';
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
                      onTapLogin()),
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
                            image: AssetImage('assets/bck.jpg'),
                            fit: BoxFit.cover,
                            opacity: 100),
                      ),
                      color: const Color.fromARGB(255, 201, 201, 201),
                    ),
                    Container(
                      width: 400,
                      height: 480,
                      color: Colors.transparent,
                      //we use Stack(); because we want the effects be on top of each other,
                      //  just like layer in photoshop.
                      child: Stack(
                        children: [
                          //blur effect ==> the third layer of stack
                          BackdropFilter(
                            filter: ImageFilter.blur(
                              //sigmaX is the Horizontal blur
                              sigmaX: 5.0,
                              //sigmaY is the Vertical blur
                              sigmaY: 5.0,
                            ),
                            //we use this container to scale up the blur effect to fit its
                            //  parent, without this container the blur effect doesn't appear.
                            child: Container(),
                          ),
                          //gradient effect ==> the second layer of stack
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.13)),
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    //begin color
                                    Colors.white.withOpacity(0.2),
                                    //end color
                                    Colors.white.withOpacity(0.9),
                                  ]),
                            ),
                          ),
                          //child ==> the first/top layer of stack
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(31.0),
                              child: Form(
                                key: formKey,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      staticTextTranslate('Login to Bitpro'),
                                      style: GoogleFonts.roboto(
                                          fontSize: getExtraLargeFontSize + 12,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Column(
                                      children: [
                                        TextFormField(
                                          style: GoogleFonts.roboto(
                                              fontSize: 18,
                                              color: Colors.black),
                                          validator: (value) => value!.isEmpty
                                              ? staticTextTranslate(
                                                  'Please enter your username')
                                              : null,
                                          decoration: InputDecoration(
                                              fillColor: Colors.grey[400],
                                              filled: true,
                                              hintStyle: GoogleFonts.roboto(
                                                  fontSize: 18,
                                                  color: Colors.grey[700]),
                                              hintText: staticTextTranslate(
                                                'Username',
                                              ),
                                              border:
                                                  const OutlineInputBorder(),
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      width: 1,
                                                      color: Color.fromARGB(
                                                          255, 19, 101, 148))),
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          width: 0.6,
                                                          color:
                                                              Colors.black))),
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
                                          style: GoogleFonts.roboto(
                                              fontSize: 18,
                                              color: Colors.black),
                                          obscureText: obscurePassword,
                                          validator: (value) => value!.isEmpty
                                              ? staticTextTranslate(
                                                  'Please enter your password')
                                              : null,
                                          decoration: InputDecoration(
                                              fillColor: Colors.grey[400],
                                              filled: true,
                                              hintStyle: GoogleFonts.roboto(
                                                  fontSize: 18,
                                                  color: Colors.grey[700]),
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      width: 1,
                                                      color: Color.fromARGB(
                                                          255, 19, 101, 148))),
                                              enabledBorder:
                                                  const OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          width: 0.6,
                                                          color: Colors.black)),
                                              suffixIcon: IconButton(
                                                  splashRadius: 1,
                                                  onPressed: () {
                                                    setState(() {
                                                      obscurePassword =
                                                          !obscurePassword;
                                                    });
                                                  },
                                                  icon: obscurePassword
                                                      ? Icon(Icons.show_chart)
                                                      : Icon(Icons.hide_image)),
                                              hintText: staticTextTranslate(
                                                  'Password'),
                                              border:
                                                  const OutlineInputBorder()),
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
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
                                                            'Cancel'),
                                                        style:
                                                            GoogleFonts.roboto(
                                                          fontSize:
                                                              getMediumFontSize +
                                                                  2,
                                                        ),
                                                      ),
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
                                                    onTapLogin();
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
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
                                          style: GoogleFonts.roboto(
                                            fontSize: getMediumFontSize + 2,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          staticTextTranslate('Version 3.0.1'),
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.roboto(
                                            fontSize: getMediumFontSize + 2,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 2,
                                        ),
                                        Text(
                                          staticTextTranslate(
                                              'Licensed Up to: ${DateFormat('MM-dd-yyyy').format(widget.licenseExpiryDate)}'),
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.roboto(
                                              fontSize: getMediumFontSize + 2,
                                              color: const Color.fromARGB(
                                                  255, 34, 82, 105)),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
          ),
        ),
      ),
    );
  }

  onTapLogin() async {
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
