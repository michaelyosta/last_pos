import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pos_app/models/category.dart'; // Assuming Category model exists
import 'package:pos_app/core/constants.dart'; // Import constants
// import 'package:intl/intl.dart'; // Optional: for advanced date formatting

class AdminViewManagerReportScreen extends StatefulWidget {
  static const String routeName = '/admin/view-manager-report';
  final String managerId;
  final String managerName;
  final FirebaseFirestore? firestoreInstanceForTest;

  const AdminViewManagerReportScreen({
    super.key,
    required this.managerId,
    required this.managerName,
    this.firestoreInstanceForTest,
  });

  @override
  State<AdminViewManagerReportScreen> createState() => _AdminViewManagerReportScreenState();
}

class _AdminViewManagerReportScreenState extends State<AdminViewManagerReportScreen> {
  late FirebaseFirestore _firestore;
  DateTime? _startDate;
  DateTime? _endDate;
  Map<String, dynamic>? _reportData;
  bool _isLoading = false;
  List<Category> _allCategories = [];
  Map<String, String> _categoryNames = {};
  bool _categoriesLoaded = false;
  String? _categoryLoadingError;

  @override
  void initState() {
    super.initState();
    _firestore = widget.firestoreInstanceForTest ?? FirebaseFirestore.instance;
    _loadCategoriesIfNeeded(); // Load categories on init
  }

