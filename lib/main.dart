import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WorkshopERPApp());
}

class WorkshopERPApp extends StatelessWidget {
  const WorkshopERPApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workshop Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB8860B),
          primary: const Color(0xFF1E293B),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E293B),
          foregroundColor: Colors.white,
          elevation: 1,
        ),
      ),
      home: const WorkshopHomeScreen(),
    );
  }
}

// -------------------------------------------------------------
// DATA MODELS
// -------------------------------------------------------------

class WorkerJob {
  final String id;
  final String workerName;
  final String designNo;
  final String taskType;
  final int piecesIssued;
  int piecesReturned;
  final double wageRatePerPiece;
  String status;
  final DateTime date;

  WorkerJob({
    required this.id,
    required this.workerName,
    required this.designNo,
    required this.taskType,
    required this.piecesIssued,
    this.piecesReturned = 0,
    required this.wageRatePerPiece,
    this.status = 'WORKING',
    required this.date,
  });

  double get wageDue => piecesReturned * wageRatePerPiece;
  int get pendingPieces => piecesIssued - piecesReturned;
}

class JewelleryStock {
  final String designNo;
  final String title;
  final String category;
  final String plating;
  final double wholesaleRate;
  final int piecesPerBox;
  int boxesInStock;

  JewelleryStock({
    required this.designNo,
    required this.title,
    required this.category,
    required this.plating,
    required this.wholesaleRate,
    required this.piecesPerBox,
    required this.boxesInStock,
  });
}

class ClientOrder {
  final String billNo;
  final String clientName;
  final String city;
  final String itemsSummary;
  final double totalBill;
  double amountPaid;
  final DateTime date;

  ClientOrder({
    required this.billNo,
    required this.clientName,
    required this.city,
    required this.itemsSummary,
    required this.totalBill,
    required this.amountPaid,
    required this.date,
  });

  double get balanceDue => totalBill - amountPaid;
}

// -------------------------------------------------------------
// MAIN TAB NAVIGATION
// -------------------------------------------------------------

class WorkshopHomeScreen extends StatefulWidget {
  const WorkshopHomeScreen({super.key});

  @override
  State<WorkshopHomeScreen> createState() => _WorkshopHomeScreenState();
}

class _WorkshopHomeScreenState extends State<WorkshopHomeScreen> {
  int _currentIndex = 0;

