import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  runApp(const RatronicsApp());
}

const Color brandRed = Color(0xFFB71C1C);

class RatronicsApp extends StatelessWidget {
  const RatronicsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RATRONICS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: brandRed),
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
        appBarTheme: const AppBarTheme(
          backgroundColor: brandRed,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class Product {
  Product({
    required this.name,
    required this.ram,
    required this.storage,
    required this.sellingPrice,
    required this.quantity,
    required this.purchasePrice,
    this.imagePath,
  });

  final String name;
  final String ram;
  final String storage;
  final double sellingPrice;
  final double purchasePrice;
  final String? imagePath;
  int quantity;

  Map<String, dynamic> toJson() => {
        'name': name,
        'ram': ram,
        'storage': storage,
        'sellingPrice': sellingPrice,
        'purchasePrice': purchasePrice,
        'quantity': quantity,
        'imagePath': imagePath,
      };

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'] as String,
      ram: json['ram'] as String,
      storage: json['storage'] as String,
      sellingPrice: (json['sellingPrice'] as num).toDouble(),
      purchasePrice: (json['purchasePrice'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
      imagePath: json['imagePath'] as String?,
    );
  }
}

class Customer {
  Customer({required this.name, required this.phone});
  final String name;
  final String phone;
}

class PaymentRecord {
  PaymentRecord({required this.amount, required this.date});
  final double amount;
  final DateTime date;
}

class LoanRecord {
  LoanRecord({
    required this.customer,
    required this.phoneModel,
    required this.agreedPrice,
    required this.deposit,
  }) : balance = agreedPrice - deposit;

  final Customer customer;
  final String phoneModel;
  final double agreedPrice;
  final double deposit;
  double balance;
  final List<PaymentRecord> payments = [];
}

class InstalmentRecord {
  InstalmentRecord({
    required this.customer,
    required this.phoneModel,
    required this.totalPrice,
    required this.deposit,
    required this.months,
  }) : balance = totalPrice - deposit;

  final Customer customer;
  final String phoneModel;
  final double totalPrice;
  final double deposit;
  final int months;
  double balance;
  bool handedOver = false;
  final List<PaymentRecord> payments = [];
}

class SalesRecord {
  SalesRecord({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.customerName,
  });

  final String productName;
  final int quantity;
  final double unitPrice;
  final String customerName;
  double get total => quantity * unitPrice;
}

class BusinessStore extends ChangeNotifier {
  final List<Product> products = [];
  final List<Customer> customers = [];
  final List<LoanRecord> loans = [];
  final List<InstalmentRecord> instalments = [];
  final List<SalesRecord> sales = [];

  static const String _productsKey = 'ratronics_products';

  Future<void> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_productsKey);

    if (saved != null) {
      final List<dynamic> decoded = jsonDecode(saved);
      products
        ..clear()
        ..addAll(
          decoded.map(
            (item) => Product.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          ),
        );
      notifyListeners();
    }
  }

  Future<void> _saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      products.map((product) => product.toJson()).toList(),
    );
    await prefs.setString(_productsKey, encoded);
  }

  Future<void> addProduct(Product product) async {
    products.add(product);
    notifyListeners();
    await _saveProducts();
  }

  void addCustomer(Customer customer) {
    customers.add(customer);
    notifyListeners();
  }

  void addLoan(LoanRecord loan) {
    loans.add(loan);
    notifyListeners();
  }

  void addInstalment(InstalmentRecord instalment) {
    instalments.add(instalment);
    notifyListeners();
  }

  void addSale(SalesRecord sale) {
    final product = products.firstWhere(
      (p) => p.name == sale.productName,
    );
    product.quantity -= sale.quantity;
    sales.add(sale);
    notifyListeners();
  }

  void addLoanPayment(LoanRecord loan, double amount) {
    loan.balance =
        (loan.balance - amount).clamp(0, double.infinity).toDouble();
    loan.payments.add(
      PaymentRecord(amount: amount, date: DateTime.now()),
    );
    notifyListeners();
  }

  void addInstalmentPayment(InstalmentRecord item, double amount) {
    item.balance =
        (item.balance - amount).clamp(0, double.infinity).toDouble();
    item.payments.add(
      PaymentRecord(amount: amount, date: DateTime.now()),
    );
    notifyListeners();
  }

  double get totalSales =>
      sales.fold(0, (sum, item) => sum + item.total);
}


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BusinessStore store = BusinessStore();

  @override
  void initState() {
    super.initState();
    store.loadProducts();
  }
  
  @override
  void dispose() {
    store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final departments = [
      _Department('RAMSO MOBILE SHOP', 'Simu, stock, mauzo na malipo', Icons.phone_android),
      _Department('RAMSO DIGITAL', 'Huduma za kidijitali', Icons.devices),
      _Department('RAMSO ELECTRONICS', 'Vifaa vya kielektroniki', Icons.electrical_services),
      _Department('RAMSO SERVICE CENTER', 'Huduma na matengenezo', Icons.build),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('RATRONICS')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 12),
          const Icon(Icons.business, size: 66, color: brandRed),
          const SizedBox(height: 8),
          const Text(
            'KARIBU RATRONICS',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text('RAMSO Business Services',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 28),
          const Text('CHAGUA KITENGO',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          ...departments.map(
            (department) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                leading: Icon(department.icon, size: 32, color: brandRed),
                title: Text(department.title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(department.subtitle),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {
                  if (department.title == 'RAMSO MOBILE SHOP') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MobileShopScreen(store: store),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DepartmentPlaceholder(
                          title: department.title,
                          subtitle: department.subtitle,
                          icon: department.icon,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Toleo la mwanzo: taarifa huhifadhiwa kwa muda wakati app iko wazi.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _Department {
  const _Department(this.title, this.subtitle, this.icon);
  final String title;
  final String subtitle;
  final IconData icon;
}

class DepartmentPlaceholder extends StatelessWidget {
  const DepartmentPlaceholder({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 76, color: brandRed),
              const SizedBox(height: 18),
              Text(title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(subtitle, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              const Text('Kitengo hiki kitaongezwa katika hatua inayofuata.',
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class MobileShopScreen extends StatelessWidget {
  const MobileShopScreen({super.key, required this.store});
  final BusinessStore store;

  @override
  Widget build(BuildContext context) {
    final items = [
      _MenuItem('Products & Stock', 'Ongeza bidhaa na angalia stock', Icons.inventory_2,
          () => _open(context, ProductsScreen(store: store))),
      _MenuItem('Sales Management', 'Rekodi mauzo ya simu', Icons.point_of_sale,
          () => _open(context, SalesScreen(store: store))),
      _MenuItem('Customer Management', 'Hifadhi wateja', Icons.people,
          () => _open(context, CustomersScreen(store: store))),
      _MenuItem('Phone Loan Management', 'Mikopo na malipo ya wateja', Icons.account_balance_wallet,
          () => _open(context, LoansScreen(store: store))),
      _MenuItem('Phone Instalment', 'Lipa kidogo kidogo; simu hutolewa baada ya malipo yote', Icons.payments,
          () => _open(context, InstalmentsScreen(store: store))),
      _MenuItem('Reports & Analytics', 'Muhtasari wa biashara', Icons.bar_chart,
          () => _open(context, ReportsScreen(store: store))),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('RAMSO MOBILE SHOP')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: brandRed,
            child: const Padding(
              padding: EdgeInsets.all(18),
              child: Row(
                children: [
                  Icon(Icons.storefront, color: Colors.white, size: 40),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BUSINESS MANAGEMENT',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Simu • Stock • Mauzo • Malipo',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Icon(item.icon, color: brandRed, size: 30),
                  title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(item.subtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: item.onTap,
                ),
              )),
        ],
      ),
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}

class _MenuItem {
  const _MenuItem(this.title, this.subtitle, this.icon, this.onTap);
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
}

String money(double amount) =>
    'TSh ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key, required this.store});
  final BusinessStore store;

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products & Stock')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: brandRed,
        foregroundColor: Colors.white,
        onPressed: _addProduct,
        icon: const Icon(Icons.add),
        label: const Text('Ongeza bidhaa'),
      ),
      body: AnimatedBuilder(
        animation: widget.store,
        builder: (context, _) {
          if (widget.store.products.isEmpty) {
            return const EmptyState(icon: Icons.inventory_2, text: 'Bado hakuna bidhaa. Bonyeza “Ongeza bidhaa”.');
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
            itemCount: widget.store.products.length,
            itemBuilder: (context, index) {
              final p = widget.store.products[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.phone_android, color: brandRed, size: 32),
                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('RAM ${p.ram} • ${p.storage} • Bei: ${money(p.sellingPrice)}\nStock: ${p.quantity}'),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _addProduct() async {
    final formKey = GlobalKey<FormState>();
    final name = TextEditingController();
    final ram = TextEditingController();
    final storage = TextEditingController();
    final selling = TextEditingController();
    final purchase = TextEditingController();
    final quantity = TextEditingController(text: '1');
    String? imagePath;

    Future<void> pickProductImage(
  ImageSource source,
  StateSetter updateDialog,
) async {
  final picker = ImagePicker();

  final picked = await picker.pickImage(
    source: source,
    imageQuality: 80,
    maxWidth: 1600,
  );

  if (picked == null) return;

  final directory = await getApplicationDocumentsDirectory();
  final dot = picked.path.lastIndexOf('.');
  final extension =
      dot >= 0 ? picked.path.substring(dot) : '.jpg';

  final savedImage = await File(picked.path).copy(
    '${directory.path}/product_${DateTime.now().microsecondsSinceEpoch}$extension',
  );

  updateDialog(() {
    imagePath = savedImage.path;
  });
}

    final result = await showDialog<Product>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
        title: const Text('Ongeza bidhaa'),
        content: SizedBox(
          width: 420,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
children: [
  if (imagePath != null)
    Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Image.file(
        File(imagePath!),
        height: 140,
        fit: BoxFit.contain,
      ),
    )
  else
    const Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Icon(
        Icons.add_a_photo,
        size: 64,
        color: Colors.grey,
      ),
    ),
  Row(
    children: [
      Expanded(
        child: OutlinedButton.icon(
          onPressed: () async {
            await pickProductImage(
              ImageSource.camera,
              setDialogState,
            );
          },
          icon: const Icon(Icons.camera_alt),
          label: const Text('Camera'),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: OutlinedButton.icon(
          onPressed: () async {
            await pickProductImage(
              ImageSource.gallery,
              setDialogState,
            );
          },
          icon: const Icon(Icons.photo_library),
          label: const Text('Gallery'),
        ),
      ),
    ],
  ),
  const SizedBox(height: 12),
  field(name, 'Jina la simu/bidhaa'),
                    field(ram, 'RAM (mf. 4GB)', required: false),
                  field(storage, 'Storage (mf. 64GB)', required: false),
                  field(selling, 'Bei ya kuuza (TSh)', number: true),
                  field(purchase, 'Bei ya kununulia (TSh)', number: true),
                  field(quantity, 'Idadi ya stock', number: true),
                ],
              ),
            ),
          ),
        ),
       actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Ghairi'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;

              Navigator.pop(
                dialogContext,
                Product(
                  name: name.text.trim(),
                  ram: ram.text.trim().isEmpty ? '-' : ram.text.trim(),
                  storage: storage.text.trim().isEmpty
                      ? '-'
                      : storage.text.trim(),
                  sellingPrice: double.parse(selling.text.trim()),
                  purchasePrice: double.parse(purchase.text.trim()),
                  quantity: int.parse(quantity.text.trim()),
                  imagePath: imagePath,
                ),
              );
            },
            child: const Text('Hifadhi'),
          ),
        ],
      ),
    ),
  );

    if (result != null) {
       await widget.store.addProduct(result);
    }
  }

Widget field(
  TextEditingController controller,
  String label, {
  bool number = false,
  bool required = true,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextFormField(
      controller: controller,
      keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      validator: (value) {
        if (required && (value == null || value.trim().isEmpty)) return 'Jaza taarifa hii';
        if (number && value != null && value.trim().isNotEmpty &&
            (double.tryParse(value.trim()) == null || double.parse(value.trim()) < 0)) {
          return 'Weka namba sahihi';
        }
        return null;
      },
    ),
  );
}

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key, required this.store});
  final BusinessStore store;

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Management')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: brandRed,
        foregroundColor: Colors.white,
        onPressed: _addCustomer,
        icon: const Icon(Icons.person_add),
        label: const Text('Ongeza mteja'),
      ),
      body: AnimatedBuilder(
        animation: widget.store,
        builder: (context, _) => widget.store.customers.isEmpty
            ? const EmptyState(icon: Icons.people, text: 'Bado hakuna wateja waliohifadhiwa.')
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                itemCount: widget.store.customers.length,
                itemBuilder: (context, i) {
                  final c = widget.store.customers[i];
                  return Card(child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(c.name),
                    subtitle: Text(c.phone),
                  ));
                },
              ),
      ),
    );
  }

  Future<void> _addCustomer() async {
    final formKey = GlobalKey<FormState>();
    final name = TextEditingController();
    final phone = TextEditingController();
    final customer = await showDialog<Customer>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ongeza mteja'),
        content: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            field(name, 'Jina la mteja'),
            field(phone, 'Namba ya simu'),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Ghairi')),
          FilledButton(onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.pop(ctx, Customer(name: name.text.trim(), phone: phone.text.trim()));
            }
          }, child: const Text('Hifadhi')),
        ],
      ),
    );
    if (customer != null) widget.store.addCustomer(customer);
  }
}

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key, required this.store});
  final BusinessStore store;

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sales Management')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: brandRed,
        foregroundColor: Colors.white,
        onPressed: _addSale,
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Rekodi mauzo'),
      ),
      body: AnimatedBuilder(
        animation: widget.store,
        builder: (context, _) => widget.store.sales.isEmpty
            ? const EmptyState(icon: Icons.point_of_sale, text: 'Bado hakuna mauzo yaliyorekodiwa.')
            : ListView(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                children: [
                  Card(child: ListTile(
                    title: const Text('Jumla ya mauzo'),
                    titleTextStyle: const TextStyle(fontWeight:FontWeight.bold, color: Colors.black, fontSize: 16),
trailing: Text(money(widget.store.totalSales), style: const TextStyle(fontWeight: FontWeight.bold, color: brandRed)),
)),
...widget.store.sales.map((s) => Card(child: ListTile(
title: Text(s.productName),
subtitle: Text('Idadi: ${s.quantity} • Mteja: ${s.customerName}'),
trailing: Text(money(s.total)),
))),
],
),
),
);
}

