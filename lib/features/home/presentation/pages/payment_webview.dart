import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentResult {
  final bool approved;
  final String? paymentId;
  const PaymentResult({required this.approved, this.paymentId});
}

class PaymentWebView extends StatefulWidget {
  final String checkoutUrl;
  const PaymentWebView({super.key, required this.checkoutUrl});

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop(const PaymentResult(approved: false));
      });
      return;
    }
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: _handleNav,
          onPageFinished: (_) => setState(() => _loading = false),
          onNavigationRequest: _handleRequest,
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  NavigationDecision _handleRequest(NavigationRequest req) {
    _handleNav(req.url);
    return NavigationDecision.navigate;
  }

  void _handleNav(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final status = uri.queryParameters['status'] ?? uri.queryParameters['collection_status'];
    final paymentId = uri.queryParameters['payment_id'];
    if (status == 'approved') {
      Navigator.of(context).pop(PaymentResult(approved: true, paymentId: paymentId));
    } else if (status == 'rejected' || status == 'failed' || status == 'cancelled' || status == 'canceled') {
      Navigator.of(context).pop(const PaymentResult(approved: false));
    } else if (uri.host.contains('example.com') && status != null) {
      Navigator.of(context).pop(PaymentResult(approved: status == 'approved', paymentId: paymentId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagar con Mercado Pago'),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const LinearProgressIndicator(minHeight: 2),
        ],
      ),
    );
  }
}

