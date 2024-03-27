import 'package:hive/hive.dart';
import 'package:bitpro_hive/model/former_z_out_data.dart';

class HiveFormerZOutDbService {
  addFormerZOutReceipt(FormerZOutData formerZOutData) async {
    var box = Hive.box('bitpro_app');
    Map lst = box.get('Former Z Out') ?? {};
    lst[formerZOutData.docId] = formerZOutData.toMap();
    await box.put('Former Z Out', lst);
  }

  Future<List<FormerZOutData>> fetchAllFormerZoutData() async {
    var box = Hive.box('bitpro_app');
    Map? lst = box.get('Former Z Out');

    if (lst == null) return [];
    return lst.values.map((v) {
      return FormerZOutData.fromMap(v);
    }).toList();
  }
}