Future<void> _addSale() async {
if (widget.store.products.isEmpty) {
showMessage(context, 'Ongeza bidhaa kwenye Stock kwanza.');
return;
}
final formKey = GlobalKey<FormState>();
Product selected = widget.store.products.first;
final qty = TextEditingController(text: '1');
final customer = TextEditingController(text: 'Cash customer');

final sale = await showDialog<SalesRecord>(  
  context: context,  
  builder: (ctx) => StatefulBuilder(  
    builder: (ctx, setDialogState) => AlertDialog(  
      title: const Text('Rekodi mauzo'),  
      content: SizedBox(  
        width: 420,  
        child: Form(  
          key: formKey,  
          child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [  
            DropdownButtonFormField<Product>(  
              value: selected,  
              isExpanded: true,  
              decoration: const InputDecoration(labelText: 'Bidhaa', border: OutlineInputBorder()),  
              items: widget.store.products.map((p) => DropdownMenuItem(value: p, child: Text('${p.name} (stock ${p.quantity})'))).toList(),  
              onChanged: (p) { if (p != null) setDialogState(() => selected = p); },  
            ),  
            const SizedBox(height: 10),  
            field(qty, 'Idadi ya kuuza', number: true),  
            field(customer, 'Jina la mteja'),  
          ])),  
        ),  
      ),  
      actions: [  
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Ghairi')),  
        FilledButton(onPressed: () {  
          if (!formKey.currentState!.validate()) return;  
          final count = int.tryParse(qty.text.trim()) ?? 0;  
          if (count < 1 || count > selected.quantity) {  
            showMessage(context, 'Idadi haipaswi kuzidi stock iliyopo.');  
            return;  
          }  
          Navigator.pop(ctx, SalesRecord(  
            productName: selected.name,  
            quantity: count,  
            unitPrice: selected.sellingPrice,  
            customerName: customer.text.trim(),  
          ));  
        }, child: const Text('Hifadhi mauzo')),  
      ],  
    ),  
  ),  
);  
if (sale != null) widget.store.addSale(sale);

}
}

