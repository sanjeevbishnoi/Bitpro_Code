import 'package:excel/excel.dart';

import '../../../model/promotion_data.dart';

Map<String, dynamic> excelPromoDataImport(Excel excel) {
  int? barcodeIndex;
  int? percentageIndex;

  List<PromotionData> localPromotionDataLst = [];

  int dublicate = 0;

  for (var table in excel.tables.keys) {
    for (int j = 0; j < excel.tables[table]!.rows.length; j++) {
      var row = excel.tables[table]!.rows.elementAt(j);
      if (j == 0) {
        for (int i = 0; i < row.length; i++) {
          if (row.elementAt(i) != null) {
            var d = row.elementAt(i)!.value.toString().toLowerCase();

            switch (d) {
              case 'barcode':
                barcodeIndex = i;
                break;
              case 'percentage':
                percentageIndex = i;
                break;
            }
          }
        }
      } else {
        if (barcodeIndex != null &&
            row.elementAt(barcodeIndex) != null &&
            percentageIndex != null &&
            row.elementAt(percentageIndex) != null) {
          if (localPromotionDataLst.indexWhere((ele) =>
                  ele.barcode ==
                  row.elementAt(barcodeIndex!)!.value.toString()) !=
              -1) {
            dublicate++;
          } else {
            String barcode = row.elementAt(barcodeIndex)!.value.toString();
            String per = row.elementAt(percentageIndex)!.value.toString();
            localPromotionDataLst
                .add(PromotionData(barcode: barcode, percentage: per));
          }
        }
      }
    }
  }

  return {
    'dublicate': dublicate,
    'localPromotionDataLst': localPromotionDataLst
  };
}
