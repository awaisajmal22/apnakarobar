import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sales_management/db/database_helper.dart';
import 'package:sales_management/models/inventory_model.dart';
import 'package:sales_management/models/item_model.dart';
import 'package:sales_management/models/sales_model.dart';

class InventoryProvider extends ChangeNotifier {
  ScrollController scrollController = ScrollController();
  void scrollToEnd() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.easeOut,
    );
  }

  TextEditingController search = TextEditingController();
  List<InventoryItem> _filterList = [];
  List<InventoryItem> get filterList => _filterList;
  searchInventoryByTitle(
      List<InventoryModel> inventoryList, String searchQuery) {
    _filterList.clear();
    filterList.clear();
    for (var inventoryData in inventoryList) {
      for (var item in inventoryData.data) {
        if (item.title!.toLowerCase().contains(searchQuery.toLowerCase())) {
          _filterList.add(item);
        }
      }
      notifyListeners();
    }
  }

  clearFilter() {
    _filterList.clear();
    filterList.clear();
    notifyListeners();
  }

  List<InventoryModel> _inventoryList = <InventoryModel>[];
  List<InventoryModel> get inventoryList => _inventoryList;
  List<InventoryItem> _products = [];
  List<InventoryItem> get products => _products;
  bool _loading = false;
  bool get loading => _loading;
  getInventoryData() async {
    _inventoryList.clear();
    inventoryList.clear();
    _products.clear();

    List<Map<String, dynamic>> inv = await DatabaseHelper.getInventory();
    final List<Map<String, dynamic>> combinedData = inv
        .expand((entry) => entry['data'])
        .cast<Map<String, dynamic>>()
        .toList();
    for (var p in combinedData) {
      _products.add(InventoryItem.fromJson(p));
    }
    List<InventoryModel> data =
        inv.map((e) => InventoryModel.fromJson(e)).toList();
    print(inv);
    for (var v in data) {
      bool isExist = _inventoryList.any((e) => e.addingDate == v.addingDate);
      if (!isExist) {
        _inventoryList.add(v);
      }
    }

    // Add items from tempList to _inventoryList

    notifyListeners();
  }

  String _selectedType = "Paid";
  String get selectedType => _selectedType;
  changeType(String val) {
    _selectedType = val;
    notifyListeners();
  }

  List<String> daysType = ['All days', 'Daily', 'Weekly', 'Monthly', 'Overall'];
  String _selectedDay = 'All days';
  String get selectedDay => _selectedDay;
  changeDay(String val) {
    _selectedDay = val;
    notifyListeners();
  }

  int _selectedYear = DateTime.now().year;

  int get selectedYear => _selectedYear;
  decrementYear() {
    if (_selectedYear <= 1998) {
    } else {
      _selectedYear--;
      notifyListeners();
    }
  }

  incrementYear() {
    if (_selectedYear == DateTime.now().year) {
    } else {
      _selectedYear++;
      notifyListeners();
    }
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  changeLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  String getTotalProducts(List<InventoryItem> item,String quantity, String name) {
    print('Length ${item.length}');
    int totalProducts = 0;
    List<InventoryItem> d = item.where((e) => e.title == name).toList();
    for (var x in d) {
      print("object ${x.quantity}");
      totalProducts += int.parse(x.quantity);
    }
    return (totalProducts + int.parse(quantity)).toString();
  }
  String getSoldProducts(List<InventoryItem> item, String name) {
    print('Length ${item.length}');
    int totalProducts = 0;
    List<InventoryItem> d = item.where((e) => e.title == name).toList();
    for (var x in d) {
      print("object ${x.quantity}");
      totalProducts += int.parse(x.quantity);
    }
    return totalProducts .toString();
  }
}