class LoansScreen extends StatefulWidget {
const LoansScreen({super.key, required this.store});
final BusinessStore store;

@override
State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('Phone Loan Management')),
floatingActionButton: FloatingActionButton.extended(
backgroundColor: brandRed,
foregroundColor: Colors.white,
onPressed: _addLoan,
icon: const Icon(Icons.add),
label: const Text('Sajili mkopo'),
),
body: AnimatedBuilder(
animation: widget.store,
builder: (context, _) => widget.store.loans.isEmpty
? const EmptyState(icon: Icons.account_balance_wallet, text: 'Bado hakuna mikopo iliyosajiliwa.')
: ListView.builder(
padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
itemCount: widget.store.loans.length,
itemBuilder: (context, i) {
final loan = widget.store.loans[i];
return Card(child: Padding(
padding: const EdgeInsets.all(8),
child: ListTile(
title: Text('${loan.customer.name} • ${loan.phoneModel}', style: const TextStyle(fontWeight: FontWeight.bold)),
subtitle: Text('Bei ya mteja: ${money(loan.agreedPrice)}\nKianzio: ${money(loan.deposit)} • Salio: ${money(loan.balance)}'),
isThreeLine: true,
trailing: IconButton(
icon: const Icon(Icons.add_card, color: brandRed),
tooltip: 'Rekodi malipo',
onPressed: () => _recordPayment(loan),
),
),
));
},
),
),
);
}

