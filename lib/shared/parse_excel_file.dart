import 'package:excel/excel.dart';

Excel parseExcelFile(List<int> _bytes) {
  return Excel.decodeBytes(_bytes);
}
