import 'package:hive/hive.dart';
import 'package:bitpro_hive/model/promo_code_data.dart';

class HivePromoDbService {
  Future addPromoData(PromoData pd) async {
    var box = Hive.box('bitpro_app');
    Map lst = box.get('Promotion Data Lst') ?? {};
    lst[pd.docId] = pd.toMap();
    await box.put('Promotion Data Lst', lst);
  }

  Future<List<PromoData>> fetchPromoData() async {
    var box = Hive.box('bitpro_app');

    Map? lst = await box.get('Promotion Data Lst');
    if (lst == null || lst.isEmpty) return [];
    return lst.values.map((v) {
      return PromoData.fromMap(v);
    }).toList();
  }

  Future<void> deleteAllPromoData() async {
    var box = Hive.box('bitpro_app');
    await box.delete('Promotion Data Lst');
  }
}
