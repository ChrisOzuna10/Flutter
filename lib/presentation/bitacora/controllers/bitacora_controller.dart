import 'package:flutter/foundation.dart';

class BitacoraController extends ChangeNotifier {
  List<String> _entries = [];
  bool _isLoading = false;

  List<String> get entries => List.unmodifiable(_entries);
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 250));
    _entries = List.generate(8, (i) => 'Bitácora ${i + 1} - Entrada de ejemplo');
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => load();

  void updateEntry(int index, String newValue) {
    if (index < 0 || index >= _entries.length) return;
    _entries[index] = newValue;
    notifyListeners();
  }
}