Future<void> _addLoan() async {
final formKey = GlobalKey<FormState>();
final name = TextEditingController();
final phone = TextEditingController();
final model = TextEditingController();
final price = TextEditingController();
final deposit = TextEditingController(text: '0');

final loan = await showDialog<LoanRecord>(  
  context: context,  
  builder: (ctx) => AlertDialog(  
    title: const Text('Sajili mkopo wa simu'),  
    content: SizedBox(width: 420, child: Form(  
      key: formKey,  
      child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [  
        field(name, 'Jina la mteja'),  
        field(phone, 'Namba ya simu'),  
        field(model, 'Aina ya simu'),  
        field(price, 'Bei ambayo mteja atalipa (TSh)', number: true),  
        field(deposit, 'Kianzio (TSh)', number: true),  
        const Text('Bei ya kununulia simu haihitajiki kwenye kipengele hiki.',  
            style: TextStyle(fontSize: 12, color: brandRed)),  
      ])),  
    )),  
    actions: [  
      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Ghairi')),  
      FilledButton(onPressed: () {  
        if (!formKey.currentState!.validate()) return;  
        final total = double.parse(price.text);  
        final first = double.parse(deposit.text);  
        if (first > total) {  
          showMessage(context, 'Kianzio hakiwezi kuzidi bei ya mteja.');  
          return;  
        }  
        Navigator.pop(ctx, LoanRecord(  
          customer: Customer(name: name.text.trim(), phone: phone.text.trim()),  
          phoneModel: model.text.trim(),  
          agreedPrice: total,  
          deposit: first,  
        ));  
      }, child: const Text('Hifadhi')),  
    ],  
  ),  
);  
if (loan != null) widget.store.addLoan(loan);

}

