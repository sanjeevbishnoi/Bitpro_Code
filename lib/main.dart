import 'package:bitpro_hive/services/providers/fetching_data_provider.dart';
import 'package:bitpro_hive/wrapper.dart';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bitpro_hive/shared/custom_top_nav_bar.dart';
import 'package:bitpro_hive/shared/global_variables/static_text_translate.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:provider/provider.dart';

bool logout = true;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // For hot reload, `unregisterAll()` needs to be called.
  await hotKeyManager.unregisterAll();

  /// ensure printer profile is loaded
  // await CapabilityProfile.ensureProfileLoaded();
  final appDocumentDirectory = await getApplicationSupportDirectory();
  Hive.init(appDocumentDirectory.path);
  await Hive.openBox('bitpro_app');
  if (logout) {
    // Box box = Hive.box('bitpro_app');
    // await box.put('is_user_logged_in', false);
    // logout = false;
  }

  runApp(const MyApp(
    setFullScreen: true,
  ));
  doWhenWindowReady(() {
    final win = appWindow;
    win.alignment = Alignment.center;
    win.title = "Bitpro";
    win.show();
    win.maximize();
  });
}

class MyApp extends StatefulWidget {
  
  final bool setFullScreen;
  const MyApp({Key? key, this.setFullScreen = false}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    var box = Hive.box('bitpro_app');
    String language = box.get('Selected Language') ?? 'English';
    if (language == 'English') {
      engSelectedLanguage = true;
    } else {
      engSelectedLanguage = false;
    }

    if (widget.setFullScreen) setFullScreen();
  }

  setFullScreen() async {
    // await DesktopWindow.setFullScreen(true);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => FetchingDataProvider(),
        ),
      ],
      child: MaterialApp(
          title: 'Bitpro',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scrollbarTheme: ScrollbarThemeData(
              
              crossAxisMargin: 2.0,
          mainAxisMargin: 2.0,
                thickness: MaterialStateProperty.all(12),
                radius: const Radius.circular(0),
                
                thumbColor: MaterialStateProperty.all(
                  Colors.grey[700]
                ),
                interactive: true,
                
                trackVisibility: MaterialStateProperty.all(true),

                trackColor: MaterialStateProperty.all(Colors.grey[300]),
                thumbVisibility: MaterialStateProperty.all(true)),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: Color.fromARGB(255, 59, 6, 80),
              unselectedItemColor: Color.fromARGB(255, 39, 39, 39),
            ),
              useMaterial3: false,
              primarySwatch: Colors.blueGrey,
              fontFamily: 'Cisco'),
          home: customTopNavBar(Wrapper()),
          builder: (context, child) {
            return Directionality(
                textDirection:
                    engSelectedLanguage ? TextDirection.ltr : TextDirection.rtl,
                child: child!);
          }),
    );
  }
}
