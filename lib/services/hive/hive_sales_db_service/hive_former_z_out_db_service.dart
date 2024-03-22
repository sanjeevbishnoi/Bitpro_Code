import 'package:hive/hive.dart';
import 'package:bitpro_hive/model/former_z_out_data.dart';

class HiveFormerZOutDbService {
  addFormerZOutReceipt(FormerZOutData formerZOutData) async {
    var box = Hive.box('bitpro_app');
    Map lst = box.get('Former Z Out') ?? {};
    lst[formerZOutData.docId] = formerZOutData.toMap();
    await box.put('Former Z Out', lst);
    // await FirebaseFirestore.instance
    //     .collection('Former Z Out')
    //     .doc()
    //     .set(formerZOutData.toMap());
  }

  Future<List<FormerZOutData>> fetchAllFormerZoutData() async {
    var box = Hive.box('bitpro_app');
    Map? lst = box.get('Former Z Out');

    if (lst == null) return [];
    return lst.values.map((v) {
      return FormerZOutData.fromMap(v);
    }).toList();

    // var qs = await FirebaseFirestore.instance.collection('Former Z Out').get();

    // return qs.docs.map((d) {
    //   return FormerZOutData(
    //     creditCardTotal: d.get('creditCardTotal'),
    //     creditCardTotalInSystem: d.get('creditCardTotalInSystem'),
    //     cashierName: d.get('cashierName'),
    //     closeDate: d.get('closeDate'),
    //     totalCashDifferences: d.get('totalCashDifferences'),
    //     formerZoutNo: d.get('formerZoutNo'),
    //     openDate: d.get('openDate'),
    //     overShort: d.get('overShort'),
    //     total: d.get('total'),
    //     totalCashEntered: d.get('totalCashEntered'),
    //     totalCashOnSystem: d.get('totalCashOnSystem'),
    //     totalNCDifferences: d.get('totalNCDifferences'),
    //   );
    // }).toList();
  }

  // Future<String> getNewZoutNo() async {
  //   var box = Hive.box('bitpro_app');
  //   Map? fLst = box.get('Former Z Out');
  //   if (fLst == null) return '10000';
  //   List<FormerZOutData> lst = fLst.values.map((v) {
  //     return FormerZOutData.fromMap(v);
  //   }).toList();

  //   lst.sort((a, b) => a.formerZoutNo.compareTo(b.formerZoutNo));

  //   return (int.parse(lst.last.formerZoutNo) + 1).toString();
  // }
}