Future<void> _recordPayment(LoanRecord loan) async {
final controller = TextEditingController();
final amount = await showDialog<double>(
context: context,
builder: (ctx) => AlertDialog(
title: const Text('Rekodi malipo'),
content: field(controller, 'Kiasi kilicholipwa (TSh)', number: true),
actions: [
TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Ghairi')),
FilledButton(onPressed: () {
final value = double.tryParse(controller.text.trim());
if (value == null || value <= 0 || value > loan.balance) {
showMessage(context, 'Weka kiasi sahihi kisichozidi salio.');
return;
}
Navigator.pop(ctx, value);
}, child: const Text('Hifadhi malipo')),
],
),
);
if (amount != null) widget.store.addLoanPayment(loan, amount);
}
}

class InstalmentsScreen extends StatefulWidget {
const InstalmentsScreen({super.key, required this.store});
final BusinessStore store;

@override
State<InstalmentsScreen> createState() => _InstalmentsScreenState();
}

class _InstalmentsScreenState extends State<InstalmentsScreen> {
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('Phone Instalment')),
floatingActionButton: FloatingActionButton.extended(
backgroundColor: brandRed,
foregroundColor: Colors.white,
onPressed: _addInstalment,
icon: const Icon(Icons.add),
label: const Text('Sajili instalment'),
),
body: AnimatedBuilder(
animation: widget.store,
builder: (context, _) => widget.store.instalments.isEmpty
? const EmptyState(icon: Icons.payments, text: 'Bado hakuna wateja wa instalment.')
: ListView.builder(
padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
itemCount: widget.store.instalments.length,
itemBuilder: (context, i) {
final item = widget.store.instalments[i];
final paid = item.balance <= 0;
return Card(
child: Padding(
padding: const EdgeInsets.all(8),
child: Column(
children: [
ListTile(
title: Text('${item.customer.name} • ${item.phoneModel}',
style: const TextStyle(fontWeight: FontWeight.bold)),
subtitle: Text(
'Bei ya mteja: ${money(item.totalPrice)}\nSalio: ${money(item.balance)} • Muda: miezi ${item.months}\nMalipo: ${paid ? 'Yamekamilika' : 'Anaendelea'}\nSimu: ${item.handedOver ? 'Imekabidhiwa' : 'Bado haijakabidhiwa'}',
),
isThreeLine: true,
),
Wrap(
spacing: 8,
children: [
OutlinedButton.icon(
onPressed: paid ? null : () => _recordPayment(item),
icon: const Icon(Icons.add_card),
label: const Text('Rekodi malipo'),
),
FilledButton.icon(
onPressed: paid && !item.handedOver
? () => _handover(item)
: null,
icon: const Icon(Icons.local_shipping),
label: const Text('Kamilisha makabidhiano'),
),
],
),
const SizedBox(height: 8),
],
),
),
);
},
),
),
);
}