  final List<WorkerJob> _workerJobs = [
    WorkerJob(
      id: 'JOB-101',
      workerName: 'Ramesh (Karigar #12)',
      designNo: 'RNG-204',
      taskType: 'Stone Setting (AD/CZ)',
      piecesIssued: 144,
      piecesReturned: 144,
      wageRatePerPiece: 4.5,
      status: 'COMPLETED',
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    WorkerJob(
      id: 'JOB-102',
      workerName: 'Bikash (Karigar #05)',
      designNo: 'CHK-88',
      taskType: 'Casting Filing & Cutting',
      piecesIssued: 60,
      piecesReturned: 30,
      wageRatePerPiece: 8.0,
      status: 'WORKING',
      date: DateTime.now(),
    ),
    WorkerJob(
      id: 'JOB-103',
      workerName: 'Sanjoy (Polishing)',
      designNo: 'RNG-301',
      taskType: 'Buffing & Polishing',
      piecesIssued: 120,
      piecesReturned: 0,
      wageRatePerPiece: 3.0,
      status: 'WORKING',
      date: DateTime.now(),
    ),
  ];

  final List<JewelleryStock> _stockList = [
    JewelleryStock(
      designNo: 'RNG-204',
      title: 'Brass Casting AD Ring',
      category: 'Rings',
      plating: 'Micro Gold (1g)',
      wholesaleRate: 1450,
      piecesPerBox: 12,
      boxesInStock: 35,
    ),
    JewelleryStock(
      designNo: 'CHK-88',
      title: 'Antique Matte Choker Set',
      category: 'Necklace',
      plating: 'Antique Matte',
      wholesaleRate: 3200,
      piecesPerBox: 4,
      boxesInStock: 8,
    ),
    JewelleryStock(
      designNo: 'TOP-12',
      title: 'Floral Earring Studs',
      category: 'Earrings',
      plating: 'Micro Gold (1g)',
      wholesaleRate: 980,
      piecesPerBox: 12,
      boxesInStock: 52,
    ),
  ];

  final List<ClientOrder> _orders = [
    ClientOrder(
      billNo: 'BILL-401',
      clientName: 'Maa Tara Jewellers',
      city: 'Burrabazar',
      itemsSummary: '10 Bx RNG-204, 5 Bx TOP-12',
      totalBill: 19400,
      amountPaid: 10000,
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ClientOrder(
      billNo: 'BILL-402',
      clientName: 'Shree Krishna Ornaments',
      city: 'Howrah',
      itemsSummary: '4 Bx CHK-88',
      totalBill: 12800,
      amountPaid: 12800,
      date: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screens = [
      WorkerJobScreen(
        jobs: _workerJobs,
        onAddJob: (job) => setState(() => _workerJobs.insert(0, job)),
        onUpdateReturned: (job, returnedCount) {
          setState(() {
            job.piecesReturned = returnedCount;
            if (job.piecesReturned >= job.piecesIssued) {
              job.status = 'COMPLETED';
            }
          });
        },
      ),
      WorkshopStockScreen(
        stock: _stockList,
        onStockAdjust: (item, delta) {
          setState(() {
            item.boxesInStock = (item.boxesInStock + delta).clamp(0, 9999);
          });
        },
        onAddStock: (item) => setState(() => _stockList.add(item)),
      ),
      ClientKhataScreen(
        orders: _orders,
        onAddOrder: (order) => setState(() => _orders.insert(0, order)),
        onAddPayment: (order, amt) {
          setState(() {
            order.amountPaid = (order.amountPaid + amt).clamp(0, order.totalBill);
          });
        },
      ),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: '50 Workers',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Stock Vault',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Client Khata',
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// TAB 1: 50-WORKER / KARIGAR ISSUE-RETURN LEDGER
// -------------------------------------------------------------

class WorkerJobScreen extends StatelessWidget {
  final List<WorkerJob> jobs;
  final Function(WorkerJob) onAddJob;
  final Function(WorkerJob, int) onUpdateReturned;

  const WorkerJobScreen({
    super.key,
    required this.jobs,
    required this.onAddJob,
    required this.onUpdateReturned,
  });

  void _showAssignWorkSheet(BuildContext context) {
    final workerCtrl = TextEditingController();
    final designCtrl = TextEditingController();
    final taskCtrl = TextEditingController(text: 'Stone Setting');
    final pcsCtrl = TextEditingController();
    final rateCtrl = TextEditingController(text: '5.0');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Issue Work to Karigar / Worker', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(controller: workerCtrl, decoration: const InputDecoration(labelText: 'Worker Name / Karigar No')),
              TextField(controller: designCtrl, decoration: const InputDecoration(labelText: 'Design / Dye Code (e.g. RNG-204)')),
              TextField(controller: taskCtrl, decoration: const InputDecoration(labelText: 'Task (Filing, Setting, Polishing, Assembly)')),
              Row(
                children: [
                  Expanded(child: TextField(controller: pcsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Pieces Issued'))),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: rateCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Wage (₹ / pc)'))),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white),
                onPressed: () {
                  final pcs = int.tryParse(pcsCtrl.text) ?? 0;
                  final rate = double.tryParse(rateCtrl.text) ?? 0.0;
                  if (workerCtrl.text.isNotEmpty && pcs > 0) {
                    onAddJob(WorkerJob(
                      id: 'JOB-${DateTime.now().millisecondsSinceEpoch % 10000}',
                      workerName: workerCtrl.text,
                      designNo: designCtrl.text,
                      taskType: taskCtrl.text,
                      piecesIssued: pcs,
                      wageRatePerPiece: rate,
                      date: DateTime.now(),
                    ));
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Issue Raw Pieces'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReceiveWorkDialog(BuildContext context, WorkerJob job) {
    final countCtrl = TextEditingController(text: '${job.piecesIssued}');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Receive Pieces - ${job.workerName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Design: ${job.designNo}'),
            Text('Issued: ${job.piecesIssued} pieces'),
            const SizedBox(height: 12),
            TextField(
              controller: countCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Finished Pieces Returned', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(countCtrl.text) ?? job.piecesReturned;
              onUpdateReturned(job, val);
              Navigator.pop(ctx);
            },
            child: const Text('Confirm & Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeJobs = jobs.where((j) => j.status == 'WORKING').length;
    final totalWageDue = jobs.where((j) => j.status == 'COMPLETED').fold(0.0, (sum, j) => sum + j.wageDue);

    return Scaffold(
      appBar: AppBar(title: const Text('Worker Job-Work & Wages')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Issue Work'),
        onPressed: () => _showAssignWorkSheet(context),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFF1F5F9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Active Workers with Brass', style: TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text('$activeJobs Working', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(height: 30, width: 1, color: Colors.grey.shade400),
                Column(
                  children: [
                    const Text('Finished Wage Payable', style: TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text('₹${totalWageDue.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: jobs.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final job = jobs[i];
                final isWorking = job.status == 'WORKING';

                return ListTile(
                  title: Text(job.workerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '${job.designNo} • ${job.taskType}\nIssued: ${job.piecesIssued} pcs | Returned: ${job.piecesReturned} pcs\nWage: ₹${job.wageRatePerPiece}/pc (Earned: ₹${job.wageDue.toStringAsFixed(0)})',
                  ),
                  isThreeLine: true,
                  trailing: isWorking
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB8860B), foregroundColor: Colors.white),
                          onPressed: () => _showReceiveWorkDialog(context, job),
                          child: const Text('Receive'),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                          child: const Text('SETTLED', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// TAB 2: PACKET & BOX STOCK VAULT
// -------------------------------------------------------------

class WorkshopStockScreen extends StatelessWidget {
  final List<JewelleryStock> stock;
  final Function(JewelleryStock, int) onStockAdjust;
  final Function(JewelleryStock) onAddStock;

  const WorkshopStockScreen({
    super.key,
    required this.stock,
    required this.onStockAdjust,
    required this.onAddStock,
  });

  void _showAddDesignSheet(BuildContext context) {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final catCtrl = TextEditingController(text: 'Ring');
    final platingCtrl = TextEditingController(text: 'Micro Gold (1g)');
    final rateCtrl = TextEditingController();
    final pcsCtrl = TextEditingController(text: '12');
    final boxCtrl = TextEditingController(text: '10');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Add Design Packet Stock', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Design / Mould Code')),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Design Name')),
              TextField(controller: catCtrl, decoration: const InputDecoration(labelText: 'Category')),
              TextField(controller: platingCtrl, decoration: const InputDecoration(labelText: 'Plating Finish')),
              Row(
                children: [
                  Expanded(child: TextField(controller: rateCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Rate / Box (₹)'))),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: pcsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Pieces / Box'))),
                ],
              ),
              TextField(controller: boxCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Boxes Ready')),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white),
                onPressed: () {
                  if (codeCtrl.text.isNotEmpty) {
                    onAddStock(JewelleryStock(
                      designNo: codeCtrl.text,
                      title: nameCtrl.text,
                      category: catCtrl.text,
                      plating: platingCtrl.text,
                      wholesaleRate: double.tryParse(rateCtrl.text) ?? 0.0,
                      piecesPerBox: int.tryParse(pcsCtrl.text) ?? 12,
                      boxesInStock: int.tryParse(boxCtrl.text) ?? 0,
                    ));
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Save to Stock'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalBoxes = stock.fold(0, (sum, i) => sum + i.boxesInStock);

    return Scaffold(
      appBar: AppBar(title: const Text('Factory Box & Packet Stock')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Design'),
        onPressed: () => _showAddDesignSheet(context),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFFBF4E2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Warehouse Stock:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('$totalBoxes Boxes', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFFB8860B))),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: stock.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final item = stock[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    child: Text(item.designNo.length > 3 ? item.designNo.substring(0, 3) : item.designNo, style: const TextStyle(fontSize: 12)),
                  ),
                  title: Text('${item.designNo} - ${item.title}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${item.plating} • ₹${item.wholesaleRate.toStringAsFixed(0)} / box (${item.piecesPerBox} pcs)'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => onStockAdjust(item, -1),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                        child: Text('${item.boxesInStock} bx', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                        onPressed: () => onStockAdjust(item, 1),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// TAB 3: CLIENT KHATA & LOCAL WHATSAPP BILL (NO LR / BILTY)
// -------------------------------------------------------------

class ClientKhataScreen extends StatelessWidget {
  final List<ClientOrder> orders;
  final Function(ClientOrder) onAddOrder;
  final Function(ClientOrder, double) onAddPayment;

  const ClientKhataScreen({
    super.key,
    required this.orders,
    required this.onAddOrder,
    required this.onAddPayment,
  });

  void _sendCleanWhatsAppBill(ClientOrder order) async {
    final buffer = StringBuffer()
      ..writeln('✨ *WHOLESALE ORDER BILL* ✨')
      ..writeln('--------------------------------')
      ..writeln('📋 *Bill No:* #${order.billNo}')
      ..writeln('🏬 *Buyer:* ${order.clientName} (${order.city})')
      ..writeln('📅 *Date:* ${order.date.day}/${order.date.month}/${order.date.year}')
      ..writeln('--------------------------------')
      ..writeln('📦 *Items Supplied:*')
      ..writeln(order.itemsSummary)
      ..writeln('--------------------------------')
      ..writeln('💰 *Total Amount:* ₹${order.totalBill.toStringAsFixed(0)}')
      ..writeln('💵 *Payment Received:* ₹${order.amountPaid.toStringAsFixed(0)}')
      ..writeln(order.balanceDue > 0
          ? '⚠️ *PENDING BALANCE DUE:* *₹${order.balanceDue.toStringAsFixed(0)}*'
          : '✅ *STATUS: FULLY SETTLED*')
      ..writeln('--------------------------------')
      ..writeln('_Thank you for your business!_');

    final message = Uri.encodeComponent(buffer.toString());
    final url = Uri.parse('https://wa.me/?text=$message');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showNewBillSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final itemsCtrl = TextEditingController();
    final totalCtrl = TextEditingController();
    final paidCtrl = TextEditingController(text: '0');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Create Wholesale Bill', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Buyer Shop / Trader Name')),
              TextField(controller: cityCtrl, decoration: const InputDecoration(labelText: 'Market / City')),
              TextField(controller: itemsCtrl, decoration: const InputDecoration(labelText: 'Items (e.g. 10 Bx Ring, 4 Bx Choker)')),
              Row(
                children: [
                  Expanded(child: TextField(controller: totalCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Total Bill (₹)'))),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: paidCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cash/UPI Paid (₹)'))),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white),
                onPressed: () {
                  final total = double.tryParse(totalCtrl.text) ?? 0.0;
                  final paid = double.tryParse(paidCtrl.text) ?? 0.0;
                  if (nameCtrl.text.isNotEmpty && total > 0) {
                    onAddOrder(ClientOrder(
                      billNo: 'B-${DateTime.now().millisecondsSinceEpoch % 10000}',
                      clientName: nameCtrl.text,
                      city: cityCtrl.text,
                      itemsSummary: itemsCtrl.text,
                      totalBill: total,
                      amountPaid: paid,
                      date: DateTime.now(),
                    ));
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Save Bill'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReceivePaymentDialog(BuildContext context, ClientOrder order) {
    final payCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Payment - ${order.clientName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pending Due: ₹${order.balanceDue.toStringAsFixed(0)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: payCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount Received (₹)', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amt = double.tryParse(payCtrl.text) ?? 0.0;
              if (amt > 0) {
                onAddPayment(order, amt);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Record Payment'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalMarketDue = orders.fold(0.0, (sum, o) => sum + o.balanceDue);

    return Scaffold(
      appBar: AppBar(title: const Text('Wholesale Khata & Payments')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Bill'),
        onPressed: () => _showNewBillSheet(context),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.red.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Market Pending:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                Text('₹${totalMarketDue.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: orders.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final o = orders[i];
                final isPending = o.balanceDue > 0;

                return ListTile(
                  title: Text(o.clientName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '${o.city} • ${o.itemsSummary}\nTotal: ₹${o.totalBill.toStringAsFixed(0)} | Paid: ₹${o.amountPaid.toStringAsFixed(0)}',
                  ),
                  isThreeLine: true,
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        isPending ? 'Due: ₹${o.balanceDue.toStringAsFixed(0)}' : 'Settled',
                        style: TextStyle(color: isPending ? Colors.red : Colors.green, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isPending)
                            InkWell(
                              onTap: () => _showReceivePaymentDialog(context, o),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                child: Text('+ Pay', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ),
                          IconButton(
                            icon: const Icon(Icons.share, color: Colors.green, size: 20),
                            onPressed: () => _sendCleanWhatsAppBill(o),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
