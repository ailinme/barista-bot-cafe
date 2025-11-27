import 'dart:convert';

import 'package:http/http.dart' as http;

/// Simple API client to fetch waveform seed values from a public API.
class ProgressApi {
  ProgressApi._internal();
  static final ProgressApi instance = ProgressApi._internal();

  /// Fetches a list of doubles normalized 0..1 to drive the line animation.
  Future<List<double>> fetchWave() async {
    try {
      final uri = Uri.parse('https://api.sampleapis.com/coffee/hot');
      final resp = await http.get(uri).timeout(const Duration(seconds: 6));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data is List) {
          final values = data.take(12).map((e) {
            final id = _toInt((e as Map?)?['id']);
            return ((id % 10) + 2) / 12.0; // small amplitude factor
          }).toList();
          if (values.isNotEmpty) return values;
        }
      }
    } catch (_) {
      // Fallback below
    }
    return const [0.3, 0.6, 0.45, 0.75, 0.4, 0.7, 0.5, 0.65];
  }

  int _toInt(dynamic v) => v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0;
}