  Future<void> _loadCategoriesIfNeeded() async {
    if (_categoriesLoaded) return;

    try {
      final snapshot = await _firestore.collection(FirestoreCollections.categories).get(); // Use constant
      _allCategories = snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
      _categoryNames = {for (var cat in _allCategories) cat.id: cat.displayName};
      setState(() {
        _categoriesLoaded = true;
        _categoryLoadingError = null;
      });
    } catch (e) {
      // print("Error loading categories: $e");
      setState(() {
        _categoryLoadingError = "Ошибка загрузки категорий: ${e.toString()}";
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_categoryLoadingError!)),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(), // More logical initial date
      currentDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      helpText: isStartDate ? 'Выберите начальную дату' : 'Выберите конечную дату',
      confirmText: 'Выбрать',
      cancelText: 'Отмена',
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Ensure end date is not before start date
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          // Ensure start date is not after end date
          if (_startDate != null && _startDate!.isAfter(_endDate!)) {
            _startDate = _endDate;
          }
        }
        _reportData = null; // Reset report data when dates change
      });
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> _fetchVehicleDataForReport(DateTime startDate, DateTime adjustedEndDate) async {
    return _firestore
        .collection(FirestoreCollections.vehicles)
        .where('managerId', isEqualTo: widget.managerId)
        .where('status', isEqualTo: VehicleStatuses.completed)
        .where('orderCompletionTimestamp', isGreaterThanOrEqualTo: startDate)
        .where('orderCompletionTimestamp', isLessThanOrEqualTo: adjustedEndDate)
        .get();
  }

  Map<String, dynamic> _processReportData(QuerySnapshot<Map<String, dynamic>> vehicleSnapshot) {
    if (vehicleSnapshot.docs.isEmpty) {
      return {'isEmpty': true};
    }

    double totalSalesAmount = 0;
    int numberOfOrders = vehicleSnapshot.docs.length;
    Map<String, Map<String, dynamic>> productAggregates = {};
    double totalTimeBasedRevenue = 0;
    Map<String, double> revenueByCategory = {};

    for (var doc in vehicleSnapshot.docs) {
      Map<String, dynamic> vehicleData = doc.data() as Map<String, dynamic>;
      totalSalesAmount += (vehicleData['totalAmount'] ?? 0.0).toDouble();
      totalTimeBasedRevenue += (vehicleData['timeBasedCost'] ?? 0.0).toDouble();

      List<dynamic> items = vehicleData['items'] ?? [];
      for (var item in items) {
        String productName = item['productName'] ?? 'Неизвестный товар';
        String categoryId = item['categoryId'] ?? 'unknown_category';
        int quantity = (item['quantity'] ?? 0).toInt();
        double price = (item['price'] ?? 0.0).toDouble();
        double revenueForItem = quantity * price;

        if (productAggregates.containsKey(productName)) {
          productAggregates[productName]!['totalQuantitySold'] += quantity;
          productAggregates[productName]!['totalRevenueFromProduct'] += revenueForItem;
        } else {
          productAggregates[productName] = {
            'productName': productName,
            'totalQuantitySold': quantity,
            'totalRevenueFromProduct': revenueForItem,
          };
        }
        revenueByCategory[categoryId] = (revenueByCategory[categoryId] ?? 0) + revenueForItem;
      }
    }

    List<Map<String, dynamic>> detailedBreakdown = productAggregates.values.toList();

    return {
      'totalSalesAmount': totalSalesAmount,
      'numberOfOrders': numberOfOrders,
      'detailedBreakdown': detailedBreakdown,
      'timeBasedRevenue': totalTimeBasedRevenue,
      'categoryRevenueBreakdown': revenueByCategory,
      'isEmpty': false,
    };
  }

  Future<void> _generateReport() async {
    if (_startDate == null || _endDate == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пожалуйста, выберите начальную и конечную даты.')),
        );
      }
      return;
    }

    if (!_categoriesLoaded && _categoryLoadingError == null) {
      await _loadCategoriesIfNeeded();
      if (!_categoriesLoaded) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_categoryLoadingError ?? 'Категории не загружены. Попробуйте еще раз.')),
          );
        }
        return;
      }
    } else if (_categoryLoadingError != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_categoryLoadingError!)),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _reportData = null;
    });

    try {
      DateTime adjustedEndDate = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
      final vehicleSnapshot = await _fetchVehicleDataForReport(_startDate!, adjustedEndDate);
      final processedData = _processReportData(vehicleSnapshot);
      
      setState(() {
        _reportData = processedData;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
        _reportData = {'error': true, 'message': e.toString()};
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при формировании отчета: ${e.toString()}')),
        );
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Не выбрано";
    // return DateFormat('yyyy-MM-dd').format(date); // Using intl package
    return date.toString().substring(0, 10); // Basic formatting
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Отчет: ${widget.managerName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _selectDate(context, true),
                  child: const Text('Начальная дата'),
                ),
                Text(_formatDate(_startDate)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _selectDate(context, false),
                  child: const Text('Конечная дата'),
                ),
                Text(_formatDate(_endDate)),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: (_startDate != null && _endDate != null && !_isLoading) ? _generateReport : null,
              child: const Text('Сформировать отчет'),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_reportData != null)
              _buildReportDisplay()
            else
              const Center(child: Text('Выберите период и сформируйте отчет.'))
          ],
        ),
      ),
    );
  }

  Widget _buildReportDisplay() {
    if (_reportData == null || _reportData!.isEmpty && !_reportData!.containsKey('isEmpty')) {
       return const Center(child: Text('Выберите период и сформируйте отчет.'));
    }
    if (_reportData!['error'] == true) {
      return Center(child: Text('Ошибка: ${_reportData!['message']}'));
    }
    if (_reportData!['isEmpty'] == true) {
      return const Center(child: Text('Нет данных за выбранный период.'));
    }

    List<Map<String, dynamic>> breakdown = 
        List<Map<String, dynamic>>.from(_reportData!['detailedBreakdown'] ?? []);

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Период: ${_formatDate(_startDate)} - ${_formatDate(_endDate)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Общая сумма продаж: ${_reportData!['totalSalesAmount']?.toStringAsFixed(2) ?? '0.00'} тнг',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Количество заказов: ${_reportData!['numberOfOrders'] ?? 0}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Детализация по товарам:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (breakdown.isEmpty)
              const Text('Нет данных по товарам.')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // To disable ListView's own scrolling
                itemCount: breakdown.length,
                itemBuilder: (context, index) {
                  final item = breakdown[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['productName'] ?? 'Неизвестный товар',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text('Количество: ${item['totalQuantitySold'] ?? 0}'),
                          Text('Сумма: ${item['totalRevenueFromProduct']?.toStringAsFixed(2) ?? '0.00'} тнг'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 24),
            Text(
              'Разбивка выручки:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            _buildPieChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    if (_reportData == null || 
        _reportData!['timeBasedRevenue'] == null || 
        _reportData!['categoryRevenueBreakdown'] == null) {
      return const Center(child: Text('Нет данных для диаграммы.'));
    }
    if (!_categoriesLoaded && _categoryLoadingError == null) {
      return const Center(child: Text('Загрузка данных категорий...'));
    }
     if (_categoryLoadingError != null) {
      return Center(child: Text('Ошибка загрузки категорий для диаграммы.'));
    }

    final List<PieChartSectionData> sections = [];
    final double timeBasedRevenue = _reportData!['timeBasedRevenue'] as double;
    final Map<String, double> categoryRevenue = _reportData!['categoryRevenueBreakdown'] as Map<String, double>;

    final List<Color> pieColors = [
      Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red,
      Colors.teal, Colors.pink, Colors.amber, Colors.cyan, Colors.lime,
      Colors.indigo, Colors.brown,
    ];
    int colorIndex = 0;

    if (timeBasedRevenue > 0) {
      sections.add(PieChartSectionData(
        color: pieColors[colorIndex % pieColors.length],
        value: timeBasedRevenue,
        title: 'Время\n${timeBasedRevenue.toStringAsFixed(0)}',
        radius: 80,
        titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 2)]),
      ));
      colorIndex++;
    }

    categoryRevenue.forEach((categoryId, revenue) {
      if (revenue > 0) {
        final categoryName = _categoryNames[categoryId] ?? 'Неизв. категория';
        sections.add(PieChartSectionData(
          color: pieColors[colorIndex % pieColors.length],
          value: revenue,
          title: '$categoryName\n${revenue.toStringAsFixed(0)}',
          radius: 80,
          titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 2)]),
        ));
        colorIndex++;
      }
    });
    
    if (sections.isEmpty) {
      return const Center(child: Text('Нет данных для отображения в диаграмме.'));
    }

    return SizedBox(
      height: 300,
      child: PieChart(
        PieChartData(
          sections: sections,
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              // Optional: Handle touch events
            },
          ),
        ),
      ),
    );
  }
}
