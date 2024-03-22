bool engSelectedLanguage = true;

staticTextTranslate(String txt) {
  if (engSelectedLanguage) return txt;
  switch (txt) {
    //new
    case 'Skip & Update':
      return 'تخطي وتحديث';
    case 'Items Not Found : 0':
      return 'العناصر غير الموجودة: 0';
    case 'Items Not Found':
      return 'لم يتم العثور على العناصر';

      //old
    case 'Price can change':
      return 'السعر يمكن أن يتغير';
    case 'Submit':
      return 'يُقدِّم';
    case 'Please enter a price':
      return 'الرجاء إدخال السعر';
    case 'Discount over the limit, Max Discount : ':
      return 'خصم فوق الحد ، الحد الأقصى للخصم:';
    case 'Copied!':
      return 'نسخ!';
    case 'Copy Device Id':
      return 'نسخ معرف الجهاز';
    case 'Please enter a valid license auth':
      return 'الرجاء إدخال ترخيص صالح';
    case 'Reset auth':
      return 'إعادة تعيين المصادقة';
    case 'Reset key':
      return 'إعادة تعيين مفتاح';
    case 'Please enter a valid license key':
      return 'الرجاء إدخال مفتاح ترخيص صالح';
    case 'Are you sure you want to delete all data?':
      return 'هل أنت متأكد أنك تريد حذف كافة البيانات؟';
    case 'Delete All':
      return 'حذف الكل';
    case 'Purchase Journal':
      return 'مجلة الشراء';
    case 'SELECT TIME':
      return 'حدد الوقت';
    case 'Barcode Settings':
      return 'إعدادات الباركود';
    case 'Default Receipt Template':
      return 'نموذج الإيصال الافتراضي';
    case 'Select Printer While Printing':
      return 'حدد الطابعة أثناء الطباعة';
    case 'Receipt Printer':
      return ' الطابعة فاتورة';
    case 'Please select a language to use':
      return 'الرجاء تحديد لغة لاستخدامها';
    case 'Enter Date':
      return 'أدخل التاريخ';
    case 'Invalid format.':
      return 'تنسيق غير صالح.';
    case 'SELECT DATE':
      return 'حدد تاريخ';
    case 'Please select from date':
      return 'الرجاء التحديد من التاريخ';
    case 'Please select to date':
      return 'الرجاء التحديد حتى الآن';
    case 'Opening Balance':
      return 'الرصيد الافتتاحي';
    case 'Select Items':
      return 'اختيار منتج';
    case 'Select a printer':
      return 'اختر طابعة';
    case 'Copies':
      return 'نسخ';
    case 'Document Quantity':
      return 'كمية الوثيقة';
    case 'On Hand Quantity':
      return 'الكمية في المخزون';
    case 'Select Printer':
      return 'حدد الطابعة';
    case 'All Listed Record':
      return 'كل المنتج';
    case 'Selected Record':
      return 'سجل مختار';
    case 'No Items Found!':
      return 'لم يتم العثور على العناصر!';
    case 'Remove item':
      return 'إزالة منتج';
    case 'Created By':
      return 'انشأ من قبل';
    case 'Select a end date/time':
      return 'حدد تاريخ / وقت الانتهاء';
    case 'Select a start date/time':
      return 'حدد تاريخ / وقت البدء';
    case 'End Date/Time':
      return 'تاريخ / وقت الانتهاء';
    case 'Start Date/Time':
      return 'تاريخ / وقت البدء';
    case 'Percentage':
      return 'النسبة ';
    case 'Promo#':
      return 'تخفيض #';
    case 'Please enter an amount':
      return 'الرجاء إدخال مبلغ';
    case 'Total Sales Amt':
      return 'المبلغ الإجمالي للمبيعات';
    case 'Customers':
      return 'عملاء';
    case 'CANCEL':
      return 'إلغاء';
    case 'Loading ...':
      return 'جار التحميل ...';
    case 'Discard':
      return 'تجاهل';
    case 'Are you sure you want to discard all changes?':
      return 'هل أنت متأكد أنك تريد تجاهل كافة التغييرات؟';
    case 'Discard Changes':
      return 'تجاهل التغييرات';
    case 'Please select a printer from the printing settings.':
      return 'الرجاء تحديد طابعة من إعدادات الطباعة.';
    case 'Select Customer':
      return 'حدد العميل';
    case 'Please select a customer, for credit payment':
      return 'الرجاء تحديد عميل للدفع عن طريق الائتمان';
    case 'Pay Credit':
      return 'دفع الائتمان';
    case 'Enter amount equal to the subtotal':
      return 'أدخل المبلغ الذي يساوي المجموع الفرعي';
    case 'Discount %':
      return 'تخفيض ٪';
    case 'Credit':
      return 'ائتمان';
    case 'Search customer':
      return 'البحث عن العملاء';
    case 'Remove Item':
      return 'إزالة منتج';
    case 'Update':
      return 'تحديث';
    case 'Payment Type':
      return 'نوع الدفع';
    case 'All':
      return 'الجميع';
    case 'Promotion':
      return 'خصومات';
    case 'Print Test':
      return 'اختبار الطباعة';
    case 'Price : 10.00':
      return 'السعر: 10.00';
    case 'Product Name':
      return 'اسم المنتج';
    case 'Product Id':
      return 'معرف المنتج';
    case 'Store Name':
      return 'اسم المتجر';
    case 'Preview':
      return 'معاينة';
    case 'Margin Left - Right':
      return "الهامش الأيسر - الأيمن";
    case 'Margin Top - Bottom':
      return 'أعلى الهامش - أسفل';
    case 'Tag Height (Inches)':
      return "ارتفاع العلامة (بوصة)";
    case 'Tag Width (Inches)':
      return "عرض العلامة (بوصة)";
    case 'Sizedbox Height':
      return "ارتفاع Sizedbox";
    case 'Barcode Width - Height':
      return "عرض الباركود - الارتفاع";
    case 'Price font size':
      return "حجم خط السعر";
    case 'Product name font size':
      return "حجم خط اسم المنتج";
    case 'Product id font size':
      return "حجم خط معرف المنتج";
    case 'Header font size':
      return "حجم خط الرأس";
    case 'Yes':
      return "نعم";
    case 'No':
      return "رقم";
    case 'Do you really want to exit?':
      return "هل حقا تريد الخروج؟";
    case 'Exit':
      return "مخرج";
    case 'Voucher# / PV#':
      return "فاتورة # / PV #";
    case 'Vendor Payment':
      return "دفع المورد";
    case 'Please enter a comment':
      return "أدخل مبلغًا صالحًا";
    case 'Enter a valid amount':
      return "أدخل مبلغًا صالحًا";
    case 'Bank':
      return "بنك";
    case 'Payment type':
      return "نوع الدفع";
    case 'Select a customer':
      return "حدد الزبون";
    case 'Total Paid':
      return "مجموع المبالغ المدفوعة";
    case 'Total Amt Purchase':
      return "إجمالي مبلغ الشراء";
    case 'Paid Amount':
      return "المبلغ المدفوع";
    case 'Purchased Amount':
      return "المبلغ المشتراة";
    case 'Comment':
      return "تعليق";
    case 'Doc Type':
      return "نوع الوثيقة";
    case 'Document#':
      return "وثيقة#";
    case 'Document':
      return "وثيقة";
    case 'Payment':
      return "قسط";
    case 'All Document':
      return "كل وثيقة";
    case 'Receipt# / RV#':
      return "الإيصال # / RV #";
    case 'Customer Payment':
      return "دفع العملاء";
    case 'Pay':
      return "دفع";
    //old
    case 'Reference no':
      return "رقم المرجع";
    case 'Language':
      return "لغة";
    case 'Change language':
      return "تغيير اللغة";
    case 'Voucher Templates':
      return "قوالب القسيمة";
    case 'Receipt Templates':
      return "قوالب الإيصالات";
    case "Remove Items":
      return "إزالة الصنف";
    case "Vendors":
      return "موردين";
    case 'Dashboard':
      return "لوحة القيادة";
    case 'Sales':
      return "مبيعات";
    case 'Purchase':
      return "مشتريات";
    case 'Merchandise':
      return "مخزون";
    case 'Employees':
      return "الموظفين";
    case 'Preferences':
      return "الإعدادات";
    case 'Backup & Restore':
      return "النسخ الاحتياطية";
    case 'Logout':
      return "تسجيل خروج";
    case 'Search':
      return "يبحث";
    case 'Company Details':
      return "تفاصيل الشركة";
    case 'Printing':
      return "طباعة";
    case 'Taxes':
      return "الضرائب";
    case 'Settings saved, successfully':
      return "تم حفظ الإعدادات بنجاح";
    case 'Tax Percentage':
      return "نسبة الضريبة";
    case 'Receipt Title (English)':
      return "عنوان الاستلام (إنجليزي)";
    case 'Receipt Title (Arabic)':
      return "عنوان الإيصال (عربي)";
    case 'Receipt Footer (English)':
      return "تذييل الإيصال (الإنجليزية)";
    case 'Receipt Footer (Arabic)':
      return "تذييل الإيصال (عربي)";
    case 'Inventory Tag Size':
      return "حجم الباركود";
    case 'Company / Store Name':
      return 'اسم الشركة / المتجر';
    case 'Phone 1':
      return "الهاتف 1";
    case 'Phone 2':
      return "الهاتف 2";
    case 'Email 1':
      return "البريد الإلكتروني 1";
    case 'Tax / Vat Number':
      return "الضرائب / رقم ضريبة القيمة المضافة";
    case 'Bank Name':
      return "اسم البنك";
    case 'IBAN / Account Number':
      return "IBAN / رقم الحساب";
    case 'Company Logo':
      return "شعار الشركة";
    case 'Register':
      return "فتع اغلاق الدرج";
    case 'Former Z out':
      return "خرج Z السابق";
    case 'Register Open':
      return "فتح التسجيل";
    case 'All Sales transactions will be counted till the closing of this register.':
      return "سيتم احتساب جميع معاملات المبيعات حتى إغلاق هذا السجل.";
    case 'Click Open Register to Open a Register':
      return "انقر فوق فتح تسجيل لفتح سجل";
    case 'Cashier :':
      return "كاشير";
    case 'Date / Time :':
      return "التاريخ / الوقت:";
    case 'Amount on system':
      return "المبلغ على النظام";
    case 'Entered Amount':
      return "المبلغ الذي تم إدخاله";
    case 'Register Closing':
      return "تسجيل إغلاق";
    case 'Non Currency':
      return "شبكة";
    case 'Amount':
      return "مبلغ";
    case 'Reference #':
      return 'المرجعي #';
    case 'Non Currency Total':
      return "إجمالي الشبكة";
    case 'Enter the Closing totals to finish the Register Closing':
      return 'أدخل إجماليات الإغلاق لإنهاء "إغلاق التسجيل"';
    case 'Enter cash total':
      return "أدخل الإجمالي النقدي";
    case 'Enter a valid value':
      return "إدخال قيمة صالحة";
    case 'Register Open / Close':
      return "تسجيل فتح / إغلاق";
    case 'All Sales transactions will be counted till closing this register.':
      return "سيتم احتساب جميع معاملات المبيعات حتى إغلاق هذا السجل.";
    case "Click Open Register to Start making Sales. If Register is Open.":
      return "انقر فوق فتح التسجيل لبدء إجراء المبيعات. إذا كان التسجيل مفتوحًا.";
    case "Click Close Register to Complete.":
      return "انقر فوق إغلاق التسجيل للإكمال.";
    case "Open Register":
      return "افتح التسجيل";
    case "Close Register":
      return "إغلاق التسجيل";
    case "Customer":
      return "عملاء";
    case "Receipt Type":
      return "نوع الفاتورة";
    case "Receipt #":
      return "الفاتورة";
    case "Customer Name":
      return "اسم العميل";
    case "Original Total":
      return "الإجمالي";
    case "Disc %":
      return "% خصم";
    case "Disc \$":
      return "\$ خصم";
    case "Tax %":
      return "الضريبة %";
    case "Tax \$":
      return "الضريبة \$";
    case "Receipt Total":
      return "إجمالي الفاتورة";
    case "Register is Closed":
      return "التسجيل مغلق";
    case "Please open the register to start selling":
      return "الرجاء فتح السجل لبدء البيع";
    case "Receipt":
      return "الفاتورة";
    case "Org. Price":
      return "السعر قبل الخصم";
    case "Total before Tax":
      return "الإجمالي قبل الضريبة";
    case "Bill to Customer":
      return "فاتورة للعميل";
    case "select customer":
      return "حدد العميل";
    case "Due Amount":
      return "مبلغ مستحق";
    case "Change Window":
      return "المتبقي";
    case "TENDERED":
      return "النقدية المأخوذة";
    case "CHANGE":
      return "المتبقي";
    case "Duplicate items found":
      return "تم العثور على عناصر مكررة";
    case "0 Duplicate items found":
      return "تم العثور على 0 عنصر مكرر";
    case "Tender":
      return "يدفع";
    case "Auth #":
      return "المصادقة #";
    case "SUBTOTAL":
      return "الإجمالي";
    case "Cash":
      return "نقدي";
    case "Credit Card":
      return "شبكة";
    case "Due":
      return "بسبب";
    case "Balance":
      return "باقي";
    case "OK":
      return "نعم";
    case "Scan or enter barcode":
      return "امسح أو أدخل الباركود";
    case "No item with the barcode":
      return "لا يوجد عنصر بالباركود";
    case "Former Zout":
      return "ملح سابق";
    case "Zout#":
      return "مالح #";
    case "Cashier":
      return "كاشير";
    case "Total":
      return "المجموع";
    case "Over / Short":
      return "اكثر \\ نقص";
    case "Total Cash On System":
      return "إجمالي النقد على النظام";
    case "Credit Card Total On System":
      return "إجمالي شبكة على النظام";
    case "Total Cash Difference":
      return "إجمالي الفرق النقدي";
    case "Close Date":
      return "تاريخ مغلق";
    case "Total N/C Difference":
      return 'إجمالي فرق N / C';
    case "Total Over / Short":
      return "إجمالي أكثر /  نقص";
    case "Total Cash Entered":
      return 'تم إدخال إجمالي النقد';
    case "Credit Card Total":
      return 'إجمالي بطاقة الائتمان';
    case "Open Date":
      return 'تاريخ مفتوح';
    case "Z out #":
      return 'Z خارج #';
    case "Cashier Name":
      return "كاشير";
    case "Company":
      return 'شركة';

    case "Customer Details":
      return "إجمالي أكثر /  نقص";
    case "Customer Id":
      return "تفاصيل العميل";
    case "Enter customer id":
      return "رقم العميل";

    case "Enter customer name":
      return 'أدخل اسم العميل';
    case "Address 1":
      return 'العنوان 1';
    case "Address 2":
      return 'العنوان 2';
    case "Company Name":
      return 'اسم الشركة';
    case "Reports":
      return 'التقارير';
    case "Sales Report":
      return 'تقرير المبيعات';
    case "Sales Summary":
      return 'ملخص المبيعات';
    case "Purchase Report":
      return 'تقرير الشراء';
    case "Purchase Summary":
      return 'ملخص شراء';
    case "Tax Report":
      return 'تقرير الضرائب';
    case "Tax Summary":
      return 'ملخص الضريبة';
    case "Sales Vat Summary":
      return 'ملخص ضريبة المبيعات';
    case "Purchase Vat Summary":
      return 'ملخص ضريبة القيمة المضافة للشراء';
    case "Payable Vat Summary":
      return 'ملخص ضريبة القيمة المضافة المستحقة الدفع';
    case "Printed on":
      return 'طبع على';
    case "Sales Journal":
      return 'مجلة المبيعات';
    case "Totals":
      return 'المجاميع';
    case "Select Date From":
      return 'حدد التاريخ من';
    case "To":
      return "إلى";
    case "Show Total With Tax":
      return "إظهار الإجمالي مع الضريبة";
    case "Run":
      return "يجري";
    case "View":
      return "رأي";
    case "Vendor Invoice #":
      return "فاتورة البائع #";
    case "Voucher #":
      return "فاتورة #";
    case "Type":
      return 'يكتب';
    case "Qty Received":
      return "استلمت الكمية";
    case "Voucher Total":
      return "إجمالي القسيمة";
    case "Vendor Inv#":
      return "فاتورة المورد";
    case "Search for Items":
      return "البحث عن العناصر";
    case "Import Items":
      return "عناصر الاستيراد";
    case "Download Sample file here.":
      return "قم بتنزيل نموذج للملف هنا.";
    case "Product Import":
      return "استيراد المنتج";
    case "Return":
      return "الإرجاع";
    case "Regular":
      return "عادي";
    case "Print & Update":
      return "طباعة وتحديث";
    case "Note":
      return "ملحوظة";
    case "Enter correct total":
      return "أدخل الإجمالي الصحيح";
    case "Enter invoice total":
      return "أدخل إجمالي الفاتورة";
    case "Purchase Invoice Total":
      return "إجمالي فاتورة الشراء";
    case "Select a date":
      return "اختر التاريخ";
    case "Select Date":
      return "حدد تاريخ";
    case "Purchase Invoice Date":
      return "تاريخ فاتورة الشراء";
    case "Enter invoice":
      return "أدخل الفاتورة";
    case "Purchase Invoice #":
      return "فاتورة الشراء #";
    case "Select a vendor":
      return "حدد المورد";
    case "Discount \$":
      return "خصم \$";
    case "Discount%":
      return "خصم";
    case "Tax%":
      return "ضريبة٪";
    case "VOUCHER TOTAL":
      return "الاجمالي";
    case "Tax":
      return "ضريبة";
    case "Line Items":
      return 'البنود';
    case "Total Qty.":
      return "إجمالي الكمية.";
    case "Voucher Price W/T":
      return "اجمالي سعر البيع";
    case "Qty":
      return "الكمية";
    case "Select Item":
      return "حدد البند";
    case "Voucher":
      return "فاتورة";
    case "Print Tag":
      return "طباعة الباركود";
    case "Print":
      return "طباعة";
    case "Imports Items":
      return "عناصر الواردات";
    case "Exports":
      return "صادرات";

    case "Department":
      return "أقسام";
    case "Adjustment":
      return "تعديل";
    case "Vendor Phone 01":
      return "هاتف البائع 01";
    case "Email":
      return "البريد الإلكتروني";
    case "Vendor":
      return "مورد";
    case "Vendor Details":
      return "تفاصيل المورد";
    case "Vendor Name":
      return "اسم المورد";
    case "Enter vendor name":
      return "أدخل اسم المورد";
    case "Email Address":
      return "عنوان البريد الالكترونى";
    case "Vendor Id":
      return "رقم المورد";
    case "Enter vendor id":
      return "أدخل اسم المورد";
    case "ID is already in use":
      return "رقم المورد موجود بالفعل في النظام";
    case "Address 01":
      return "العنوان 01";
    case "Phone 01":
      return "الهاتف 01";
    case "Address 02":
      return "العنوان 02";
    case "Phone 02":
      return "هاتف 02";
    case "VAT Number":
      return "الرقم الضريبي";

    case "Export":
      return "يصدّر";
    case "Import items":
      return "الأصناف المستوردة";
    case "Barcode / Item Code":
      return "الباركود / رمز الصنف";
    case "Item Name":
      return "اسم العنصر";

    case "Barcode":
      return "باركود";
    case "Item Code":
      return "رمز الصنف";
    case "OH Qty":
      return "كمية في المخزون";
    case "Cost":
      return "كلفة";
    case "Price":
      return "سعر";
    case "Price W/T":
      return "سعر البيع";
    case "Ext Cost":
      return "اجمالي التكلفة";
    case "Ext Price W/T":
      return "الاجمالي مع الضريبة";

    case "Download Now.":
      return "التحميل الان.";
    case "File":
      return "ملف";
    case "No path found":
      return "لم يتم العثور على مسار";
    case "Select File":
      return "حدد ملف";
    case "Items Found : 0":
      return "العناصر التي تم العثور عليها: 0";
    case "Note : ":
      return "ملحوظة : ";
    case "0 Duplicate items found in Excel sheet, \n 0 Items Barcode already exists,\n 0 Wrong Vendor Id or Department Id Found.":
      return "تم العثور على 0 عنصر مكرر في ورقة Excel ، \n 0 الرمز الشريطي للعناصر موجود بالفعل ، \n 0 تم العثور على معرف البائع أو معرف القسم غير الصحيح.";
    case "Import":
      return "يستورد";
    case "Skip & Import":
      return "تخطي والاستيراد";
    case "Items Found":
      return "العناصر الموجودة";
    case "Inventory":
      return "مخزون";
    case "General Details":
      return "تفاصيل عامة";
    case "Item Code / SKU":
      return "رمز الصنف / SKU";
    case "Enter item code":
      return "أدخل رمز الصنف";
    case "Item code is already in use":
      return 'كود البند قيد الاستخدام بالفعل';

    case "Product Name":
      return "اسم المنتج";
    case "Enter product name":
      return "أدخل اسم المنتج";

    case "Select a department":
      return "حدد القسم";

    case "Description ":
      return "وصف";

    case "Enter a number":
      return "أدخل رقما";
    case "Margin ":
      return "نسبة";
    case "Price W/T ":
      return "السعر مع الضريبة";
    case "Barcode ":
      return "الباركود";
    case "Change Image":
      return "تحميل الصور";
    case "Upload Image":
      return "تحميل الصور";
    case "Cancel Image":
      return "إلغاء الصورة";
    case "Product Image":
      return "صورة المنتج";
    case "Enter department name":
      return "أدخل اسم القسم";
    case "Department Name":
      return "اسم القسم";

    case "Enter department id":
      return "أدخل معرف القسم";
    case "Department Id":
      return "معرف القسم";
    case "Department Details":
      return "تفاصيل القسم";

    case "User Groups":
      return "مجموعات الاعضاء";
    case "Max Discount %":
      return "أقصى خصم٪";
    case "Emp. Id":
      return "رقم الموظف";
    case "User Role":
      return "مجموعة إدارة الوصول";
    case "Employee Name":
      return "اسم الموظف";
    case "Employee ID":
      return "رقم الموظف";
    case "All Roles":
      return "كل الأدوار";
    case "Enter a value between 0 - 100%":
      return "أدخل قيمة بين 0-100٪";
    case "Enter a valid number":
      return "أدخل رقمًا صالحًا";
    case "Max Discount % ":
      return "أقصى خصم٪";
    case "Select a role":
      return "حدد دورًا";
    case "Select Role":
      return "حدد الدور";

    case "Please make sure your passwords match.":
      return "يرجى التأكد من تطابق كلمات السر الخاصة بك.";
    case "Re enter your password":
      return "أعد إدخال كلمة المرور";
    case "Confirm Password":
      return "تأكيد كلمة المرور";

    case "Enter employee id":
      return "أدخل معرف الموظف";
    case "Employee Id":
      return "رقم الموظف";
    case "Enter your password":
      return "ادخل رقمك السري";
    case "(optional)":
      return "(اختياري)";
    case "Last Name ":
      return "الاسم الثاني";
    case "Username is already in use":
      return "هذا الاسم مستخدم من قبل شخص ما";
    case "Enter your username":
      return "أدخل اسم المستخدم الخاص بك";
    case "Enter your name":
      return "أدخل أسمك";
    case "First Name":
      return "الاسم الاول";
    case "Employee Details":
      return "تفاصيل الموظف";

    case "Create":
      return "جديد";
    case "Edit":
      return "يحرر";
    case "Refresh":
      return "ينعش";
    case "Date Range":
      return "نطاق الموعد";
    case "Group Name":
      return "أسم المجموعة";
    case "Group Description":
      return "وصف المجموعة";
    case "Created Date":
      return "تاريخ الإنشاء";
    case "Created by":
      return "انشأ من قبل";
    case "Cancel":
      return "يلغي";
    case "Save":
      return "يحفظ";
    case "  Adjustment":
      return "تعديل";
    case "  Receipt":
      return "موبيعات";
    case "  Purchase voucher":
      return "مشتريات";
    case "  Settings":
      return "إعدادات";
    case "  Reports":
      return "التقارير";
    case "  Sales Receipt":
      return "موبيعات";
    case "  Registers":
      return "السجلات";
    case "  Backup & Reset":
      return "إعادة تعيين النسخ الاحتياطي";
    case "  Former Z Out":
      return "خرج Z السابق";
    case '  Customers':
      return "عملاء";
    case '  Inventory':
      return "مخزون";
    case '  Departments':
      return "اقسام";
    case "  Vendors":
      return "موردين";
    case "  Groups":
      return "مجموعات";
    case "  Employees":
      return "الموظفين";
    case "  All active permission can be assigned to this Group":
      return "يمكن تعيين كافة الأذونات النشطة لهذه المجموعة";
    case "Enter group description":
      return "أدخل وصف المجموعة";

    case "Enter group name":
      return "أدخل اسم المجموعة";

    case "Module Permission":
      return "إذن الوحدة النمطية";
    case "Groups":
      return "مجموعات";
    case "Back":
      return "السابق";
    case "Reset":
      return "إعادة ضبط";
    case "Please backup before, resetting the application.":
      return "يرجى النسخ الاحتياطي من قبل ، إعادة تعيين التطبيق.";
    case "Reset Application?":
      return "إعادة تعيين التطبيق؟";
    case "Reset Application":
      return "إعادة تعيين التطبيق";
    case "Restore":
      return "يعيد";
    case "Backup":
      return "النسخ الاحتياطية";
    case "Login to Bitpro":
      return "تسجيل الدخول إلى Bitpro";
    case "Please enter your username":
      return "الرجاء إدخال اسم المستخدم";
    case "Username":
      return "اسم المستخدم";
    case "Please enter your password":
      return "من فضلك أدخل رقمك السري";
    case "Password":
      return "كلمة المرور";

    case "Enter the correct username and password.":
      return "أدخل اسم المستخدم وكلمة المرور الصحيحين.";
    case "Login":
      return "تسجيل الدخول";
    case "Bitpro is a trademark of Bitpro\nInternational, www.bitproglobal.com":
      return "Bitpro هي علامة تجارية لشركة Bitpro\nعالميًا ، www.bitproglobal.com ";
    case "Version 1.0.0":
      return "الإصدار 1.0.0";
    case "Licensed Up to: 20-12-2022":
      return "مرخص لها حتى: 20-12-2022";
    case "Saved":
      return "البيانات المحفوظة";

    default:
      return txt;
  }
}
