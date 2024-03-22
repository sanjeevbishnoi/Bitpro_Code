import 'package:hive/hive.dart';
import 'package:bitpro_hive/model/customer_payment_data.dart';

class HiveCustomerPaymentDbService {
  Future addCustomerPaymentData(
      DateTime createdDate,
      String documentNo,
      String docId,
      String customerId,
      String paymentType,
      double amount,
      String comment) async {
    var box = Hive.box('bitpro_app');

    Map customers = box.get('Sales Customer Payments Data') ?? {};

    CustomerPaymentData customerPaymentData = CustomerPaymentData(
        documentNo: documentNo,
        docId: docId,
        customerId: customerId,
        createdDate: createdDate,
        amount: amount,
        comment: comment,
        paymentType: paymentType);

    String dId = customerPaymentData.docId;

    customers[dId] = customerPaymentData.toMap();
    await box.put('Sales Customer Payments Data', customers);
  }

  Future<List<CustomerPaymentData>> fetchAllCustomerPaymentData() async {
    var box = Hive.box('bitpro_app');
    Map? customerPaymentData = box.get('Sales Customer Payments Data');
    if (customerPaymentData == null) return [];
    return customerPaymentData.keys.map((k) {
      var ud = customerPaymentData[k];

      return CustomerPaymentData.fromMap(ud);
    }).toList();
  }
}