Future<void> _addInstalment() async {
final formKey = GlobalKey<FormState>();
final name = TextEditingController();
final phone = TextEditingController();
final model = TextEditingController();
final price = TextEditingController();
final deposit = TextEditingController(text: '0');
final months = TextEditingController(text: '3');

final item = await showDialog<InstalmentRecord>(  
  context: context,  
  builder: (ctx) => AlertDialog(  
    title: const Text('Sajili Phone Instalment'),  
    content: SizedBox(width: 420, child: Form(  
      key: formKey,  
      child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [  
        field(name, 'Jina la mteja'),  
        field(phone, 'Namba ya simu'),  
        field(model, 'Aina ya simu anayochagua'),  
        field(price, 'Bei ya mteja kulipa (TSh)', number: true),  
        field(deposit, 'Kianzio (TSh)', number: true),  
        field(months, 'Muda wa malipo kwa miezi', number: true),  
        const Text('Simu itakabidhiwa tu baada ya salio kufika TSh 0.',  
            style: TextStyle(fontSize: 12, color: brandRed)),  
      ])),  
    )),  
    actions: [  
      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Ghairi')),  
      FilledButton(onPressed: () {  
        if (!formKey.currentState!.validate()) return;  
        final total = double.parse(price.text);  
        final first = double.parse(deposit.text);  
        final duration = int.tryParse(months.text) ?? 0;  
        if (first > total || duration < 1) {  
          showMessage(context, 'Kianzio au muda si sahihi.');  
          return;  
        }  
        Navigator.pop(ctx, InstalmentRecord(  
          customer: Customer(name: name.text.trim(), phone: phone.text.trim()),  
          phoneModel: model.text.trim(),  
          totalPrice: total,  
          deposit: first,  
          months: duration,  
        ));  
      }, child: const Text('Hifadhi')),  
    ],  
  ),  
);  
if (item != null) widget.store.addInstalment(item);

}

