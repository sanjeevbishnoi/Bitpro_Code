import 'package:bitpro_hive/firebase_backend_setup/firebase_backend_setup.dart';
import 'package:bitpro_hive/firebase_backend_setup/workstation_setup.dart';
import 'package:bitpro_hive/home/license_module/license_module.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bitpro_hive/auth/login_page.dart';
import 'package:bitpro_hive/home/home_page.dart';
import 'model/user_data.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  State<Wrapper> createState() => _WrapperState();
}

bool globalIsFbSetupSkipted = true;

class _WrapperState extends State<Wrapper> {
  var box = Hive.box('bitpro_app');

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box>(
        valueListenable: Hive.box('bitpro_app').listenable(),
        builder: (context, box, widget) {
          Map? firebaseBackendData = box.get('firebase_backend_data');

          globalIsFbSetupSkipted = firebaseBackendData != null &&
                  firebaseBackendData['setupSkipped'] == true
              ? true
              : false;

          // box.clear();
          if (firebaseBackendData == null) {
            return const FirebaseBackendSetupPage();
          }

          if (firebaseBackendData['setupSkipped'] == false &&
              firebaseBackendData['workstationSetupDone'] == false) {
            return const WorkstationSetupPage();
          }

          // Map? licenseData = box.get('license_data');

          // if (licenseData == null ||
          //     !licenseData.containsKey('key') ||
          //     !licenseData.containsKey('auth')) {
          //   return LicenseModule();
          // } else {
          //check license Expiry Date

          DateTime licenseExpiryDate =
              DateTime.now().add(const Duration(days: 20));
          // DateTime.parse(licenseData['expiry_date']);

          if (licenseExpiryDate.compareTo(DateTime.now()) == -1) {
            return LicenseModule(
              licenseExpiredDate: licenseExpiryDate,
            );
          }

          bool? loggedIn = box.get('is_user_logged_in');
          Map? ud = box.get('user_data');

          if (loggedIn == null || !loggedIn || ud == null) {
            return LoginPage(
              licenseExpiryDate: licenseExpiryDate,
            );
          }

          return HomePage(
            userData: UserData.fromMap(ud),
          );
        }
        // }
        );
  }
}
