import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';

class DocumentViewerPage extends StatefulWidget {
  final String title;
  final String assetPath;

  const DocumentViewerPage({
    super.key,
    required this.title,
    required this.assetPath,
  });

  @override
  State<DocumentViewerPage> createState() => _DocumentViewerPageState();
}

class _DocumentViewerPageState extends State<DocumentViewerPage> {
  String _content = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final text = await rootBundle.loadString(widget.assetPath);
      if (mounted) {
        setState(() {
          _content = text;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'No se pudo cargar el documento.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _error != null
          ? Center(child: Text(_error!))
          : _content.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Markdown(
                  data: _content,
                  padding: const EdgeInsets.all(16),
                ),
    );
  }
}

