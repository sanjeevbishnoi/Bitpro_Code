import 'package:hive/hive.dart';
import 'package:bitpro_hive/model/customer_data.dart';

class HiveCustomerDbService {
  Future addCustomerData(CustomerData customerData) async {
    var box = Hive.box('bitpro_app');

    Map userGroups = box.get('Sales Customer Data') ?? {};

    String dId = customerData.docId;
    userGroups[dId] = customerData.toMap();
    await box.put('Sales Customer Data', userGroups);
  }

  Future<List<CustomerData>> fetchAllCustomersData() async {
    var box = Hive.box('bitpro_app');
    Map? customers = box.get('Sales Customer Data');
    if (customers == null) return [];
    return customers.keys.map((k) {
      var ud = customers[k];

      return CustomerData.fromMap(ud);
    }).toList();
  }
}
