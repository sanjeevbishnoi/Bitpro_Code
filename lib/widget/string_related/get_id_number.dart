import 'package:bitpro_hive/services/hive/hive_settings/hive_store_db_service.dart';

Future<String> getIdNumber(int currentItemNum) async {
  int storeCode = await HiveStoreDbService().getSelectedStoreCode();
  int workstationId = await HiveStoreDbService().getWorkstationNumber();

  int newNum = int.parse('$storeCode${workstationId}00000000') + currentItemNum;

  return newNum.toString();
}