Future<void> _recordPayment(InstalmentRecord item) async {
final controller = TextEditingController();
final amount = await showDialog<double>(
context: context,
builder: (ctx) => AlertDialog(
title: const Text('Rekodi instalment payment'),
content: field(controller, 'Kiasi kilicholipwa (TSh)', number: true),
actions: [
TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Ghairi')),
FilledButton(onPressed: () {
final value = double.tryParse(controller.text.trim());
if (value == null || value <= 0 || value > item.balance) {
showMessage(context, 'Weka kiasi sahihi kisichozidi salio.');
return;
}
Navigator.pop(ctx, value);
}, child: const Text('Hifadhi malipo')),
],
),
);
if (amount != null) widget.store.addInstalmentPayment(item, amount);
}

Future<void> _handover(InstalmentRecord item) async {
final confirmed = await showDialog<bool>(
context: context,
builder: (ctx) => AlertDialog(
title: const Text('Thibitisha makabidhiano'),
content: Text('Malipo yamekamilika. Unathibitisha kuwa simu ya ${item.phoneModel} imekabidhiwa/kutumwa kwa ${item.customer.name}?'),
actions: [
TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Bado')),
FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Thibitisha')),
],
),
);
if (confirmed == true && item.balance <= 0) {
setState(() => item.handedOver = true);
widget.store.notifyListeners();
if (mounted) showMessage(context, 'Makabidhiano yamerekodiwa.');
}
}
}

class ReportsScreen extends StatelessWidget {
const ReportsScreen({super.key, required this.store});
final BusinessStore store;

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('Reports & Analytics')),
body: AnimatedBuilder(
animation: store,
builder: (context, _) => ListView(
padding: const EdgeInsets.all(16),
children: [
reportCard('Jumla ya mauzo yaliyorekodiwa', money(store.totalSales), Icons.point_of_sale),
reportCard('Aina za bidhaa', '${store.products.length}', Icons.inventory_2),
reportCard('Jumla ya stock iliyopo', '${store.products.fold<int>(0, (sum, p) => sum + p.quantity)}', Icons.warehouse),
reportCard('Wateja', '${store.customers.length}', Icons.people),
reportCard('Mikopo ya simu', '${store.loans.length}', Icons.account_balance_wallet),
reportCard('Instalment', '${store.instalments.length}', Icons.payments),
const Padding(
padding: EdgeInsets.only(top: 12),
child: Text(
'Hizi ni takwimu za taarifa zilizoingizwa kwenye app hii wakati iko wazi. Uhifadhi wa kudumu na online sync bado vinahitaji kuongezwa.',
style: TextStyle(color: Colors.grey, fontSize: 12),
),
),
],
),
),
);
}

Widget reportCard(String title, String value, IconData icon) {
return Card(
child: ListTile(
leading: Icon(icon, color: brandRed, size: 30),
title: Text(title),
trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: brandRed)),
),
);
}
}

class EmptyState extends StatelessWidget {
const EmptyState({super.key, required this.icon, required this.text});
final IconData icon;
final String text;

@override
Widget build(BuildContext context) {
return Center(
child: Padding(
padding: const EdgeInsets.all(28),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
Icon(icon, size: 58, color: Colors.grey),
const SizedBox(height: 14),
Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
],
),
),
);
}
}
