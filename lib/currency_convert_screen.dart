import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final _amountController = TextEditingController();
  final List<String> _currencies = [
    'USD', // US Dollar
    'EUR', // Euro
    'GBP', // British Pound
    'JPY', // Japanese Yen
    'INR', // Indian Rupee
    'PKR', // Pakistani Rupee
    'AUD', // Australian Dollar
    'CAD', // Canadian Dollar
    'CHF', // Swiss Franc
    'CNY', // Chinese Yuan
    'HKD', // Hong Kong Dollar
    'NZD', // New Zealand Dollar
    'SGD', // Singapore Dollar
    'ZAR', // South African Rand
    'AED', // UAE Dirham
    'SAR', // Saudi Riyal
    'MYR', // Malaysian Ringgit
    'THB', // Thai Baht
    'NOK', // Norwegian Krone
    'SEK', // Swedish Krona
    'DKK', // Danish Krone
    'KRW', // South Korean Won
    'BRL', // Brazilian Real
    'MXN', // Mexican Peso
    'IDR', // Indonesian Rupiah
    'TRY', // Turkish Lira
    'RUB', // Russian Ruble
    'EGP', // Egyptian Pound
    'VND', // Vietnamese Dong
  ];

  String _fromCurrency = 'USD';
  String _toCurrency = 'EUR';
  String? _result;
  bool _isLoading = false;
  String? _error;
  List<String> _history = [];
  List<String> _favorites = [];

  @override
  void initState() {
    super.initState();
    _currencies.sort();
    _loadHistoryAndFavorites();
  }

  Future<void> _loadHistoryAndFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _history = prefs.getStringList('history') ?? [];
      _favorites = prefs.getStringList('favorites') ?? [];
    });
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('history', _history);
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favorites);
  }

  Future<void> _convertCurrency() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final amount = double.tryParse(_amountController.text);
    if (amount == null) {
      setState(() {
        _error = "Invalid amount entered.";
        _isLoading = false;
      });
      return;
    }

    final url = 'https://api.exchangerate-api.com/v4/latest/$_fromCurrency';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rate = data['rates'][_toCurrency];
        final converted = (rate * amount).toStringAsFixed(2);
        setState(() {
          _result = '$amount $_fromCurrency = $converted $_toCurrency';
          _history.insert(0, _result!);
          _isLoading = false;
        });
        _saveHistory();
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _toggleFavorite() {
    final pair = '$_fromCurrency > $_toCurrency';
    setState(() {
      if (_favorites.contains(pair)) {
        _favorites.remove(pair);
      } else {
        _favorites.add(pair);
      }
    });
    _saveFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final isFavorite = _favorites.contains('$_fromCurrency > $_toCurrency');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.star : Icons.star_border),
            onPressed: _toggleFavorite,
            tooltip: isFavorite ? 'Remove Favorite' : 'Add to Favorites',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Enter amount'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _buildDropdown(_fromCurrency,
                        (val) => setState(() => _fromCurrency = val ?? ''))),
                const SizedBox(width: 16),
                const Icon(Icons.swap_horiz),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildDropdown(_toCurrency,
                        (val) => setState(() => _toCurrency = val ?? ''))),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _convertCurrency,
              child: const Text('Convert'),
            ),
            if (_isLoading) ...[
              const SizedBox(height: 20),
              const Center(child: CircularProgressIndicator()),
            ],
            if (_error != null) ...[
              const SizedBox(height: 20),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            if (_result != null) ...[
              const SizedBox(height: 20),
              Text(_result!,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ],
            const SizedBox(height: 30),
            const Text('Favorites:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ..._favorites.map((f) => ListTile(title: Text(f))),
            const Divider(),
            const Text('Conversion History:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ..._history.map((h) => ListTile(title: Text(h))),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String currentValue, ValueChanged<String?>? onChanged) {
    return DropdownButton<String>(
      value: currentValue,
      isExpanded: true,
      onChanged: onChanged,
      items: _currencies.map((currency) {
        return DropdownMenuItem(
          value: currency,
          child: Text(currency),
        );
      }).toList(),
    );
  }
}
